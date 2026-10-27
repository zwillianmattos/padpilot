enum KeyModifier {
  control('⌃'),
  option('⌥'),
  shift('⇧'),
  command('⌘');

  const KeyModifier(this.symbol);

  final String symbol;
}

enum ResponseCurve { linear, quadratic, exponential }

enum MouseButtonType { left, right, middle }

enum ScrollAxis { vertical, horizontal }

class DirectionalSpeed {
  const DirectionalSpeed({required this.up, required this.down, required this.left, required this.right});

  const DirectionalSpeed.all(double value) : this(up: value, down: value, left: value, right: value);

  factory DirectionalSpeed.fromJson(Map<String, dynamic> json) => DirectionalSpeed(
    up: (json['up'] as num?)?.toDouble() ?? 10,
    down: (json['down'] as num?)?.toDouble() ?? 10,
    left: (json['left'] as num?)?.toDouble() ?? 10,
    right: (json['right'] as num?)?.toDouble() ?? 10,
  );

  final double up;
  final double down;
  final double left;
  final double right;

  Map<String, dynamic> toJson() => {'up': up, 'down': down, 'left': left, 'right': right};

  DirectionalSpeed copyWith({double? up, double? down, double? left, double? right}) =>
      DirectionalSpeed(up: up ?? this.up, down: down ?? this.down, left: left ?? this.left, right: right ?? this.right);
}

/// What PadPilot does when an input fires.
sealed class OutputAction {
  const OutputAction();

  factory OutputAction.fromJson(Map<String, dynamic> json) => switch (json['type']) {
    'key' => KeyAction(
      json['keyCode'] as int,
      modifiers: [
        for (final name in (json['modifiers'] as List? ?? const [])) KeyModifier.values.byName(name as String),
      ],
    ),
    'mouseMove' => MouseMoveAction(
      speed: DirectionalSpeed.fromJson((json['speed'] as Map? ?? const {}).cast<String, dynamic>()),
      deadzone: (json['deadzone'] as num?)?.toDouble() ?? MouseMoveAction.defaultDeadzone,
      curve: ResponseCurve.values.byName(json['curve'] as String? ?? 'quadratic'),
    ),
    'mouseClick' => MouseClickAction(MouseButtonType.values.byName(json['button'] as String? ?? 'left')),
    'scroll' => ScrollWheelAction(
      axis: ScrollAxis.values.byName(json['axis'] as String? ?? 'vertical'),
      amount: (json['amount'] as num?)?.toDouble() ?? 3,
    ),
    final type => throw FormatException('Unknown action type: $type'),
  };

  Map<String, dynamic> toJson();

  bool get isContinuous => false;
}

class KeyAction extends OutputAction {
  const KeyAction(this.keyCode, {this.modifiers = const []});

  final int keyCode;
  final List<KeyModifier> modifiers;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'key',
    'keyCode': keyCode,
    'modifiers': [for (final m in modifiers) m.name],
  };

  KeyAction copyWith({int? keyCode, List<KeyModifier>? modifiers}) =>
      KeyAction(keyCode ?? this.keyCode, modifiers: modifiers ?? this.modifiers);
}

class MouseMoveAction extends OutputAction {
  const MouseMoveAction({
    this.speed = const DirectionalSpeed.all(12),
    this.deadzone = defaultDeadzone,
    this.curve = ResponseCurve.quadratic,
  });

  static const defaultDeadzone = 0.15;

  final DirectionalSpeed speed;
  final double deadzone;
  final ResponseCurve curve;

  @override
  bool get isContinuous => true;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'mouseMove',
    'speed': speed.toJson(),
    'deadzone': deadzone,
    'curve': curve.name,
  };

  MouseMoveAction copyWith({DirectionalSpeed? speed, double? deadzone, ResponseCurve? curve}) =>
      MouseMoveAction(speed: speed ?? this.speed, deadzone: deadzone ?? this.deadzone, curve: curve ?? this.curve);
}

class MouseClickAction extends OutputAction {
  const MouseClickAction(this.button);

  final MouseButtonType button;

  @override
  Map<String, dynamic> toJson() => {'type': 'mouseClick', 'button': button.name};
}

class ScrollWheelAction extends OutputAction {
  const ScrollWheelAction({this.axis = ScrollAxis.vertical, this.amount = 3});

  final ScrollAxis axis;

  /// Positive scrolls up (vertical) or right (horizontal).
  final double amount;

  @override
  bool get isContinuous => true;

  @override
  Map<String, dynamic> toJson() => {'type': 'scroll', 'axis': axis.name, 'amount': amount};

  ScrollWheelAction copyWith({ScrollAxis? axis, double? amount}) =>
      ScrollWheelAction(axis: axis ?? this.axis, amount: amount ?? this.amount);
}
