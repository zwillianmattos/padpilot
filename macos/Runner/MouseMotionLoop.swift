import Foundation

/// High-frequency timer (~120 Hz) driving smooth mouse movement and
/// continuous scroll. Ticks run on the engine queue with the elapsed seconds.
final class MouseMotionLoop {
  static let frequency = 120.0

  var onTick: ((Double) -> Void)?

  private let queue: DispatchQueue
  private var timer: DispatchSourceTimer?
  private var lastTick: UInt64 = 0

  init(queue: DispatchQueue) {
    self.queue = queue
  }

  var isRunning: Bool { timer != nil }

  func start() {
    guard timer == nil else { return }
    let timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    timer.schedule(
      deadline: .now(),
      repeating: .nanoseconds(Int(1_000_000_000 / Self.frequency)),
      leeway: .microseconds(500)
    )
    lastTick = DispatchTime.now().uptimeNanoseconds
    timer.setEventHandler { [weak self] in
      guard let self else { return }
      let now = DispatchTime.now().uptimeNanoseconds
      let elapsed = Double(now - self.lastTick) / 1_000_000_000
      self.lastTick = now
      // Cap so a stalled tick never produces a huge jump.
      self.onTick?(min(elapsed, 0.05))
    }
    timer.resume()
    self.timer = timer
  }

  func stop() {
    timer?.cancel()
    timer = nil
  }
}
