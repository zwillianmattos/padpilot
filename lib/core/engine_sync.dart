import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/game_hub/game_hub_providers.dart';
import '../features/settings/settings_provider.dart';
import 'providers.dart';

/// Pushes the profile to run, the on/off switch and the global hotkey to the
/// native engine whenever they change. Watched once from the app root.
///
/// A focused game can override both: its bound profile replaces the chosen
/// one, and "PadPilot off for this game" pauses mapping while it's in front.
final engineSyncProvider = Provider<void>((ref) {
  final channel = ref.read(joystickChannelProvider);

  ref.listen(effectiveProfileProvider, (_, profile) {
    if (profile != null) channel.setActiveProfile(profile);
  }, fireImmediately: true);

  ref.listen(
    Provider((ref) {
      final enabled = ref.watch(settingsProvider.select((s) => s.value?.mappingEnabled));
      final pausedByGame = ref.watch(gameOverrideProvider)?.$2.padpilotOff ?? false;
      return enabled == null ? null : enabled && !pausedByGame;
    }),
    (_, enabled) {
      if (enabled != null) channel.setMappingEnabled(enabled);
    },
    fireImmediately: true,
  );

  ref.listen(settingsProvider.select((s) => s.value?.toggleHotkey?.toJson().toString()), (_, _) {
    final settings = ref.read(settingsProvider).value;
    if (settings != null) channel.setToggleHotkey(settings.toggleHotkey);
  }, fireImmediately: true);
});
