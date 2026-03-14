import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import '../../models/room_model.dart';
import '../../models/canvas_element.dart';
import 'sync_service.dart';

/// Firebase Realtime Database implementation of [SyncService].
///
/// RTDB structure:
/// ```
/// rooms/{roomId}/
///   info/           → RoomInfo JSON
///   elements/{pageId}/{elementId} → CanvasElement JSON + userId
///   cursors/{userId} → CursorEvent JSON
///   participants/{userId} → Participant JSON
/// ```
class FirebaseSyncService implements SyncService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  DatabaseReference _roomRef(String roomId) => _db.child('rooms/$roomId');

  /// Generate a random 6-character invite code.
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  @override
  Future<String> createRoom({
    required String lectureId,
    required String hostId,
    required String hostName,
    required String title,
  }) async {
    final roomRef = _db.child('rooms').push();
    final roomId = roomRef.key!;
    final inviteCode = _generateInviteCode();

    final roomInfo = RoomInfo(
      roomId: roomId,
      hostId: hostId,
      title: title,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    await roomRef.child('info').set(roomInfo.toJson());

    // Add host as instructor participant
    await roomRef.child('participants/$hostId').set(
      Participant(
        userId: hostId,
        displayName: hostName,
        role: 'instructor',
        canDraw: true,
        isOnline: true,
      ).toJson(),
    );

    // Auto-remove participant on disconnect
    await roomRef
        .child('participants/$hostId/isOnline')
        .onDisconnect()
        .set(false);

    // Store invite code index for lookup
    await _db.child('inviteCodes/$inviteCode').set(roomId);

    return inviteCode;
  }

  @override
  Future<String?> joinRoom({
    required String inviteCode,
    required String userId,
    required String displayName,
  }) async {
    // Look up room ID by invite code
    final codeSnap =
        await _db.child('inviteCodes/$inviteCode').get();
    if (!codeSnap.exists) return null;

    final roomId = codeSnap.value as String;

    // Add participant
    final participantRef =
        _roomRef(roomId).child('participants/$userId');
    await participantRef.set(
      Participant(
        userId: userId,
        displayName: displayName,
        role: 'student',
        canDraw: true,
        isOnline: true,
      ).toJson(),
    );

    // Auto-set offline on disconnect
    await participantRef.child('isOnline').onDisconnect().set(false);

    return roomId;
  }

  @override
  Future<void> leaveRoom({
    required String roomId,
    required String userId,
  }) async {
    // Remove participant and cursor
    await _roomRef(roomId).child('participants/$userId').remove();
    await _roomRef(roomId).child('cursors/$userId').remove();
  }

  @override
  Future<void> closeRoom(String roomId) async {
    // Remove invite code index
    final infoSnap = await _roomRef(roomId).child('info').get();
    if (infoSnap.exists) {
      final data = Map<String, dynamic>.from(infoSnap.value as Map);
      final inviteCode = data['inviteCode'] as String?;
      if (inviteCode != null) {
        await _db.child('inviteCodes/$inviteCode').remove();
      }
    }
    // Remove entire room
    await _roomRef(roomId).remove();
  }

  @override
  Stream<ElementEvent> elementStream(String roomId, String pageId) {
    final ref = _roomRef(roomId).child('elements/$pageId');
    final controller = StreamController<ElementEvent>.broadcast();

    final addSub = ref.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        controller.add(ElementEvent(
          elementId: event.snapshot.key!,
          elementJson: Map<String, dynamic>.from(event.snapshot.value as Map),
          action: ElementAction.added,
        ));
      }
    });

    final changeSub = ref.onChildChanged.listen((event) {
      if (event.snapshot.value != null) {
        controller.add(ElementEvent(
          elementId: event.snapshot.key!,
          elementJson: Map<String, dynamic>.from(event.snapshot.value as Map),
          action: ElementAction.modified,
        ));
      }
    });

    final removeSub = ref.onChildRemoved.listen((event) {
      controller.add(ElementEvent(
        elementId: event.snapshot.key!,
        action: ElementAction.removed,
      ));
    });

    controller.onCancel = () {
      addSub.cancel();
      changeSub.cancel();
      removeSub.cancel();
    };

    return controller.stream;
  }

  @override
  Stream<List<CursorEvent>> cursorStream(String roomId) {
    final ref = _roomRef(roomId).child('cursors');
    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return <CursorEvent>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((e) {
        final cursorData = Map<String, dynamic>.from(e.value as Map);
        cursorData['userId'] = e.key;
        return CursorEvent.fromJson(cursorData);
      }).toList();
    });
  }

  @override
  Stream<List<Participant>> participantStream(String roomId) {
    final ref = _roomRef(roomId).child('participants');
    return ref.onValue.map((event) {
      if (event.snapshot.value == null) return <Participant>[];
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      return data.entries.map((e) {
        final pData = Map<String, dynamic>.from(e.value as Map);
        return Participant.fromJson(e.key, pData);
      }).toList();
    });
  }

  @override
  Future<void> sendElement({
    required String roomId,
    required String pageId,
    required CanvasElement element,
    required String userId,
  }) async {
    final json = element.toJson();
    json['_userId'] = userId;
    await _roomRef(roomId)
        .child('elements/$pageId/${element.id}')
        .set(json);
  }

  @override
  Future<void> removeElement({
    required String roomId,
    required String pageId,
    required String elementId,
  }) async {
    await _roomRef(roomId)
        .child('elements/$pageId/$elementId')
        .remove();
  }

  @override
  Future<void> sendCursor({
    required String roomId,
    required CursorEvent cursor,
  }) async {
    await _roomRef(roomId)
        .child('cursors/${cursor.userId}')
        .set(cursor.toJson());
  }

  @override
  Future<void> setPermission({
    required String roomId,
    required String userId,
    required bool canDraw,
  }) async {
    await _roomRef(roomId)
        .child('participants/$userId/canDraw')
        .set(canDraw);
  }

  @override
  Future<RoomInfo?> getRoomByInviteCode(String inviteCode) async {
    final codeSnap =
        await _db.child('inviteCodes/$inviteCode').get();
    if (!codeSnap.exists) return null;

    final roomId = codeSnap.value as String;
    final infoSnap = await _roomRef(roomId).child('info').get();
    if (!infoSnap.exists) return null;

    final data = Map<String, dynamic>.from(infoSnap.value as Map);
    return RoomInfo.fromJson(data);
  }
}
