import '../../models/room_model.dart';
import '../../models/canvas_element.dart';

/// Abstract interface for real-time collaboration sync.
///
/// Implementations can use Firebase Realtime Database, WebSocket, or
/// any other transport. The rest of the app only depends on this interface.
abstract class SyncService {
  /// Create a new collaboration room. Returns the invite code.
  Future<String> createRoom({
    required String lectureId,
    required String hostId,
    required String hostName,
    required String title,
  });

  /// Join an existing room by invite code.
  /// Returns the roomId if successful, null if code not found.
  Future<String?> joinRoom({
    required String inviteCode,
    required String userId,
    required String displayName,
  });

  /// Leave the current room. Cleans up participant and cursor data.
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  });

  /// Close a room (host only). Removes all room data.
  Future<void> closeRoom(String roomId);

  /// Stream of element events (add/modify/remove) for a specific page.
  Stream<ElementEvent> elementStream(String roomId, String pageId);

  /// Stream of cursor positions from all participants.
  Stream<List<CursorEvent>> cursorStream(String roomId);

  /// Stream of participant list changes.
  Stream<List<Participant>> participantStream(String roomId);

  /// Send/update an element to the room.
  Future<void> sendElement({
    required String roomId,
    required String pageId,
    required CanvasElement element,
    required String userId,
  });

  /// Mark an element as removed.
  Future<void> removeElement({
    required String roomId,
    required String pageId,
    required String elementId,
  });

  /// Send cursor position update.
  Future<void> sendCursor({
    required String roomId,
    required CursorEvent cursor,
  });

  /// Set draw permission for a participant (host only).
  Future<void> setPermission({
    required String roomId,
    required String userId,
    required bool canDraw,
  });

  /// Get room info by invite code.
  Future<RoomInfo?> getRoomByInviteCode(String inviteCode);
}
