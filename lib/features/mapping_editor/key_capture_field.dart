import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../models/output_action.dart';
import '../../widgets/app_theme.dart';
import '../../l10n/l10n.dart';
import 'action_labels.dart';

/// Shows a key combo; click to record a new one from the physical keyboard
/// (modifiers included). Recording happens natively so key codes are exact.
class KeyCaptureField extends ConsumerStatefulWidget {
  const KeyCaptureField({super.key, required this.value, required this.onChanged, this.startRecording = false});

  final KeyAction? value;
  final ValueChanged<KeyAction> onChanged;
  final bool startRecording;

  @override
  ConsumerState<KeyCaptureField> createState() => _KeyCaptureFieldState();
}

class _KeyCaptureFieldState extends ConsumerState<KeyCaptureField> {
  bool _recording = false;

  @override
  void initState() {
    super.initState();
    if (widget.startRecording) WidgetsBinding.instance.addPostFrameCallback((_) => _record());
  }

  @override
  void dispose() {
    if (_recording) ref.read(joystickChannelProvider).cancelKeyCapture();
    super.dispose();
  }

  Future<void> _record() async {
    final channel = ref.read(joystickChannelProvider);
    if (_recording) {
      await channel.cancelKeyCapture();
      return;
    }
    setState(() => _recording = true);
    final key = await channel.captureKey();
    if (!mounted) return;
    setState(() => _recording = false);
    if (key != null) widget.onChanged(KeyAction(key.keyCode, modifiers: key.modifiers));
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(keyLabelsProvider).value ?? const {};
    final value = widget.value;
    final l10n = context.l10n;
    final text = _recording
        ? l10n.pressAKey
        : value == null
        ? l10n.clickToRecord
        : actionSummary(value, labels, l10n);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: _record,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _recording ? context.palette.accentSoft : context.palette.surface,
          border: Border.all(color: _recording ? context.palette.accent : context.palette.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              _recording ? Icons.fiber_manual_record : Icons.keyboard_outlined,
              size: 18,
              color: _recording ? context.palette.accent : context.palette.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: value == null || _recording ? 13 : 16,
                  fontWeight: value == null || _recording ? FontWeight.w500 : FontWeight.w700,
                  color: _recording ? context.palette.accent : context.palette.text,
                ),
              ),
            ),
            Text(
              (_recording ? l10n.cancel : l10n.record).toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: context.palette.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
