import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'stroke.dart';

class CanvasObject {
  final String id;
  final String type; // 'text', 'image', 'shape', 'sticker'
  final Map<String, dynamic> data;
  final double x;
  final double y;
  final double rotation;
  final double scaleX;
  final double scaleY;
  final int zIndex;

  CanvasObject({
    String? id,
    required this.type,
    required this.data,
    this.x = 0,
    this.y = 0,
    this.rotation = 0,
    this.scaleX = 1,
    this.scaleY = 1,
    this.zIndex = 0,
  }) : id = id ?? const Uuid().v4();

  CanvasObject copyWith({
    double? x,
    double? y,
    double? rotation,
    double? scaleX,
    double? scaleY,
    int? zIndex,
    Map<String, dynamic>? data,
  }) {
    return CanvasObject(
      id: id,
      type: type,
      data: data ?? this.data,
      x: x ?? this.x,
      y: y ?? this.y,
      rotation: rotation ?? this.rotation,
      scaleX: scaleX ?? this.scaleX,
      scaleY: scaleY ?? this.scaleY,
      zIndex: zIndex ?? this.zIndex,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'data': data,
        'transform': {
          'x': x,
          'y': y,
          'rotation': rotation,
          'scaleX': scaleX,
          'scaleY': scaleY,
        },
        'zIndex': zIndex,
      };

  factory CanvasObject.fromJson(Map<String, dynamic> json) {
    final transform = json['transform'] as Map<String, dynamic>? ?? {};
    return CanvasObject(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>,
      x: (transform['x'] as num?)?.toDouble() ?? 0,
      y: (transform['y'] as num?)?.toDouble() ?? 0,
      rotation: (transform['rotation'] as num?)?.toDouble() ?? 0,
      scaleX: (transform['scaleX'] as num?)?.toDouble() ?? 1,
      scaleY: (transform['scaleY'] as num?)?.toDouble() ?? 1,
      zIndex: json['zIndex'] as int? ?? 0,
    );
  }
}

class PageData {
  final String id;
  final Color backgroundColor;
  final String? backgroundImageUrl;
  final List<Stroke> strokes;
  final List<CanvasObject> objects;
  final int order;

  PageData({
    String? id,
    this.backgroundColor = Colors.white,
    this.backgroundImageUrl,
    List<Stroke>? strokes,
    List<CanvasObject>? objects,
    this.order = 0,
  })  : id = id ?? const Uuid().v4(),
        strokes = strokes ?? [],
        objects = objects ?? [];

  PageData copyWith({
    Color? backgroundColor,
    String? backgroundImageUrl,
    List<Stroke>? strokes,
    List<CanvasObject>? objects,
    int? order,
  }) {
    return PageData(
      id: id,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      strokes: strokes ?? this.strokes,
      objects: objects ?? this.objects,
      order: order ?? this.order,
    );
  }

  List<Stroke> get visibleStrokes =>
      strokes.where((s) => !s.isDeleted).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'background': {
          'color': backgroundColor.toARGB32(),
          'image': backgroundImageUrl,
        },
        'strokes': strokes.map((s) => s.toJson()).toList(),
        'objects': objects.map((o) => o.toJson()).toList(),
        'order': order,
      };

  factory PageData.fromJson(Map<String, dynamic> json) {
    final bg = json['background'] as Map<String, dynamic>? ?? {};
    return PageData(
      id: json['id'] as String,
      backgroundColor: Color(bg['color'] as int? ?? 0xFFFFFFFF),
      backgroundImageUrl: bg['image'] as String?,
      strokes: (json['strokes'] as List?)
              ?.map((s) => Stroke.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      objects: (json['objects'] as List?)
              ?.map((o) => CanvasObject.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
    );
  }
}
