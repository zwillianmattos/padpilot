import '../../l10n/l10n.dart';
import '../../models/input_source.dart';
import '../../models/mapping.dart';
import '../../models/output_action.dart';
import '../../models/profile.dart';

/// macOS virtual key codes used by the samples (ANSI positions).
abstract final class Keys {
  static const a = 0, s = 1, d = 2, f = 3, c = 8, v = 9, b = 11, q = 12, w = 13, e = 14, r = 15;
  static const one = 18, two = 19, three = 20, equal = 24, minus = 27, rightBracket = 30, leftBracket = 33;
  static const l = 37, m = 46, z = 6, tab = 48, space = 49, escape = 53, enter = 36, delete = 51;
  static const shift = 56, option = 58, control = 59;
  static const left = 123, right = 124, down = 125, up = 126;
}

Mapping _key(InputSource input, int code, [List<KeyModifier> modifiers = const []]) => Mapping(
  input: input,
  action: KeyAction(code, modifiers: modifiers),
);

Mapping _click(InputSource input, MouseButtonType button) => Mapping(input: input, action: MouseClickAction(button));

const _cmd = [KeyModifier.command];

List<Profile> sampleProfiles(AppLocalizations l10n) => [
  Profile(
    id: 'fps-default',
    name: 'FPS',
    mappings: [
      _key(const StickDirectionInput(Side.left, Direction.up), Keys.w),
      _key(const StickDirectionInput(Side.left, Direction.down), Keys.s),
      _key(const StickDirectionInput(Side.left, Direction.left), Keys.a),
      _key(const StickDirectionInput(Side.left, Direction.right), Keys.d),
      const Mapping(
        input: StickAxisInput(Side.right),
        action: MouseMoveAction(speed: DirectionalSpeed(up: 12, down: 12, left: 14, right: 14)),
      ),
      _click(const TriggerInput(Side.right), MouseButtonType.left),
      _click(const TriggerInput(Side.left), MouseButtonType.right),
      _key(const ButtonInput(GamepadButton.a), Keys.space),
      _key(const ButtonInput(GamepadButton.b), Keys.c),
      _key(const ButtonInput(GamepadButton.x), Keys.r),
      _key(const ButtonInput(GamepadButton.y), Keys.f),
      _key(const ButtonInput(GamepadButton.leftShoulder), Keys.q),
      _key(const ButtonInput(GamepadButton.rightShoulder), Keys.e),
      _key(const ButtonInput(GamepadButton.leftStickButton), Keys.shift),
      _key(const ButtonInput(GamepadButton.start), Keys.escape),
      _key(const ButtonInput(GamepadButton.select), Keys.tab),
      const Mapping(input: DpadInput(Direction.up), action: ScrollWheelAction(amount: 3)),
      const Mapping(input: DpadInput(Direction.down), action: ScrollWheelAction(amount: -3)),
      _key(const DpadInput(Direction.left), Keys.one),
      _key(const DpadInput(Direction.right), Keys.two),
    ],
  ),
  Profile(
    id: 'media-player',
    name: l10n.sampleMediaPlayer,
    mappings: [
      _key(const ButtonInput(GamepadButton.a), Keys.space),
      _key(const ButtonInput(GamepadButton.b), Keys.escape),
      _key(const ButtonInput(GamepadButton.y), Keys.f),
      _key(const ButtonInput(GamepadButton.x), Keys.m),
      _key(const DpadInput(Direction.left), Keys.left),
      _key(const DpadInput(Direction.right), Keys.right),
      _key(const DpadInput(Direction.up), Keys.up),
      _key(const DpadInput(Direction.down), Keys.down),
      _key(const ButtonInput(GamepadButton.leftShoulder), Keys.left, _cmd),
      _key(const ButtonInput(GamepadButton.rightShoulder), Keys.right, _cmd),
      const Mapping(
        input: StickAxisInput(Side.left),
        action: MouseMoveAction(speed: DirectionalSpeed.all(8)),
      ),
      _click(const TriggerInput(Side.right), MouseButtonType.left),
    ],
  ),
  Profile(
    id: 'navigation',
    name: l10n.sampleNavigation,
    mappings: [
      const Mapping(
        input: StickAxisInput(Side.left),
        action: MouseMoveAction(speed: DirectionalSpeed.all(14), curve: ResponseCurve.exponential),
      ),
      const Mapping(input: StickAxisInput(Side.right), action: ScrollWheelAction(amount: 4)),
      _click(const ButtonInput(GamepadButton.a), MouseButtonType.left),
      _click(const ButtonInput(GamepadButton.x), MouseButtonType.right),
      _click(const TriggerInput(Side.right), MouseButtonType.left),
      _click(const TriggerInput(Side.left), MouseButtonType.middle),
      _key(const ButtonInput(GamepadButton.b), Keys.leftBracket, _cmd),
      _key(const ButtonInput(GamepadButton.y), Keys.l, _cmd),
      _key(const ButtonInput(GamepadButton.leftShoulder), Keys.tab, [KeyModifier.control, KeyModifier.shift]),
      _key(const ButtonInput(GamepadButton.rightShoulder), Keys.tab, [KeyModifier.control]),
      _key(const ButtonInput(GamepadButton.start), 17 /* T */, _cmd),
      _key(const ButtonInput(GamepadButton.select), 13 /* W */, _cmd),
      const Mapping(input: DpadInput(Direction.up), action: ScrollWheelAction(amount: 5)),
      const Mapping(input: DpadInput(Direction.down), action: ScrollWheelAction(amount: -5)),
      _key(const DpadInput(Direction.left), Keys.leftBracket, _cmd),
      _key(const DpadInput(Direction.right), Keys.rightBracket, _cmd),
    ],
  ),
  Profile(
    id: 'photo-editing',
    name: l10n.samplePhotoEditing,
    mappings: [
      const Mapping(
        input: StickAxisInput(Side.left),
        action: MouseMoveAction(speed: DirectionalSpeed.all(6), deadzone: 0.12, curve: ResponseCurve.exponential),
      ),
      const Mapping(input: StickAxisInput(Side.right), action: ScrollWheelAction(amount: 3)),
      _click(const ButtonInput(GamepadButton.a), MouseButtonType.left),
      _key(const ButtonInput(GamepadButton.b), Keys.z, _cmd),
      _key(const ButtonInput(GamepadButton.y), Keys.z, [KeyModifier.command, KeyModifier.shift]),
      _key(const ButtonInput(GamepadButton.x), Keys.space),
      _key(const ButtonInput(GamepadButton.leftShoulder), Keys.leftBracket),
      _key(const ButtonInput(GamepadButton.rightShoulder), Keys.rightBracket),
      _key(const TriggerInput(Side.left), Keys.option),
      _key(const TriggerInput(Side.right), Keys.shift),
      _key(const DpadInput(Direction.left), Keys.left),
      _key(const DpadInput(Direction.right), Keys.right),
      _key(const DpadInput(Direction.up), Keys.equal, _cmd),
      _key(const DpadInput(Direction.down), Keys.minus, _cmd),
      _key(const ButtonInput(GamepadButton.start), Keys.s, _cmd),
      _key(const ButtonInput(GamepadButton.select), Keys.tab),
    ],
  ),
];
