import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/joystick_events.dart';
import '../../core/providers.dart';
import '../../models/controller_info.dart';

/// Connected controllers, kept current by connect/disconnect events.
class ControllersNotifier extends Notifier<List<ControllerInfo>> {
  @override
  List<ControllerInfo> build() {
    ref.listen(joystickEventsProvider, (_, next) {
      switch (next.value) {
        case ControllerConnected(:final controller):
          state = [...state.where((c) => c.id != controller.id), controller];
        case ControllerDisconnected(:final id):
          state = state.where((c) => c.id != id).toList();
        default:
          break;
      }
    });
    ref.read(joystickChannelProvider).getControllers().then((list) {
      if (ref.mounted) state = list;
    });
    return const [];
  }
}

final controllersProvider = NotifierProvider<ControllersNotifier, List<ControllerInfo>>(ControllersNotifier.new);

/// Latest input snapshot per controller id. Only updates while some screen
/// keeps live input enabled (see [LiveInputScope]).
class LiveInputNotifier extends Notifier<Map<String, Map<String, double>>> {
  @override
  Map<String, Map<String, double>> build() {
    ref.listen(joystickEventsProvider, (_, next) {
      switch (next.value) {
        case InputStateChanged(:final controllerId, :final values):
          state = {...state, controllerId: values};
        case ControllerDisconnected(:final id):
          state = {...state}..remove(id);
        default:
          break;
      }
    });
    return const {};
  }
}

final liveInputProvider = NotifierProvider<LiveInputNotifier, Map<String, Map<String, double>>>(LiveInputNotifier.new);
