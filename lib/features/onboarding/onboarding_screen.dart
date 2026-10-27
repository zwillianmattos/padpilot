import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/joystick_channel.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/permissions_status.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/spacing.dart';
import '../../widgets/hero_photo.dart';
import '../../widgets/page_header.dart';
import '../settings/settings_provider.dart';
import 'permissions_provider.dart';

/// Explains and checks the two macOS permissions. Status updates live as
/// the user flips switches in System Settings.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key, this.firstRun = false});

  /// On first run there's nowhere to go back to; finishing opens home.
  final bool firstRun;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(permissionsProvider);
    final channel = ref.read(joystickChannelProvider);
    final l10n = context.l10n;

    Future<void> grant(PermissionType type) async {
      await channel.requestPermission(type);
      await channel.openPermissionSettings(type);
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            leading: firstRun ? null : const BackChevron(),
            title: firstRun ? l10n.welcome : l10n.permissions,
            subtitle: Text(l10n.tagline, style: TextStyle(fontSize: 14, color: context.palette.muted)),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: AppSpace.pageInsets,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 4 / 5,
                          child: HeroPhoto(
                            alignment: const Alignment(0.1, 0),
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PadPilot',
                                      style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      l10n.tagline,
                                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.35),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _PermissionCard(
                              icon: Icons.accessibility_new,
                              title: l10n.accessibility,
                              required: true,
                              description: l10n.accessibilityDesc,
                              state: status.accessibility,
                              onGrant: () => grant(PermissionType.accessibility),
                            ),
                            const SizedBox(height: 14),
                            _PermissionCard(
                              icon: Icons.sensors,
                              title: l10n.inputMonitoring,
                              required: false,
                              description: l10n.inputMonitoringDesc,
                              state: status.inputMonitoring,
                              onGrant: () => grant(PermissionType.inputMonitoring),
                              extra: InputMonitoringHelp(status: status),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              l10n.permissionsAutoUpdate,
                              style: TextStyle(fontSize: 12, color: context.palette.muted),
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton(
                                onPressed: () async {
                                  await ref.read(settingsProvider.notifier).completeOnboarding();
                                  if (!firstRun && context.mounted) Navigator.of(context).maybePop();
                                },
                                child: Text(
                                  (status.canInject ? l10n.continueLabel : l10n.continueAnyway).toUpperCase(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.required,
    required this.description,
    required this.state,
    required this.onGrant,
    this.extra,
  });

  final IconData icon;
  final String title;
  final bool required;
  final String description;
  final PermissionState state;
  final VoidCallback onGrant;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final granted = state == PermissionState.granted;
    final l10n = context.l10n;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSpace.card - 2),
      decoration: BoxDecoration(
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: granted ? context.palette.success : Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: granted ? context.palette.success : context.palette.text),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(
                      (required ? l10n.required : l10n.optional).toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: context.palette.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 12.5, color: context.palette.muted, height: 1.35)),
                const SizedBox(height: 12),
                if (granted)
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: context.palette.success),
                      const SizedBox(width: 6),
                      Text(
                        l10n.allowed,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.palette.success),
                      ),
                    ],
                  )
                else
                  OutlinedButton(onPressed: onGrant, child: Text(l10n.openSystemSettings.toUpperCase())),
                if (extra != null) ...[const SizedBox(height: 12), extra!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Help for Input Monitoring: ad-hoc signed builds are sometimes missing
/// from the list, and the grant only applies after a relaunch.
class InputMonitoringHelp extends ConsumerWidget {
  const InputMonitoringHelp({super.key, required this.status});

  final PermissionsStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final channel = ref.read(joystickChannelProvider);
    if (status.restartRequired) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.restartRequiredDesc, style: TextStyle(fontSize: 12.5, color: p.warning, height: 1.4)),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: channel.relaunch,
            icon: const Icon(Icons.restart_alt, size: 18),
            label: Text(l10n.restartApp.toUpperCase()),
          ),
        ],
      );
    }
    if (status.inputMonitoring == PermissionState.granted) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.notListedHint, style: TextStyle(fontSize: 12, color: p.muted, height: 1.4)),
        TextButton.icon(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: channel.revealApp,
          icon: const Icon(Icons.folder_open_outlined, size: 16),
          label: Text(l10n.revealApp),
        ),
      ],
    );
  }
}
