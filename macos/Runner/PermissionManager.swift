import AppKit
import ApplicationServices
import IOKit.hid

/// Tracks Accessibility (event injection) and Input Monitoring (generic HID)
/// and reports changes, since macOS gives no callback when they're granted.
final class PermissionManager {
  var onChange: (([String: String]) -> Void)?

  private var timer: Timer?
  private var last: [String: String] = [:]
  /// Input Monitoring only takes effect for a process started after it was
  /// granted, so a grant during this run needs a relaunch.
  private lazy var inputMonitoringAtLaunch = inputMonitoring

  var status: [String: String] {
    let monitoring = inputMonitoring
    return [
      "accessibility": accessibility,
      "inputMonitoring": monitoring,
      "restartRequired": monitoring == "granted" && inputMonitoringAtLaunch != "granted" ? "true" : "false",
    ]
  }

  var accessibility: String { AXIsProcessTrusted() ? "granted" : "denied" }

  var inputMonitoring: String {
    switch IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) {
    case kIOHIDAccessTypeGranted: return "granted"
    case kIOHIDAccessTypeDenied: return "denied"
    default: return "unknown"
    }
  }

  func startMonitoring() {
    _ = inputMonitoringAtLaunch
    last = status
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
      guard let self else { return }
      let current = self.status
      if current != self.last {
        self.last = current
        self.onChange?(current)
      }
    }
  }

  func request(_ type: String) {
    switch type {
    case "accessibility":
      let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
      _ = AXIsProcessTrustedWithOptions(options)
    case "inputMonitoring":
      // Requesting is what adds the app to the Input Monitoring list.
      _ = IOHIDRequestAccess(kIOHIDRequestTypeListenEvent)
    default:
      break
    }
  }

  /// Starts a fresh copy of the app and quits this one.
  func relaunch() {
    let path = Bundle.main.bundlePath
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/bin/sh")
    task.arguments = ["-c", "sleep 1; /usr/bin/open \"$0\"", path]
    try? task.run()
    NSApp.terminate(nil)
  }

  /// Shows the app bundle in Finder so it can be added with "+" in the
  /// privacy list when macOS doesn't list it by itself.
  func revealApp() {
    NSWorkspace.shared.activateFileViewerSelecting([Bundle.main.bundleURL])
  }

  func openSettings(_ type: String) {
    let pane = type == "inputMonitoring" ? "Privacy_ListenEvent" : "Privacy_Accessibility"
    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?\(pane)") {
      NSWorkspace.shared.open(url)
    }
  }
}
