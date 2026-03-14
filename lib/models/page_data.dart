import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'canvas_element.dart';

class PageData {
  final String id;
  final Color backgroundColor;
  final String? backgroundImageUrl;
  final List<CanvasElement> elements;
  final int order;

  PageData({
    String? id,
    this.backgroundColor = Colors.white,
    this.backgroundImageUrl,
    List<CanvasElement>? elements,
    this.order = 0,
  })  : id = id ?? const Uuid().v4(),
        elements = elements ?? [];

  PageData copyWith({
    Color? backgroundColor,
    String? backgroundImageUrl,
    List<CanvasElement>? elements,
    int? order,
  }) {
    return PageData(
      id: id,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImageUrl: backgroundImageUrl ?? this.backgroundImageUrl,
      elements: elements ?? this.elements,
      order: order ?? this.order,
    );
  }

  List<CanvasElement> get visibleElements =>
      elements.where((e) => !e.isDeleted).toList();

  Map<String, dynamic> toJson() => {
        'id': id,
        'background': {
          'color': backgroundColor.toARGB32(),
          'image': backgroundImageUrl,
        },
        'elements': elements.map((e) => e.toJson()).toList(),
        'order': order,
      };

  factory PageData.fromJson(Map<String, dynamic> json) {
    final bg = json['background'] as Map<String, dynamic>? ?? {};
    return PageData(
      id: json['id'] as String,
      backgroundColor: Color(bg['color'] as int? ?? 0xFFFFFFFF),
      backgroundImageUrl: bg['image'] as String?,
      elements: (json['elements'] as List?)
              ?.map((e) =>
                  CanvasElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      order: json['order'] as int? ?? 0,
    );
  }
}
