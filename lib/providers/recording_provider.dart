import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording_model.dart';
import '../models/canvas_element.dart';
import 'canvas_provider.dart';

enum RecordingMode { idle, recording, playing, paused }

class RecordingState {
  final RecordingMode mode;
  final LectureRecording? recording;
  final int currentTimeMs;
  final int totalDurationMs;
  final double playbackSpeed;

  const RecordingState({
    this.mode = RecordingMode.idle,
    this.recording,
    this.currentTimeMs = 0,
    this.totalDurationMs = 0,
    this.playbackSpeed = 1.0,
  });

  RecordingState copyWith({
    RecordingMode? mode,
    LectureRecording? recording,
    int? currentTimeMs,
    int? totalDurationMs,
    double? playbackSpeed,
  }) {
    return RecordingState(
      mode: mode ?? this.mode,
      recording: recording ?? this.recording,
      currentTimeMs: currentTimeMs ?? this.currentTimeMs,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
    );
  }

  bool get isRecording => mode == RecordingMode.recording;
  bool get isPlaying => mode == RecordingMode.playing;
  bool get isPaused => mode == RecordingMode.paused;
  bool get isIdle => mode == RecordingMode.idle;
  bool get hasRecording => recording != null;

  double get progress =>
      totalDurationMs > 0 ? currentTimeMs / totalDurationMs : 0.0;

  String get currentTimeDisplay => _formatTime(currentTimeMs);
  String get totalTimeDisplay => _formatTime(totalDurationMs);

  static String _formatTime(int ms) {
    final seconds = (ms / 1000).floor();
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class RecordingNotifier extends StateNotifier<RecordingState> {
  final Ref _ref;
  DateTime? _recordingStart;
  final List<RecordedEvent> _events = [];
  Timer? _playbackTimer;
  int _playbackEventIndex = 0;

  RecordingNotifier(this._ref) : super(const RecordingState());

  /// Start recording canvas events.
  void startRecording(String lectureId) {
    _events.clear();
    _recordingStart = DateTime.now();

    state = state.copyWith(
      mode: RecordingMode.recording,
      currentTimeMs: 0,
      totalDurationMs: 0,
    );

    // Start a timer to update current time display
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state.isRecording && _recordingStart != null) {
        final elapsed =
            DateTime.now().difference(_recordingStart!).inMilliseconds;
        state = state.copyWith(currentTimeMs: elapsed);
      }
    });
  }

  /// Record a stroke start event.
  void recordStrokeStart(Offset position) {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.strokeStart, {
      'x': position.dx,
      'y': position.dy,
    });
  }

  /// Record a stroke update (point added).
  void recordStrokeUpdate(Offset position) {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.strokeUpdate, {
      'x': position.dx,
      'y': position.dy,
    });
  }

  /// Record a stroke end event.
  void recordStrokeEnd() {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.strokeEnd, {});
  }

  /// Record an element being added.
  void recordAddElement(CanvasElement element) {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.addElement, {
      'element': element.toJson(),
    });
  }

  /// Record an element being removed.
  void recordRemoveElement(String elementId) {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.removeElement, {
      'elementId': elementId,
    });
  }

  /// Record a tool change.
  void recordToolChange(String toolName) {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.toolChange, {
      'tool': toolName,
    });
  }

  /// Record a page change.
  void recordPageChange(String pageId) {
    if (!state.isRecording) return;
    _addEvent(RecordedEventType.pageChange, {
      'pageId': pageId,
    });
  }

  void _addEvent(RecordedEventType type, Map<String, dynamic> data) {
    final elapsed =
        DateTime.now().difference(_recordingStart!).inMilliseconds;
    _events.add(RecordedEvent(
      timestampMs: elapsed,
      type: type,
      data: data,
    ));
  }

  /// Stop recording and save.
  LectureRecording? stopRecording() {
    if (!state.isRecording) return null;

    _playbackTimer?.cancel();
    final duration =
        DateTime.now().difference(_recordingStart!).inMilliseconds;

    final recording = LectureRecording(
      lectureId: '', // caller should set this
      title: 'Recording',
      createdAt: _recordingStart!,
      durationMs: duration,
      events: List.from(_events),
    );

    state = state.copyWith(
      mode: RecordingMode.idle,
      recording: recording,
      totalDurationMs: duration,
      currentTimeMs: 0,
    );

    _events.clear();
    _recordingStart = null;

    return recording;
  }

  /// Load a recording for playback.
  void loadRecording(LectureRecording recording) {
    _playbackTimer?.cancel();
    state = state.copyWith(
      mode: RecordingMode.idle,
      recording: recording,
      totalDurationMs: recording.durationMs,
      currentTimeMs: 0,
    );
  }

  /// Start or resume playback.
  void play() {
    final recording = state.recording;
    if (recording == null || recording.events.isEmpty) return;

    if (state.isPaused) {
      // Resume from current position
      state = state.copyWith(mode: RecordingMode.playing);
    } else {
      // Start from beginning
      _playbackEventIndex = 0;
      state = state.copyWith(
        mode: RecordingMode.playing,
        currentTimeMs: 0,
      );

      // Clear canvas for clean playback
      _ref.read(canvasProvider.notifier).clearAll();
    }

    _startPlaybackLoop();
  }

  /// Pause playback.
  void pause() {
    _playbackTimer?.cancel();
    state = state.copyWith(mode: RecordingMode.paused);
  }

  /// Stop playback and reset.
  void stop() {
    _playbackTimer?.cancel();
    _playbackEventIndex = 0;
    state = state.copyWith(
      mode: RecordingMode.idle,
      currentTimeMs: 0,
    );
  }

  /// Set playback speed (0.5x, 1x, 1.5x, 2x).
  void setPlaybackSpeed(double speed) {
    state = state.copyWith(playbackSpeed: speed);
  }

  /// Seek to a specific position (0.0 to 1.0).
  void seekTo(double position) {
    final targetMs = (position * state.totalDurationMs).round();
    _playbackEventIndex = 0;
    state = state.copyWith(currentTimeMs: targetMs);

    // Find the event index closest to target time
    final recording = state.recording;
    if (recording != null) {
      for (int i = 0; i < recording.events.length; i++) {
        if (recording.events[i].timestampMs > targetMs) {
          _playbackEventIndex = i;
          break;
        }
      }
    }
  }

  void _startPlaybackLoop() {
    _playbackTimer?.cancel();

    final recording = state.recording;
    if (recording == null) return;

    _playbackTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (_) {
        if (!state.isPlaying) return;

        final currentTime = state.currentTimeMs +
            (16 * state.playbackSpeed).round();

        // Process events up to current time
        while (_playbackEventIndex < recording.events.length) {
          final event = recording.events[_playbackEventIndex];
          if (event.timestampMs <= currentTime) {
            _processEvent(event);
            _playbackEventIndex++;
          } else {
            break;
          }
        }

        // Check if playback is complete
        if (currentTime >= state.totalDurationMs) {
          _playbackTimer?.cancel();
          state = state.copyWith(
            mode: RecordingMode.idle,
            currentTimeMs: state.totalDurationMs,
          );
          return;
        }

        state = state.copyWith(currentTimeMs: currentTime);
      },
    );
  }

  void _processEvent(RecordedEvent event) {
    final canvasNotifier = _ref.read(canvasProvider.notifier);

    switch (event.type) {
      case RecordedEventType.strokeStart:
        canvasNotifier.startStroke(
          Offset(
            (event.data['x'] as num).toDouble(),
            (event.data['y'] as num).toDouble(),
          ),
        );
        break;
      case RecordedEventType.strokeUpdate:
        canvasNotifier.updateStroke(
          Offset(
            (event.data['x'] as num).toDouble(),
            (event.data['y'] as num).toDouble(),
          ),
        );
        break;
      case RecordedEventType.strokeEnd:
        canvasNotifier.endStroke();
        break;
      case RecordedEventType.addElement:
        if (event.data['element'] != null) {
          try {
            final element = CanvasElement.fromJson(
              event.data['element'] as Map<String, dynamic>,
            );
            canvasNotifier.mergeRemoteElement(element);
          } catch (e) {
            debugPrint('Failed to replay element: $e');
          }
        }
        break;
      case RecordedEventType.removeElement:
        final elementId = event.data['elementId'] as String?;
        if (elementId != null) {
          canvasNotifier.removeRemoteElement(elementId);
        }
        break;
      case RecordedEventType.toolChange:
        // Tool changes are visual only during playback
        break;
      case RecordedEventType.colorChange:
        break;
      case RecordedEventType.pageChange:
        break;
      case RecordedEventType.modifyElement:
        break;
      case RecordedEventType.clear:
        canvasNotifier.clearAll();
        break;
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}

final recordingProvider =
    StateNotifierProvider<RecordingNotifier, RecordingState>((ref) {
  return RecordingNotifier(ref);
});
