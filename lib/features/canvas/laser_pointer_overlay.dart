import 'dart:async';
import 'package:flutter/material.dart';

/// A fading laser pointer trail overlay.
/// Points fade out after [fadeDuration].
class LaserPointerOverlay extends StatefulWidget {
  final bool isActive;
  final Duration fadeDuration;

  const LaserPointerOverlay({
    super.key,
    required this.isActive,
    this.fadeDuration = const Duration(milliseconds: 800),
  });

  @override
  State<LaserPointerOverlay> createState() => LaserPointerOverlayState();
}

class LaserPointerOverlayState extends State<LaserPointerOverlay>
    with SingleTickerProviderStateMixin {
  final List<_LaserPoint> _points = [];
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    _cleanupTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _cleanup(),
    );
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  void addPoint(Offset position) {
    if (!widget.isActive || !mounted) return;
    setState(() {
      _points.add(_LaserPoint(position, DateTime.now()));
    });
  }

  void _cleanup() {
    if (_points.isEmpty || !mounted) return;
    final now = DateTime.now();
    final cutoff = now.subtract(widget.fadeDuration);
    final before = _points.length;
    _points.removeWhere((p) => p.time.isBefore(cutoff));
    // Repaint while points remain (so the trail keeps fading) and once
    // more when the last point expires.
    if (_points.length != before || _points.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive || _points.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size.infinite,
      painter: _LaserPainter(
        points: _points,
        fadeDuration: widget.fadeDuration,
      ),
    );
  }
}

class _LaserPoint {
  final Offset position;
  final DateTime time;
  const _LaserPoint(this.position, this.time);
}

class _LaserPainter extends CustomPainter {
  final List<_LaserPoint> points;
  final Duration fadeDuration;

  _LaserPainter({required this.points, required this.fadeDuration});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final now = DateTime.now();

    for (int i = 0; i < points.length; i++) {
      final elapsed = now.difference(points[i].time);
      final progress = elapsed.inMilliseconds / fadeDuration.inMilliseconds;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final paint = Paint()
        ..color = Colors.red.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;

      // Outer glow
      final glowPaint = Paint()
        ..color = Colors.red.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(points[i].position, 6, glowPaint);
      canvas.drawCircle(points[i].position, 3, paint);
    }

    // Draw trail line between consecutive points
    if (points.length >= 2) {
      for (int i = 1; i < points.length; i++) {
        final elapsed = now.difference(points[i].time);
        final progress = elapsed.inMilliseconds / fadeDuration.inMilliseconds;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        if (opacity <= 0) continue;

        final paint = Paint()
          ..color = Colors.red.withValues(alpha: opacity * 0.5)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        canvas.drawLine(points[i - 1].position, points[i].position, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_LaserPainter oldDelegate) => true;
}
