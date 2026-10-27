import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/joystick_channel.dart';
import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/controller_info.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/controller_artwork.dart';
import '../../widgets/hero_photo.dart';
import '../../widgets/mapping_toggle.dart';
import '../../widgets/page_header.dart';
import '../../widgets/pill.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../game_hub/hub_screen.dart';
import '../mapping_editor/device_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../onboarding/permissions_provider.dart';
import '../profiles/profiles_provider.dart';
import '../profiles/profiles_screen.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_screen.dart';
import 'controllers_provider.dart';

/// Landing page: greeting and connected controllers as large product shots.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static String greeting(DateTime now, AppLocalizations l10n) => switch (now.hour) {
    < 5 => l10n.greetingEvening,
    < 12 => l10n.greetingMorning,
    < 18 => l10n.greetingAfternoon,
    _ => l10n.greetingEvening,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controllers = ref.watch(controllersProvider);
    final permissions = ref.watch(permissionsProvider);
    final l10n = context.l10n;
    void push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(
            title: greeting(DateTime.now(), l10n),
            actions: [
              HeaderAction(label: l10n.howToConnect, icon: Icons.add, onPressed: () => _showConnectHelp(context)),
              const HeaderDivider(),
              HeaderAction(label: l10n.games, icon: Icons.grid_view_rounded, onPressed: () => push(const HubScreen())),
              const HeaderDivider(),
              HeaderAction(
                label: l10n.diagnosticsShort,
                icon: Icons.query_stats,
                onPressed: () => push(DiagnosticsScreen(controller: controllers.firstOrNull)),
              ),
              const HeaderDivider(),
              HeaderAction(
                label: l10n.profiles,
                icon: Icons.layers_outlined,
                onPressed: () => push(const ProfilesScreen()),
              ),
              const HeaderDivider(),
              const MappingToggle(),
              const HeaderDivider(),
              if (permissions.restartRequired)
                HeaderAction(
                  label: l10n.restartApp,
                  icon: Icons.restart_alt,
                  color: context.palette.warning,
                  onPressed: () => ref.read(joystickChannelProvider).relaunch(),
                ),
              if (!permissions.canInject && JoystickChannel.nativeEngineAvailable)
                HeaderIconButton(
                  icon: Icons.shield_outlined,
                  tooltip: l10n.permissionsPending,
                  badge: context.palette.warning,
                  onPressed: () => push(const OnboardingScreen()),
                ),
              HeaderIconButton(
                icon: Icons.settings_outlined,
                tooltip: l10n.settings,
                onPressed: () => push(const SettingsScreen()),
              ),
            ],
          ),
          if (!JoystickChannel.nativeEngineAvailable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.palette.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: context.palette.warning, size: 18),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.windowsPreview, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                child: Row(
                  children: [
                    if (controllers.isEmpty)
                      const _EmptyDeviceCard()
                    else
                      for (final c in controllers)
                        _DeviceCard(
                          controller: c,
                          onTap: () => push(DeviceScreen(controller: c)),
                        ),
                  ],
                ),
              ),
            ),
          ),
          const _ActiveProfileBar(),
        ],
      ),
    );
  }

  static void _showConnectHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final l10n = context.l10n;
        return AlertDialog(
          title: Text(l10n.connectTitle),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Tip(Icons.usb, l10n.tipUsbTitle, l10n.tipUsb),
                _Tip(Icons.bluetooth, l10n.tipBluetoothTitle, l10n.tipBluetooth),
                _Tip(Icons.info_outline, l10n.tipXbox360Title, l10n.tipXbox360),
                _Tip(Icons.info_outline, l10n.tipPs3Title, l10n.tipPs3),
                _Tip(Icons.info_outline, l10n.tipHidTitle, l10n.tipHid),
              ],
            ),
          ),
          actions: [FilledButton(onPressed: () => Navigator.pop(context), child: Text(l10n.gotIt.toUpperCase()))],
        );
      },
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.icon, this.title, this.text);

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.palette.muted),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$title\n',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: text,
                  style: TextStyle(color: context.palette.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _DeviceCard extends StatefulWidget {
  const _DeviceCard({required this.controller, required this.onTap});

  final ControllerInfo controller;
  final VoidCallback onTap;

  @override
  State<_DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<_DeviceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final l10n = context.l10n;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSlide(
                duration: const Duration(milliseconds: 180),
                offset: Offset(0, _hover ? -0.03 : 0),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  scale: _hover ? 1.03 : 1,
                  child: SizedBox(width: 320, child: ControllerArtwork(style: c.style)),
                ),
              ),
              const SizedBox(height: 20),
              Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pill(label: l10n.connected, dot: context.palette.success),
                  const SizedBox(width: 6),
                  Pill(
                    label: c.isGenericHid ? l10n.genericHid : (c.vendor.isEmpty ? l10n.controllerFallback : c.vendor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyDeviceCard extends StatelessWidget {
  const _EmptyDeviceCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: 820,
      height: 420,
      child: HeroPhoto(
        alignment: const Alignment(0, 0.2),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noController,
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(l10n.noControllerHint, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 20),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeviceScreen())),
                  child: Text(l10n.editAnyway.toUpperCase()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveProfileBar extends ConsumerWidget {
  const _ActiveProfileBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(profilesProvider).value ?? const [];
    final active = ref.watch(activeProfileProvider);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Center(
        child: PopupMenuButton<String>(
          tooltip: l10n.switchActiveProfile,
          position: PopupMenuPosition.over,
          onSelected: (id) => ref.read(settingsProvider.notifier).setActiveProfile(id),
          itemBuilder: (_) => [
            for (final p in profiles)
              CheckedPopupMenuItem(value: p.id, checked: p.id == active?.id, child: Text(p.name)),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: context.palette.surface, borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.layers_outlined, size: 16, color: context.palette.muted),
                const SizedBox(width: 8),
                Text('${l10n.profileInUse} ', style: TextStyle(fontSize: 12, color: context.palette.muted)),
                Text(active?.name ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const Icon(Icons.expand_more, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
