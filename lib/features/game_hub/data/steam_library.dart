import 'dart:io';

import '../models/steam_game.dart';
import 'vdf.dart';

/// Reads the local Steam install: every library folder and its installed
/// games (appmanifest_*.acf), plus the signed-in SteamID64. Needs no key.
class SteamLibrary {
  SteamLibrary({String? steamRoot}) : root = steamRoot ?? _defaultRoot();

  static String _defaultRoot() {
    if (Platform.isWindows) {
      final programFiles = Platform.environment['ProgramFiles(x86)'] ?? r'C:\Program Files (x86)';
      return '$programFiles\\Steam';
    }
    return '${Platform.environment['HOME']}/Library/Application Support/Steam';
  }

  final String root;

  /// Tools and runtimes Steam installs alongside games.
  static const _notGames = {228980, 1007, 1070560, 1391110, 1628350};

  bool get isInstalled => Directory(root).existsSync();

  Future<List<String>> libraryPaths() async {
    final paths = <String>{root};
    final file = File('$root/steamapps/libraryfolders.vdf');
    if (await file.exists()) {
      final vdf = parseVdf(await file.readAsString());
      final folders = vdf.child('libraryfolders') ?? vdf.child('LibraryFolders') ?? const {};
      for (final entry in folders.values) {
        // New format: { "path" "..." }, old format: "1" "path".
        final path = entry is Map ? (entry.cast<String, Object>()).string('path') : entry as String?;
        if (path != null && path.isNotEmpty) paths.add(path);
      }
    }
    return paths.toList();
  }

  Future<List<SteamGame>> installedGames() async {
    final games = <int, SteamGame>{};
    for (final library in await libraryPaths()) {
      final dir = Directory('$library/steamapps');
      if (!await dir.exists()) continue;
      await for (final entity in dir.list()) {
        final name = entity.uri.pathSegments.last;
        if (entity is! File || !name.startsWith('appmanifest_') || !name.endsWith('.acf')) continue;
        try {
          final game = _parseManifest(await entity.readAsString(), library);
          if (game != null && !_notGames.contains(game.appId)) games[game.appId] = game;
        } on FileSystemException {
          continue; // Unreadable manifest.
        }
      }
    }
    return games.values.toList()..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  static SteamGame? _parseManifest(String source, String library) {
    final state = parseVdf(source).child('AppState');
    final appId = int.tryParse(state?.string('appid') ?? '');
    if (state == null || appId == null) return null;
    final lastPlayed = int.tryParse(state.string('LastPlayed') ?? '') ?? 0;
    return SteamGame(
      appId: appId,
      name: state.string('name') ?? 'App $appId',
      installDir: state.string('installdir'),
      libraryPath: library,
      sizeOnDisk: int.tryParse(state.string('SizeOnDisk') ?? ''),
      lastPlayed: lastPlayed > 0 ? DateTime.fromMillisecondsSinceEpoch(lastPlayed * 1000) : null,
    );
  }

  /// SteamID64 of the most recently signed-in account, if any.
  Future<String?> signedInSteamId() async {
    final file = File('$root/config/loginusers.vdf');
    if (!await file.exists()) return null;
    final users = parseVdf(await file.readAsString()).child('users') ?? const {};
    String? best;
    var bestTime = -1;
    for (final entry in users.entries) {
      final user = entry.value is Map ? (entry.value as Map).cast<String, Object>() : null;
      if (user == null) continue;
      if (user.string('MostRecent') == '1') return entry.key;
      final time = int.tryParse(user.string('Timestamp') ?? '') ?? 0;
      if (time > bestTime) {
        bestTime = time;
        best = entry.key;
      }
    }
    return best;
  }
}
