import '../../l10n/l10n.dart';
import '../../models/output_action.dart';

/// Native labels come from the keyboard layout; these few are words, so
/// they're translated here.
String keyLabel(int keyCode, Map<int, String> labels, AppLocalizations l10n) => switch (keyCode) {
  49 => l10n.keySpace,
  54 => l10n.keyRight('Command'),
  60 => l10n.keyRight('Shift'),
  61 => l10n.keyRight('Option'),
  62 => l10n.keyRight('Control'),
  _ => labels[keyCode] ?? l10n.keyFallback(keyCode),
};

/// Short summary of an action, e.g. "⌘Q", "Move mouse", "Left click".
String actionSummary(OutputAction? action, Map<int, String> labels, AppLocalizations l10n) => switch (action) {
  null => l10n.notAssigned,
  KeyAction(:final keyCode, :final modifiers) =>
    '${KeyModifier.values.where(modifiers.contains).map((m) => m.symbol).join()}${keyLabel(keyCode, labels, l10n)}',
  MouseMoveAction() => l10n.actionMoveMouse,
  MouseClickAction(:final button) => switch (button) {
    MouseButtonType.left => l10n.actionClickLeft,
    MouseButtonType.right => l10n.actionClickRight,
    MouseButtonType.middle => l10n.actionClickMiddle,
  },
  ScrollWheelAction(:final axis, :final amount) => switch (axis) {
    ScrollAxis.vertical => amount >= 0 ? l10n.actionScrollUp : l10n.actionScrollDown,
    ScrollAxis.horizontal => amount >= 0 ? l10n.actionScrollRight : l10n.actionScrollLeft,
  },
};
