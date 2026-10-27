import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/settings_provider.dart';
import '../l10n/l10n.dart';
import 'app_theme.dart';

/// Global on/off switch for the mapping engine.
class MappingToggle extends ConsumerWidget {
  const MappingToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(settingsProvider).value?.mappingEnabled ?? false;
    final l10n = context.l10n;
    return Tooltip(
      message: enabled ? l10n.mappingDisable : l10n.mappingEnable,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(settingsProvider.notifier).toggleMapping(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: enabled ? context.palette.success : context.palette.muted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                (enabled ? l10n.mappingActive : l10n.mappingPaused).toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8),
              ),
              const SizedBox(width: 4),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: enabled,
                  onChanged: (v) => ref.read(settingsProvider.notifier).setMappingEnabled(v),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
