/// A game in the hub, merged from the local Steam install and (optionally)
/// the user's Steam account.
class SteamGame {
  const SteamGame({
    required this.appId,
    required this.name,
    this.installDir,
    this.libraryPath,
    this.sizeOnDisk,
    this.lastPlayed,
    this.playtimeMinutes,
    this.playtime2WeeksMinutes,
  });

  final int appId;
  final String name;

  /// Folder under `steamapps/common/` when installed.
  final String? installDir;
  final String? libraryPath;
  final int? sizeOnDisk;
  final DateTime? lastPlayed;
  final int? playtimeMinutes;
  final int? playtime2WeeksMinutes;

  bool get installed => installDir != null;

  /// Absolute install folder, used to recognise the game's process.
  String? get installPath => installed ? '$libraryPath/steamapps/common/$installDir' : null;

  String get storeUrl => 'https://store.steampowered.com/app/$appId';

  String get runUrl => 'steam://run/$appId';

  /// Fills gaps in this (local) record with account data.
  SteamGame mergeAccount(SteamGame account) => SteamGame(
    appId: appId,
    name: name.isNotEmpty ? name : account.name,
    installDir: installDir,
    libraryPath: libraryPath,
    sizeOnDisk: sizeOnDisk,
    lastPlayed: _latest(lastPlayed, account.lastPlayed),
    playtimeMinutes: account.playtimeMinutes ?? playtimeMinutes,
    playtime2WeeksMinutes: account.playtime2WeeksMinutes ?? playtime2WeeksMinutes,
  );

  static DateTime? _latest(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }
}

enum ControllerSupport { full, partial, none }

/// Store metadata from `store.steampowered.com/api/appdetails`.
class GameDetails {
  const GameDetails({
    required this.appId,
    required this.name,
    required this.type,
    this.shortDescription = '',
    this.genres = const [],
    this.categories = const [],
    this.mac = false,
    this.windows = false,
    this.linux = false,
    this.controllerSupport = ControllerSupport.none,
    this.metacritic,
    this.releaseDate,
    this.headerImage,
    this.screenshots = const [],
    this.developers = const [],
  });

  factory GameDetails.fromJson(int appId, Map<String, dynamic> data) {
    final platforms = (data['platforms'] as Map?) ?? const {};
    return GameDetails(
      appId: appId,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'game',
      shortDescription: _stripHtml(data['short_description'] as String? ?? ''),
      genres: [for (final g in (data['genres'] as List? ?? const [])) (g as Map)['description'] as String],
      categories: [for (final c in (data['categories'] as List? ?? const [])) (c as Map)['description'] as String],
      mac: platforms['mac'] == true,
      windows: platforms['windows'] == true,
      linux: platforms['linux'] == true,
      controllerSupport: switch (data['controller_support']) {
        'full' => ControllerSupport.full,
        'partial' => ControllerSupport.partial,
        _ => ControllerSupport.none,
      },
      metacritic: ((data['metacritic'] as Map?)?['score'] as num?)?.toInt(),
      releaseDate: (data['release_date'] as Map?)?['date'] as String?,
      headerImage: data['header_image'] as String?,
      screenshots: [
        for (final s in (data['screenshots'] as List? ?? const []).take(8)) (s as Map)['path_thumbnail'] as String,
      ],
      developers: [for (final d in (data['developers'] as List? ?? const [])) d as String],
    );
  }

  final int appId;
  final String name;
  final String type;
  final String shortDescription;
  final List<String> genres;
  final List<String> categories;
  final bool mac;
  final bool windows;
  final bool linux;
  final ControllerSupport controllerSupport;
  final int? metacritic;
  final String? releaseDate;
  final String? headerImage;
  final List<String> screenshots;
  final List<String> developers;

  bool get windowsOnly => windows && !mac;

  static String _stripHtml(String s) =>
      s.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&quot;', '"').replaceAll('&amp;', '&').replaceAll('&#39;', "'");
}

/// What the user customised for one game.
class GameSettings {
  const GameSettings({
    required this.appId,
    this.profileId,
    this.autoSwitch = true,
    this.padpilotOff = false,
    this.hidden = false,
    this.pinned = false,
  });

  factory GameSettings.fromJson(Map<String, dynamic> json) => GameSettings(
    appId: json['appId'] as int,
    profileId: json['profileId'] as String?,
    autoSwitch: json['autoSwitch'] as bool? ?? true,
    padpilotOff: json['padpilotOff'] as bool? ?? false,
    hidden: json['hidden'] as bool? ?? false,
    pinned: json['pinned'] as bool? ?? false,
  );

  final int appId;

  /// Profile to use while this game is in front.
  final String? profileId;

  /// Switch to [profileId] automatically when the game comes to the front.
  final bool autoSwitch;

  /// Pause mapping while the game is in front (e.g. native controller support).
  final bool padpilotOff;
  final bool hidden;
  final bool pinned;

  Map<String, dynamic> toJson() => {
    'appId': appId,
    'profileId': profileId,
    'autoSwitch': autoSwitch,
    'padpilotOff': padpilotOff,
    'hidden': hidden,
    'pinned': pinned,
  };

  GameSettings copyWith({
    String? Function()? profileId,
    bool? autoSwitch,
    bool? padpilotOff,
    bool? hidden,
    bool? pinned,
  }) => GameSettings(
    appId: appId,
    profileId: profileId != null ? profileId() : this.profileId,
    autoSwitch: autoSwitch ?? this.autoSwitch,
    padpilotOff: padpilotOff ?? this.padpilotOff,
    hidden: hidden ?? this.hidden,
    pinned: pinned ?? this.pinned,
  );
}

/// A store listing shown for discovery (not owned).
class FeaturedGame {
  const FeaturedGame({required this.appId, required this.name, required this.mac, this.discountPercent = 0});

  final int appId;
  final String name;
  final bool mac;
  final int discountPercent;
}
