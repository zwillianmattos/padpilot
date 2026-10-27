import Carbon

/// Display names for macOS virtual key codes. Key codes are physical
/// positions, so printable keys are translated with the active layout.
enum KeyCodeMap {
  private static let special: [Int: String] = [
    36: "Return", 48: "Tab", 49: "Space", 51: "Delete", 53: "Esc",
    55: "Command", 54: "Right Command", 56: "Shift", 60: "Right Shift",
    58: "Option", 61: "Right Option", 59: "Control", 62: "Right Control",
    57: "Caps Lock", 63: "Fn",
    122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
    98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
    105: "F13", 107: "F14", 113: "F15", 106: "F16", 64: "F17", 79: "F18", 80: "F19", 90: "F20",
    123: "←", 124: "→", 125: "↓", 126: "↑",
    115: "Home", 119: "End", 116: "Page Up", 121: "Page Down", 117: "Delete ⌦", 114: "Help",
    76: "Enter (keypad)", 71: "Clear (keypad)",
  ]

  private static let keypad: Set<Int> = [65, 67, 69, 75, 78, 81, 82, 83, 84, 85, 86, 87, 88, 89, 91, 92]

  static func label(for code: Int) -> String? {
    if let name = special[code] { return name }
    let printable = (0...50).contains(code) || keypad.contains(code)
    guard printable, let char = translate(code) else { return nil }
    return keypad.contains(code) ? "\(char) (keypad)" : char.uppercased()
  }

  static func allLabels() -> [Int: String] {
    var labels: [Int: String] = [:]
    for code in 0..<128 {
      if let label = label(for: code) { labels[code] = label }
    }
    return labels
  }

  private static func translate(_ code: Int) -> String? {
    guard
      let source = TISCopyCurrentKeyboardLayoutInputSource()?.takeRetainedValue(),
      let pointer = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
    else { return nil }
    let data = Unmanaged<CFData>.fromOpaque(pointer).takeUnretainedValue() as Data
    return data.withUnsafeBytes { raw -> String? in
      guard let layout = raw.baseAddress?.assumingMemoryBound(to: UCKeyboardLayout.self) else { return nil }
      var deadKeys: UInt32 = 0
      var chars = [UniChar](repeating: 0, count: 4)
      var length = 0
      let status = UCKeyTranslate(
        layout, UInt16(code), UInt16(kUCKeyActionDisplay), 0, UInt32(LMGetKbdType()),
        OptionBits(kUCKeyTranslateNoDeadKeysMask), &deadKeys, chars.count, &length, &chars
      )
      guard status == noErr, length > 0 else { return nil }
      let string = String(utf16CodeUnits: chars, count: length).trimmingCharacters(in: .whitespacesAndNewlines)
      return string.isEmpty ? nil : string
    }
  }
}
