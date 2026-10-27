import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/steam_game.dart';

class SteamApiException implements Exception {
  const SteamApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get unauthorized => statusCode == 401 || statusCode == 403;

  @override
  String toString() => message;
}

/// Steam Web API + public store endpoints. Store responses are cached on
/// disk so the hub works offline and stays under the (undocumented)
/// appdetails rate limit of roughly 200 requests per 5 minutes.
class SteamApi {
  SteamApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  Directory? _cacheDir;

  static const _detailsTtl = Duration(days: 7);
  static const _featuredTtl = Duration(hours: 6);

  /// Portrait poster first, then landscape fallbacks.
  static List<String> posterUrls(int appId, {String? headerImage}) => [
    'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/library_600x900_2x.jpg',
    'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/library_600x900.jpg',
    ?headerImage,
    'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/header.jpg',
  ];

  static List<String> heroUrls(int appId, {String? headerImage}) => [
    'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/library_hero.jpg',
    ?headerImage,
    'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/header.jpg',
  ];

  static String logoUrl(int appId) => 'https://cdn.cloudflare.steamstatic.com/steam/apps/$appId/logo.png';

  Future<Directory> get cacheDir async {
    if (_cacheDir != null) return _cacheDir!;
    final support = await getApplicationSupportDirectory();
    return _cacheDir = await Directory('${support.path}/cache').create(recursive: true);
  }

  // Serialises appdetails requests: a handful in flight, backing off on 429.
  final _queue = <Completer<void>>[];
  int _inFlight = 0;
  static const _maxInFlight = 3;
  DateTime _pausedUntil = DateTime.fromMillisecondsSinceEpoch(0);

  Future<T> _throttled<T>(Future<T> Function() run) async {
    if (_inFlight >= _maxInFlight) {
      final slot = Completer<void>();
      _queue.add(slot);
      await slot.future;
    }
    _inFlight++;
    try {
      final wait = _pausedUntil.difference(DateTime.now());
      if (!wait.isNegative) await Future<void>.delayed(wait);
      return await run();
    } finally {
      _inFlight--;
      if (_queue.isNotEmpty) _queue.removeAt(0).complete();
    }
  }

  /// Store metadata, from disk cache when fresh. Null if Steam has no
  /// store page for the app (e.g. delisted or a tool).
  Future<GameDetails?> appDetails(int appId, {String language = 'english'}) async {
    final file = File('${(await cacheDir).path}/appdetails/${appId}_$language.json');
    final cached = await _readCache(file, _detailsTtl);
    if (cached != null) return _parseDetails(appId, cached);

    return _throttled(() async {
      final uri = Uri.https('store.steampowered.com', '/api/appdetails', {'appids': '$appId', 'l': language});
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 429) {
        _pausedUntil = DateTime.now().add(const Duration(minutes: 1));
        // Serve stale cache rather than nothing while rate limited.
        final stale = await _readCache(file, null);
        if (stale != null) return _parseDetails(appId, stale);
        throw const SteamApiException('Steam store rate limit', statusCode: 429);
      }
      if (response.statusCode != 200) {
        throw SteamApiException('appdetails HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
      await _writeCache(file, response.body);
      return _parseDetails(appId, response.body);
    });
  }

  static GameDetails? _parseDetails(int appId, String body) {
    final root = jsonDecode(body) as Map<String, dynamic>;
    final entry = root['$appId'] as Map<String, dynamic>?;
    if (entry == null || entry['success'] != true) return null;
    return GameDetails.fromJson(appId, entry['data'] as Map<String, dynamic>);
  }

  /// Top sellers and new releases, for discovery when the library is small.
  Future<List<FeaturedGame>> featured({String language = 'english'}) async {
    final file = File('${(await cacheDir).path}/featured_$language.json');
    var body = await _readCache(file, _featuredTtl);
    if (body == null) {
      final uri = Uri.https('store.steampowered.com', '/api/featuredcategories', {'l': language});
      final response = await _client.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        body = await _readCache(file, null);
        if (body == null) throw SteamApiException('featured HTTP ${response.statusCode}');
      } else {
        body = response.body;
        await _writeCache(file, body);
      }
    }
    final root = jsonDecode(body) as Map<String, dynamic>;
    final seen = <int>{};
    final games = <FeaturedGame>[];
    for (final section in ['top_sellers', 'new_releases', 'specials']) {
      for (final item in ((root[section] as Map?)?['items'] as List? ?? const [])) {
        final map = item as Map;
        // type 0 = game; skip DLC, bundles and subscriptions.
        if (map['type'] != 0 || !seen.add(map['id'] as int)) continue;
        games.add(
          FeaturedGame(
            appId: map['id'] as int,
            name: map['name'] as String? ?? '',
            mac: map['mac_available'] == true,
            discountPercent: (map['discount_percent'] as num?)?.toInt() ?? 0,
          ),
        );
      }
    }
    return games;
  }

  /// Every game on the account with playtime. Empty for private profiles.
  Future<List<SteamGame>> ownedGames({required String apiKey, required String steamId}) async {
    final uri = Uri.https('api.steampowered.com', '/IPlayerService/GetOwnedGames/v1/', {
      'key': apiKey,
      'steamid': steamId,
      'include_appinfo': '1',
      'include_played_free_games': '1',
      'format': 'json',
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw SteamApiException('GetOwnedGames HTTP ${response.statusCode}', statusCode: response.statusCode);
    }
    final games = ((jsonDecode(response.body) as Map)['response'] as Map?)?['games'] as List? ?? const [];
    return [
      for (final g in games.cast<Map>())
        SteamGame(
          appId: g['appid'] as int,
          name: g['name'] as String? ?? 'App ${g['appid']}',
          playtimeMinutes: (g['playtime_forever'] as num?)?.toInt(),
          playtime2WeeksMinutes: (g['playtime_2weeks'] as num?)?.toInt(),
          lastPlayed: switch ((g['rtime_last_played'] as num?)?.toInt()) {
            final t? when t > 0 => DateTime.fromMillisecondsSinceEpoch(t * 1000),
            _ => null,
          },
        ),
    ];
  }

  /// Display name for the account, to confirm the link worked.
  Future<String?> personaName({required String apiKey, required String steamId}) async {
    final uri = Uri.https('api.steampowered.com', '/ISteamUser/GetPlayerSummaries/v2/', {
      'key': apiKey,
      'steamids': steamId,
    });
    final response = await _client.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw SteamApiException('GetPlayerSummaries HTTP ${response.statusCode}', statusCode: response.statusCode);
    }
    final players = ((jsonDecode(response.body) as Map)['response'] as Map?)?['players'] as List? ?? const [];
    return players.isEmpty ? null : (players.first as Map)['personaname'] as String?;
  }

  /// Downloads the first URL that exists into the disk cache. Missing
  /// artwork (404) is remembered so it isn't requested again.
  Future<File?> cachedImage(List<String> urls) async {
    final dir = await Directory('${(await cacheDir).path}/images').create(recursive: true);
    for (final url in urls) {
      final name = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
      final file = File('${dir.path}/${name.length > 120 ? name.substring(name.length - 120) : name}');
      final missing = File('${file.path}.404');
      if (await file.exists()) return file;
      if (await missing.exists()) continue;
      try {
        final response = await _client.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
        if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
          await file.writeAsBytes(response.bodyBytes);
          return file;
        }
        if (response.statusCode == 404) await missing.writeAsString('');
      } on Exception {
        // Network error: try the next URL, don't remember anything.
      }
    }
    return null;
  }

  Future<String?> _readCache(File file, Duration? ttl) async {
    if (!await file.exists()) return null;
    if (ttl != null && DateTime.now().difference(await file.lastModified()) > ttl) return null;
    return file.readAsString();
  }

  Future<void> _writeCache(File file, String body) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(body);
  }
}
