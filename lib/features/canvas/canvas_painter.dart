import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/stroke.dart';

class CanvasPainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? activeStroke;
  final ui.Image? cachedImage;

  CanvasPainter({
    required this.strokes,
    this.activeStroke,
    this.cachedImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw cached completed strokes
    if (cachedImage != null) {
      canvas.drawImage(cachedImage!, Offset.zero, Paint());
    } else {
      // Fallback: draw all strokes
      for (final stroke in strokes) {
        if (!stroke.isDeleted) {
          _drawStroke(canvas, stroke);
        }
      }
    }

    // Draw active stroke (in progress)
    if (activeStroke != null) {
      _drawStroke(canvas, activeStroke!);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = stroke.toPaint();

    switch (stroke.tool) {
      case DrawingTool.pen:
      case DrawingTool.highlighter:
        _drawFreehand(canvas, stroke, paint);
        break;
      case DrawingTool.line:
        _drawLine(canvas, stroke, paint);
        break;
      case DrawingTool.rectangle:
        _drawRectangle(canvas, stroke, paint);
        break;
      case DrawingTool.circle:
        _drawCircle(canvas, stroke, paint);
        break;
      case DrawingTool.triangle:
        _drawTriangle(canvas, stroke, paint);
        break;
      case DrawingTool.curve:
        _drawFreehand(canvas, stroke, paint);
        break;
      default:
        _drawFreehand(canvas, stroke, paint);
        break;
    }
  }

  void _drawFreehand(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length == 1) {
      final p = stroke.points.first;
      canvas.drawCircle(
          Offset(p.x, p.y), paint.strokeWidth / 2, paint..style = PaintingStyle.fill);
      paint.style = PaintingStyle.stroke;
      return;
    }

    final path = Path();
    path.moveTo(stroke.points.first.x, stroke.points.first.y);

    for (int i = 1; i < stroke.points.length - 1; i++) {
      final p0 = stroke.points[i];
      final p1 = stroke.points[i + 1];
      final midX = (p0.x + p1.x) / 2;
      final midY = (p0.y + p1.y) / 2;
      path.quadraticBezierTo(p0.x, p0.y, midX, midY);
    }

    if (stroke.points.length > 1) {
      final last = stroke.points.last;
      path.lineTo(last.x, last.y);
    }

    canvas.drawPath(path, paint);
  }

  void _drawLine(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;
    final first = stroke.points.first;
    final last = stroke.points.last;
    canvas.drawLine(Offset(first.x, first.y), Offset(last.x, last.y), paint);
  }

  void _drawRectangle(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;
    final first = stroke.points.first;
    final last = stroke.points.last;
    final rect = Rect.fromPoints(Offset(first.x, first.y), Offset(last.x, last.y));
    canvas.drawRect(rect, paint);
  }

  void _drawCircle(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;
    final first = stroke.points.first;
    final last = stroke.points.last;
    final rect = Rect.fromPoints(Offset(first.x, first.y), Offset(last.x, last.y));
    canvas.drawOval(rect, paint);
  }

  void _drawTriangle(Canvas canvas, Stroke stroke, Paint paint) {
    if (stroke.points.length < 2) return;
    final first = stroke.points.first;
    final last = stroke.points.last;
    final path = Path();
    final topX = (first.x + last.x) / 2;
    path.moveTo(topX, math.min(first.y, last.y));
    path.lineTo(math.min(first.x, last.x), math.max(first.y, last.y));
    path.lineTo(math.max(first.x, last.x), math.max(first.y, last.y));
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.activeStroke != activeStroke ||
        oldDelegate.strokes.length != strokes.length ||
        oldDelegate.cachedImage != cachedImage;
  }
}
