import AppKit
import CoreGraphics

enum MouseButton: String {
  case left, right, middle

  var cgButton: CGMouseButton {
    switch self {
    case .left: return .left
    case .right: return .right
    case .middle: return .center
    }
  }

  var downType: CGEventType {
    switch self {
    case .left: return .leftMouseDown
    case .right: return .rightMouseDown
    case .middle: return .otherMouseDown
    }
  }

  var upType: CGEventType {
    switch self {
    case .left: return .leftMouseUp
    case .right: return .rightMouseUp
    case .middle: return .otherMouseUp
    }
  }

  var dragType: CGEventType {
    switch self {
    case .left: return .leftMouseDragged
    case .right: return .rightMouseDragged
    case .middle: return .otherMouseDragged
    }
  }
}

/// Posts synthetic keyboard and mouse events. Keys and buttons are
/// reference counted so overlapping mappings never release each other.
final class EventInjector {
  static let modifierFlags: [CGKeyCode: CGEventFlags] = [
    55: .maskCommand, 54: .maskCommand,
    56: .maskShift, 60: .maskShift,
    58: .maskAlternate, 61: .maskAlternate,
    59: .maskControl, 62: .maskControl,
    63: .maskSecondaryFn,
  ]

  private let source = CGEventSource(stateID: .hidSystemState)
  private var keyCounts: [CGKeyCode: Int] = [:]
  private var buttonCounts: [MouseButton: Int] = [:]
  private var lastClick: (button: MouseButton, time: TimeInterval, count: Int64)?

  init() {
    source?.localEventsSuppressionInterval = 0
  }

  private var flags: CGEventFlags {
    keyCounts.reduce(into: CGEventFlags()) { flags, entry in
      if entry.value > 0, let flag = Self.modifierFlags[entry.key] { flags.insert(flag) }
    }
  }

  // MARK: Keyboard

  func pressKey(_ code: CGKeyCode, modifiers: [CGKeyCode]) {
    modifiers.forEach(keyDown)
    keyDown(code)
  }

  func releaseKey(_ code: CGKeyCode, modifiers: [CGKeyCode]) {
    keyUp(code)
    modifiers.reversed().forEach(keyUp)
  }

  private func keyDown(_ code: CGKeyCode) {
    keyCounts[code, default: 0] += 1
    if keyCounts[code] == 1 { postKey(code, down: true) }
  }

  private func keyUp(_ code: CGKeyCode) {
    guard let count = keyCounts[code], count > 0 else { return }
    keyCounts[code] = count - 1
    if count == 1 {
      keyCounts[code] = nil
      postKey(code, down: false)
    }
  }

  private func postKey(_ code: CGKeyCode, down: Bool) {
    guard let event = CGEvent(keyboardEventSource: source, virtualKey: code, keyDown: down) else { return }
    if Self.modifierFlags[code] != nil { event.type = .flagsChanged }
    event.flags = flags
    event.post(tap: .cghidEventTap)
  }

  // MARK: Mouse

  private var cursor: CGPoint { CGEvent(source: nil)?.location ?? .zero }

  func mouseDown(_ button: MouseButton) {
    buttonCounts[button, default: 0] += 1
    guard buttonCounts[button] == 1 else { return }
    let now = ProcessInfo.processInfo.systemUptime
    var count: Int64 = 1
    if let last = lastClick, last.button == button, now - last.time < NSEvent.doubleClickInterval {
      count = last.count + 1
    }
    lastClick = (button, now, count)
    postMouse(button.downType, button: button, at: cursor, clickState: count)
  }

  func mouseUp(_ button: MouseButton) {
    guard let count = buttonCounts[button], count > 0 else { return }
    buttonCounts[button] = count - 1
    guard count == 1 else { return }
    buttonCounts[button] = nil
    postMouse(button.upType, button: button, at: cursor, clickState: lastClick?.count ?? 1)
  }

  func moveMouse(dx: Double, dy: Double) {
    let current = cursor
    let target = clampToScreens(CGPoint(x: current.x + dx, y: current.y + dy), from: current)
    let held = [MouseButton.left, .right, .middle].first { (buttonCounts[$0] ?? 0) > 0 }
    guard let event = CGEvent(
      mouseEventSource: source,
      mouseType: held?.dragType ?? .mouseMoved,
      mouseCursorPosition: target,
      mouseButton: held?.cgButton ?? .left
    ) else { return }
    // Games that hide the cursor read the raw deltas instead of the position.
    event.setIntegerValueField(.mouseEventDeltaX, value: Int64(dx))
    event.setIntegerValueField(.mouseEventDeltaY, value: Int64(dy))
    event.flags = flags
    event.post(tap: .cghidEventTap)
  }

  /// Positive vertical scrolls up, positive horizontal scrolls right.
  func scroll(vertical: Int32, horizontal: Int32, units: CGScrollEventUnit) {
    guard let event = CGEvent(
      scrollWheelEvent2Source: source,
      units: units,
      wheelCount: 2,
      wheel1: vertical,
      wheel2: -horizontal,
      wheel3: 0
    ) else { return }
    event.flags = flags
    event.post(tap: .cghidEventTap)
  }

  func releaseAll() {
    for button in Array(buttonCounts.keys) {
      buttonCounts[button] = 1
      mouseUp(button)
    }
    // Regular keys first, then modifiers.
    let codes = keyCounts.keys.sorted { (Self.modifierFlags[$0] == nil ? 0 : 1) < (Self.modifierFlags[$1] == nil ? 0 : 1) }
    for code in codes {
      keyCounts[code] = 1
      keyUp(code)
    }
  }

  private func postMouse(_ type: CGEventType, button: MouseButton, at point: CGPoint, clickState: Int64) {
    guard let event = CGEvent(mouseEventSource: source, mouseType: type, mouseCursorPosition: point, mouseButton: button.cgButton) else { return }
    event.setIntegerValueField(.mouseEventClickState, value: clickState)
    event.flags = flags
    event.post(tap: .cghidEventTap)
  }

  private func clampToScreens(_ point: CGPoint, from origin: CGPoint) -> CGPoint {
    var count: UInt32 = 0
    CGGetActiveDisplayList(0, nil, &count)
    var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
    CGGetActiveDisplayList(count, &displays, &count)
    let bounds = displays.map(CGDisplayBounds)
    if bounds.contains(where: { $0.contains(point) }) { return point }
    guard let screen = bounds.first(where: { $0.contains(origin) }) ?? bounds.first else { return point }
    return CGPoint(
      x: min(max(point.x, screen.minX), screen.maxX - 1),
      y: min(max(point.y, screen.minY), screen.maxY - 1)
    )
  }
}
