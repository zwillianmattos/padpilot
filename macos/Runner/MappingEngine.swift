import CoreGraphics
import Foundation

enum ResponseCurve: String {
  case linear, quadratic, exponential

  func apply(_ x: Double) -> Double {
    switch self {
    case .linear: return x
    case .quadratic: return x * x
    case .exponential: return (exp(3 * x) - 1) / (exp(3) - 1)
    }
  }
}

struct DirectionalSpeed {
  var up: Double, down: Double, left: Double, right: Double
}

enum InputSpec {
  case button(String)
  case dpad(String)
  case stickDirection(stick: String, direction: String, threshold: Float)
  case stickAxis(stick: String)
  case trigger(String, threshold: Float)

  var isAnalog: Bool {
    if case .stickAxis = self { return true }
    return false
  }
}

enum ActionSpec {
  case key(code: CGKeyCode, modifiers: [CGKeyCode])
  case mouseMove(speed: DirectionalSpeed, deadzone: Double, curve: ResponseCurve)
  case mouseClick(MouseButton)
  /// Positive vertical = up, positive horizontal = right.
  case scroll(horizontal: Bool, amount: Double)

  var isContinuous: Bool {
    switch self {
    case .mouseMove, .scroll: return true
    default: return false
    }
  }
}

struct MappingRule {
  let input: InputSpec
  let action: ActionSpec
}

struct ProfileError: Error, CustomStringConvertible {
  let description: String
}

/// Parses the profile JSON contract shared with Dart. Mappings that can't be
/// parsed are skipped so one bad entry doesn't disable a whole profile.
enum ProfileParser {
  static let modifierKeyCodes: [String: CGKeyCode] = ["command": 55, "shift": 56, "option": 58, "control": 59]

  static func parse(_ json: String) throws -> [MappingRule] {
    guard
      let data = json.data(using: .utf8),
      let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
      let mappings = root["mappings"] as? [[String: Any]]
    else { throw ProfileError(description: "Invalid profile") }

    return mappings.compactMap { mapping in
      guard
        let input = (mapping["input"] as? [String: Any]).flatMap(parseInput),
        let action = (mapping["action"] as? [String: Any]).flatMap(parseAction)
      else { return nil }
      // A whole stick only makes sense for continuous actions.
      if input.isAnalog && !action.isContinuous { return nil }
      return MappingRule(input: input, action: action)
    }
  }

  private static func parseInput(_ json: [String: Any]) -> InputSpec? {
    let threshold = Float(json["threshold"] as? Double ?? 0.5)
    switch json["type"] as? String {
    case "button": return (json["button"] as? String).map(InputSpec.button)
    case "dpad": return (json["direction"] as? String).map(InputSpec.dpad)
    case "stickDirection":
      guard let stick = json["stick"] as? String, let direction = json["direction"] as? String else { return nil }
      return .stickDirection(stick: stick, direction: direction, threshold: threshold)
    case "stickAxis": return (json["stick"] as? String).map { .stickAxis(stick: $0) }
    case "trigger": return (json["trigger"] as? String).map { .trigger($0, threshold: threshold) }
    default: return nil
    }
  }

  private static func parseAction(_ json: [String: Any]) -> ActionSpec? {
    switch json["type"] as? String {
    case "key":
      guard let code = json["keyCode"] as? Int else { return nil }
      let modifiers = (json["modifiers"] as? [String] ?? []).compactMap { modifierKeyCodes[$0] }
      return .key(code: CGKeyCode(code), modifiers: modifiers)
    case "mouseMove":
      let speed = json["speed"] as? [String: Double] ?? [:]
      return .mouseMove(
        speed: DirectionalSpeed(
          up: speed["up"] ?? 10, down: speed["down"] ?? 10,
          left: speed["left"] ?? 10, right: speed["right"] ?? 10
        ),
        deadzone: min(max(json["deadzone"] as? Double ?? 0.15, 0), 0.95),
        curve: ResponseCurve(rawValue: json["curve"] as? String ?? "") ?? .quadratic
      )
    case "mouseClick":
      return MouseButton(rawValue: json["button"] as? String ?? "left").map(ActionSpec.mouseClick)
    case "scroll":
      return .scroll(horizontal: json["axis"] as? String == "horizontal", amount: json["amount"] as? Double ?? 3)
    default:
      return nil
    }
  }
}

/// Applies the active profile to normalized controller state. Runs entirely
/// on the engine queue so input never round-trips through Dart.
final class MappingEngine {
  var onCapture: (([String: Any]) -> Void)?

  private let injector = EventInjector()
  private let loop: MouseMotionLoop
  private var rules: [MappingRule] = []
  private var enabled = false
  private var capturing = false
  private var states: [String: [String: Float]] = [:]
  /// Digital rules currently held, keyed "controllerId|ruleIndex".
  private var active: Set<String> = []
  private var captureLatch: [String: Set<String>] = [:]
  private var scrollRepeats: [String: Double] = [:]
  private var moveRemainder = CGPoint.zero
  private var scrollRemainder = CGPoint.zero

  private static let scrollRepeatDelay = 0.35
  private static let scrollRepeatInterval = 0.1
  private static let stickScrollPixels = 2.0
  private static let stickScrollDeadzone = 0.2

  init(queue: DispatchQueue) {
    loop = MouseMotionLoop(queue: queue)
    loop.onTick = { [weak self] dt in self?.tick(dt) }
  }

  func setRules(_ rules: [MappingRule]) {
    releaseAll()
    self.rules = rules
    updateLoop()
  }

  func setEnabled(_ enabled: Bool) {
    if !enabled { releaseAll() }
    self.enabled = enabled
    updateLoop()
  }

  func setCapturing(_ capturing: Bool) {
    if capturing { releaseAll() }
    self.capturing = capturing
    // Inputs already held when capture starts are not reported.
    captureLatch = states.mapValues(Self.activeCaptureInputs).mapValues { Set($0.map(\.id)) }
    updateLoop()
  }

  func update(controller id: String, values: [String: Float]) {
    states[id] = values
    if capturing {
      detectCapture(controller: id, values: values)
      return
    }
    guard enabled else { return }
    for (index, rule) in rules.enumerated() where !rule.input.isAnalog {
      let key = "\(id)|\(index)"
      let wasOn = active.contains(key)
      let isOn = Self.isPressed(rule.input, values: values, wasPressed: wasOn)
      guard isOn != wasOn else { continue }
      if isOn {
        active.insert(key)
        press(rule.action, key: key)
      } else {
        active.remove(key)
        release(rule.action, key: key)
      }
    }
  }

  func removeController(_ id: String) {
    states[id] = nil
    captureLatch[id] = nil
    for key in active where key.hasPrefix("\(id)|") {
      active.remove(key)
      if let index = Int(key.split(separator: "|")[1]), index < rules.count {
        release(rules[index].action, key: key)
      }
    }
  }

  // MARK: Digital actions

  private func press(_ action: ActionSpec, key: String) {
    switch action {
    case let .key(code, modifiers): injector.pressKey(code, modifiers: modifiers)
    case let .mouseClick(button): injector.mouseDown(button)
    case let .scroll(horizontal, amount):
      scrollLines(horizontal: horizontal, amount: amount)
      scrollRepeats[key] = Self.scrollRepeatDelay
    case .mouseMove: break // handled by tick
    }
  }

  private func release(_ action: ActionSpec, key: String) {
    switch action {
    case let .key(code, modifiers): injector.releaseKey(code, modifiers: modifiers)
    case let .mouseClick(button): injector.mouseUp(button)
    case .scroll: scrollRepeats[key] = nil
    case .mouseMove: break
    }
  }

  private func releaseAll() {
    for key in active {
      if let index = Int(key.split(separator: "|")[1]), index < rules.count {
        release(rules[index].action, key: key)
      }
    }
    active.removeAll()
    scrollRepeats.removeAll()
    injector.releaseAll()
  }

  private func scrollLines(horizontal: Bool, amount: Double) {
    let lines = Int32(amount.rounded())
    injector.scroll(vertical: horizontal ? 0 : lines, horizontal: horizontal ? lines : 0, units: .line)
  }

  static func isPressed(_ input: InputSpec, values: [String: Float], wasPressed: Bool) -> Bool {
    // Release slightly below the press point so values near the edge don't chatter.
    func over(_ value: Float, _ threshold: Float) -> Bool {
      value >= (wasPressed ? threshold * 0.8 : threshold)
    }
    switch input {
    case let .button(name):
      return over(values[name] ?? 0, 0.5)
    case let .dpad(direction):
      return over(values[InputName.dpad(direction)] ?? 0, 0.5)
    case let .stickDirection(stick, direction, threshold):
      let x = values[InputName.stickX(stick)] ?? 0
      let y = values[InputName.stickY(stick)] ?? 0
      switch direction {
      case "up": return over(y, threshold)
      case "down": return over(-y, threshold)
      case "left": return over(-x, threshold)
      case "right": return over(x, threshold)
      default: return false
      }
    case let .trigger(trigger, threshold):
      return over(values[InputName.trigger(trigger)] ?? 0, threshold)
    case .stickAxis:
      return false
    }
  }

  // MARK: Continuous motion

  private func updateLoop() {
    let needed = enabled && !capturing && rules.contains { $0.action.isContinuous }
    if needed { loop.start() } else { loop.stop() }
  }

  private func tick(_ dt: Double) {
    let scale = dt * MouseMotionLoop.frequency
    var move = CGPoint.zero
    var scroll = CGPoint.zero

    for (index, rule) in rules.enumerated() {
      switch (rule.input, rule.action) {
      case let (.stickAxis(stick), .mouseMove(speed, deadzone, curve)):
        for values in states.values {
          let (x, y) = Self.shapedStick(stick, values: values, deadzone: deadzone, curve: curve)
          move.x += x * (x >= 0 ? speed.right : speed.left) * scale
          move.y -= y * (y >= 0 ? speed.up : speed.down) * scale
        }

      case let (.stickAxis(stick), .scroll(horizontal, amount)):
        for values in states.values {
          let (x, y) = Self.shapedStick(stick, values: values, deadzone: Self.stickScrollDeadzone, curve: .quadratic)
          let pixels = amount * Self.stickScrollPixels * scale
          if horizontal { scroll.x += x * pixels } else { scroll.y += y * pixels }
        }

      case let (input, .mouseMove(speed, _, _)):
        let held = states.keys.filter { active.contains("\($0)|\(index)") }.count
        guard held > 0 else { continue }
        let vector = Self.digitalVector(input, speed: speed)
        move.x += vector.x * scale * Double(held)
        move.y += vector.y * scale * Double(held)

      default:
        continue
      }
    }

    for (key, remaining) in scrollRepeats {
      var next = remaining - dt
      if next <= 0, let index = Int(key.split(separator: "|")[1]), index < rules.count,
         case let .scroll(horizontal, amount) = rules[index].action {
        scrollLines(horizontal: horizontal, amount: amount)
        next += Self.scrollRepeatInterval
      }
      scrollRepeats[key] = next
    }

    if let (dx, dy) = Self.drain(move, remainder: &moveRemainder) {
      injector.moveMouse(dx: dx, dy: dy)
    }
    if let (sx, sy) = Self.drain(scroll, remainder: &scrollRemainder) {
      injector.scroll(vertical: Int32(sy), horizontal: Int32(sx), units: .pixel)
    }
  }

  /// Accumulates fractional movement between ticks so slow speeds stay smooth.
  private static func drain(_ delta: CGPoint, remainder: inout CGPoint) -> (Double, Double)? {
    if delta == .zero {
      remainder = .zero
      return nil
    }
    remainder.x += delta.x
    remainder.y += delta.y
    let whole = CGPoint(x: remainder.x.rounded(.towardZero), y: remainder.y.rounded(.towardZero))
    remainder.x -= whole.x
    remainder.y -= whole.y
    return whole == .zero ? nil : (Double(whole.x), Double(whole.y))
  }

  /// Radial deadzone, rescale to 0...1, then the response curve.
  private static func shapedStick(_ stick: String, values: [String: Float], deadzone: Double, curve: ResponseCurve) -> (Double, Double) {
    let x = Double(values[InputName.stickX(stick)] ?? 0)
    let y = Double(values[InputName.stickY(stick)] ?? 0)
    let magnitude = hypot(x, y)
    guard magnitude > deadzone else { return (0, 0) }
    let scaled = min(1, (magnitude - deadzone) / (1 - deadzone))
    let shaped = curve.apply(scaled)
    return (x / magnitude * shaped, y / magnitude * shaped)
  }

  /// Screen-space movement per tick for a held digital input.
  private static func digitalVector(_ input: InputSpec, speed: DirectionalSpeed) -> CGPoint {
    let direction: String?
    switch input {
    case let .dpad(d): direction = d
    case let .stickDirection(_, d, _): direction = d
    default: direction = nil
    }
    switch direction {
    case "up": return CGPoint(x: 0, y: -speed.up)
    case "down": return CGPoint(x: 0, y: speed.down)
    case "left": return CGPoint(x: -speed.left, y: 0)
    case "right": return CGPoint(x: speed.right, y: 0)
    default: return CGPoint(x: speed.right - speed.left, y: speed.down - speed.up)
    }
  }

  // MARK: Capture

  private struct CaptureCandidate {
    let id: String
    let input: [String: Any]
    let value: Float
  }

  private func detectCapture(controller id: String, values: [String: Float]) {
    let current = Self.activeCaptureInputs(values)
    let latched = captureLatch[id] ?? []
    for candidate in current where !latched.contains(candidate.id) {
      onCapture?(["controllerId": id, "name": candidate.id, "input": candidate.input, "value": candidate.value])
    }
    captureLatch[id] = Set(current.map(\.id))
  }

  private static func activeCaptureInputs(_ values: [String: Float]) -> [CaptureCandidate] {
    var result: [CaptureCandidate] = []
    for button in InputName.buttons {
      let value = values[button] ?? 0
      if value >= 0.5 { result.append(.init(id: "button:\(button)", input: ["type": "button", "button": button], value: value)) }
    }
    for direction in ["up", "down", "left", "right"] {
      let value = values[InputName.dpad(direction)] ?? 0
      if value >= 0.5 { result.append(.init(id: "dpad:\(direction)", input: ["type": "dpad", "direction": direction], value: value)) }
    }
    for trigger in ["left", "right"] {
      let value = values[InputName.trigger(trigger)] ?? 0
      if value >= 0.5 {
        result.append(.init(id: "trigger:\(trigger)", input: ["type": "trigger", "trigger": trigger, "threshold": 0.5], value: value))
      }
    }
    for stick in InputName.sticks {
      let x = values[InputName.stickX(stick)] ?? 0
      let y = values[InputName.stickY(stick)] ?? 0
      let magnitude = hypot(x, y)
      guard magnitude >= 0.6 else { continue }
      let direction = abs(x) > abs(y) ? (x > 0 ? "right" : "left") : (y > 0 ? "up" : "down")
      result.append(.init(
        id: "stick:\(stick):\(direction)",
        input: ["type": "stickDirection", "stick": stick, "direction": direction, "threshold": 0.4],
        value: magnitude
      ))
    }
    return result
  }
}
