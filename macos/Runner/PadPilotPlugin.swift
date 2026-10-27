import Cocoa
import FlutterMacOS
import ServiceManagement

/// Bridge between Dart and the native mapping stack.
/// MethodChannel `wanmind/padpilot`, EventChannel `wanmind/padpilot/events`.
final class PadPilotPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static var instance: PadPilotPlugin?

  private let queue = DispatchQueue(label: "br.com.wanmind.padpilot.engine", qos: .userInteractive)
  private lazy var input = ControllerInput(queue: queue)
  private lazy var engine = MappingEngine(queue: queue)
  private let permissions = PermissionManager()
  private let hotkey = HotkeyManager()

  private var sink: FlutterEventSink?
  private var mappingEnabled = false

  // Engine-queue state for the live input viewer.
  private var liveInput = false
  private var pendingLive: [String: [String: Float]] = [:]
  private var liveFlushScheduled = false

  // Engine-queue state for the stick diagnostics screen.
  private var diagnostics = false
  private var lastDiagnosticSample: [String: UInt64] = [:]
  private var pendingRaw: [String: RawHIDSnapshot] = [:]
  private var rawFlushScheduled = false

  // Main-thread state for keyboard capture.
  private var keyMonitor: Any?
  private var keyResult: FlutterResult?
  private var pendingModifier: UInt16?

  static func register(with registrar: FlutterPluginRegistrar) {
    let plugin = PadPilotPlugin()
    let channel = FlutterMethodChannel(name: "wanmind/padpilot", binaryMessenger: registrar.messenger)
    registrar.addMethodCallDelegate(plugin, channel: channel)
    FlutterEventChannel(name: "wanmind/padpilot/events", binaryMessenger: registrar.messenger)
      .setStreamHandler(plugin)
    plugin.start()
    instance = plugin
  }

  private func start() {
    input.onConnect = { [weak self] info in self?.emit("controllerConnected", info.dictionary) }
    input.onDisconnect = { [weak self] id in
      self?.engine.removeController(id)
      self?.pendingLive[id] = nil
      self?.emit("controllerDisconnected", ["id": id])
    }
    input.onState = { [weak self] id, values in
      self?.engine.update(controller: id, values: values)
      self?.forwardLive(id, values)
      self?.forwardDiagnostic(id, values)
    }
    input.onRaw = { [weak self] snapshot in self?.forwardRaw(snapshot) }
    engine.onCapture = { [weak self] payload in self?.emit("inputCaptured", payload) }

    permissions.onChange = { [weak self] status in
      guard let self else { return }
      self.emit("permissionChanged", status)
      if status["inputMonitoring"] == "granted" { self.queue.async { self.input.startHID() } }
    }
    permissions.startMonitoring()

    hotkey.onFire = { [weak self] in
      guard let self else { return }
      self.setMappingEnabled(!self.mappingEnabled)
      self.emit("mappingToggled", ["enabled": self.mappingEnabled])
    }

    // Report which app is in front so Dart can auto-switch game profiles.
    NSWorkspace.shared.notificationCenter.addObserver(
      forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
    ) { [weak self] note in
      guard let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication else { return }
      self?.emit("appActivated", Self.describe(app))
    }

    input.start()
    if permissions.inputMonitoring == "granted" { queue.async { self.input.startHID() } }
  }

  // MARK: FlutterStreamHandler

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    sink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    sink = nil
    return nil
  }

  private func emit(_ type: String, _ data: [String: Any]) {
    DispatchQueue.main.async { self.sink?(["type": type, "data": data]) }
  }

  /// Called on the engine queue; throttles state to ~30 fps for the UI.
  private func forwardLive(_ id: String, _ values: [String: Float]) {
    guard liveInput else { return }
    pendingLive[id] = values
    guard !liveFlushScheduled else { return }
    liveFlushScheduled = true
    queue.asyncAfter(deadline: .now() + 1.0 / 30) { [weak self] in
      guard let self else { return }
      self.liveFlushScheduled = false
      let pending = self.pendingLive
      self.pendingLive = [:]
      for (id, values) in pending {
        self.emit("inputState", ["controllerId": id, "values": values.mapValues(Double.init)])
      }
    }
  }

  /// Called on the engine queue. Near-unthrottled (≤250 Hz) so the stick
  /// plot and statistics see every change the controller reports.
  private func forwardDiagnostic(_ id: String, _ values: [String: Float]) {
    guard diagnostics else { return }
    let now = DispatchTime.now().uptimeNanoseconds
    if let last = lastDiagnosticSample[id], now - last < 4_000_000 { return }
    lastDiagnosticSample[id] = now
    emit("diagnosticSample", [
      "controllerId": id,
      "time": Double(now) / 1_000_000_000,
      "values": values.mapValues(Double.init),
    ])
  }

  /// Called on the engine queue; raw HID counts throttled to ~60 fps.
  private func forwardRaw(_ snapshot: RawHIDSnapshot) {
    pendingRaw[snapshot.id] = snapshot
    guard !rawFlushScheduled else { return }
    rawFlushScheduled = true
    queue.asyncAfter(deadline: .now() + 1.0 / 60) { [weak self] in
      guard let self else { return }
      self.rawFlushScheduled = false
      let pending = self.pendingRaw
      self.pendingRaw = [:]
      for snapshot in pending.values { self.emit("rawHid", snapshot.dictionary) }
    }
  }

  // MARK: MethodChannel

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getControllers":
      queue.async {
        let list = self.input.controllers.map(\.dictionary)
        DispatchQueue.main.async { result(list) }
      }

    case "setActiveProfile":
      guard let json = call.arguments as? String else { return result(badArgs(call)) }
      do {
        let rules = try ProfileParser.parse(json)
        queue.async { self.engine.setRules(rules) }
        result(rules.count)
      } catch {
        result(FlutterError(code: "invalid_profile", message: "\(error)", details: nil))
      }

    case "setMappingEnabled":
      guard let enabled = call.arguments as? Bool else { return result(badArgs(call)) }
      setMappingEnabled(enabled)
      result(nil)

    case "startCapture":
      queue.async { self.engine.setCapturing(true) }
      result(nil)

    case "stopCapture":
      queue.async { self.engine.setCapturing(false) }
      result(nil)

    case "setLiveInput":
      guard let enabled = call.arguments as? Bool else { return result(badArgs(call)) }
      queue.async { self.liveInput = enabled }
      result(nil)

    case "setDiagnostics":
      guard let enabled = call.arguments as? Bool else { return result(badArgs(call)) }
      queue.async {
        self.diagnostics = enabled
        self.lastDiagnosticSample = [:]
        self.input.setRawCapture(enabled)
      }
      result(nil)

    case "getPermissions":
      result(permissions.status)

    case "requestPermission":
      guard let type = call.arguments as? String else { return result(badArgs(call)) }
      permissions.request(type)
      result(nil)

    case "openPermissionSettings":
      guard let type = call.arguments as? String else { return result(badArgs(call)) }
      permissions.openSettings(type)
      result(nil)

    case "captureKey":
      captureKey(result)

    case "cancelKeyCapture":
      finishKeyCapture(nil)
      result(nil)

    case "getKeyLabels":
      result(Dictionary(uniqueKeysWithValues: KeyCodeMap.allLabels().map { (String($0.key), $0.value) }))

    case "setToggleHotkey":
      if let args = call.arguments as? [String: Any], let keyCode = args["keyCode"] as? Int {
        result(hotkey.register(keyCode: keyCode, modifiers: args["modifiers"] as? [String] ?? []))
      } else {
        hotkey.unregister()
        result(true)
      }

    case "getLaunchAtLogin":
      result(SMAppService.mainApp.status == .enabled)

    case "setLaunchAtLogin":
      guard let enabled = call.arguments as? Bool else { return result(badArgs(call)) }
      do {
        if enabled { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
        result(nil)
      } catch {
        result(FlutterError(code: "login_item", message: error.localizedDescription, details: nil))
      }

    case "relaunch":
      result(nil)
      DispatchQueue.main.async { self.permissions.relaunch() }

    case "revealApp":
      permissions.revealApp()
      result(nil)

    case "getFrontmostApp":
      result(NSWorkspace.shared.frontmostApplication.map(Self.describe))

    case "openUrl":
      guard let string = call.arguments as? String, let url = URL(string: string) else { return result(badArgs(call)) }
      result(NSWorkspace.shared.open(url))

    case "getSecret":
      guard let account = call.arguments as? String else { return result(badArgs(call)) }
      result(Keychain.get(account))

    case "setSecret":
      guard let args = call.arguments as? [String: Any], let account = args["account"] as? String else {
        return result(badArgs(call))
      }
      result(Keychain.set(account, args["value"] as? String))

    case "setDockIconVisible":
      guard let visible = call.arguments as? Bool else { return result(badArgs(call)) }
      NSApp.setActivationPolicy(visible ? .regular : .accessory)
      if visible { NSApp.activate(ignoringOtherApps: true) }
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private static func describe(_ app: NSRunningApplication) -> [String: Any] {
    [
      "name": app.localizedName ?? "",
      "bundleId": app.bundleIdentifier ?? "",
      "path": app.bundleURL?.path ?? "",
      "executable": app.executableURL?.path ?? "",
      "pid": Int(app.processIdentifier),
    ]
  }

  private func setMappingEnabled(_ enabled: Bool) {
    mappingEnabled = enabled
    queue.async { self.engine.setEnabled(enabled) }
  }

  private func badArgs(_ call: FlutterMethodCall) -> FlutterError {
    FlutterError(code: "bad_args", message: "Invalid arguments for \(call.method)", details: nil)
  }

  // MARK: Keyboard capture

  /// Waits for the next key (with modifiers) pressed in the app window.
  /// A modifier pressed and released alone is captured as the key itself.
  private func captureKey(_ result: @escaping FlutterResult) {
    finishKeyCapture(nil)
    keyResult = result
    keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
      guard let self else { return event }
      if event.type == .keyDown {
        self.finishKeyCapture(event.keyCode, modifiers: Self.modifierNames(event.modifierFlags))
      } else if let flag = EventInjector.modifierFlags[event.keyCode] {
        let isDown = CGEventFlags(rawValue: UInt64(event.modifierFlags.rawValue)).contains(flag)
        if isDown {
          self.pendingModifier = event.keyCode
        } else if self.pendingModifier == event.keyCode {
          self.finishKeyCapture(event.keyCode, modifiers: [])
        }
      }
      return nil
    }
  }

  private func finishKeyCapture(_ keyCode: UInt16?, modifiers: [String] = []) {
    if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
    keyMonitor = nil
    pendingModifier = nil
    guard let result = keyResult else { return }
    keyResult = nil
    guard let keyCode else { return result(nil) }
    result([
      "keyCode": Int(keyCode),
      "modifiers": modifiers,
      "label": KeyCodeMap.label(for: Int(keyCode)) ?? "Key \(keyCode)",
    ])
  }

  private static func modifierNames(_ flags: NSEvent.ModifierFlags) -> [String] {
    var names: [String] = []
    if flags.contains(.control) { names.append("control") }
    if flags.contains(.option) { names.append("option") }
    if flags.contains(.shift) { names.append("shift") }
    if flags.contains(.command) { names.append("command") }
    return names
  }
}
