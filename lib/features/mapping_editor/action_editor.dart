import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../../models/input_source.dart';
import '../../models/output_action.dart';
import '../../widgets/app_theme.dart';
import 'key_capture_field.dart';

enum _ActionKind { none, key, click, move, scroll }

/// Edits the action assigned to one input (plus the input's threshold).
class ActionEditor extends StatefulWidget {
  const ActionEditor({
    super.key,
    required this.input,
    required this.action,
    required this.onActionChanged,
    required this.onInputChanged,
  });

  final InputSource input;
  final OutputAction? action;
  final ValueChanged<OutputAction?> onActionChanged;
  final ValueChanged<InputSource> onInputChanged;

  @override
  State<ActionEditor> createState() => _ActionEditorState();
}

class _ActionEditorState extends State<ActionEditor> {
  bool _recordOnNextKey = false;

  _ActionKind get _kind => switch (widget.action) {
    null => _ActionKind.none,
    KeyAction() => _ActionKind.key,
    MouseClickAction() => _ActionKind.click,
    MouseMoveAction() => _ActionKind.move,
    ScrollWheelAction() => _ActionKind.scroll,
  };

  Direction? get _direction => switch (widget.input) {
    DpadInput(:final direction) => direction,
    StickDirectionInput(:final direction) => direction,
    _ => null,
  };

  void _selectKind(_ActionKind kind) {
    if (kind == _kind) return;
    _recordOnNextKey = kind == _ActionKind.key;
    final direction = _direction;
    widget.onActionChanged(switch (kind) {
      _ActionKind.none => null,
      _ActionKind.key => const KeyAction(49),
      _ActionKind.click => const MouseClickAction(MouseButtonType.left),
      _ActionKind.move => const MouseMoveAction(),
      _ActionKind.scroll => ScrollWheelAction(
        axis: direction == Direction.left || direction == Direction.right ? ScrollAxis.horizontal : ScrollAxis.vertical,
        amount: direction == Direction.down || direction == Direction.left ? -3 : 3,
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final analog = widget.input.isAnalog;
    final l10n = context.l10n;
    final kinds = analog ? const [_ActionKind.none, _ActionKind.move, _ActionKind.scroll] : _ActionKind.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final kind in kinds)
              ChoiceChip(
                label: Text(_kindLabel(kind, l10n)),
                selected: _kind == kind,
                showCheckmark: false,
                onSelected: (_) => _selectKind(kind),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kind == kind ? context.palette.accent : context.palette.text,
                ),
                selectedColor: context.palette.accentSoft,
                side: BorderSide(color: _kind == kind ? context.palette.accent : context.palette.border),
              ),
          ],
        ),
        const SizedBox(height: 20),
        ...switch (widget.action) {
          final KeyAction action => _keyEditor(action, l10n),
          final MouseClickAction action => _clickEditor(action, l10n),
          final MouseMoveAction action => _moveEditor(action, analog, l10n),
          final ScrollWheelAction action => _scrollEditor(action, analog, l10n),
          null => const <Widget>[],
        },
        ..._thresholdEditor(l10n),
      ],
    );
  }

  List<Widget> _keyEditor(KeyAction action, AppLocalizations l10n) {
    final record = _recordOnNextKey;
    _recordOnNextKey = false;
    return [
      KeyCaptureField(value: action, onChanged: widget.onActionChanged, startRecording: record),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        children: [
          for (final modifier in KeyModifier.values)
            FilterChip(
              label: Text('${modifier.symbol} ${_modifierName(modifier)}'),
              selected: action.modifiers.contains(modifier),
              showCheckmark: false,
              labelStyle: const TextStyle(fontSize: 12),
              selectedColor: context.palette.accentSoft,
              side: BorderSide(color: context.palette.border),
              onSelected: (on) => widget.onActionChanged(
                action.copyWith(
                  modifiers: on
                      ? [...action.modifiers, modifier]
                      : action.modifiers.where((m) => m != modifier).toList(),
                ),
              ),
            ),
        ],
      ),
    ];
  }

  List<Widget> _clickEditor(MouseClickAction action, AppLocalizations l10n) => [
    SegmentedButton<MouseButtonType>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: MouseButtonType.left, label: Text(l10n.mouseLeft)),
        ButtonSegment(value: MouseButtonType.middle, label: Text(l10n.mouseMiddle)),
        ButtonSegment(value: MouseButtonType.right, label: Text(l10n.mouseRight)),
      ],
      selected: {action.button},
      onSelectionChanged: (s) => widget.onActionChanged(MouseClickAction(s.first)),
    ),
    const SizedBox(height: 8),
    _Hint(l10n.clickHint),
  ];

  List<Widget> _moveEditor(MouseMoveAction action, bool analog, AppLocalizations l10n) {
    final direction = _direction;
    final speed = action.speed;
    void setSpeed(DirectionalSpeed s) => widget.onActionChanged(action.copyWith(speed: s));

    return [
      if (analog) ...[
        _Label(l10n.responseCurve),
        SegmentedButton<ResponseCurve>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: ResponseCurve.linear, label: Text(l10n.curveLinear)),
            ButtonSegment(value: ResponseCurve.quadratic, label: Text(l10n.curveQuadratic)),
            ButtonSegment(value: ResponseCurve.exponential, label: Text(l10n.curveExponential)),
          ],
          selected: {action.curve},
          onSelectionChanged: (s) => widget.onActionChanged(action.copyWith(curve: s.first)),
        ),
        const SizedBox(height: 20),
        _SliderRow(
          label: l10n.deadzone,
          value: action.deadzone,
          min: 0,
          max: 0.5,
          format: (v) => '${(v * 100).round()}%',
          onChanged: (v) => widget.onActionChanged(action.copyWith(deadzone: v)),
        ),
        const SizedBox(height: 10),
        _SpeedEditor(speed: speed, onChanged: setSpeed),
      ] else if (direction != null)
        _SliderRow(
          label: l10n.speed,
          value: switch (direction) {
            Direction.up => speed.up,
            Direction.down => speed.down,
            Direction.left => speed.left,
            Direction.right => speed.right,
          },
          min: 1,
          max: 40,
          format: (v) => v.round().toString(),
          onChanged: (v) => setSpeed(switch (direction) {
            Direction.up => speed.copyWith(up: v),
            Direction.down => speed.copyWith(down: v),
            Direction.left => speed.copyWith(left: v),
            Direction.right => speed.copyWith(right: v),
          }),
        )
      else
        _SpeedEditor(speed: speed, onChanged: setSpeed),
    ];
  }

  List<Widget> _scrollEditor(ScrollWheelAction action, bool analog, AppLocalizations l10n) {
    final horizontal = action.axis == ScrollAxis.horizontal;
    return [
      SegmentedButton<ScrollAxis>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment(value: ScrollAxis.vertical, label: Text(l10n.vertical)),
          ButtonSegment(value: ScrollAxis.horizontal, label: Text(l10n.horizontal)),
        ],
        selected: {action.axis},
        onSelectionChanged: (s) => widget.onActionChanged(action.copyWith(axis: s.first)),
      ),
      const SizedBox(height: 16),
      if (analog)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(l10n.invertDirection, style: const TextStyle(fontSize: 13)),
          value: action.amount < 0,
          onChanged: (on) => widget.onActionChanged(action.copyWith(amount: action.amount.abs() * (on ? -1 : 1))),
        )
      else
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: true, label: Text(horizontal ? l10n.dirRight : l10n.dirUp)),
            ButtonSegment(value: false, label: Text(horizontal ? l10n.dirLeft : l10n.dirDown)),
          ],
          selected: {action.amount >= 0},
          onSelectionChanged: (s) =>
              widget.onActionChanged(action.copyWith(amount: action.amount.abs() * (s.first ? 1 : -1))),
        ),
      const SizedBox(height: 16),
      _SliderRow(
        label: analog ? l10n.speed : l10n.linesPerStep,
        value: action.amount.abs().clamp(1, 10).toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        format: (v) => v.round().toString(),
        onChanged: (v) =>
            widget.onActionChanged(action.copyWith(amount: v.roundToDouble() * (action.amount < 0 ? -1 : 1))),
      ),
    ];
  }

  List<Widget> _thresholdEditor(AppLocalizations l10n) {
    final input = widget.input;
    if (widget.action == null) return const [];
    final (double? threshold, ValueChanged<double>? set) = switch (input) {
      StickDirectionInput() => (input.threshold, (v) => widget.onInputChanged(input.copyWith(threshold: v))),
      TriggerInput() => (input.threshold, (v) => widget.onInputChanged(input.copyWith(threshold: v))),
      _ => (null, null),
    };
    if (threshold == null || set == null) return const [];
    return [
      const SizedBox(height: 16),
      _SliderRow(
        label: l10n.triggerFrom,
        value: threshold,
        min: 0.1,
        max: 0.95,
        format: (v) => '${(v * 100).round()}%',
        onChanged: set,
      ),
    ];
  }

  static String _kindLabel(_ActionKind kind, AppLocalizations l10n) => switch (kind) {
    _ActionKind.none => l10n.kindNone,
    _ActionKind.key => l10n.kindKey,
    _ActionKind.click => l10n.kindClick,
    _ActionKind.move => l10n.kindMove,
    _ActionKind.scroll => l10n.kindScroll,
  };

  static String _modifierName(KeyModifier m) => switch (m) {
    KeyModifier.control => 'Control',
    KeyModifier.option => 'Option',
    KeyModifier.shift => 'Shift',
    KeyModifier.command => 'Command',
  };
}

/// Per-direction speed with an optional "all equal" link.
class _SpeedEditor extends StatefulWidget {
  const _SpeedEditor({required this.speed, required this.onChanged});

  final DirectionalSpeed speed;
  final ValueChanged<DirectionalSpeed> onChanged;

  @override
  State<_SpeedEditor> createState() => _SpeedEditorState();
}

class _SpeedEditorState extends State<_SpeedEditor> {
  late bool _linked = _allEqual(widget.speed);

  static bool _allEqual(DirectionalSpeed s) => s.up == s.down && s.down == s.left && s.left == s.right;

  @override
  Widget build(BuildContext context) {
    final s = widget.speed;
    final l10n = context.l10n;
    String format(double v) => v.round().toString();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: _Label(l10n.speed)),
            Text(l10n.sameSpeedAllDirections, style: TextStyle(fontSize: 12, color: context.palette.muted)),
            Transform.scale(
              scale: 0.75,
              child: Switch(value: _linked, onChanged: (v) => setState(() => _linked = v)),
            ),
          ],
        ),
        if (_linked)
          _SliderRow(
            label: l10n.speedAll,
            value: s.right,
            min: 1,
            max: 40,
            format: format,
            onChanged: (v) => widget.onChanged(DirectionalSpeed.all(v)),
          )
        else ...[
          _SliderRow(
            label: l10n.dirUp,
            value: s.up,
            min: 1,
            max: 40,
            format: format,
            onChanged: (v) => widget.onChanged(s.copyWith(up: v)),
          ),
          _SliderRow(
            label: l10n.dirDown,
            value: s.down,
            min: 1,
            max: 40,
            format: format,
            onChanged: (v) => widget.onChanged(s.copyWith(down: v)),
          ),
          _SliderRow(
            label: l10n.dirLeft,
            value: s.left,
            min: 1,
            max: 40,
            format: format,
            onChanged: (v) => widget.onChanged(s.copyWith(left: v)),
          ),
          _SliderRow(
            label: l10n.dirRight,
            value: s.right,
            min: 1,
            max: 40,
            format: format,
            onChanged: (v) => widget.onChanged(s.copyWith(right: v)),
          ),
        ],
      ],
    );
  }
}

/// Slider that only commits on release, so dragging doesn't rewrite the
/// profile file and re-sync the engine on every frame.
class _SliderRow extends StatefulWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  State<_SliderRow> createState() => _SliderRowState();
}

class _SliderRowState extends State<_SliderRow> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final value = (_dragging ?? widget.value).clamp(widget.min, widget.max).toDouble();
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(widget.label, style: TextStyle(fontSize: 12, color: context.palette.muted)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: (v) => setState(() => _dragging = v),
            onChangeEnd: (v) {
              setState(() => _dragging = null);
              widget.onChanged(v);
            },
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            widget.format(value),
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(fontSize: 12, color: context.palette.muted));
}
