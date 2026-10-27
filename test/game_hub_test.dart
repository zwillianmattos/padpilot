import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:padpilot/features/game_hub/data/steam_library.dart';
import 'package:padpilot/features/game_hub/data/vdf.dart';
import 'package:padpilot/features/game_hub/game_hub_providers.dart';
import 'package:padpilot/features/game_hub/models/steam_game.dart';
import 'package:padpilot/models/profile.dart';

void main() {
  test('parses nested VDF with escapes, comments and case-insensitive lookup', () {
    final vdf = parseVdf(r'''
// comment
"AppState"
{
  "appid"   "570"
  "name"    "Dota \"2\""
  "UserConfig" { "language" "english" }
}
''');
    final state = vdf.child('appstate')!;
    expect(state.string('AppID'), '570');
    expect(state.string('name'), 'Dota "2"');
    expect(state.child('userconfig')!.string('language'), 'english');
    expect(state.string('UserConfig'), isNull);
  });

  group('SteamLibrary', () {
    late Directory root;
    late Directory external;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('steam');
      external = await Directory.systemTemp.createTemp('lib2');
      await Directory('${root.path}/steamapps').create();
      await Directory('${external.path}/steamapps').create();
      await Directory('${root.path}/config').create();
      await File('${root.path}/steamapps/libraryfolders.vdf').writeAsString('''
"libraryfolders"
{
  "0" { "path" "${root.path}" }
  "1" { "path" "${external.path}" }
}''');
      await File('${root.path}/steamapps/appmanifest_400.acf').writeAsString(
        '''
"AppState" { "appid" "400" "name" "Portal" "installdir" "Portal" "SizeOnDisk" "4000000000" "LastPlayed" "1700000000" }''',
      );
      await File('${external.path}/steamapps/appmanifest_620.acf').writeAsString('''
"AppState" { "appid" "620" "name" "Portal 2" "installdir" "Portal 2" }''');
      // Steamworks redistributables are not a game.
      await File('${root.path}/steamapps/appmanifest_228980.acf').writeAsString('''
"AppState" { "appid" "228980" "name" "Steamworks Common Redistributables" "installdir" "Steamworks Shared" }''');
      await File('${root.path}/config/loginusers.vdf').writeAsString('''
"users" {
  "76561190000000001" { "AccountName" "a" "MostRecent" "0" "Timestamp" "100" }
  "76561190000000002" { "AccountName" "b" "MostRecent" "1" "Timestamp" "50" }
}''');
    });

    tearDown(() async {
      await root.delete(recursive: true);
      await external.delete(recursive: true);
    });

    test('finds installed games across library folders', () async {
      final games = await SteamLibrary(steamRoot: root.path).installedGames();
      expect(games.map((g) => g.name), ['Portal', 'Portal 2']);
      final portal = games.first;
      expect(portal.installPath, '${root.path}/steamapps/common/Portal');
      expect(portal.sizeOnDisk, 4000000000);
      expect(portal.lastPlayed, DateTime.fromMillisecondsSinceEpoch(1700000000 * 1000));
      expect(games.last.libraryPath, external.path);
    });

    test('reads the most recent SteamID64', () async {
      expect(await SteamLibrary(steamRoot: root.path).signedInSteamId(), '76561190000000002');
    });

    test('a missing Steam install yields no games', () async {
      final library = SteamLibrary(steamRoot: '${root.path}/nope');
      expect(library.isInstalled, isFalse);
      expect(await library.installedGames(), isEmpty);
    });
  });

  test('GameDetails reads store fields', () {
    final d = GameDetails.fromJson(1091500, {
      'name': 'Cyberpunk 2077',
      'type': 'game',
      'short_description': 'Open-world <b>RPG</b> &amp; more',
      'controller_support': 'full',
      'platforms': {'windows': true, 'mac': true, 'linux': false},
      'genres': [
        {'id': '3', 'description': 'RPG'},
      ],
      'metacritic': {'score': 86},
      'release_date': {'date': '10 Dec, 2020'},
    });
    expect(d.shortDescription, 'Open-world RPG & more');
    expect(d.controllerSupport, ControllerSupport.full);
    expect(d.windowsOnly, isFalse);
    expect(d.metacritic, 86);
  });

  test('suggests a sample profile from genres when it exists', () {
    const profiles = [Profile(id: 'fps-default', name: 'FPS'), Profile(id: 'navigation', name: 'Nav')];
    const shooter = GameDetails(appId: 1, name: 'x', type: 'game', genres: ['Action']);
    const strategy = GameDetails(appId: 2, name: 'y', type: 'game', genres: ['Strategy']);
    const other = GameDetails(appId: 3, name: 'z', type: 'game', genres: ['Racing']);
    expect(suggestedProfileId(shooter, profiles), 'fps-default');
    expect(suggestedProfileId(strategy, profiles), 'navigation');
    expect(suggestedProfileId(other, profiles), isNull);
    expect(suggestedProfileId(shooter, const []), isNull);
  });

  test('account data fills playtime without losing install info', () {
    const local = SteamGame(appId: 1, name: 'Game', installDir: 'Game', libraryPath: '/lib');
    final merged = local.mergeAccount(
      SteamGame(appId: 1, name: 'Game', playtimeMinutes: 90, lastPlayed: DateTime(2026)),
    );
    expect(merged.installed, isTrue);
    expect(merged.playtimeMinutes, 90);
    expect(merged.lastPlayed, DateTime(2026));
  });
}
