import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'page_data.dart';
import '../core/constants/app_constants.dart';

class Lecture {
  final String id;
  final String title;
  final double pageWidth;
  final double pageHeight;
  final List<PageData> pages;
  final String? ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lecture({
    String? id,
    this.title = 'Untitled Lecture',
    this.pageWidth = AppConstants.defaultPageWidth,
    this.pageHeight = AppConstants.defaultPageHeight,
    List<PageData>? pages,
    this.ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        pages = pages ?? [PageData(order: 0)],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Lecture copyWith({
    String? title,
    double? pageWidth,
    double? pageHeight,
    List<PageData>? pages,
    DateTime? updatedAt,
  }) {
    return Lecture(
      id: id,
      title: title ?? this.title,
      pageWidth: pageWidth ?? this.pageWidth,
      pageHeight: pageHeight ?? this.pageHeight,
      pages: pages ?? this.pages,
      ownerId: ownerId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Serialize to .icn JSON format
  Map<String, dynamic> toIcn() => {
        'version': '1.0',
        'metadata': {
          'id': id,
          'title': title,
          'author': ownerId,
          'created': createdAt.toIso8601String(),
          'modified': updatedAt.toIso8601String(),
        },
        'settings': {
          'pageWidth': pageWidth,
          'pageHeight': pageHeight,
        },
        'pages': pages.map((p) => p.toJson()).toList(),
      };

  factory Lecture.fromIcn(Map<String, dynamic> json) {
    final metadata = json['metadata'] as Map<String, dynamic>? ?? {};
    final settings = json['settings'] as Map<String, dynamic>? ?? {};

    // Parse pages defensively: skip any unreadable page rather than
    // failing the whole open.
    final pages = <PageData>[];
    for (final p in (json['pages'] as List?) ?? const []) {
      if (p is! Map) continue;
      try {
        pages.add(PageData.fromJson(Map<String, dynamic>.from(p)));
      } catch (err) {
        debugPrint('Skipping unreadable page: $err');
      }
    }

    DateTime parseDate(dynamic v) {
      if (v is String) {
        return DateTime.tryParse(v) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return Lecture(
      id: metadata['id'] as String? ?? const Uuid().v4(),
      title: metadata['title'] as String? ?? 'Untitled',
      pageWidth: (settings['pageWidth'] as num?)?.toDouble() ??
          AppConstants.defaultPageWidth,
      pageHeight: (settings['pageHeight'] as num?)?.toDouble() ??
          AppConstants.defaultPageHeight,
      pages: pages.isNotEmpty ? pages : [PageData(order: 0)],
      ownerId: metadata['author'] as String?,
      createdAt: parseDate(metadata['created']),
      updatedAt: parseDate(metadata['modified']),
    );
  }
}
