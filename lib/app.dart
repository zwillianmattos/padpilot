import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/engine_sync.dart';
import 'core/platform/joystick_channel.dart';
import 'features/controllers/home_screen.dart';
import 'features/menu_bar/tray_service.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_provider.dart';
import 'l10n/l10n.dart';
import 'widgets/app_theme.dart';

class PadPilotApp extends ConsumerWidget {
  const PadPilotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(engineSyncProvider);
    ref.watch(trayServiceProvider);
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'PadPilot',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      locale: resolveLocale(settings.value?.localeCode),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: settings.when(
        loading: () => const Scaffold(),
        error: (_, _) => const HomeScreen(),
        // Permissions onboarding only applies where the native engine runs.
        data: (s) => s.onboardingDone || !JoystickChannel.nativeEngineAvailable
            ? const HomeScreen()
            : const OnboardingScreen(firstRun: true),
      ),
    );
  }
}
