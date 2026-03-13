import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum DrawingTool {
  none,
  pen,
  highlighter,
  line,
  curve,
  rectangle,
  circle,
  triangle,
  polygon,
  eraser,
  strokeEraser,
  selection,
  rotation,
  text,
  pan,
  laserPointer,
  sticker,
  graph,
  autoShape,
}

class StrokePoint {
  final double x;
  final double y;
  final double pressure;

  const StrokePoint(this.x, this.y, [this.pressure = 1.0]);

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'p': pressure};

  factory StrokePoint.fromJson(Map<String, dynamic> json) => StrokePoint(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
        (json['p'] as num?)?.toDouble() ?? 1.0,
      );

  Offset toOffset() => Offset(x, y);
}

class Stroke {
  final String id;
  final DrawingTool tool;
  final Color color;
  final double strokeWidth;
  final List<StrokePoint> points;
  final int timestamp;
  final bool isDeleted;

  Stroke({
    String? id,
    required this.tool,
    required this.color,
    required this.strokeWidth,
    required this.points,
    int? timestamp,
    this.isDeleted = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  Stroke copyWith({
    String? id,
    DrawingTool? tool,
    Color? color,
    double? strokeWidth,
    List<StrokePoint>? points,
    int? timestamp,
    bool? isDeleted,
  }) {
    return Stroke(
      id: id ?? this.id,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      points: points ?? this.points,
      timestamp: timestamp ?? this.timestamp,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Paint toPaint() {
    final paint = Paint()
      ..color = tool == DrawingTool.highlighter
          ? color.withValues(alpha: 0.4)
          : color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    if (tool == DrawingTool.highlighter) {
      paint.blendMode = BlendMode.multiply;
    }

    return paint;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tool': tool.name,
        'color': color.toARGB32(),
        'width': strokeWidth,
        'points': points.map((p) => p.toJson()).toList(),
        'timestamp': timestamp,
        'isDeleted': isDeleted,
      };

  factory Stroke.fromJson(Map<String, dynamic> json) => Stroke(
        id: json['id'] as String,
        tool: DrawingTool.values.firstWhere(
          (t) => t.name == json['tool'],
          orElse: () => DrawingTool.pen,
        ),
        color: Color(json['color'] as int),
        strokeWidth: (json['width'] as num).toDouble(),
        points: (json['points'] as List)
            .map((p) => StrokePoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        timestamp: json['timestamp'] as int,
        isDeleted: json['isDeleted'] as bool? ?? false,
      );
}
