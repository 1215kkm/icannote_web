import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/canvas_element.dart';

/// Layered canvas painter using CanvasElement model.
///
/// Layers (bottom to top):
/// 1. Background (page color/pattern)
/// 2. Content cache (completed elements rendered as ui.Image)
/// 3. Active element (in-progress drawing)
/// 4. UI overlay (selection handles)
class CanvasPainter extends CustomPainter {
  final List<CanvasElement> elements;
  final CanvasElement? activeElement;
  final ui.Image? cachedImage;
  final String? selectedElementId;
  final String? backgroundPattern;

  CanvasPainter({
    required this.elements,
    this.activeElement,
    this.cachedImage,
    this.selectedElementId,
    this.backgroundPattern,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1: Background pattern
    if (backgroundPattern != null) {
      _paintBackgroundPattern(canvas, size, backgroundPattern!);
    }

    // Layer 2: Content - completed elements (skip stickers, rendered as widgets)
    if (cachedImage != null) {
      canvas.drawImage(cachedImage!, Offset.zero, Paint());
    } else {
      for (final element in elements) {
        if (!element.isDeleted && element is! StickerElement) {
          element.paint(canvas, size);
        }
      }
    }

    // Layer 3: Active element (in progress)
    if (activeElement != null) {
      activeElement!.paint(canvas, size);
    }

    // Layer 4: UI overlay - selection handles
    if (selectedElementId != null) {
      final selected =
          elements.where((e) => e.id == selectedElementId).toList();
      if (selected.isNotEmpty) {
        _paintSelectionHandles(canvas, selected.first);
      }
    }
  }

  void _paintBackgroundPattern(Canvas canvas, Size size, String pattern) {
    final paint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    switch (pattern) {
      case 'grid':
        const spacing = 30.0;
        for (double x = 0; x <= size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y <= size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;
      case 'ruled':
        const spacing = 30.0;
        for (double y = spacing; y <= size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        // Red margin line
        final marginPaint = Paint()
          ..color = const Color(0xFFFFCDD2)
          ..strokeWidth = 1.0;
        canvas.drawLine(const Offset(80, 0), Offset(80, size.height), marginPaint);
        break;
      case 'dots':
        const spacing = 25.0;
        final dotPaint = Paint()
          ..color = const Color(0xFFCCCCCC)
          ..style = PaintingStyle.fill;
        for (double x = spacing; x <= size.width; x += spacing) {
          for (double y = spacing; y <= size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
          }
        }
        break;
    }
  }

  void _paintSelectionHandles(Canvas canvas, CanvasElement element) {
    final bbox = element.boundingBox;
    const handleSize = 8.0;
    const handleHalf = handleSize / 2;

    final borderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(bbox, borderPaint);

    final handleFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleBorderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final handles = [
      bbox.topLeft,
      bbox.topCenter,
      bbox.topRight,
      bbox.centerLeft,
      bbox.centerRight,
      bbox.bottomLeft,
      bbox.bottomCenter,
      bbox.bottomRight,
    ];

    for (final handle in handles) {
      final rect = Rect.fromCenter(
        center: handle,
        width: handleSize,
        height: handleSize,
      );
      canvas.drawRect(rect, handleFillPaint);
      canvas.drawRect(rect, handleBorderPaint);
    }

    final rotationCenter = Offset(bbox.center.dx, bbox.top - 20);
    canvas.drawLine(bbox.topCenter, rotationCenter, borderPaint);
    canvas.drawCircle(rotationCenter, handleHalf, handleFillPaint);
    canvas.drawCircle(rotationCenter, handleHalf, handleBorderPaint);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    // NOTE: compare list *contents*, not just length. In-place edits
    // (move / recolor / font change / sticker reveal / undo of a modify)
    // keep the same length but produce new element instances, so a
    // length-only check would skip the repaint and the canvas would
    // appear frozen until an element is added or removed.
    return oldDelegate.activeElement != activeElement ||
        !listEquals(oldDelegate.elements, elements) ||
        oldDelegate.cachedImage != cachedImage ||
        oldDelegate.selectedElementId != selectedElementId ||
        oldDelegate.backgroundPattern != backgroundPattern;
  }
}
