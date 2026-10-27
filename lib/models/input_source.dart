import 'dart:math' as math;

enum GamepadButton { a, b, x, y, leftShoulder, rightShoulder, leftStickButton, rightStickButton, start, select, home }

enum Direction { up, down, left, right }

enum Side { left, right }

/// A physical input on the controller, as defined by the profile contract.
sealed class InputSource {
  const InputSource();

  factory InputSource.fromJson(Map<String, dynamic> json) {
    final threshold = (json['threshold'] as num?)?.toDouble();
    return switch (json['type']) {
      'button' => ButtonInput(GamepadButton.values.byName(json['button'] as String)),
      'dpad' => DpadInput(Direction.values.byName(json['direction'] as String)),
      'stickDirection' => StickDirectionInput(
        Side.values.byName(json['stick'] as String),
        Direction.values.byName(json['direction'] as String),
        threshold: threshold ?? StickDirectionInput.defaultThreshold,
      ),
      'stickAxis' => StickAxisInput(Side.values.byName(json['stick'] as String)),
      'trigger' => TriggerInput(
        Side.values.byName(json['trigger'] as String),
        threshold: threshold ?? TriggerInput.defaultThreshold,
      ),
      final type => throw FormatException('Unknown input type: $type'),
    };
  }

  Map<String, dynamic> toJson();

  /// Identity of the input regardless of thresholds. Matches the `name`
  /// reported by native capture events.
  String get key;

  /// Whole sticks drive continuous actions only (mouse move, scroll).
  bool get isAnalog => false;

  /// Current activation (0...1) given a native input snapshot.
  double liveValue(Map<String, double> values);
}

class ButtonInput extends InputSource {
  const ButtonInput(this.button);

  final GamepadButton button;

  @override
  String get key => 'button:${button.name}';

  @override
  Map<String, dynamic> toJson() => {'type': 'button', 'button': button.name};

  @override
  double liveValue(Map<String, double> values) => values[button.name] ?? 0;
}

class DpadInput extends InputSource {
  const DpadInput(this.direction);

  final Direction direction;

  @override
  String get key => 'dpad:${direction.name}';

  @override
  Map<String, dynamic> toJson() => {'type': 'dpad', 'direction': direction.name};

  @override
  double liveValue(Map<String, double> values) {
    final name = direction.name;
    return values['dpad${name[0].toUpperCase()}${name.substring(1)}'] ?? 0;
  }
}

class StickDirectionInput extends InputSource {
  const StickDirectionInput(this.stick, this.direction, {this.threshold = defaultThreshold});

  static const defaultThreshold = 0.4;

  final Side stick;
  final Direction direction;
  final double threshold;

  @override
  String get key => 'stick:${stick.name}:${direction.name}';

  @override
  Map<String, dynamic> toJson() => {
    'type': 'stickDirection',
    'stick': stick.name,
    'direction': direction.name,
    'threshold': threshold,
  };

  StickDirectionInput copyWith({double? threshold}) =>
      StickDirectionInput(stick, direction, threshold: threshold ?? this.threshold);

  @override
  double liveValue(Map<String, double> values) {
    final x = values['${stick.name}StickX'] ?? 0;
    final y = values['${stick.name}StickY'] ?? 0;
    final value = switch (direction) {
      Direction.up => y,
      Direction.down => -y,
      Direction.left => -x,
      Direction.right => x,
    };
    return value.clamp(0, 1).toDouble();
  }
}

class StickAxisInput extends InputSource {
  const StickAxisInput(this.stick);

  final Side stick;

  @override
  String get key => 'axis:${stick.name}';

  @override
  bool get isAnalog => true;

  @override
  Map<String, dynamic> toJson() => {'type': 'stickAxis', 'stick': stick.name};

  @override
  double liveValue(Map<String, double> values) {
    final x = values['${stick.name}StickX'] ?? 0;
    final y = values['${stick.name}StickY'] ?? 0;
    return math.min(1, math.sqrt(x * x + y * y));
  }
}

class TriggerInput extends InputSource {
  const TriggerInput(this.trigger, {this.threshold = defaultThreshold});

  static const defaultThreshold = 0.5;

  final Side trigger;
  final double threshold;

  @override
  String get key => 'trigger:${trigger.name}';

  @override
  Map<String, dynamic> toJson() => {'type': 'trigger', 'trigger': trigger.name, 'threshold': threshold};

  TriggerInput copyWith({double? threshold}) => TriggerInput(trigger, threshold: threshold ?? this.threshold);

  @override
  double liveValue(Map<String, double> values) => values['${trigger.name}Trigger'] ?? 0;
}
