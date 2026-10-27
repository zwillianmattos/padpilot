import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final options = WindowOptions(
    size: const Size(1240, 800),
    minimumSize: const Size(1000, 680),
    center: true,
    title: 'PadPilot',
    // Content runs under the traffic lights on macOS; Windows keeps its caption buttons.
    titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
    // Match the system appearance so the window doesn't flash white in dark mode.
    backgroundColor: PlatformDispatcher.instance.platformBrightness == Brightness.dark
        ? const Color(0xFF131316)
        : Colors.white,
  );
  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: PadPilotApp()));
}
