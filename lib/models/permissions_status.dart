enum PermissionState { granted, denied, unknown }

class PermissionsStatus {
  const PermissionsStatus({required this.accessibility, required this.inputMonitoring, this.restartRequired = false});

  const PermissionsStatus.unknown()
    : accessibility = PermissionState.unknown,
      inputMonitoring = PermissionState.unknown,
      restartRequired = false;

  factory PermissionsStatus.fromMap(Map<Object?, Object?> map) => PermissionsStatus(
    accessibility: _parse(map['accessibility']),
    inputMonitoring: _parse(map['inputMonitoring']),
    restartRequired: map['restartRequired'] == 'true',
  );

  final PermissionState accessibility;
  final PermissionState inputMonitoring;

  /// Input Monitoring was granted while running; it applies after a relaunch.
  final bool restartRequired;

  /// Accessibility is required; Input Monitoring only matters for generic HID pads.
  bool get canInject => accessibility == PermissionState.granted;

  bool get allGranted => canInject && inputMonitoring == PermissionState.granted;

  static PermissionState _parse(Object? value) =>
      PermissionState.values.asNameMap()[value as String? ?? ''] ?? PermissionState.unknown;
}
