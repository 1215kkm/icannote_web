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
    bool clearBackgroundImage = false,
    List<CanvasElement>? elements,
    int? order,
  }) {
    return PageData(
      id: id,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImageUrl: clearBackgroundImage
          ? null
          : (backgroundImageUrl ?? this.backgroundImageUrl),
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
    final rawColor = bg['color'];
    // Parse elements one by one so a single corrupt/foreign element
    // is skipped instead of aborting the entire file open.
    final elements = <CanvasElement>[];
    for (final e in (json['elements'] as List?) ?? const []) {
      if (e is! Map) continue;
      try {
        elements.add(CanvasElement.fromJson(Map<String, dynamic>.from(e)));
      } catch (err) {
        debugPrint('Skipping unreadable canvas element: $err');
      }
    }
    return PageData(
      id: json['id'] as String?,
      backgroundColor:
          Color(rawColor is num ? rawColor.toInt() : 0xFFFFFFFF),
      backgroundImageUrl: bg['image'] as String?,
      elements: elements,
      order: json['order'] as int? ?? 0,
    );
  }
}
