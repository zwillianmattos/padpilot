import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/joystick_events.dart';
import '../../core/providers.dart';
import '../../core/storage/settings_repository.dart';
import '../../models/output_action.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    // The global hotkey flips mapping natively; mirror it here.
    ref.listen(joystickEventsProvider, (_, next) {
      if (next.value case MappingToggled(:final enabled)) _update((s) => s.copyWith(mappingEnabled: enabled));
    });
    return ref.read(settingsRepositoryProvider).load();
  }

  Future<void> _update(AppSettings Function(AppSettings) change) async {
    final current = await future;
    final next = change(current);
    state = AsyncData(next);
    await ref.read(settingsRepositoryProvider).save(next);
  }

  Future<void> setActiveProfile(String id) => _update((s) => s.copyWith(activeProfileId: id));

  Future<void> setMappingEnabled(bool enabled) => _update((s) => s.copyWith(mappingEnabled: enabled));

  Future<void> toggleMapping() => _update((s) => s.copyWith(mappingEnabled: !s.mappingEnabled));

  Future<void> setToggleHotkey(KeyAction? hotkey) => _update((s) => s.copyWith(toggleHotkey: () => hotkey));

  Future<void> completeOnboarding() => _update((s) => s.copyWith(onboardingDone: true));

  Future<void> setLocale(String? code) => _update((s) => s.copyWith(localeCode: () => code));

  Future<void> markSamplesSeeded() => _update((s) => s.copyWith(samplesSeeded: true));
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
