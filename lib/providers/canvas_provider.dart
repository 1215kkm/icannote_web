import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stroke.dart';
import '../core/constants/app_constants.dart';

class CanvasState {
  final DrawingTool currentTool;
  final Color currentColor;
  final double strokeWidth;
  final List<Stroke> strokes;
  final List<Stroke> redoStack;
  final Stroke? activeStroke;
  final double zoom;
  final Offset panOffset;
  final String? selectedStrokeId;

  const CanvasState({
    this.currentTool = DrawingTool.pen,
    this.currentColor = Colors.black,
    this.strokeWidth = AppConstants.defaultStrokeWidth,
    this.strokes = const [],
    this.redoStack = const [],
    this.activeStroke,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.selectedStrokeId,
  });

  CanvasState copyWith({
    DrawingTool? currentTool,
    Color? currentColor,
    double? strokeWidth,
    List<Stroke>? strokes,
    List<Stroke>? redoStack,
    Stroke? Function()? activeStroke,
    double? zoom,
    Offset? panOffset,
    String? Function()? selectedStrokeId,
  }) {
    return CanvasState(
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokes: strokes ?? this.strokes,
      redoStack: redoStack ?? this.redoStack,
      activeStroke:
          activeStroke != null ? activeStroke() : this.activeStroke,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      selectedStrokeId: selectedStrokeId != null
          ? selectedStrokeId()
          : this.selectedStrokeId,
    );
  }
}

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  void setTool(DrawingTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void startStroke(Offset position) {
    if (state.currentTool == DrawingTool.pan ||
        state.currentTool == DrawingTool.none ||
        state.currentTool == DrawingTool.selection) {
      return;
    }

    if (state.currentTool == DrawingTool.strokeEraser) {
      _eraseStrokeAt(position);
      return;
    }

    final point = StrokePoint(position.dx, position.dy);
    final stroke = Stroke(
      tool: state.currentTool,
      color: state.currentColor,
      strokeWidth: state.strokeWidth,
      points: [point],
    );
    state = state.copyWith(activeStroke: () => stroke);
  }

  void updateStroke(Offset position) {
    if (state.activeStroke == null) {
      if (state.currentTool == DrawingTool.strokeEraser) {
        _eraseStrokeAt(position);
      }
      return;
    }

    final point = StrokePoint(position.dx, position.dy);
    final updatedPoints = [...state.activeStroke!.points, point];

    final tool = state.activeStroke!.tool;

    if (tool == DrawingTool.line ||
        tool == DrawingTool.rectangle ||
        tool == DrawingTool.circle ||
        tool == DrawingTool.triangle) {
      // For shapes, only keep first and last point
      final shapePoints = [state.activeStroke!.points.first, point];
      state = state.copyWith(
        activeStroke: () => state.activeStroke!.copyWith(points: shapePoints),
      );
    } else {
      state = state.copyWith(
        activeStroke: () =>
            state.activeStroke!.copyWith(points: updatedPoints),
      );
    }
  }

  void endStroke() {
    if (state.activeStroke == null) return;

    if (state.activeStroke!.points.length < 2 &&
        state.activeStroke!.tool == DrawingTool.pen) {
      // Single dot - add a tiny offset to make it visible
      final p = state.activeStroke!.points.first;
      state = state.copyWith(
        activeStroke: () => state.activeStroke!.copyWith(
          points: [p, StrokePoint(p.x + 0.1, p.y + 0.1, p.pressure)],
        ),
      );
    }

    final newStrokes = [...state.strokes, state.activeStroke!];
    state = state.copyWith(
      strokes: newStrokes,
      redoStack: [], // Clear redo on new stroke
      activeStroke: () => null,
    );
  }

  void undo() {
    if (state.strokes.isEmpty) return;
    final last = state.strokes.last;
    final newStrokes = state.strokes.sublist(0, state.strokes.length - 1);
    final newRedo = [...state.redoStack, last];
    state = state.copyWith(strokes: newStrokes, redoStack: newRedo);
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final last = state.redoStack.last;
    final newStrokes = [...state.strokes, last];
    final newRedo =
        state.redoStack.sublist(0, state.redoStack.length - 1);
    state = state.copyWith(strokes: newStrokes, redoStack: newRedo);
  }

  void clearAll() {
    state = state.copyWith(strokes: [], redoStack: []);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.25, 5.0));
  }

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  void loadStrokes(List<Stroke> strokes) {
    state = state.copyWith(strokes: strokes, redoStack: []);
  }

  void _eraseStrokeAt(Offset position) {
    const hitRadius = 10.0;
    for (int i = state.strokes.length - 1; i >= 0; i--) {
      final stroke = state.strokes[i];
      for (final point in stroke.points) {
        final dx = point.x - position.dx;
        final dy = point.y - position.dy;
        if (dx * dx + dy * dy < hitRadius * hitRadius) {
          final newStrokes = [...state.strokes];
          newStrokes.removeAt(i);
          state = state.copyWith(strokes: newStrokes);
          return;
        }
      }
    }
  }
}

final canvasProvider =
    StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});
