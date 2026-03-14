import 'package:flutter/material.dart';

/// Information about a collaboration room.
class RoomInfo {
  final String roomId;
  final String hostId;
  final String title;
  final String inviteCode;
  final DateTime createdAt;

  const RoomInfo({
    required this.roomId,
    required this.hostId,
    required this.title,
    required this.inviteCode,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'hostId': hostId,
        'title': title,
        'inviteCode': inviteCode,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory RoomInfo.fromJson(Map<String, dynamic> json) => RoomInfo(
        roomId: json['roomId'] as String,
        hostId: json['hostId'] as String,
        title: json['title'] as String? ?? '',
        inviteCode: json['inviteCode'] as String,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}

/// A participant in a collaboration room.
class Participant {
  final String userId;
  final String displayName;
  final String role; // 'instructor' or 'student'
  final bool canDraw;
  final bool isOnline;

  const Participant({
    required this.userId,
    required this.displayName,
    this.role = 'student',
    this.canDraw = true,
    this.isOnline = true,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'role': role,
        'canDraw': canDraw,
        'isOnline': isOnline,
      };

  factory Participant.fromJson(String userId, Map<String, dynamic> json) =>
      Participant(
        userId: userId,
        displayName: json['displayName'] as String? ?? '',
        role: json['role'] as String? ?? 'student',
        canDraw: json['canDraw'] as bool? ?? true,
        isOnline: json['isOnline'] as bool? ?? false,
      );
}

/// A cursor position event from a remote user.
class CursorEvent {
  final String userId;
  final String displayName;
  final double x;
  final double y;
  final Color color;
  final String tool;
  final int timestamp;

  const CursorEvent({
    required this.userId,
    required this.displayName,
    required this.x,
    required this.y,
    required this.color,
    this.tool = '',
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'x': x,
        'y': y,
        'color': color.toARGB32(),
        'tool': tool,
        'timestamp': timestamp,
      };

  factory CursorEvent.fromJson(Map<String, dynamic> json) => CursorEvent(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String? ?? '',
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        color: Color(json['color'] as int? ?? 0xFF000000),
        tool: json['tool'] as String? ?? '',
        timestamp: json['timestamp'] as int? ?? 0,
      );
}

/// An element event received from the sync service.
enum ElementAction { added, modified, removed }

class ElementEvent {
  final String elementId;
  final Map<String, dynamic>? elementJson;
  final ElementAction action;
  final String? userId;

  const ElementEvent({
    required this.elementId,
    this.elementJson,
    required this.action,
    this.userId,
  });
}
