import 'dart:ui';

import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Locale for a stored language code (null = follow the system), falling
/// back to English when the language isn't supported.
Locale resolveLocale(String? code) {
  final wanted = code ?? PlatformDispatcher.instance.locale.languageCode;
  final supported = AppLocalizations.supportedLocales.map((l) => l.languageCode);
  return Locale(supported.contains(wanted) ? wanted : 'en');
}

/// Strings for code outside the widget tree (menu bar, sample profiles).
AppLocalizations l10nFor(String? code) => lookupAppLocalizations(resolveLocale(code));
