import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/room_model.dart';
import '../models/canvas_element.dart';
import '../services/sync/sync_service.dart';
import '../services/sync/firebase_sync_service.dart';
import 'auth_provider.dart';
import 'canvas_provider.dart';
import 'lecture_provider.dart';

class SyncState {
  final String? roomId;
  final String? inviteCode;
  final bool isConnected;
  final bool isHost;
  final bool canDraw;
  final List<Participant> participants;
  final List<CursorEvent> remoteCursors;
  final String? currentPageId;

  const SyncState({
    this.roomId,
    this.inviteCode,
    this.isConnected = false,
    this.isHost = false,
    this.canDraw = true,
    this.participants = const [],
    this.remoteCursors = const [],
    this.currentPageId,
  });

  SyncState copyWith({
    String? roomId,
    String? inviteCode,
    bool? isConnected,
    bool? isHost,
    bool? canDraw,
    List<Participant>? participants,
    List<CursorEvent>? remoteCursors,
    String? currentPageId,
  }) {
    return SyncState(
      roomId: roomId ?? this.roomId,
      inviteCode: inviteCode ?? this.inviteCode,
      isConnected: isConnected ?? this.isConnected,
      isHost: isHost ?? this.isHost,
      canDraw: canDraw ?? this.canDraw,
      participants: participants ?? this.participants,
      remoteCursors: remoteCursors ?? this.remoteCursors,
      currentPageId: currentPageId ?? this.currentPageId,
    );
  }
}

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;
  final SyncService _syncService = FirebaseSyncService();

  StreamSubscription? _elementSub;
  StreamSubscription? _cursorSub;
  StreamSubscription? _participantSub;

  // Debounce cursor sends
  DateTime _lastCursorSend = DateTime.now();
  static const _cursorThrottleMs = 50;

  // Track which element IDs came from remote to avoid echo
  final Set<String> _remoteElementIds = {};

  SyncNotifier(this._ref) : super(const SyncState());

  String? get _currentUserId =>
      _ref.read(authProvider).user?.uid;

  String? get _currentUserName =>
      _ref.read(authProvider).user?.displayName;

  /// Create a new collaboration room.
  Future<String?> createRoom(String title) async {
    final userId = _currentUserId;
    final userName = _currentUserName;
    if (userId == null) return null;

    final lecture = _ref.read(lectureProvider).lecture;
    if (lecture == null) return null;

    try {
      final inviteCode = await _syncService.createRoom(
        lectureId: lecture.id,
        hostId: userId,
        hostName: userName ?? 'Host',
        title: title,
      );

      // Look up the roomId
      final roomInfo = await _syncService.getRoomByInviteCode(inviteCode);
      if (roomInfo == null) return null;

      state = state.copyWith(
        roomId: roomInfo.roomId,
        inviteCode: inviteCode,
        isConnected: true,
        isHost: true,
        canDraw: true,
      );

      _subscribeToRoom(roomInfo.roomId);
      return inviteCode;
    } catch (e) {
      debugPrint('Failed to create room: $e');
      return null;
    }
  }

  /// Join an existing room by invite code.
  Future<bool> joinRoom(String inviteCode) async {
    final userId = _currentUserId;
    final userName = _currentUserName;
    if (userId == null) return false;

    try {
      final roomId = await _syncService.joinRoom(
        inviteCode: inviteCode.toUpperCase().trim(),
        userId: userId,
        displayName: userName ?? 'User',
      );

      if (roomId == null) return false;

      state = state.copyWith(
        roomId: roomId,
        inviteCode: inviteCode,
        isConnected: true,
        isHost: false,
        canDraw: true,
      );

      _subscribeToRoom(roomId);
      return true;
    } catch (e) {
      debugPrint('Failed to join room: $e');
      return false;
    }
  }

  /// Leave the current room.
  Future<void> leaveRoom() async {
    final roomId = state.roomId;
    final userId = _currentUserId;
    if (roomId == null || userId == null) return;

    _cancelSubscriptions();

    try {
      if (state.isHost) {
        await _syncService.closeRoom(roomId);
      } else {
        await _syncService.leaveRoom(roomId: roomId, userId: userId);
      }
    } catch (e) {
      debugPrint('Failed to leave room: $e');
    }

    _remoteElementIds.clear();
    state = const SyncState();
  }

  /// Send an element update to the room.
  void sendElement(String pageId, CanvasElement element) {
    final roomId = state.roomId;
    final userId = _currentUserId;
    if (roomId == null || userId == null || !state.isConnected) return;

    // Don't send back elements that came from remote
    if (_remoteElementIds.contains(element.id)) {
      _remoteElementIds.remove(element.id);
      return;
    }

    _syncService.sendElement(
      roomId: roomId,
      pageId: pageId,
      element: element,
      userId: userId,
    );
  }

  /// Send a "remove element" event.
  void sendRemoveElement(String pageId, String elementId) {
    final roomId = state.roomId;
    if (roomId == null || !state.isConnected) return;

    _syncService.removeElement(
      roomId: roomId,
      pageId: pageId,
      elementId: elementId,
    );
  }

  /// Send cursor position (throttled).
  void sendCursorPosition(double x, double y) {
    final now = DateTime.now();
    if (now.difference(_lastCursorSend).inMilliseconds < _cursorThrottleMs) {
      return;
    }
    _lastCursorSend = now;

    final roomId = state.roomId;
    final userId = _currentUserId;
    final userName = _currentUserName;
    if (roomId == null || userId == null) return;

    final canvasState = _ref.read(canvasProvider);
    _syncService.sendCursor(
      roomId: roomId,
      cursor: CursorEvent(
        userId: userId,
        displayName: userName ?? 'User',
        x: x,
        y: y,
        color: canvasState.currentColor,
        tool: canvasState.currentTool.name,
        timestamp: now.millisecondsSinceEpoch,
      ),
    );
  }

  /// Toggle draw permission for a participant (host only).
  Future<void> togglePermission(String userId) async {
    if (!state.isHost || state.roomId == null) return;

    final participant = state.participants.firstWhere(
      (p) => p.userId == userId,
      orElse: () => Participant(userId: userId, displayName: ''),
    );

    await _syncService.setPermission(
      roomId: state.roomId!,
      userId: userId,
      canDraw: !participant.canDraw,
    );
  }

  /// Set the current page ID for element streaming.
  void setCurrentPage(String pageId) {
    if (state.currentPageId == pageId) return;
    state = state.copyWith(currentPageId: pageId);

    // Re-subscribe to element stream for new page
    if (state.roomId != null) {
      _elementSub?.cancel();
      _subscribeToElements(state.roomId!, pageId);
    }
  }

  void _subscribeToRoom(String roomId) {
    // Subscribe to participants
    _participantSub = _syncService.participantStream(roomId).listen(
      (participants) {
        state = state.copyWith(participants: participants);

        // Update own canDraw permission
        final userId = _currentUserId;
        if (userId != null) {
          final me = participants
              .where((p) => p.userId == userId)
              .firstOrNull;
          if (me != null) {
            state = state.copyWith(canDraw: me.canDraw);
          }
        }
      },
    );

    // Subscribe to cursors
    _cursorSub = _syncService.cursorStream(roomId).listen(
      (cursors) {
        // Filter out own cursor
        final userId = _currentUserId;
        final remote = cursors.where((c) => c.userId != userId).toList();
        state = state.copyWith(remoteCursors: remote);
      },
    );

    // Subscribe to elements for current page
    final pageId = state.currentPageId ??
        _ref.read(lectureProvider).currentPage?.id;
    if (pageId != null) {
      state = state.copyWith(currentPageId: pageId);
      _subscribeToElements(roomId, pageId);
    }
  }

  void _subscribeToElements(String roomId, String pageId) {
    _elementSub = _syncService.elementStream(roomId, pageId).listen(
      (event) {
        final canvasNotifier = _ref.read(canvasProvider.notifier);

        switch (event.action) {
          case ElementAction.added:
          case ElementAction.modified:
            if (event.elementJson != null) {
              try {
                final element = CanvasElement.fromJson(event.elementJson!);
                _remoteElementIds.add(element.id);
                canvasNotifier.mergeRemoteElement(element);
              } catch (e) {
                debugPrint('Failed to parse remote element: $e');
              }
            }
            break;
          case ElementAction.removed:
            _remoteElementIds.add(event.elementId);
            canvasNotifier.removeRemoteElement(event.elementId);
            break;
        }
      },
    );
  }

  void _cancelSubscriptions() {
    _elementSub?.cancel();
    _cursorSub?.cancel();
    _participantSub?.cancel();
    _elementSub = null;
    _cursorSub = null;
    _participantSub = null;
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
