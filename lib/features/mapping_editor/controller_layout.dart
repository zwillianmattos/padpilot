import 'package:flutter/painting.dart';

import '../../l10n/l10n.dart';
import '../../models/controller_info.dart';
import '../../models/input_source.dart';

/// A clickable spot on the controller photo, grouping the inputs that
/// belong to one physical control (e.g. a stick has axis, 4 directions, click).
class ControlSpot {
  const ControlSpot({required this.id, required this.label, required this.position, required this.inputs});

  final String id;
  final String label;

  /// Position as a fraction of the photo's width/height.
  final Offset position;
  final List<LabeledInput> inputs;

  bool contains(String inputKey) => inputs.any((i) => i.input.key == inputKey);
}

class LabeledInput {
  const LabeledInput(this.label, this.input);

  final String label;
  final InputSource input;
}

/// Builds the hotspot list for one photo with labels in the current language.
List<ControlSpot> controlSpotsFor(ControllerStyle style, AppLocalizations l10n) {
  List<LabeledInput> stick(Side side, String clickName) => [
    LabeledInput(l10n.wholeStick, StickAxisInput(side)),
    LabeledInput(l10n.dirUp, StickDirectionInput(side, Direction.up)),
    LabeledInput(l10n.dirDown, StickDirectionInput(side, Direction.down)),
    LabeledInput(l10n.dirLeft, StickDirectionInput(side, Direction.left)),
    LabeledInput(l10n.dirRight, StickDirectionInput(side, Direction.right)),
    LabeledInput(
      l10n.pressNamed(clickName),
      ButtonInput(side == Side.left ? GamepadButton.leftStickButton : GamepadButton.rightStickButton),
    ),
  ];

  final dpad = [
    LabeledInput(l10n.dirUp, const DpadInput(Direction.up)),
    LabeledInput(l10n.dirDown, const DpadInput(Direction.down)),
    LabeledInput(l10n.dirLeft, const DpadInput(Direction.left)),
    LabeledInput(l10n.dirRight, const DpadInput(Direction.right)),
  ];

  ControlSpot button(String id, String label, Offset position, GamepadButton button) =>
      ControlSpot(id: id, label: label, position: position, inputs: [LabeledInput(l10n.press, ButtonInput(button))]);

  ControlSpot trigger(String id, String label, Offset position, Side side) =>
      ControlSpot(id: id, label: label, position: position, inputs: [LabeledInput(l10n.press, TriggerInput(side))]);

  return switch (style) {
    ControllerStyle.xbox => [
      trigger('lt', 'LT', const Offset(0.19, 0.10), Side.left),
      button('lb', 'LB', const Offset(0.30, 0.07), GamepadButton.leftShoulder),
      trigger('rt', 'RT', const Offset(0.81, 0.10), Side.right),
      button('rb', 'RB', const Offset(0.70, 0.07), GamepadButton.rightShoulder),
      ControlSpot(
        id: 'ls',
        label: l10n.leftStick,
        position: const Offset(0.275, 0.294),
        inputs: stick(Side.left, 'LS'),
      ),
      ControlSpot(
        id: 'rs',
        label: l10n.rightStick,
        position: const Offset(0.617, 0.481),
        inputs: stick(Side.right, 'RS'),
      ),
      ControlSpot(id: 'dpad', label: l10n.dpad, position: const Offset(0.385, 0.499), inputs: dpad),
      button('y', 'Y', const Offset(0.725, 0.214), GamepadButton.y),
      button('x', 'X', const Offset(0.664, 0.294), GamepadButton.x),
      button('b', 'B', const Offset(0.785, 0.294), GamepadButton.b),
      button('a', 'A', const Offset(0.725, 0.379), GamepadButton.a),
      button('select', 'View', const Offset(0.435, 0.292), GamepadButton.select),
      button('start', 'Menu', const Offset(0.564, 0.292), GamepadButton.start),
      button('home', 'Xbox', const Offset(0.5, 0.162), GamepadButton.home),
    ],
    ControllerStyle.playstation => [
      trigger('lt', 'L2', const Offset(0.13, 0.11), Side.left),
      button('lb', 'L1', const Offset(0.22, 0.07), GamepadButton.leftShoulder),
      trigger('rt', 'R2', const Offset(0.87, 0.11), Side.right),
      button('rb', 'R1', const Offset(0.78, 0.07), GamepadButton.rightShoulder),
      ControlSpot(id: 'ls', label: l10n.leftStick, position: const Offset(0.35, 0.475), inputs: stick(Side.left, 'L3')),
      ControlSpot(
        id: 'rs',
        label: l10n.rightStick,
        position: const Offset(0.646, 0.475),
        inputs: stick(Side.right, 'R3'),
      ),
      ControlSpot(id: 'dpad', label: l10n.dpad, position: const Offset(0.217, 0.295), inputs: dpad),
      button('y', l10n.triangle, const Offset(0.783, 0.2), GamepadButton.y),
      button('x', l10n.square, const Offset(0.715, 0.295), GamepadButton.x),
      button('b', l10n.circle, const Offset(0.848, 0.295), GamepadButton.b),
      button('a', l10n.cross, const Offset(0.783, 0.394), GamepadButton.a),
      button('select', 'Create', const Offset(0.288, 0.155), GamepadButton.select),
      button('start', 'Options', const Offset(0.713, 0.155), GamepadButton.start),
      button('home', 'PS', const Offset(0.493, 0.467), GamepadButton.home),
    ],
  };
}
