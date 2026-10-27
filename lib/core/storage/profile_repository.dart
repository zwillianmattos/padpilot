import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/profile.dart';

/// Stores each profile as `profiles/<id>.json` in Application Support
/// (`~/Library/Application Support/br.com.wanmind.padpilot`).
class ProfileRepository {
  Directory? _dir;

  Future<Directory> get directory async {
    if (_dir != null) return _dir!;
    final support = await getApplicationSupportDirectory();
    return _dir = await Directory('${support.path}/profiles').create(recursive: true);
  }

  Future<List<Profile>> loadAll() async {
    final dir = await directory;
    final profiles = <Profile>[];
    await for (final entity in dir.list()) {
      if (entity is! File || !entity.path.endsWith('.json')) continue;
      try {
        profiles.add(Profile.fromJson(jsonDecode(await entity.readAsString()) as Map<String, dynamic>));
      } on FormatException {
        // Skip files that aren't valid profiles instead of failing the whole list.
      }
    }
    profiles.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return profiles;
  }

  Future<void> save(Profile profile) async {
    final dir = await directory;
    await File(
      '${dir.path}/${profile.id}.json',
    ).writeAsString(const JsonEncoder.withIndent('  ').convert(profile.toJson()));
  }

  Future<void> delete(String id) async {
    final file = File('${(await directory).path}/$id.json');
    if (await file.exists()) await file.delete();
  }

  Future<Profile> import(String path) async =>
      Profile.fromJson(jsonDecode(await File(path).readAsString()) as Map<String, dynamic>);

  Future<void> export(Profile profile, String path) =>
      File(path).writeAsString(const JsonEncoder.withIndent('  ').convert(profile.toJson()));
}
