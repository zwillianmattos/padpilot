import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/input_source.dart';
import '../../models/output_action.dart';
import '../../models/profile.dart';
import '../settings/settings_provider.dart';
import 'sample_profiles.dart';

class ProfilesNotifier extends AsyncNotifier<List<Profile>> {
  @override
  Future<List<Profile>> build() async {
    final repo = ref.read(profileRepositoryProvider);
    final settings = await ref.read(settingsProvider.future);
    var profiles = await repo.loadAll();
    if (!settings.samplesSeeded) {
      for (final sample in sampleProfiles(l10nFor(settings.localeCode))) {
        if (profiles.every((p) => p.id != sample.id)) await repo.save(sample);
      }
      await ref.read(settingsProvider.notifier).markSamplesSeeded();
      profiles = await repo.loadAll();
    }
    return profiles;
  }

  Future<void> _replace(List<Profile> profiles) async {
    profiles.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    state = AsyncData(profiles);
  }

  Future<void> save(Profile profile) async {
    await ref.read(profileRepositoryProvider).save(profile);
    final current = await future;
    await _replace([...current.where((p) => p.id != profile.id), profile]);
  }

  Future<Profile> create(String name) async {
    final profile = Profile(id: Profile.newId(), name: name);
    await save(profile);
    return profile;
  }

  Future<Profile> duplicate(Profile source, {required String name}) async {
    final copy = source.copyWith(id: Profile.newId(), name: name);
    await save(copy);
    return copy;
  }

  Future<void> rename(Profile profile, String name) => save(profile.copyWith(name: name));

  Future<void> delete(Profile profile) async {
    await ref.read(profileRepositoryProvider).delete(profile.id);
    final current = await future;
    await _replace(current.where((p) => p.id != profile.id).toList());
  }

  Future<Profile> import(String path) async {
    final imported = await ref.read(profileRepositoryProvider).import(path);
    final current = await future;
    final profile = current.any((p) => p.id == imported.id) ? imported.copyWith(id: Profile.newId()) : imported;
    await save(profile);
    return profile;
  }

  Future<void> export(Profile profile, String path) => ref.read(profileRepositoryProvider).export(profile, path);

  Future<void> restoreSamples() async {
    final settings = await ref.read(settingsProvider.future);
    for (final sample in sampleProfiles(l10nFor(settings.localeCode))) {
      await save(sample);
    }
  }

  Future<void> setMapping(String profileId, InputSource input, OutputAction? action) async {
    final current = await future;
    final profile = current.firstWhere((p) => p.id == profileId);
    await save(profile.withMapping(input, action));
  }
}

final profilesProvider = AsyncNotifierProvider<ProfilesNotifier, List<Profile>>(ProfilesNotifier.new);

/// The profile the engine is running: the chosen one, else the FPS sample,
/// else the first.
final activeProfileProvider = Provider<Profile?>((ref) {
  final profiles = ref.watch(profilesProvider).value ?? const [];
  if (profiles.isEmpty) return null;
  final id = ref.watch(settingsProvider).value?.activeProfileId;
  return profiles.where((p) => p.id == id).firstOrNull ??
      profiles.where((p) => p.id == 'fps-default').firstOrNull ??
      profiles.first;
});
