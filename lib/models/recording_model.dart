/// A recorded lecture session — stores timestamped canvas events for playback.
class LectureRecording {
  final String lectureId;
  final String title;
  final DateTime createdAt;
  final int durationMs;
  final List<RecordedEvent> events;

  const LectureRecording({
    required this.lectureId,
    required this.title,
    required this.createdAt,
    required this.durationMs,
    this.events = const [],
  });

  Map<String, dynamic> toJson() => {
        'lectureId': lectureId,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'durationMs': durationMs,
        'events': events.map((e) => e.toJson()).toList(),
      };

  factory LectureRecording.fromJson(Map<String, dynamic> json) {
    return LectureRecording(
      lectureId: json['lectureId'] as String,
      title: json['title'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      durationMs: json['durationMs'] as int? ?? 0,
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => RecordedEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Types of events that can be recorded.
enum RecordedEventType {
  strokeStart,
  strokeUpdate,
  strokeEnd,
  addElement,
  removeElement,
  modifyElement,
  pageChange,
  toolChange,
  colorChange,
  clear,
}

/// A single recorded event with timestamp offset.
class RecordedEvent {
  final int timestampMs; // offset from recording start
  final RecordedEventType type;
  final Map<String, dynamic> data;

  const RecordedEvent({
    required this.timestampMs,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestampMs,
        'type': type.name,
        'data': data,
      };

  factory RecordedEvent.fromJson(Map<String, dynamic> json) {
    return RecordedEvent(
      timestampMs: json['timestampMs'] as int,
      type: RecordedEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RecordedEventType.addElement,
      ),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }
}
