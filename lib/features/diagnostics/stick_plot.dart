import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../widgets/app_theme.dart';
import 'stick_analyzer.dart';

/// Square plot of one stick: unit circle, dead zone, circularity envelope,
/// recent trail, measured rest center and the live position.
class StickPlot extends StatelessWidget {
  const StickPlot({super.key, required this.stick, required this.repaint, this.deadzone});

  final StickAnalyzer stick;
  final Listenable repaint;
  final double? deadzone;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: CustomPaint(painter: _StickPainter(stick, deadzone, repaint, context.palette)),
  );
}

class _StickPainter extends CustomPainter {
  _StickPainter(this.stick, this.deadzone, Listenable repaint, this.palette) : super(repaint: repaint);

  final StickAnalyzer stick;
  final double? deadzone;
  final AppPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    // Leave room outside the circle for corners that exceed 1.0.
    final radius = size.shortestSide / 2 * 0.82;
    Offset at(double x, double y) => center + Offset(x * radius, -y * radius);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      Paint()..color = palette.background,
    );

    final grid = Paint()
      ..color = palette.border
      ..strokeWidth = 1;
    canvas.drawLine(at(-1.15, 0), at(1.15, 0), grid);
    canvas.drawLine(at(0, -1.15), at(0, 1.15), grid);
    canvas.drawCircle(center, radius * 0.5, grid..style = PaintingStyle.stroke);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = palette.muted.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (deadzone case final dz? when dz > 0) {
      canvas.drawCircle(center, radius * dz, Paint()..color = palette.warning.withValues(alpha: 0.18));
      canvas.drawCircle(
        center,
        radius * dz,
        Paint()
          ..color = palette.warning
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    _paintEnvelope(canvas, at);

    final trail = stick.trail;
    for (var i = 0; i < trail.length; i++) {
      final t = (i + 1) / trail.length;
      canvas.drawCircle(
        at(trail[i].$1, trail[i].$2),
        1.6,
        Paint()..color = palette.accent.withValues(alpha: 0.08 + 0.5 * t),
      );
    }

    if (stick.calibration case final c?) {
      final p = at(c.meanX, c.meanY);
      final cross = Paint()
        ..color = palette.danger
        ..strokeWidth = 1.5;
      canvas.drawLine(p - const Offset(5, 0), p + const Offset(5, 0), cross);
      canvas.drawLine(p - const Offset(0, 5), p + const Offset(0, 5), cross);
    }

    final dot = at(stick.x, stick.y);
    canvas.drawLine(
      center,
      dot,
      Paint()
        ..color = palette.accent.withValues(alpha: 0.35)
        ..strokeWidth = 1.5,
    );
    canvas.drawCircle(dot, 8, Paint()..color = Colors.white);
    canvas.drawCircle(dot, 6, Paint()..color = palette.accent);
  }

  void _paintEnvelope(Canvas canvas, Offset Function(double, double) at) {
    final bins = stick.envelope;
    if (bins.every((r) => r == 0)) return;
    final path = Path();
    var started = false;
    for (var i = 0; i < bins.length; i++) {
      final r = bins[i];
      if (r == 0) {
        started = false;
        continue;
      }
      // Bin i spans angles starting at -π; draw at the bin's middle.
      final a = -math.pi + (i + 0.5) / bins.length * 2 * math.pi;
      final p = at(math.cos(a) * r, math.sin(a) * r);
      if (started) {
        path.lineTo(p.dx, p.dy);
      } else {
        path.moveTo(p.dx, p.dy);
        started = true;
      }
    }
    if (bins.every((r) => r > 0)) path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = palette.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_StickPainter old) => old.deadzone != deadzone || old.stick != stick || old.palette != palette;
}
