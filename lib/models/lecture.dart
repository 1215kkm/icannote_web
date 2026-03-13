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
    return Lecture(
      id: metadata['id'] as String? ?? const Uuid().v4(),
      title: metadata['title'] as String? ?? 'Untitled',
      pageWidth: (settings['pageWidth'] as num?)?.toDouble() ??
          AppConstants.defaultPageWidth,
      pageHeight: (settings['pageHeight'] as num?)?.toDouble() ??
          AppConstants.defaultPageHeight,
      pages: (json['pages'] as List?)
              ?.map((p) => PageData.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [PageData(order: 0)],
      ownerId: metadata['author'] as String?,
      createdAt: metadata['created'] != null
          ? DateTime.parse(metadata['created'] as String)
          : DateTime.now(),
      updatedAt: metadata['modified'] != null
          ? DateTime.parse(metadata['modified'] as String)
          : DateTime.now(),
    );
  }
}
