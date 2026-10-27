import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/platform/joystick_events.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../profiles/profiles_provider.dart';
import '../settings/settings_provider.dart';
import 'data/steam_api.dart';
import 'data/steam_library.dart';
import 'models/steam_game.dart';

final steamApiProvider = Provider((ref) => SteamApi());

final steamLibraryProvider = Provider((ref) => SteamLibrary());

final installedGamesProvider = FutureProvider((ref) => ref.watch(steamLibraryProvider).installedGames());

/// Steam store language for the app's current language.
final steamLanguageProvider = Provider((ref) {
  final code = resolveLocale(ref.watch(settingsProvider).value?.localeCode).languageCode;
  return switch (code) {
    'pt' => 'brazilian',
    'es' => 'spanish',
    _ => 'english',
  };
});

// MARK: Account

class SteamAccount {
  const SteamAccount({required this.apiKey, required this.steamId, this.personaName});

  final String apiKey;
  final String steamId;
  final String? personaName;
}

/// Optional Steam Web API link. The key lives in the macOS Keychain.
class SteamAccountNotifier extends AsyncNotifier<SteamAccount?> {
  static const _keyAccount = 'steamApiKey';
  static const _idAccount = 'steamId64';

  @override
  Future<SteamAccount?> build() async {
    final channel = ref.read(joystickChannelProvider);
    final key = await channel.getSecret(_keyAccount);
    final id = await channel.getSecret(_idAccount);
    if (key == null || id == null) return null;
    return SteamAccount(apiKey: key, steamId: id);
  }

  /// Validates against Steam before saving; throws [SteamApiException].
  Future<SteamAccount> link({required String apiKey, required String steamId}) async {
    final persona = await ref.read(steamApiProvider).personaName(apiKey: apiKey, steamId: steamId);
    if (persona == null) throw const SteamApiException('SteamID not found');
    final channel = ref.read(joystickChannelProvider);
    await channel.setSecret(_keyAccount, apiKey);
    await channel.setSecret(_idAccount, steamId);
    final account = SteamAccount(apiKey: apiKey, steamId: steamId, personaName: persona);
    state = AsyncData(account);
    return account;
  }

  Future<void> unlink() async {
    final channel = ref.read(joystickChannelProvider);
    await channel.setSecret(_keyAccount, null);
    await channel.setSecret(_idAccount, null);
    state = const AsyncData(null);
  }
}

final steamAccountProvider = AsyncNotifierProvider<SteamAccountNotifier, SteamAccount?>(SteamAccountNotifier.new);

final ownedGamesProvider = FutureProvider<List<SteamGame>>((ref) async {
  final account = await ref.watch(steamAccountProvider.future);
  if (account == null) return const [];
  return ref.watch(steamApiProvider).ownedGames(apiKey: account.apiKey, steamId: account.steamId);
});

/// Installed games merged with the account's owned games (no duplicates).
final libraryProvider = FutureProvider<List<SteamGame>>((ref) async {
  final installed = await ref.watch(installedGamesProvider.future);
  // Account errors (bad key, offline) must not hide the local library.
  final owned = await ref.watch(ownedGamesProvider.future).catchError((_) => <SteamGame>[]);
  final byId = {for (final g in installed) g.appId: g};
  for (final g in owned) {
    byId[g.appId] = byId[g.appId]?.mergeAccount(g) ?? g;
  }
  return byId.values.toList();
});

final gameDetailsProvider = FutureProvider.family<GameDetails?, int>((ref, appId) {
  final language = ref.watch(steamLanguageProvider);
  return ref.watch(steamApiProvider).appDetails(appId, language: language);
});

final featuredGamesProvider = FutureProvider<List<FeaturedGame>>((ref) {
  return ref.watch(steamApiProvider).featured(language: ref.watch(steamLanguageProvider));
});

// MARK: Per-game settings

class GameSettingsNotifier extends AsyncNotifier<Map<int, GameSettings>> {
  Future<File> get _file async => File('${(await getApplicationSupportDirectory()).path}/games.json');

  @override
  Future<Map<int, GameSettings>> build() async {
    final file = await _file;
    if (!await file.exists()) return const {};
    try {
      final list = jsonDecode(await file.readAsString()) as List;
      return {
        for (final item in list)
          if (GameSettings.fromJson((item as Map).cast<String, dynamic>()) case final s) s.appId: s,
      };
    } on FormatException {
      return const {};
    }
  }

  GameSettings of(int appId) => state.value?[appId] ?? GameSettings(appId: appId);

  Future<void> edit(int appId, GameSettings Function(GameSettings) change) async {
    final current = await future;
    final next = {...current, appId: change(current[appId] ?? GameSettings(appId: appId))};
    state = AsyncData(next);
    final file = await _file;
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert([for (final s in next.values) s.toJson()]));
  }
}

final gameSettingsProvider = AsyncNotifierProvider<GameSettingsNotifier, Map<int, GameSettings>>(
  GameSettingsNotifier.new,
);

/// Sample profile that fits a game's genres, if one exists.
String? suggestedProfileId(GameDetails? details, List<Profile> profiles) {
  if (details == null) return null;
  final tags = {...details.genres, ...details.categories}.map((t) => t.toLowerCase()).join(' ');
  final id = switch (tags) {
    _ when tags.contains('shooter') || tags.contains('action') || tags.contains('fps') => 'fps-default',
    _
        when tags.contains('strategy') ||
            tags.contains('simulation') ||
            tags.contains('casual') ||
            tags.contains('puzzle') =>
      'navigation',
    _ => null,
  };
  return profiles.any((p) => p.id == id) ? id : null;
}

// MARK: Focus

/// The installed game whose process is in front, matched by its install
/// folder (`…/steamapps/common/<installdir>/`).
class FocusedGameNotifier extends Notifier<SteamGame?> {
  FrontApp? _lastApp;

  @override
  SteamGame? build() {
    ref.listen(joystickEventsProvider, (_, next) {
      if (next.value case AppActivated(:final app)) {
        _lastApp = app;
        state = _match(app);
      }
    });
    // Re-match when the library loads after the app was already in front.
    ref.listen(installedGamesProvider, (_, _) {
      if (_lastApp case final app?) state = _match(app);
    });
    ref.read(joystickChannelProvider).getFrontmostApp().then((app) {
      if (app != null && ref.mounted) {
        _lastApp = app;
        state = _match(app);
      }
    });
    return null;
  }

  SteamGame? _match(FrontApp app) {
    final games = ref.read(installedGamesProvider).value ?? const [];
    for (final game in games) {
      final dir = game.installPath;
      if (dir == null) continue;
      if (app.path.startsWith('$dir/') || app.executable.startsWith('$dir/')) return game;
    }
    return null;
  }
}

final focusedGameProvider = NotifierProvider<FocusedGameNotifier, SteamGame?>(FocusedGameNotifier.new);

/// The game in front and the settings that apply to it, when auto-switch
/// should take over from the profile chosen by the user.
final gameOverrideProvider = Provider<(SteamGame, GameSettings)?>((ref) {
  final game = ref.watch(focusedGameProvider);
  if (game == null) return null;
  final settings = ref.watch(gameSettingsProvider).value?[game.appId];
  if (settings == null) return null;
  if (settings.padpilotOff || (settings.autoSwitch && settings.profileId != null)) return (game, settings);
  return null;
});

/// Profile the engine should run right now: the focused game's profile
/// when auto-switch applies, else the one chosen by the user.
final effectiveProfileProvider = Provider<Profile?>((ref) {
  final override = ref.watch(gameOverrideProvider);
  final profiles = ref.watch(profilesProvider).value ?? const [];
  final id = override?.$2.profileId;
  if (id != null) {
    for (final p in profiles) {
      if (p.id == id) return p;
    }
  }
  return ref.watch(activeProfileProvider);
});
