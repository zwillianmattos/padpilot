/// Which artwork and button labels to use for a controller.
enum ControllerStyle { xbox, playstation }

class ControllerInfo {
  const ControllerInfo({required this.id, required this.name, required this.vendor, required this.type});

  factory ControllerInfo.fromMap(Map<Object?, Object?> map) => ControllerInfo(
    id: map['id'] as String,
    name: map['name'] as String? ?? 'Controle',
    vendor: map['vendor'] as String? ?? '',
    type: map['type'] as String? ?? 'gameController',
  );

  final String id;
  final String name;

  /// GameController product category (e.g. "DualSense") or HID manufacturer.
  final String vendor;

  /// `gameController` or `hid`.
  final String type;

  bool get isGenericHid => type == 'hid';

  ControllerStyle get style {
    final text = '$name $vendor'.toLowerCase();
    const playstation = ['dualsense', 'dualshock', 'playstation', 'ps4', 'ps5', 'ps3', 'sony'];
    return playstation.any(text.contains) ? ControllerStyle.playstation : ControllerStyle.xbox;
  }
}
