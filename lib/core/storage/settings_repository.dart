import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/output_action.dart';

class AppSettings {
  const AppSettings({
    this.activeProfileId,
    this.mappingEnabled = true,
    this.toggleHotkey,
    this.onboardingDone = false,
    this.samplesSeeded = false,
    this.localeCode,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    activeProfileId: json['activeProfileId'] as String?,
    mappingEnabled: json['mappingEnabled'] as bool? ?? true,
    toggleHotkey: json['toggleHotkey'] == null
        ? null
        : OutputAction.fromJson((json['toggleHotkey'] as Map).cast<String, dynamic>()) as KeyAction,
    onboardingDone: json['onboardingDone'] as bool? ?? false,
    samplesSeeded: json['samplesSeeded'] as bool? ?? false,
    localeCode: json['localeCode'] as String?,
  );

  final String? activeProfileId;
  final bool mappingEnabled;

  /// Global shortcut that toggles mapping on/off.
  final KeyAction? toggleHotkey;
  final bool onboardingDone;
  final bool samplesSeeded;

  /// `en`, `pt` or `es`; null follows the system language.
  final String? localeCode;

  Map<String, dynamic> toJson() => {
    'activeProfileId': activeProfileId,
    'mappingEnabled': mappingEnabled,
    'toggleHotkey': toggleHotkey?.toJson(),
    'onboardingDone': onboardingDone,
    'samplesSeeded': samplesSeeded,
    'localeCode': localeCode,
  };

  AppSettings copyWith({
    String? activeProfileId,
    bool? mappingEnabled,
    KeyAction? Function()? toggleHotkey,
    bool? onboardingDone,
    bool? samplesSeeded,
    String? Function()? localeCode,
  }) => AppSettings(
    activeProfileId: activeProfileId ?? this.activeProfileId,
    mappingEnabled: mappingEnabled ?? this.mappingEnabled,
    toggleHotkey: toggleHotkey != null ? toggleHotkey() : this.toggleHotkey,
    onboardingDone: onboardingDone ?? this.onboardingDone,
    samplesSeeded: samplesSeeded ?? this.samplesSeeded,
    localeCode: localeCode != null ? localeCode() : this.localeCode,
  );
}

class SettingsRepository {
  Future<File> get _file async => File('${(await getApplicationSupportDirectory()).path}/settings.json');

  Future<AppSettings> load() async {
    final file = await _file;
    if (!await file.exists()) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(await file.readAsString()) as Map<String, dynamic>);
    } on FormatException {
      return const AppSettings();
    }
  }

  Future<void> save(AppSettings settings) async {
    final file = await _file;
    await file.parent.create(recursive: true);
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(settings.toJson()));
  }
}
