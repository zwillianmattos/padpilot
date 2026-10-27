import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/platform/joystick_channel.dart';
import '../../core/platform/joystick_events.dart';
import '../../models/input_source.dart';
import 'stick_analyzer.dart';

class RawAxisStats {
  RawAxisStats(this.axis) : observedMin = axis.value, observedMax = axis.value;

  RawHidAxis axis;
  int observedMin;
  int observedMax;

  void update(RawHidAxis next) {
    axis = next;
    if (next.value < observedMin) observedMin = next.value;
    if (next.value > observedMax) observedMax = next.value;
  }

  /// Logical span in counts; e.g. 255 for an 8-bit axis.
  int get span => axis.max - axis.min;
}

class RawDeviceStats {
  RawDeviceStats(this.name);

  final String name;
  final Map<String, RawAxisStats> axes = {};
}

/// Turns diagnostic events into per-stick statistics. Notifies on every
/// sample, so plots can repaint at the controller's own rate.
class DiagnosticsSession extends ChangeNotifier {
  DiagnosticsSession(this._channel, {this.controllerId});

  final JoystickChannel _channel;

  /// Controller to analyze; null picks whichever sends data first.
  String? controllerId;

  final Map<Side, StickAnalyzer> sticks = {Side.left: StickAnalyzer(), Side.right: StickAnalyzer()};
  final Map<Side, TriggerAnalyzer> triggers = {Side.left: TriggerAnalyzer(), Side.right: TriggerAnalyzer()};
  final Map<String, RawDeviceStats> raw = {};
  final RateMeter _rate = RateMeter();
  final Stopwatch _clock = Stopwatch()..start();
  StreamSubscription<JoystickEvent>? _subscription;

  double get _now => _clock.elapsedMicroseconds / 1e6;

  int get eventsPerSecond => _rate.rateAt(_now);

  Future<void> start() async {
    _subscription = _channel.events.listen(_onEvent);
    await _channel.setDiagnostics(true);
  }

  void _onEvent(JoystickEvent event) {
    switch (event) {
      case DiagnosticSample(:final controllerId, :final values):
        this.controllerId ??= controllerId;
        if (controllerId != this.controllerId) return;
        _rate.add(_now);
        for (final side in Side.values) {
          final name = side.name;
          sticks[side]!.add(values['${name}StickX'] ?? 0, values['${name}StickY'] ?? 0);
          triggers[side]!.add(values['${name}Trigger'] ?? 0);
        }
        notifyListeners();
      case RawHidSnapshot(:final id, :final name, :final axes):
        final device = raw.putIfAbsent(id, () => RawDeviceStats(name));
        for (final entry in axes.entries) {
          final stats = device.axes[entry.key];
          if (stats == null) {
            device.axes[entry.key] = RawAxisStats(entry.value);
          } else {
            stats.update(entry.value);
          }
        }
        notifyListeners();
      default:
        break;
    }
  }

  /// Captures [duration] of rest samples for one stick, then computes its
  /// center offset, noise and a suggested dead zone.
  Future<CenterCalibration?> calibrate(Side side, {Duration duration = const Duration(seconds: 2)}) async {
    final stick = sticks[side]!..startCalibration();
    notifyListeners();
    await Future<void>.delayed(duration);
    final result = stick.finishCalibration();
    notifyListeners();
    return result;
  }

  void reset() {
    for (final s in sticks.values) {
      s.reset();
    }
    for (final t in triggers.values) {
      t.reset();
    }
    raw.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel.setDiagnostics(false);
    super.dispose();
  }
}
