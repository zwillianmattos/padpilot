import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/providers.dart';
import '../../l10n/l10n.dart';
import '../../models/profile.dart';
import '../profiles/profiles_provider.dart';
import '../settings/settings_provider.dart';

/// Menu bar icon: toggle mapping, switch profile, open the window, quit.
/// Closing the window only hides it so mapping keeps running here.
class TrayService with TrayListener, WindowListener {
  TrayService(this._ref);

  final Ref _ref;

  Future<void> start() async {
    // macOS wants a monochrome template image; Windows needs an .ico.
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/tray/tray_icon.ico' : 'assets/tray/tray_icon.png',
      isTemplate: Platform.isMacOS,
    );
    await trayManager.setToolTip('PadPilot');
    trayManager.addListener(this);
    windowManager.addListener(this);
    await windowManager.setPreventClose(true);

    _ref.listen(settingsProvider, (_, _) => _rebuildMenu());
    _ref.listen(profilesProvider, (_, _) => _rebuildMenu());
    await _rebuildMenu();
  }

  Future<void> _rebuildMenu() async {
    final settings = _ref.read(settingsProvider).value;
    final l10n = l10nFor(settings?.localeCode);
    final enabled = settings?.mappingEnabled ?? false;
    final profiles = _ref.read(profilesProvider).value ?? const <Profile>[];
    final active = _ref.read(activeProfileProvider);
    await trayManager.setContextMenu(
      Menu(
        items: [
          MenuItem.checkbox(
            label: l10n.trayMappingActive,
            checked: enabled,
            onClick: (_) => _ref.read(settingsProvider.notifier).toggleMapping(),
          ),
          MenuItem.separator(),
          MenuItem.submenu(
            label: l10n.trayProfile(active?.name ?? '—'),
            submenu: Menu(
              items: [
                for (final p in profiles)
                  MenuItem.checkbox(
                    label: p.name,
                    checked: p.id == active?.id,
                    onClick: (_) => _ref.read(settingsProvider.notifier).setActiveProfile(p.id),
                  ),
              ],
            ),
          ),
          MenuItem.separator(),
          MenuItem(label: l10n.trayOpen, onClick: (_) => showWindow()),
          MenuItem(label: l10n.trayQuit, onClick: (_) => _quit()),
        ],
      ),
    );
  }

  Future<void> showWindow() async {
    await _ref.read(joystickChannelProvider).setDockIconVisible(true);
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _quit() async {
    await windowManager.setPreventClose(false);
    await SystemNavigator.pop();
  }

  @override
  void onTrayIconMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  Future<void> onWindowClose() async {
    await windowManager.hide();
    await _ref.read(joystickChannelProvider).setDockIconVisible(false);
  }
}

final trayServiceProvider = Provider((ref) {
  final service = TrayService(ref);
  service.start();
  return service;
});
