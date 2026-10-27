import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../models/controller_info.dart';
import '../../models/output_action.dart';
import '../../models/permissions_status.dart';
import '../../models/profile.dart';
import 'joystick_events.dart';

class CapturedKey {
  const CapturedKey({required this.keyCode, required this.modifiers, required this.label});

  final int keyCode;
  final List<KeyModifier> modifiers;
  final String label;
}

enum PermissionType { accessibility, inputMonitoring }

/// Typed wrapper over the native PadPilot plugin.
///
/// The native engine exists only on macOS for now. Elsewhere every call
/// resolves to its empty result, so the UI runs as a preview.
class JoystickChannel {
  static const _methods = _TolerantChannel(MethodChannel('wanmind/padpilot'));
  static const _events = EventChannel('wanmind/padpilot/events');

  /// Whether controller input and event injection work on this platform.
  static bool get nativeEngineAvailable => Platform.isMacOS;

  late final Stream<JoystickEvent> events = nativeEngineAvailable
      ? _events.receiveBroadcastStream().map(JoystickEvent.parse).where((e) => e != null).cast<JoystickEvent>()
      : const Stream<JoystickEvent>.empty();

  Future<List<ControllerInfo>> getControllers() async {
    final list = await _methods.invokeListMethod<Map<Object?, Object?>>('getControllers') ?? const [];
    return [for (final map in list) ControllerInfo.fromMap(map)];
  }

  Future<void> setActiveProfile(Profile profile) =>
      _methods.invokeMethod('setActiveProfile', jsonEncode(profile.toJson()));

  Future<void> setMappingEnabled(bool enabled) => _methods.invokeMethod('setMappingEnabled', enabled);

  Future<void> startCapture() => _methods.invokeMethod('startCapture');

  Future<void> stopCapture() => _methods.invokeMethod('stopCapture');

  Future<void> setLiveInput(bool enabled) => _methods.invokeMethod('setLiveInput', enabled);

  /// Streams [DiagnosticSample] and [RawHidSnapshot] events while on.
  Future<void> setDiagnostics(bool enabled) => _methods.invokeMethod('setDiagnostics', enabled);

  Future<PermissionsStatus> getPermissions() async {
    final map = await _methods.invokeMapMethod<Object?, Object?>('getPermissions');
    return map == null ? const PermissionsStatus.unknown() : PermissionsStatus.fromMap(map);
  }

  Future<void> requestPermission(PermissionType type) => _methods.invokeMethod('requestPermission', type.name);

  Future<void> openPermissionSettings(PermissionType type) =>
      _methods.invokeMethod('openPermissionSettings', type.name);

  /// Waits for the next key pressed in the app window. Null if cancelled.
  Future<CapturedKey?> captureKey() async {
    final map = await _methods.invokeMapMethod<String, Object?>('captureKey');
    if (map == null) return null;
    return CapturedKey(
      keyCode: map['keyCode'] as int,
      modifiers: [for (final m in map['modifiers'] as List) KeyModifier.values.byName(m as String)],
      label: map['label'] as String,
    );
  }

  Future<void> cancelKeyCapture() => _methods.invokeMethod('cancelKeyCapture');

  /// Key code → display name for the active keyboard layout.
  Future<Map<int, String>> getKeyLabels() async {
    final map = await _methods.invokeMapMethod<String, String>('getKeyLabels') ?? const {};
    return {for (final e in map.entries) int.parse(e.key): e.value};
  }

  /// Registers the global on/off shortcut; null clears it. Returns false if
  /// the shortcut is taken by the system or another app.
  Future<bool> setToggleHotkey(KeyAction? hotkey) async {
    final ok = await _methods.invokeMethod<bool>(
      'setToggleHotkey',
      hotkey == null
          ? null
          : {
              'keyCode': hotkey.keyCode,
              'modifiers': [for (final m in hotkey.modifiers) m.name],
            },
    );
    return ok ?? false;
  }

  Future<bool> getLaunchAtLogin() async => await _methods.invokeMethod<bool>('getLaunchAtLogin') ?? false;

  Future<void> setLaunchAtLogin(bool enabled) => _methods.invokeMethod('setLaunchAtLogin', enabled);

  Future<FrontApp?> getFrontmostApp() async {
    final map = await _methods.invokeMapMethod<Object?, Object?>('getFrontmostApp');
    return map == null ? null : FrontApp.fromMap(map);
  }

  Future<bool> openUrl(String url) async {
    if (Platform.isWindows) {
      // Lets Windows pick the handler (browser, or Steam for steam:// links).
      final result = await Process.run('rundll32', ['url.dll,FileProtocolHandler', url]);
      return result.exitCode == 0;
    }
    return await _methods.invokeMethod<bool>('openUrl', url) ?? false;
  }

  /// Reads a secret from the macOS Keychain.
  Future<String?> getSecret(String account) => _methods.invokeMethod<String>('getSecret', account);

  /// Writes a secret to the Keychain; null deletes it.
  Future<bool> setSecret(String account, String? value) async =>
      await _methods.invokeMethod<bool>('setSecret', {'account': account, 'value': value}) ?? false;

  /// Quits and reopens the app (needed after granting Input Monitoring).
  Future<void> relaunch() => _methods.invokeMethod('relaunch');

  /// Selects the app bundle in Finder, for adding it to a privacy list by hand.
  Future<void> revealApp() => _methods.invokeMethod('revealApp');

  Future<void> setDockIconVisible(bool visible) => _methods.invokeMethod('setDockIconVisible', visible);
}

/// Method channel whose calls resolve to null when no native handler is
/// registered on this platform, instead of throwing.
class _TolerantChannel {
  const _TolerantChannel(this._channel);

  final MethodChannel _channel;

  Future<T?> _guard<T>(Future<T?> Function() call) async {
    try {
      return await call();
    } on MissingPluginException {
      return null;
    }
  }

  Future<T?> invokeMethod<T>(String method, [Object? arguments]) =>
      _guard(() => _channel.invokeMethod<T>(method, arguments));

  Future<Map<K, V>?> invokeMapMethod<K, V>(String method, [Object? arguments]) =>
      _guard(() => _channel.invokeMapMethod<K, V>(method, arguments));

  Future<List<T>?> invokeListMethod<T>(String method, [Object? arguments]) =>
      _guard(() => _channel.invokeListMethod<T>(method, arguments));
}
