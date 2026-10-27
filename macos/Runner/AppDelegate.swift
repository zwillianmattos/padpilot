import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  // Mapping keeps running from the menu bar after the window is closed.
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
