import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ──────────────────── JSON parse helpers ────────────────────
// Tolerant helpers so a single malformed/foreign (.icn) element never
// throws and aborts the whole file load.

double _numAt(List? list, int index, double fallback) {
  if (list == null || index >= list.length) return fallback;
  final v = list[index];
  return v is num ? v.toDouble() : fallback;
}

Rect _rectFromJson(dynamic raw) {
  final list = raw is List ? raw : null;
  return Rect.fromLTRB(
    _numAt(list, 0, 0),
    _numAt(list, 1, 0),
    _numAt(list, 2, 0),
    _numAt(list, 3, 0),
  );
}

Color _colorFromJson(dynamic raw, [int fallback = 0xFF000000]) {
  if (raw is num) return Color(raw.toInt());
  return Color(fallback);
}

/// Base class for all drawable elements on the canvas
abstract class CanvasElement {
  final String id;
  final int zIndex;
  final double rotation;
  final int timestamp;
  final bool isDeleted;

  CanvasElement({
    String? id,
    this.zIndex = 0,
    this.rotation = 0,
    int? timestamp,
    this.isDeleted = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// Paint this element onto the canvas
  void paint(Canvas canvas, Size size);

  /// Get the bounding box for hit testing
  Rect get boundingBox;

  /// Serialize to JSON
  Map<String, dynamic> toJson();

  /// Create a copy with modified fields
  CanvasElement copyWithBase({
    int? zIndex,
    double? rotation,
    bool? isDeleted,
  });

  /// Check if a point is inside this element (for hit testing)
  bool containsPoint(Offset point) {
    return boundingBox.contains(point);
  }

  /// Factory to deserialize from JSON
  static CanvasElement fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    switch (type) {
      case 'stroke':
        return StrokeElement.fromJson(json);
      case 'shape':
        return ShapeElement.fromJson(json);
      case 'text':
        return TextCanvasElement.fromJson(json);
      case 'image':
        return ImageCanvasElement.fromJson(json);
      case 'sticker':
        return StickerElement.fromJson(json);
      default:
        return StrokeElement.fromJson(json);
    }
  }
}

// ──────────────────── Stroke Element ────────────────────

enum StrokeTool { pen, highlighter, line, curve }

class StrokePoint {
  final double x;
  final double y;
  final double pressure;

  const StrokePoint(this.x, this.y, [this.pressure = 1.0]);

  Offset toOffset() => Offset(x, y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'p': pressure};

  factory StrokePoint.fromJson(Map<String, dynamic> json) => StrokePoint(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
        (json['p'] as num?)?.toDouble() ?? 1.0,
      );
}

class StrokeElement extends CanvasElement {
  final StrokeTool tool;
  final Color color;
  final double strokeWidth;
  final List<StrokePoint> points;

  StrokeElement({
    super.id,
    super.zIndex,
    super.rotation,
    super.timestamp,
    super.isDeleted,
    required this.tool,
    required this.color,
    required this.strokeWidth,
    required this.points,
  });

  Paint get strokePaint {
    final paint = Paint()
      ..color = tool == StrokeTool.highlighter
          ? color.withValues(alpha: 0.4)
          : color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;
    if (tool == StrokeTool.highlighter) {
      paint.blendMode = BlendMode.multiply;
    }
    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = strokePaint;

    if (tool == StrokeTool.line) {
      if (points.length >= 2) {
        canvas.drawLine(
          points.first.toOffset(),
          points.last.toOffset(),
          paint,
        );
      }
      return;
    }

    if (points.length == 1) {
      canvas.drawCircle(
        points.first.toOffset(),
        strokeWidth / 2,
        paint..style = PaintingStyle.fill,
      );
      paint.style = PaintingStyle.stroke;
      return;
    }

    // Use Catmull-Rom-style smoothing for pen/highlighter
    final path = Path();
    path.moveTo(points.first.x, points.first.y);

    if (points.length == 2) {
      path.lineTo(points.last.x, points.last.y);
    } else {
      // Smooth curve: use midpoints as control points
      for (int i = 1; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        // Control point is the current point, end is midpoint between current and next
        final midX = (p1.x + p2.x) / 2;
        final midY = (p1.y + p2.y) / 2;
        path.quadraticBezierTo(p1.x, p1.y, midX, midY);
      }
      // Last segment
      final last = points.last;
      final secondLast = points[points.length - 2];
      path.quadraticBezierTo(secondLast.x, secondLast.y, last.x, last.y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  Rect get boundingBox {
    if (points.isEmpty) return Rect.zero;
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final p in points) {
      if (p.x < minX) minX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.x > maxX) maxX = p.x;
      if (p.y > maxY) maxY = p.y;
    }
    final pad = strokeWidth / 2;
    return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
  }

  StrokeElement copyWith({
    StrokeTool? tool,
    Color? color,
    double? strokeWidth,
    List<StrokePoint>? points,
    int? zIndex,
    double? rotation,
    bool? isDeleted,
  }) {
    return StrokeElement(
      id: id,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      points: points ?? this.points,
      zIndex: zIndex ?? this.zIndex,
      rotation: rotation ?? this.rotation,
      timestamp: timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  CanvasElement copyWithBase({int? zIndex, double? rotation, bool? isDeleted}) {
    return copyWith(zIndex: zIndex, rotation: rotation, isDeleted: isDeleted);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'stroke',
        'id': id,
        'tool': tool.name,
        'color': color.toARGB32(),
        'width': strokeWidth,
        'points': points.map((p) => p.toJson()).toList(),
        'zIndex': zIndex,
        'rotation': rotation,
        'timestamp': timestamp,
        'isDeleted': isDeleted,
      };

  factory StrokeElement.fromJson(Map<String, dynamic> json) => StrokeElement(
        id: json['id'] as String?,
        tool: StrokeTool.values.firstWhere(
          (t) => t.name == json['tool'],
          orElse: () => StrokeTool.pen,
        ),
        color: _colorFromJson(json['color']),
        strokeWidth: (json['width'] as num?)?.toDouble() ?? 3.0,
        points: ((json['points'] as List?) ?? const [])
            .whereType<Map>()
            .map((p) =>
                StrokePoint.fromJson(Map<String, dynamic>.from(p)))
            .toList(),
        zIndex: json['zIndex'] as int? ?? 0,
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
        timestamp: json['timestamp'] as int? ?? 0,
        isDeleted: json['isDeleted'] as bool? ?? false,
      );
}

// ──────────────────── Shape Element ────────────────────

enum ShapeType { rectangle, circle, triangle, polygon }

class ShapeElement extends CanvasElement {
  final ShapeType shapeType;
  final Rect rect;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeWidth;
  final int sides; // For polygon

  ShapeElement({
    super.id,
    super.zIndex,
    super.rotation,
    super.timestamp,
    super.isDeleted,
    required this.shapeType,
    required this.rect,
    required this.strokeColor,
    this.fillColor,
    required this.strokeWidth,
    this.sides = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    Paint? fillPaint;
    if (fillColor != null) {
      fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
    }

    if (rotation != 0) {
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(rotation);
      canvas.translate(-rect.center.dx, -rect.center.dy);
    }

    switch (shapeType) {
      case ShapeType.rectangle:
        if (fillPaint != null) canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, strokePaint);
      case ShapeType.circle:
        if (fillPaint != null) canvas.drawOval(rect, fillPaint);
        canvas.drawOval(rect, strokePaint);
      case ShapeType.triangle:
        final path = _trianglePath();
        if (fillPaint != null) canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
      case ShapeType.polygon:
        final path = _polygonPath();
        if (fillPaint != null) canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, strokePaint);
    }

    if (rotation != 0) canvas.restore();
  }

  Path _trianglePath() {
    final path = Path();
    path.moveTo(rect.center.dx, rect.top);
    path.lineTo(rect.left, rect.bottom);
    path.lineTo(rect.right, rect.bottom);
    path.close();
    return path;
  }

  Path _polygonPath() {
    final path = Path();
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final rx = rect.width / 2;
    final ry = rect.height / 2;
    for (int i = 0; i < sides; i++) {
      final angle = (i * 2 * math.pi / sides) - (math.pi / 2);
      final x = cx + rx * math.cos(angle);
      final y = cy + ry * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  Rect get boundingBox => rect.inflate(strokeWidth / 2);

  ShapeElement copyWith({
    ShapeType? shapeType,
    Rect? rect,
    Color? strokeColor,
    Color? fillColor,
    double? strokeWidth,
    int? sides,
    int? zIndex,
    double? rotation,
    bool? isDeleted,
  }) {
    return ShapeElement(
      id: id,
      shapeType: shapeType ?? this.shapeType,
      rect: rect ?? this.rect,
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor ?? this.fillColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      sides: sides ?? this.sides,
      zIndex: zIndex ?? this.zIndex,
      rotation: rotation ?? this.rotation,
      timestamp: timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  CanvasElement copyWithBase({int? zIndex, double? rotation, bool? isDeleted}) {
    return copyWith(zIndex: zIndex, rotation: rotation, isDeleted: isDeleted);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'shape',
        'id': id,
        'shapeType': shapeType.name,
        'rect': [rect.left, rect.top, rect.right, rect.bottom],
        'strokeColor': strokeColor.toARGB32(),
        'fillColor': fillColor?.toARGB32(),
        'width': strokeWidth,
        'sides': sides,
        'zIndex': zIndex,
        'rotation': rotation,
        'timestamp': timestamp,
        'isDeleted': isDeleted,
      };

  factory ShapeElement.fromJson(Map<String, dynamic> json) {
    return ShapeElement(
      id: json['id'] as String?,
      shapeType: ShapeType.values.firstWhere(
        (t) => t.name == json['shapeType'],
        orElse: () => ShapeType.rectangle,
      ),
      rect: _rectFromJson(json['rect']),
      strokeColor: _colorFromJson(json['strokeColor']),
      fillColor:
          json['fillColor'] != null ? _colorFromJson(json['fillColor']) : null,
      strokeWidth: (json['width'] as num?)?.toDouble() ?? 2.0,
      sides: json['sides'] as int? ?? 5,
      zIndex: json['zIndex'] as int? ?? 0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

// ──────────────────── Text Element ────────────────────

class TextCanvasElement extends CanvasElement {
  final String text;
  final Offset position;
  final double fontSize;
  final Color color;
  final bool isBold;
  final bool isItalic;
  final double maxWidth;

  TextCanvasElement({
    super.id,
    super.zIndex,
    super.rotation,
    super.timestamp,
    super.isDeleted,
    required this.text,
    required this.position,
    this.fontSize = 16,
    this.color = Colors.black,
    this.isBold = false,
    this.isItalic = false,
    this.maxWidth = 300,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(
      fontSize: fontSize,
      color: color,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final tp = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: null,
    );
    tp.layout(maxWidth: maxWidth);

    if (rotation != 0) {
      canvas.save();
      canvas.translate(position.dx + tp.width / 2, position.dy + tp.height / 2);
      canvas.rotate(rotation);
      canvas.translate(-(position.dx + tp.width / 2), -(position.dy + tp.height / 2));
    }

    tp.paint(canvas, position);

    if (rotation != 0) canvas.restore();
  }

  @override
  Rect get boundingBox {
    final textStyle = TextStyle(fontSize: fontSize);
    final tp = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    return Rect.fromLTWH(position.dx, position.dy, tp.width, tp.height);
  }

  TextCanvasElement copyWith({
    String? text,
    Offset? position,
    double? fontSize,
    Color? color,
    bool? isBold,
    bool? isItalic,
    double? maxWidth,
    int? zIndex,
    double? rotation,
    bool? isDeleted,
  }) {
    return TextCanvasElement(
      id: id,
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      maxWidth: maxWidth ?? this.maxWidth,
      zIndex: zIndex ?? this.zIndex,
      rotation: rotation ?? this.rotation,
      timestamp: timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  CanvasElement copyWithBase({int? zIndex, double? rotation, bool? isDeleted}) {
    return copyWith(zIndex: zIndex, rotation: rotation, isDeleted: isDeleted);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'id': id,
        'text': text,
        'position': [position.dx, position.dy],
        'fontSize': fontSize,
        'color': color.toARGB32(),
        'isBold': isBold,
        'isItalic': isItalic,
        'maxWidth': maxWidth,
        'zIndex': zIndex,
        'rotation': rotation,
        'timestamp': timestamp,
        'isDeleted': isDeleted,
      };

  factory TextCanvasElement.fromJson(Map<String, dynamic> json) {
    final pos = json['position'] as List?;
    return TextCanvasElement(
      id: json['id'] as String?,
      text: json['text'] as String? ?? '',
      position: Offset(
        _numAt(pos, 0, 0),
        _numAt(pos, 1, 0),
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16,
      color: _colorFromJson(json['color']),
      isBold: json['isBold'] as bool? ?? false,
      isItalic: json['isItalic'] as bool? ?? false,
      maxWidth: (json['maxWidth'] as num?)?.toDouble() ?? 300,
      zIndex: json['zIndex'] as int? ?? 0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

// ──────────────────── Image Element ────────────────────

class ImageCanvasElement extends CanvasElement {
  final String imageUrl;
  final Rect rect;

  ImageCanvasElement({
    super.id,
    super.zIndex,
    super.rotation,
    super.timestamp,
    super.isDeleted,
    required this.imageUrl,
    required this.rect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Image painting requires async loading - handled by widget layer
    // Draw placeholder
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, paint);
    final border = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, border);
  }

  @override
  Rect get boundingBox => rect;

  @override
  CanvasElement copyWithBase({int? zIndex, double? rotation, bool? isDeleted}) {
    return ImageCanvasElement(
      id: id,
      imageUrl: imageUrl,
      rect: rect,
      zIndex: zIndex ?? this.zIndex,
      rotation: rotation ?? this.rotation,
      timestamp: timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'id': id,
        'imageUrl': imageUrl,
        'rect': [rect.left, rect.top, rect.right, rect.bottom],
        'zIndex': zIndex,
        'rotation': rotation,
        'timestamp': timestamp,
        'isDeleted': isDeleted,
      };

  factory ImageCanvasElement.fromJson(Map<String, dynamic> json) {
    return ImageCanvasElement(
      id: json['id'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      rect: _rectFromJson(json['rect']),
      zIndex: json['zIndex'] as int? ?? 0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}

// ──────────────────── Sticker Element ────────────────────

class StickerElement extends CanvasElement {
  final Rect rect;
  final Color coverColor;
  final bool isRevealed;

  StickerElement({
    super.id,
    super.zIndex,
    super.rotation,
    super.timestamp,
    super.isDeleted,
    required this.rect,
    this.coverColor = Colors.amber,
    this.isRevealed = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (isRevealed) return; // Don't paint if revealed
    final paint = Paint()
      ..color = coverColor
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, paint);
    // Draw "?" icon
    final textPainter = TextPainter(
      text: TextSpan(
        text: '?',
        style: TextStyle(
          fontSize: rect.height * 0.5,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  Rect get boundingBox => rect;

  StickerElement copyWith({
    Rect? rect,
    Color? coverColor,
    bool? isRevealed,
    int? zIndex,
    double? rotation,
    bool? isDeleted,
  }) {
    return StickerElement(
      id: id,
      rect: rect ?? this.rect,
      coverColor: coverColor ?? this.coverColor,
      isRevealed: isRevealed ?? this.isRevealed,
      zIndex: zIndex ?? this.zIndex,
      rotation: rotation ?? this.rotation,
      timestamp: timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  CanvasElement copyWithBase({int? zIndex, double? rotation, bool? isDeleted}) {
    return copyWith(
      zIndex: zIndex,
      rotation: rotation,
      isDeleted: isDeleted,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'sticker',
        'id': id,
        'rect': [rect.left, rect.top, rect.right, rect.bottom],
        'coverColor': coverColor.toARGB32(),
        'isRevealed': isRevealed,
        'zIndex': zIndex,
        'rotation': rotation,
        'timestamp': timestamp,
        'isDeleted': isDeleted,
      };

  factory StickerElement.fromJson(Map<String, dynamic> json) {
    return StickerElement(
      id: json['id'] as String?,
      rect: _rectFromJson(json['rect']),
      coverColor: _colorFromJson(json['coverColor'], 0xFFFFC107),
      isRevealed: json['isRevealed'] as bool? ?? false,
      zIndex: json['zIndex'] as int? ?? 0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }
}
