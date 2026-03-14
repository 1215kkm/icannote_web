import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../models/canvas_element.dart';

/// Layered canvas painter using CanvasElement model.
///
/// Layers (bottom to top):
/// 1. Background (page color/image)
/// 2. Content cache (completed elements rendered as ui.Image)
/// 3. Active element (in-progress drawing)
/// 4. UI overlay (selection handles)
class CanvasPainter extends CustomPainter {
  final List<CanvasElement> elements;
  final CanvasElement? activeElement;
  final ui.Image? cachedImage;
  final String? selectedElementId;

  CanvasPainter({
    required this.elements,
    this.activeElement,
    this.cachedImage,
    this.selectedElementId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Layer 2: Content - completed elements
    if (cachedImage != null) {
      canvas.drawImage(cachedImage!, Offset.zero, Paint());
    } else {
      // Fallback: draw all elements directly
      for (final element in elements) {
        if (!element.isDeleted) {
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
      final selected = elements.where((e) => e.id == selectedElementId).toList();
      if (selected.isNotEmpty) {
        _paintSelectionHandles(canvas, selected.first);
      }
    }
  }

  void _paintSelectionHandles(Canvas canvas, CanvasElement element) {
    final bbox = element.boundingBox;
    const handleSize = 8.0;
    const handleHalf = handleSize / 2;

    // Selection border (dashed-style with solid blue)
    final borderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(bbox, borderPaint);

    // Handle fill
    final handleFillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Handle border
    final handleBorderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw 8 resize handles (corners + edge midpoints)
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

    // Rotation handle (circle above top center)
    final rotationCenter = Offset(bbox.center.dx, bbox.top - 20);
    canvas.drawLine(bbox.topCenter, rotationCenter, borderPaint);
    canvas.drawCircle(rotationCenter, handleHalf, handleFillPaint);
    canvas.drawCircle(rotationCenter, handleHalf, handleBorderPaint);
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return oldDelegate.activeElement != activeElement ||
        oldDelegate.elements.length != elements.length ||
        oldDelegate.cachedImage != cachedImage ||
        oldDelegate.selectedElementId != selectedElementId;
  }
}
