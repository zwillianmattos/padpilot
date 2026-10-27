import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/joystick_events.dart';
import '../../core/providers.dart';
import '../../models/permissions_status.dart';

class PermissionsNotifier extends Notifier<PermissionsStatus> {
  @override
  PermissionsStatus build() {
    ref.listen(joystickEventsProvider, (_, next) {
      if (next.value case PermissionChanged(:final status)) state = status;
    });
    refresh();
    return const PermissionsStatus.unknown();
  }

  Future<void> refresh() async {
    final status = await ref.read(joystickChannelProvider).getPermissions();
    if (ref.mounted) state = status;
  }
}

final permissionsProvider = NotifierProvider<PermissionsNotifier, PermissionsStatus>(PermissionsNotifier.new);
