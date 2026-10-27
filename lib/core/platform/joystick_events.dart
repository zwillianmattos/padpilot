import '../../models/controller_info.dart';
import '../../models/input_source.dart';
import '../../models/permissions_status.dart';

/// Events pushed by the native plugin on `wanmind/padpilot/events`.
sealed class JoystickEvent {
  const JoystickEvent();

  static JoystickEvent? parse(Object? raw) {
    if (raw is! Map) return null;
    final data = (raw['data'] as Map?) ?? const {};
    return switch (raw['type']) {
      'controllerConnected' => ControllerConnected(ControllerInfo.fromMap(data)),
      'controllerDisconnected' => ControllerDisconnected(data['id'] as String),
      'inputCaptured' => InputCaptured(
        controllerId: data['controllerId'] as String,
        name: data['name'] as String,
        input: InputSource.fromJson((data['input'] as Map).cast<String, dynamic>()),
        value: (data['value'] as num).toDouble(),
      ),
      'inputState' => InputStateChanged(
        controllerId: data['controllerId'] as String,
        values: _doubles(data['values'] as Map),
      ),
      'permissionChanged' => PermissionChanged(PermissionsStatus.fromMap(data)),
      'mappingToggled' => MappingToggled(data['enabled'] as bool),
      'diagnosticSample' => DiagnosticSample(
        controllerId: data['controllerId'] as String,
        time: (data['time'] as num).toDouble(),
        values: _doubles(data['values'] as Map),
      ),
      'rawHid' => RawHidSnapshot(
        id: data['id'] as String,
        name: data['name'] as String,
        axes: {
          for (final e in (data['axes'] as Map).entries)
            e.key as String: RawHidAxis(
              value: (e.value as Map)['value'] as int,
              min: e.value['min'] as int,
              max: e.value['max'] as int,
            ),
        },
      ),
      'appActivated' => AppActivated(FrontApp.fromMap(data)),
      _ => null,
    };
  }

  static Map<String, double> _doubles(Map map) => {
    for (final e in map.entries) e.key as String: (e.value as num).toDouble(),
  };
}

class ControllerConnected extends JoystickEvent {
  const ControllerConnected(this.controller);

  final ControllerInfo controller;
}

class ControllerDisconnected extends JoystickEvent {
  const ControllerDisconnected(this.id);

  final String id;
}

/// Only sent while capture mode is on.
class InputCaptured extends JoystickEvent {
  const InputCaptured({required this.controllerId, required this.name, required this.input, required this.value});

  final String controllerId;
  final String name;
  final InputSource input;
  final double value;
}

/// Throttled snapshot of every input; only sent while live input is on.
class InputStateChanged extends JoystickEvent {
  const InputStateChanged({required this.controllerId, required this.values});

  final String controllerId;
  final Map<String, double> values;
}

class PermissionChanged extends JoystickEvent {
  const PermissionChanged(this.status);

  final PermissionsStatus status;
}

/// Fired when the global hotkey toggles mapping natively.
class MappingToggled extends JoystickEvent {
  const MappingToggled(this.enabled);

  final bool enabled;
}

/// Every input change (≤250 Hz); only sent while diagnostics is on.
class DiagnosticSample extends JoystickEvent {
  const DiagnosticSample({required this.controllerId, required this.time, required this.values});

  final String controllerId;

  /// Seconds since boot, from the native clock.
  final double time;
  final Map<String, double> values;
}

class RawHidAxis {
  const RawHidAxis({required this.value, required this.min, required this.max});

  final int value;
  final int min;
  final int max;
}

/// Sensor counts straight from the HID report, before GameController's
/// processing; only sent while diagnostics is on.
class RawHidSnapshot extends JoystickEvent {
  const RawHidSnapshot({required this.id, required this.name, required this.axes});

  final String id;
  final String name;
  final Map<String, RawHidAxis> axes;
}

class FrontApp {
  const FrontApp({required this.name, required this.bundleId, required this.path, required this.executable});

  factory FrontApp.fromMap(Map<Object?, Object?> map) => FrontApp(
    name: map['name'] as String? ?? '',
    bundleId: map['bundleId'] as String? ?? '',
    path: map['path'] as String? ?? '',
    executable: map['executable'] as String? ?? '',
  );

  final String name;
  final String bundleId;

  /// Bundle path (…/Game.app) or empty for bare executables.
  final String path;
  final String executable;
}

/// Another app came to the front (used to auto-switch game profiles).
class AppActivated extends JoystickEvent {
  const AppActivated(this.app);

  final FrontApp app;
}
