import Carbon

/// System-wide shortcut via Carbon hot keys, which need no extra permission.
final class HotkeyManager {
  var onFire: (() -> Void)?

  private var hotKeyRef: EventHotKeyRef?
  private var handlerRef: EventHandlerRef?

  @discardableResult
  func register(keyCode: Int, modifiers: [String]) -> Bool {
    unregister()
    installHandlerIfNeeded()
    var flags: UInt32 = 0
    if modifiers.contains("command") { flags |= UInt32(cmdKey) }
    if modifiers.contains("shift") { flags |= UInt32(shiftKey) }
    if modifiers.contains("option") { flags |= UInt32(optionKey) }
    if modifiers.contains("control") { flags |= UInt32(controlKey) }
    let id = EventHotKeyID(signature: OSType(0x5044_504C), id: 1) // 'PDPL'
    return RegisterEventHotKey(UInt32(keyCode), flags, id, GetApplicationEventTarget(), 0, &hotKeyRef) == noErr
  }

  func unregister() {
    if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
    hotKeyRef = nil
  }

  private func installHandlerIfNeeded() {
    guard handlerRef == nil else { return }
    var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
    InstallEventHandler(GetApplicationEventTarget(), { _, _, context in
      guard let context else { return noErr }
      let manager = Unmanaged<HotkeyManager>.fromOpaque(context).takeUnretainedValue()
      DispatchQueue.main.async { manager.onFire?() }
      return noErr
    }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), &handlerRef)
  }
}
