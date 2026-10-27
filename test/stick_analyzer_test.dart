import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:padpilot/features/diagnostics/stick_analyzer.dart';

void main() {
  test('a perfect circle has full coverage, radius 1 and no deviation', () {
    final stick = StickAnalyzer();
    for (var i = 0; i < 720; i++) {
      final a = i / 720 * 2 * math.pi;
      stick.add(math.cos(a), math.sin(a));
    }
    expect(stick.coverage, 1);
    expect(stick.outerRadius, closeTo(1, 1e-9));
    expect(stick.circularityError, closeTo(0, 1e-9));
  });

  test('a square gate shows corners beyond 1 and a clear deviation', () {
    final stick = StickAnalyzer();
    for (var i = 0; i < 720; i++) {
      final a = i / 720 * 2 * math.pi;
      final scale = 1 / math.max(math.cos(a).abs(), math.sin(a).abs());
      stick.add(math.cos(a) * scale, math.sin(a) * scale);
    }
    expect(stick.outerRadius!, greaterThan(1.05));
    expect(stick.circularityError!, greaterThan(0.05));
  });

  test('resolution is estimated from the smallest step between values', () {
    final stick = StickAnalyzer();
    // 8-bit axis: 256 levels across -1…1.
    for (var i = 0; i < 256; i++) {
      stick.add(-1 + i * 2 / 255, 0);
    }
    expect(stick.resolutionLevels, 255);
    expect(stick.resolutionBits!, closeTo(8, 0.01));
  });

  test('center calibration measures drift, noise and suggests a dead zone', () {
    final stick = StickAnalyzer()..startCalibration();
    for (final (x, y) in [(0.03, -0.01), (0.05, 0.01), (0.04, 0.0), (0.04, 0.0)]) {
      stick.add(x, y);
    }
    final c = stick.finishCalibration()!;
    expect(c.meanX, closeTo(0.04, 1e-9));
    expect(c.meanY, closeTo(0, 1e-9));
    expect(c.noiseX, greaterThan(0));
    expect(c.maxDeviation, closeTo(math.sqrt(0.05 * 0.05 + 0.01 * 0.01), 1e-9));
    expect(c.suggestedDeadzone, closeTo(c.maxDeviation * 1.2 + 0.02, 1e-9));
    expect(stick.isCalibrating, isFalse);
  });

  test('a still stick that sends nothing calibrates from its last position', () {
    final stick = StickAnalyzer()..add(0.02, 0.0);
    stick.startCalibration();
    final c = stick.finishCalibration()!;
    expect(c.samples, 0);
    expect(c.meanX, 0.02);
    expect(c.noiseX, 0);
  });
}
