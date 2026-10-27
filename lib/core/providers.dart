import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'platform/joystick_channel.dart';
import 'platform/joystick_events.dart';
import 'storage/profile_repository.dart';
import 'storage/settings_repository.dart';

final joystickChannelProvider = Provider((ref) => JoystickChannel());

final joystickEventsProvider = StreamProvider<JoystickEvent>((ref) => ref.watch(joystickChannelProvider).events);

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

/// Key code → label for the active keyboard layout.
final keyLabelsProvider = FutureProvider((ref) => ref.watch(joystickChannelProvider).getKeyLabels());
