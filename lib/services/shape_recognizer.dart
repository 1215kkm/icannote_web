import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Recognized shape types from freehand drawing.
enum RecognizedShape {
  line,
  rectangle,
  circle,
  triangle,
  none,
}

/// Result of shape recognition.
class ShapeRecognitionResult {
  final RecognizedShape shape;
  final double confidence;
  final Rect boundingBox;
  final List<Offset> keyPoints;

  const ShapeRecognitionResult({
    required this.shape,
    required this.confidence,
    required this.boundingBox,
    this.keyPoints = const [],
  });

  bool get isRecognized => shape != RecognizedShape.none && confidence > 0.6;
}

/// Recognizes geometric shapes from freehand stroke points.
class ShapeRecognizer {
  static const double _minConfidence = 0.6;
  static const int _minPoints = 5;

  /// Analyze a set of points and return the best matching shape.
  static ShapeRecognitionResult recognize(List<Offset> points) {
    if (points.length < _minPoints) {
      return const ShapeRecognitionResult(
        shape: RecognizedShape.none,
        confidence: 0,
        boundingBox: Rect.zero,
      );
    }

    final bbox = _boundingBox(points);
    final results = <ShapeRecognitionResult>[
      _checkLine(points, bbox),
      _checkRectangle(points, bbox),
      _checkCircle(points, bbox),
      _checkTriangle(points, bbox),
    ];

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    final best = results.first;

    if (best.confidence >= _minConfidence) {
      return best;
    }

    return ShapeRecognitionResult(
      shape: RecognizedShape.none,
      confidence: 0,
      boundingBox: bbox,
    );
  }

  static Rect _boundingBox(List<Offset> points) {
    double minX = double.infinity, maxX = double.negativeInfinity;
    double minY = double.infinity, maxY = double.negativeInfinity;
    for (final p in points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  /// Check if the points form a straight line.
  static ShapeRecognitionResult _checkLine(List<Offset> points, Rect bbox) {
    final start = points.first;
    final end = points.last;
    final lineLength = (end - start).distance;

    if (lineLength < 20) {
      return ShapeRecognitionResult(
        shape: RecognizedShape.line,
        confidence: 0,
        boundingBox: bbox,
      );
    }

    // Measure max deviation from the line
    double maxDeviation = 0;
    for (final p in points) {
      final d = _pointToLineDistance(p, start, end);
      if (d > maxDeviation) maxDeviation = d;
    }

    final confidence = 1.0 - (maxDeviation / lineLength).clamp(0.0, 1.0);

    return ShapeRecognitionResult(
      shape: RecognizedShape.line,
      confidence: confidence,
      boundingBox: bbox,
      keyPoints: [start, end],
    );
  }

  /// Check if the points form a rectangle.
  static ShapeRecognitionResult _checkRectangle(
      List<Offset> points, Rect bbox) {
    final width = bbox.width;
    final height = bbox.height;

    if (width < 20 || height < 20) {
      return ShapeRecognitionResult(
        shape: RecognizedShape.rectangle,
        confidence: 0,
        boundingBox: bbox,
      );
    }

    // Check if stroke is closed (end near start)
    final closedness = 1.0 -
        ((points.last - points.first).distance /
                math.max(width, height))
            .clamp(0.0, 1.0);

    // Measure how closely points follow the rectangle perimeter
    double totalDeviation = 0;
    for (final p in points) {
      final dLeft = (p.dx - bbox.left).abs();
      final dRight = (p.dx - bbox.right).abs();
      final dTop = (p.dy - bbox.top).abs();
      final dBottom = (p.dy - bbox.bottom).abs();
      final minDist = [dLeft, dRight, dTop, dBottom].reduce(math.min);
      totalDeviation += minDist;
    }

    final avgDeviation = totalDeviation / points.length;
    final perimeterFit = 1.0 -
        (avgDeviation / (math.min(width, height) * 0.3)).clamp(0.0, 1.0);

    // Aspect ratio penalty (very elongated shapes are less likely rectangles)
    final aspectRatio = width / height;
    final aspectPenalty =
        (aspectRatio > 0.2 && aspectRatio < 5.0) ? 1.0 : 0.5;

    final confidence = (perimeterFit * 0.6 + closedness * 0.4) * aspectPenalty;

    return ShapeRecognitionResult(
      shape: RecognizedShape.rectangle,
      confidence: confidence,
      boundingBox: bbox,
    );
  }

  /// Check if the points form a circle.
  static ShapeRecognitionResult _checkCircle(List<Offset> points, Rect bbox) {
    final center = bbox.center;
    final avgRadius = (bbox.width + bbox.height) / 4;

    if (avgRadius < 10) {
      return ShapeRecognitionResult(
        shape: RecognizedShape.circle,
        confidence: 0,
        boundingBox: bbox,
      );
    }

    // Check if stroke is closed
    final closedness = 1.0 -
        ((points.last - points.first).distance / (avgRadius * 2))
            .clamp(0.0, 1.0);

    // Measure how closely points follow a circle
    double totalDeviation = 0;
    for (final p in points) {
      final dist = (p - center).distance;
      totalDeviation += (dist - avgRadius).abs();
    }

    final avgDeviation = totalDeviation / points.length;
    final circleFit =
        1.0 - (avgDeviation / avgRadius).clamp(0.0, 1.0);

    // Aspect ratio (circles should be roughly square)
    final aspectRatio = bbox.width / bbox.height;
    final aspectScore =
        1.0 - (aspectRatio - 1.0).abs().clamp(0.0, 1.0);

    final confidence =
        circleFit * 0.5 + closedness * 0.3 + aspectScore * 0.2;

    return ShapeRecognitionResult(
      shape: RecognizedShape.circle,
      confidence: confidence,
      boundingBox: bbox,
    );
  }

  /// Check if the points form a triangle.
  static ShapeRecognitionResult _checkTriangle(
      List<Offset> points, Rect bbox) {
    if (bbox.width < 20 || bbox.height < 20) {
      return ShapeRecognitionResult(
        shape: RecognizedShape.triangle,
        confidence: 0,
        boundingBox: bbox,
      );
    }

    // Find 3 corners (points with sharpest angle changes)
    final corners = _findCorners(points, 3);

    if (corners.length < 3) {
      return ShapeRecognitionResult(
        shape: RecognizedShape.triangle,
        confidence: 0,
        boundingBox: bbox,
      );
    }

    // Check closedness
    final closedness = 1.0 -
        ((points.last - points.first).distance /
                math.max(bbox.width, bbox.height))
            .clamp(0.0, 1.0);

    // Measure how closely points follow the triangle edges
    double totalDeviation = 0;
    for (final p in points) {
      double minDist = double.infinity;
      for (int i = 0; i < corners.length; i++) {
        final j = (i + 1) % corners.length;
        final d = _pointToLineDistance(p, corners[i], corners[j]);
        if (d < minDist) minDist = d;
      }
      totalDeviation += minDist;
    }

    final avgDeviation = totalDeviation / points.length;
    final edgeFit = 1.0 -
        (avgDeviation / (math.min(bbox.width, bbox.height) * 0.2))
            .clamp(0.0, 1.0);

    final confidence = edgeFit * 0.6 + closedness * 0.4;

    return ShapeRecognitionResult(
      shape: RecognizedShape.triangle,
      confidence: confidence,
      boundingBox: bbox,
      keyPoints: corners,
    );
  }

  /// Find N corner points from a list of points by detecting sharp angle changes.
  static List<Offset> _findCorners(List<Offset> points, int count) {
    if (points.length < 10) return [];

    // Sample points to reduce noise
    final step = math.max(1, points.length ~/ 50);
    final sampled = <Offset>[];
    for (int i = 0; i < points.length; i += step) {
      sampled.add(points[i]);
    }
    if (sampled.length < 5) return [];

    // Calculate angle change at each point
    final angles = <_IndexedAngle>[];
    for (int i = 1; i < sampled.length - 1; i++) {
      final a = sampled[i - 1];
      final b = sampled[i];
      final c = sampled[i + 1];

      final angle = _angleBetween(a, b, c);
      angles.add(_IndexedAngle(i, angle));
    }

    // Sort by angle (sharpest first)
    angles.sort((a, b) => a.angle.compareTo(b.angle));

    // Pick top N corners that are well-separated
    final corners = <Offset>[];
    for (final a in angles) {
      if (corners.length >= count) break;

      final candidate = sampled[a.index];
      bool tooClose = false;
      for (final c in corners) {
        if ((candidate - c).distance <
            math.min(sampled.first.dx, sampled.first.dy) * 0.1 + 20) {
          tooClose = true;
          break;
        }
      }
      if (!tooClose) corners.add(candidate);
    }

    return corners;
  }

  static double _angleBetween(Offset a, Offset b, Offset c) {
    final v1 = a - b;
    final v2 = c - b;
    final dot = v1.dx * v2.dx + v1.dy * v2.dy;
    final cross = v1.dx * v2.dy - v1.dy * v2.dx;
    return math.atan2(cross.abs(), dot).abs();
  }

  static double _pointToLineDistance(Offset point, Offset a, Offset b) {
    final ab = b - a;
    final ap = point - a;
    final abLen = ab.distance;
    if (abLen == 0) return ap.distance;

    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / (abLen * abLen))
        .clamp(0.0, 1.0);
    final projection = a + Offset(ab.dx * t, ab.dy * t);
    return (point - projection).distance;
  }
}

class _IndexedAngle {
  final int index;
  final double angle;
  _IndexedAngle(this.index, this.angle);
}
