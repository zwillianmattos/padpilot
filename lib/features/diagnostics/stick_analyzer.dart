import 'dart:math' as math;

/// Result of holding a stick still: where "center" really is and how much
/// it wanders. A dead zone must cover the worst wander, not the average.
class CenterCalibration {
  const CenterCalibration({
    required this.meanX,
    required this.meanY,
    required this.noiseX,
    required this.noiseY,
    required this.maxDeviation,
    required this.samples,
  });

  final double meanX;
  final double meanY;

  /// Standard deviation per axis while at rest.
  final double noiseX;
  final double noiseY;

  /// Largest distance from (0, 0) seen while at rest.
  final double maxDeviation;
  final int samples;

  double get drift => math.sqrt(meanX * meanX + meanY * meanY);

  /// Worst rest deviation plus a 20% margin and a small floor, capped at 50%.
  double get suggestedDeadzone => math.min(0.5, maxDeviation * 1.2 + 0.02);
}

/// Accumulates stick samples for the diagnostics screen: trail, per-angle
/// outer envelope (circularity), axis ranges, resolution and rest noise.
class StickAnalyzer {
  StickAnalyzer({this.trailLength = 160, this.bins = 72});

  final int trailLength;
  final int bins;

  double x = 0;
  double y = 0;
  final List<(double, double)> trail = [];
  late final List<double> envelope = List.filled(bins, 0);
  double minX = 0, maxX = 0, minY = 0, maxY = 0;
  final Set<double> _distinctX = {};
  final Set<double> _distinctY = {};
  int samples = 0;

  CenterCalibration? calibration;
  List<(double, double)>? _calibrating;

  bool get isCalibrating => _calibrating != null;

  double get magnitude => math.sqrt(x * x + y * y);

  /// Degrees, 0 = right, counter-clockwise (stick Y up is positive).
  double get angle => (math.atan2(y, x) * 180 / math.pi + 360) % 360;

  void add(double nx, double ny) {
    x = nx;
    y = ny;
    samples++;
    trail.add((nx, ny));
    if (trail.length > trailLength) trail.removeAt(0);
    minX = math.min(minX, nx);
    maxX = math.max(maxX, nx);
    minY = math.min(minY, ny);
    maxY = math.max(maxY, ny);
    if (_distinctX.length < 8192) _distinctX.add(nx);
    if (_distinctY.length < 8192) _distinctY.add(ny);

    final r = math.sqrt(nx * nx + ny * ny);
    // Ignore the middle so rest noise doesn't count as envelope.
    if (r > 0.3) {
      final bin = ((math.atan2(ny, nx) + math.pi) / (2 * math.pi) * bins).floor() % bins;
      envelope[bin] = math.max(envelope[bin], r);
    }
    _calibrating?.add((nx, ny));
  }

  void startCalibration() => _calibrating = [];

  /// Ends the rest capture; null if nothing was sampled.
  CenterCalibration? finishCalibration() {
    final points = _calibrating;
    _calibrating = null;
    // Sticks only report changes, so a perfectly still stick may send
    // nothing: treat the last known position as the only sample.
    final data = (points == null || points.isEmpty) ? [(x, y)] : points;
    final n = data.length;
    final mx = data.fold(0.0, (s, p) => s + p.$1) / n;
    final my = data.fold(0.0, (s, p) => s + p.$2) / n;
    double variance(double Function((double, double)) axis, double mean) =>
        data.fold(0.0, (s, p) => s + math.pow(axis(p) - mean, 2)) / n;
    calibration = CenterCalibration(
      meanX: mx,
      meanY: my,
      noiseX: math.sqrt(variance((p) => p.$1, mx)),
      noiseY: math.sqrt(variance((p) => p.$2, my)),
      maxDeviation: data.fold(0.0, (m, p) => math.max(m, math.sqrt(p.$1 * p.$1 + p.$2 * p.$2))),
      samples: points?.length ?? 0,
    );
    return calibration;
  }

  /// Fraction of angle bins the stick has reached the outer area in.
  double get coverage => envelope.where((r) => r > 0).length / bins;

  /// Mean outer radius over visited bins: ~1.0 is ideal, < 1 means the
  /// stick never reaches full deflection, > 1 means square-ish corners.
  double? get outerRadius {
    final visited = envelope.where((r) => r > 0).toList();
    if (visited.isEmpty) return null;
    return visited.reduce((a, b) => a + b) / visited.length;
  }

  /// Mean relative deviation of the envelope from its own average radius.
  double? get circularityError {
    final mean = outerRadius;
    if (mean == null) return null;
    final visited = envelope.where((r) => r > 0);
    return visited.fold(0.0, (s, r) => s + (r - mean).abs()) / visited.length / mean;
  }

  /// Estimated steps across -1…1, from the smallest gap between distinct
  /// values seen. Null until enough movement has been recorded.
  int? get resolutionLevels {
    final step = math.min(_smallestStep(_distinctX) ?? double.infinity, _smallestStep(_distinctY) ?? double.infinity);
    if (step == double.infinity) return null;
    return (2 / step).round();
  }

  double? get resolutionBits {
    final levels = resolutionLevels;
    return levels == null ? null : math.log(levels) / math.ln2;
  }

  static double? _smallestStep(Set<double> values) {
    if (values.length < 16) return null;
    final sorted = values.toList()..sort();
    var smallest = double.infinity;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i] - sorted[i - 1];
      if (gap > 1e-7 && gap < smallest) smallest = gap;
    }
    return smallest == double.infinity ? null : smallest;
  }

  void reset() {
    x = y = 0;
    trail.clear();
    envelope.fillRange(0, bins, 0);
    minX = maxX = minY = maxY = 0;
    _distinctX.clear();
    _distinctY.clear();
    samples = 0;
    calibration = null;
    _calibrating = null;
  }
}

class TriggerAnalyzer {
  double value = 0;
  double min = double.infinity;
  double max = 0;

  void add(double v) {
    value = v;
    if (v < min) min = v;
    if (v > max) max = v;
  }

  void reset() {
    value = 0;
    min = double.infinity;
    max = 0;
  }
}

/// Events per second over a sliding one-second window.
class RateMeter {
  final List<double> _times = [];

  void add(double time) {
    _times.add(time);
    while (_times.isNotEmpty && time - _times.first > 1) {
      _times.removeAt(0);
    }
  }

  int rateAt(double now) => _times.where((t) => now - t <= 1).length;
}
