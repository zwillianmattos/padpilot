import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/permissions_status.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/page_header.dart';
import '../../widgets/pill.dart';
import '../../widgets/section.dart';
import '../../widgets/spacing.dart';
import '../mapping_editor/key_capture_field.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/permissions_provider.dart';
import 'settings_provider.dart';

final _launchAtLoginProvider = FutureProvider.autoDispose(
  (ref) => ref.read(joystickChannelProvider).getLaunchAtLogin(),
);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).value;
    final launchAtLogin = ref.watch(_launchAtLoginProvider).value ?? false;
    final permissions = ref.watch(permissionsProvider);
    final channel = ref.read(joystickChannelProvider);
    final l10n = context.l10n;
    final p = context.palette;

    void toast(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(leading: const BackChevron(), title: l10n.settings),
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720 + AppSpace.page * 2),
                child: ListView(
                  padding: AppSpace.pageInsets,
                  children: [
                    Section(
                      title: l10n.general,
                      children: [
                        SettingRow(
                          title: l10n.language,
                          trailing: DropdownButton<String?>(
                            value: settings?.localeCode,
                            underline: const SizedBox.shrink(),
                            borderRadius: BorderRadius.circular(10),
                            items: [
                              DropdownMenuItem(value: null, child: Text(l10n.languageSystem)),
                              const DropdownMenuItem(value: 'en', child: Text('English')),
                              const DropdownMenuItem(value: 'pt', child: Text('Português')),
                              const DropdownMenuItem(value: 'es', child: Text('Español')),
                            ],
                            onChanged: (code) => ref.read(settingsProvider.notifier).setLocale(code),
                          ),
                        ),
                        SettingRow(
                          title: l10n.launchAtLogin,
                          subtitle: l10n.launchAtLoginDesc,
                          trailing: Switch(
                            value: launchAtLogin,
                            onChanged: (on) async {
                              try {
                                await channel.setLaunchAtLogin(on);
                              } catch (e) {
                                if (context.mounted) toast(l10n.couldNotChange('$e'));
                              }
                              ref.invalidate(_launchAtLoginProvider);
                            },
                          ),
                        ),
                      ],
                    ),
                    Section(
                      title: l10n.globalShortcut,
                      children: [
                        SettingRow(
                          title: l10n.toggleShortcutTitle,
                          subtitle: l10n.globalShortcutDesc,
                          below: Row(
                            children: [
                              Expanded(
                                child: KeyCaptureField(
                                  value: settings?.toggleHotkey,
                                  onChanged: (hotkey) async {
                                    if (hotkey.modifiers.isEmpty) return toast(l10n.shortcutNeedsModifier);
                                    final ok = await channel.setToggleHotkey(hotkey);
                                    if (!ok) {
                                      if (context.mounted) toast(l10n.shortcutInUse);
                                      return;
                                    }
                                    await ref.read(settingsProvider.notifier).setToggleHotkey(hotkey);
                                  },
                                ),
                              ),
                              if (settings?.toggleHotkey != null) ...[
                                const SizedBox(width: AppSpace.sm),
                                IconButton(
                                  tooltip: l10n.removeShortcut,
                                  onPressed: () => ref.read(settingsProvider.notifier).setToggleHotkey(null),
                                  icon: const Icon(Icons.close, size: 18),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    Section(
                      title: l10n.permissions,
                      children: [
                        SettingRow(
                          title: l10n.accessibility,
                          subtitle: l10n.accessibilityDesc,
                          trailing: _PermissionPill(permissions.accessibility),
                        ),
                        SettingRow(
                          title: l10n.inputMonitoring,
                          subtitle: l10n.inputMonitoringDesc,
                          trailing: _PermissionPill(permissions.inputMonitoring),
                          below: InputMonitoringHelp(status: permissions),
                        ),
                        SettingRow(
                          title: l10n.managePermissions,
                          trailing: OutlinedButton(
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingScreen())),
                            child: Text(l10n.open.toUpperCase()),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Text('PadPilot · Wanmind Innovation', style: TextStyle(fontSize: 11, color: p.muted)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionPill extends StatelessWidget {
  const _PermissionPill(this.state);

  final PermissionState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final (text, color) = switch (state) {
      PermissionState.granted => (l10n.allowed, p.success),
      PermissionState.denied => (l10n.permissionDenied, p.danger),
      PermissionState.unknown => (l10n.permissionUnknown, p.warning),
    };
    return Pill(label: text, dot: color, background: p.background);
  }
}
