import Foundation
import GameController
import IOKit.hid

/// Normalized input names shared by every controller source.
/// Buttons are 0/1, stick axes -1...1 (Y positive = up), triggers 0...1.
enum InputName {
  static let buttons = [
    "a", "b", "x", "y", "leftShoulder", "rightShoulder",
    "leftStickButton", "rightStickButton", "start", "select", "home",
  ]
  static let dpad = ["dpadUp", "dpadDown", "dpadLeft", "dpadRight"]
  static let triggers = ["leftTrigger", "rightTrigger"]
  static let sticks = ["left", "right"]

  static func stickX(_ stick: String) -> String { "\(stick)StickX" }
  static func stickY(_ stick: String) -> String { "\(stick)StickY" }
  static func trigger(_ trigger: String) -> String { "\(trigger)Trigger" }
  static func dpad(_ direction: String) -> String { "dpad" + direction.prefix(1).uppercased() + direction.dropFirst() }
}

struct ControllerInfo {
  let id: String
  let name: String
  let vendor: String
  let type: String

  var dictionary: [String: Any] { ["id": id, "name": name, "vendor": vendor, "type": type] }
}

/// Reads controllers through GameController and, as a fallback, generic HID
/// joysticks through IOHIDManager. All state lives on `queue`.
final class ControllerInput {
  var onConnect: ((ControllerInfo) -> Void)?
  var onDisconnect: ((String) -> Void)?
  var onState: ((String, [String: Float]) -> Void)?
  /// Raw HID axis counts, only while raw capture is on (diagnostics).
  var onRaw: ((RawHIDSnapshot) -> Void)?

  private let queue: DispatchQueue
  private var nextId = 1
  private var gameControllers: [ObjectIdentifier: (info: ControllerInfo, controller: GCController)] = [:]
  private var hidManager: IOHIDManager?
  private var hidDevices: [ObjectIdentifier: HIDDeviceState] = [:]
  /// Every matched HID gamepad, including ones GameController also handles,
  /// so diagnostics can show the sensor values before Apple's processing.
  private var rawDevices: [ObjectIdentifier: RawHIDSnapshot] = [:]
  private var rawCapture = false
  private var observers: [NSObjectProtocol] = []

  init(queue: DispatchQueue) {
    self.queue = queue
  }

  /// Must be called on queue.
  var controllers: [ControllerInfo] {
    gameControllers.values.map(\.info) + hidDevices.values.map(\.info)
  }

  func start() {
    // Keep receiving input while another app is in front.
    GCController.shouldMonitorBackgroundEvents = true

    let center = NotificationCenter.default
    observers.append(center.addObserver(forName: .GCControllerDidConnect, object: nil, queue: .main) { [weak self] note in
      guard let controller = note.object as? GCController else { return }
      self?.queue.async { self?.attach(controller) }
    })
    observers.append(center.addObserver(forName: .GCControllerDidDisconnect, object: nil, queue: .main) { [weak self] note in
      guard let controller = note.object as? GCController else { return }
      self?.queue.async { self?.detach(controller) }
    })
    let existing = GCController.controllers()
    queue.async { existing.forEach(self.attach) }
  }

  // MARK: GameController

  private func attach(_ controller: GCController) {
    let key = ObjectIdentifier(controller)
    guard gameControllers[key] == nil else { return }
    let id = makeId("gc")
    let info = ControllerInfo(
      id: id,
      name: controller.vendorName ?? controller.productCategory,
      vendor: controller.productCategory,
      type: "gameController"
    )
    controller.handlerQueue = queue
    if let pad = controller.extendedGamepad {
      pad.valueChangedHandler = { [weak self] pad, _ in
        self?.onState?(id, Self.snapshot(pad))
      }
    } else if let pad = controller.microGamepad {
      pad.valueChangedHandler = { [weak self] pad, _ in
        self?.onState?(id, Self.snapshot(pad))
      }
    }
    gameControllers[key] = (info, controller)
    onConnect?(info)
  }

  private func detach(_ controller: GCController) {
    guard let entry = gameControllers.removeValue(forKey: ObjectIdentifier(controller)) else { return }
    onDisconnect?(entry.info.id)
  }

  private static func snapshot(_ pad: GCExtendedGamepad) -> [String: Float] {
    [
      "a": pad.buttonA.value,
      "b": pad.buttonB.value,
      "x": pad.buttonX.value,
      "y": pad.buttonY.value,
      "leftShoulder": pad.leftShoulder.value,
      "rightShoulder": pad.rightShoulder.value,
      "leftStickButton": pad.leftThumbstickButton?.value ?? 0,
      "rightStickButton": pad.rightThumbstickButton?.value ?? 0,
      "start": pad.buttonMenu.value,
      "select": pad.buttonOptions?.value ?? 0,
      "home": pad.buttonHome?.value ?? 0,
      "dpadUp": pad.dpad.up.value,
      "dpadDown": pad.dpad.down.value,
      "dpadLeft": pad.dpad.left.value,
      "dpadRight": pad.dpad.right.value,
      "leftStickX": pad.leftThumbstick.xAxis.value,
      "leftStickY": pad.leftThumbstick.yAxis.value,
      "rightStickX": pad.rightThumbstick.xAxis.value,
      "rightStickY": pad.rightThumbstick.yAxis.value,
      "leftTrigger": pad.leftTrigger.value,
      "rightTrigger": pad.rightTrigger.value,
    ]
  }

  private static func snapshot(_ pad: GCMicroGamepad) -> [String: Float] {
    [
      "a": pad.buttonA.value,
      "x": pad.buttonX.value,
      "start": pad.buttonMenu.value,
      "dpadUp": pad.dpad.up.value,
      "dpadDown": pad.dpad.down.value,
      "dpadLeft": pad.dpad.left.value,
      "dpadRight": pad.dpad.right.value,
    ]
  }

  // MARK: IOHIDManager fallback

  /// Starts the generic HID reader. Requires the Input Monitoring permission.
  func startHID() {
    guard hidManager == nil else { return }
    let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    let usages = [kHIDUsage_GD_Joystick, kHIDUsage_GD_GamePad, kHIDUsage_GD_MultiAxisController]
    let matching = usages.map { [kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop, kIOHIDDeviceUsageKey: $0] }
    IOHIDManagerSetDeviceMatchingMultiple(manager, matching as CFArray)

    let context = Unmanaged.passUnretained(self).toOpaque()
    IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, device in
      guard let context else { return }
      Unmanaged<ControllerInput>.fromOpaque(context).takeUnretainedValue().hidAttached(device)
    }, context)
    IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, device in
      guard let context else { return }
      Unmanaged<ControllerInput>.fromOpaque(context).takeUnretainedValue().hidDetached(device)
    }, context)
    IOHIDManagerRegisterInputValueCallback(manager, { context, _, _, value in
      guard let context else { return }
      Unmanaged<ControllerInput>.fromOpaque(context).takeUnretainedValue().hidValue(value)
    }, context)

    IOHIDManagerSetDispatchQueue(manager, queue)
    IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    IOHIDManagerActivate(manager)
    hidManager = manager
  }

  /// Must be called on queue. Raw values only flow while this is on.
  func setRawCapture(_ enabled: Bool) {
    rawCapture = enabled
    if !enabled {
      for key in rawDevices.keys { rawDevices[key]?.axes = [:] }
    }
  }

  private func hidAttached(_ device: IOHIDDevice) {
    let key = ObjectIdentifier(device)
    let name = IOHIDDeviceGetProperty(device, kIOHIDProductKey as CFString) as? String ?? "Joystick HID"
    let vendor = IOHIDDeviceGetProperty(device, kIOHIDManufacturerKey as CFString) as? String ?? ""
    if rawDevices[key] == nil {
      rawDevices[key] = RawHIDSnapshot(id: makeId("raw"), name: name)
    }
    // GameController already handles this device; avoid duplicate input.
    if GCController.supportsHIDDevice(device) { return }
    guard hidDevices[key] == nil else { return }
    let info = ControllerInfo(id: makeId("hid"), name: name, vendor: vendor, type: "hid")
    hidDevices[key] = HIDDeviceState(info: info)
    onConnect?(info)
  }

  private func hidDetached(_ device: IOHIDDevice) {
    rawDevices[ObjectIdentifier(device)] = nil
    guard let state = hidDevices.removeValue(forKey: ObjectIdentifier(device)) else { return }
    onDisconnect?(state.info.id)
  }

  private func hidValue(_ value: IOHIDValue) {
    let element = IOHIDValueGetElement(value)
    let key = ObjectIdentifier(IOHIDElementGetDevice(element))
    let page = Int(IOHIDElementGetUsagePage(element))
    let usage = Int(IOHIDElementGetUsage(element))
    let raw = IOHIDValueGetIntegerValue(value)
    let min = IOHIDElementGetLogicalMin(element)
    let max = IOHIDElementGetLogicalMax(element)

    if rawCapture, page == kHIDPage_GenericDesktop, let name = RawHIDSnapshot.axisNames[usage], var snapshot = rawDevices[key] {
      snapshot.axes[name] = RawHIDSnapshot.Axis(value: raw, min: min, max: max)
      rawDevices[key] = snapshot
      onRaw?(snapshot)
    }

    guard var state = hidDevices[key] else { return }
    let unit = max > min ? Float(raw - min) / Float(max - min) : 0
    let axis = unit * 2 - 1

    switch page {
    case kHIDPage_Button:
      guard let name = HIDDeviceState.buttonNames[usage] else { return }
      state.values[name] = raw != 0 ? 1 : 0
    case kHIDPage_GenericDesktop:
      switch usage {
      case kHIDUsage_GD_X: state.values["leftStickX"] = axis
      case kHIDUsage_GD_Y: state.values["leftStickY"] = -axis
      case kHIDUsage_GD_Z: state.values["rightStickX"] = axis
      case kHIDUsage_GD_Rz: state.values["rightStickY"] = -axis
      case kHIDUsage_GD_Rx: state.values["leftTrigger"] = unit
      case kHIDUsage_GD_Ry: state.values["rightTrigger"] = unit
      case kHIDUsage_GD_Hatswitch: state.setHat(Int(raw - min))
      default: return
      }
    default:
      return
    }
    hidDevices[key] = state
    onState?(state.info.id, state.values)
  }

  private func makeId(_ prefix: String) -> String {
    defer { nextId += 1 }
    return "\(prefix)-\(nextId)"
  }
}

struct RawHIDSnapshot {
  struct Axis {
    let value: Int
    let min: Int
    let max: Int
  }

  static let axisNames: [Int: String] = [
    kHIDUsage_GD_X: "X", kHIDUsage_GD_Y: "Y", kHIDUsage_GD_Z: "Z",
    kHIDUsage_GD_Rx: "Rx", kHIDUsage_GD_Ry: "Ry", kHIDUsage_GD_Rz: "Rz",
    kHIDUsage_GD_Slider: "Slider", kHIDUsage_GD_Dial: "Dial", kHIDUsage_GD_Hatswitch: "Hat",
  ]

  let id: String
  let name: String
  var axes: [String: Axis] = [:]

  var dictionary: [String: Any] {
    [
      "id": id,
      "name": name,
      "axes": axes.mapValues { ["value": $0.value, "min": $0.min, "max": $0.max] },
    ]
  }
}

private struct HIDDeviceState {
  let info: ControllerInfo
  var values: [String: Float] = [:]

  /// Common DirectInput layout used by most generic pads.
  static let buttonNames: [Int: String] = [
    1: "x", 2: "a", 3: "b", 4: "y",
    5: "leftShoulder", 6: "rightShoulder",
    7: "leftTrigger", 8: "rightTrigger",
    9: "select", 10: "start",
    11: "leftStickButton", 12: "rightStickButton",
    13: "home",
  ]

  /// Hat switch: 0 = N, clockwise in 8 steps; anything else is neutral.
  mutating func setHat(_ position: Int) {
    let up: Set = [7, 0, 1], right: Set = [1, 2, 3], down: Set = [3, 4, 5], left: Set = [5, 6, 7]
    values["dpadUp"] = up.contains(position) ? 1 : 0
    values["dpadRight"] = right.contains(position) ? 1 : 0
    values["dpadDown"] = down.contains(position) ? 1 : 0
    values["dpadLeft"] = left.contains(position) ? 1 : 0
  }
}
