import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/stroke.dart' show DrawingTool;
import '../models/canvas_element.dart';
import '../core/constants/app_constants.dart';

// ──────────────────── Command Pattern ────────────────────

abstract class CanvasCommand {
  void execute(List<CanvasElement> elements);
  void undo(List<CanvasElement> elements);
}

class AddElementCommand extends CanvasCommand {
  final CanvasElement element;
  AddElementCommand(this.element);

  @override
  void execute(List<CanvasElement> elements) {
    elements.add(element);
  }

  @override
  void undo(List<CanvasElement> elements) {
    elements.removeWhere((e) => e.id == element.id);
  }
}

class RemoveElementCommand extends CanvasCommand {
  final CanvasElement element;
  final int index;
  RemoveElementCommand(this.element, this.index);

  @override
  void execute(List<CanvasElement> elements) {
    elements.removeWhere((e) => e.id == element.id);
  }

  @override
  void undo(List<CanvasElement> elements) {
    final insertAt = index.clamp(0, elements.length);
    elements.insert(insertAt, element);
  }
}

class ModifyElementCommand extends CanvasCommand {
  final String elementId;
  final CanvasElement oldElement;
  final CanvasElement newElement;
  ModifyElementCommand(this.elementId, this.oldElement, this.newElement);

  @override
  void execute(List<CanvasElement> elements) {
    final idx = elements.indexWhere((e) => e.id == elementId);
    if (idx != -1) elements[idx] = newElement;
  }

  @override
  void undo(List<CanvasElement> elements) {
    final idx = elements.indexWhere((e) => e.id == elementId);
    if (idx != -1) elements[idx] = oldElement;
  }
}

class BatchCommand extends CanvasCommand {
  final List<CanvasCommand> commands;
  BatchCommand(this.commands);

  @override
  void execute(List<CanvasElement> elements) {
    for (final cmd in commands) {
      cmd.execute(elements);
    }
  }

  @override
  void undo(List<CanvasElement> elements) {
    for (final cmd in commands.reversed) {
      cmd.undo(elements);
    }
  }
}

// ──────────────────── Canvas State ────────────────────

class CanvasState {
  final DrawingTool currentTool;
  final Color currentColor;
  final double strokeWidth;
  final List<CanvasElement> elements;
  final List<CanvasCommand> undoStack;
  final List<CanvasCommand> redoStack;
  final CanvasElement? activeElement;
  final double zoom;
  final Offset panOffset;
  final String? selectedElementId;
  final int polygonSides;

  const CanvasState({
    this.currentTool = DrawingTool.pen,
    this.currentColor = Colors.black,
    this.strokeWidth = AppConstants.defaultStrokeWidth,
    this.elements = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.activeElement,
    this.zoom = 1.0,
    this.panOffset = Offset.zero,
    this.selectedElementId,
    this.polygonSides = 5,
  });

  CanvasElement? get selectedElement {
    if (selectedElementId == null) return null;
    final idx = elements.indexWhere((e) => e.id == selectedElementId);
    return idx != -1 ? elements[idx] : null;
  }

  CanvasState copyWith({
    DrawingTool? currentTool,
    Color? currentColor,
    double? strokeWidth,
    List<CanvasElement>? elements,
    List<CanvasCommand>? undoStack,
    List<CanvasCommand>? redoStack,
    CanvasElement? Function()? activeElement,
    double? zoom,
    Offset? panOffset,
    String? Function()? selectedElementId,
    int? polygonSides,
  }) {
    return CanvasState(
      currentTool: currentTool ?? this.currentTool,
      currentColor: currentColor ?? this.currentColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      elements: elements ?? this.elements,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      activeElement:
          activeElement != null ? activeElement() : this.activeElement,
      zoom: zoom ?? this.zoom,
      panOffset: panOffset ?? this.panOffset,
      selectedElementId: selectedElementId != null
          ? selectedElementId()
          : this.selectedElementId,
      polygonSides: polygonSides ?? this.polygonSides,
    );
  }
}

// ──────────────────── Canvas Notifier ────────────────────

class CanvasNotifier extends StateNotifier<CanvasState> {
  CanvasNotifier() : super(const CanvasState());

  // Track drag start for selection move
  Offset? _selectionDragStart;

  void setTool(DrawingTool tool) {
    state = state.copyWith(
      currentTool: tool,
      selectedElementId: () => null,
    );
  }

  void setColor(Color color) {
    state = state.copyWith(currentColor: color);
    // Update selected element color if any
    if (state.selectedElementId != null) {
      final el = state.selectedElement;
      if (el is StrokeElement) {
        _modifyElement(el.id, el.copyWith(color: color));
      } else if (el is ShapeElement) {
        _modifyElement(el.id, el.copyWith(strokeColor: color));
      } else if (el is TextCanvasElement) {
        _modifyElement(el.id, el.copyWith(color: color));
      }
    }
  }

  void setStrokeWidth(double width) {
    state = state.copyWith(strokeWidth: width);
  }

  void setPolygonSides(int sides) {
    state = state.copyWith(polygonSides: sides.clamp(3, 12));
  }

  // ──── Drawing Input ────

  void startStroke(Offset position) {
    final tool = state.currentTool;

    if (tool == DrawingTool.pan || tool == DrawingTool.none) {
      return;
    }

    if (tool == DrawingTool.selection) {
      _startSelection(position);
      return;
    }

    if (tool == DrawingTool.strokeEraser) {
      _eraseStrokeAt(position);
      return;
    }

    if (tool == DrawingTool.eraser) {
      _detailErase(position);
      return;
    }

    if (tool == DrawingTool.text || tool == DrawingTool.sticker) {
      // Text and sticker are handled via separate methods
      return;
    }

    // Drawing tools
    if (_isStrokeTool(tool)) {
      final strokeTool = _toStrokeTool(tool);
      final point = StrokePoint(position.dx, position.dy);
      final stroke = StrokeElement(
        tool: strokeTool,
        color: state.currentColor,
        strokeWidth: state.strokeWidth,
        points: [point],
      );
      state = state.copyWith(activeElement: () => stroke);
    } else if (_isShapeTool(tool)) {
      final shapeType = _toShapeType(tool);
      final shape = ShapeElement(
        shapeType: shapeType,
        rect: Rect.fromPoints(position, position),
        strokeColor: state.currentColor,
        strokeWidth: state.strokeWidth,
        sides: state.polygonSides,
      );
      state = state.copyWith(activeElement: () => shape);
    }
  }

  void updateStroke(Offset position) {
    final tool = state.currentTool;

    if (tool == DrawingTool.selection) {
      _updateSelection(position);
      return;
    }

    if (tool == DrawingTool.strokeEraser) {
      _eraseStrokeAt(position);
      return;
    }

    if (tool == DrawingTool.eraser) {
      _detailErase(position);
      return;
    }

    if (state.activeElement == null) return;

    if (state.activeElement is StrokeElement) {
      final stroke = state.activeElement as StrokeElement;
      final point = StrokePoint(position.dx, position.dy);

      if (stroke.tool == StrokeTool.line) {
        // Line: only first and last point
        state = state.copyWith(
          activeElement: () => stroke.copyWith(
            points: [stroke.points.first, point],
          ),
        );
      } else {
        state = state.copyWith(
          activeElement: () => stroke.copyWith(
            points: [...stroke.points, point],
          ),
        );
      }
    } else if (state.activeElement is ShapeElement) {
      final shape = state.activeElement as ShapeElement;
      // Update rect from origin to current position
      final origin = shape.rect.topLeft;
      state = state.copyWith(
        activeElement: () => shape.copyWith(
          rect: Rect.fromPoints(origin, position),
        ),
      );
    }
  }

  void endStroke() {
    final tool = state.currentTool;

    if (tool == DrawingTool.selection) {
      _selectionDragStart = null;
      return;
    }

    if (state.activeElement == null) return;

    if (state.activeElement is StrokeElement) {
      final stroke = state.activeElement as StrokeElement;
      if (stroke.points.length < 2 &&
          stroke.tool == StrokeTool.pen) {
        // Single dot - make visible
        final p = stroke.points.first;
        final dotStroke = stroke.copyWith(
          points: [p, StrokePoint(p.x + 0.1, p.y + 0.1, p.pressure)],
        );
        _addElement(dotStroke);
      } else {
        _addElement(stroke);
      }
    } else if (state.activeElement is ShapeElement) {
      final shape = state.activeElement as ShapeElement;
      // Only add if shape has reasonable size
      if (shape.rect.width.abs() > 2 || shape.rect.height.abs() > 2) {
        // Normalize rect
        final normalized = shape.copyWith(
          rect: Rect.fromLTRB(
            shape.rect.left < shape.rect.right ? shape.rect.left : shape.rect.right,
            shape.rect.top < shape.rect.bottom ? shape.rect.top : shape.rect.bottom,
            shape.rect.left < shape.rect.right ? shape.rect.right : shape.rect.left,
            shape.rect.top < shape.rect.bottom ? shape.rect.bottom : shape.rect.top,
          ),
        );
        _addElement(normalized);
      }
    }

    state = state.copyWith(activeElement: () => null);
  }

  // ──── Text Tool ────

  void addTextElement(Offset position, String text, {
    double fontSize = 16,
    bool isBold = false,
    bool isItalic = false,
  }) {
    if (text.trim().isEmpty) return;
    final element = TextCanvasElement(
      text: text,
      position: position,
      fontSize: fontSize,
      color: state.currentColor,
      isBold: isBold,
      isItalic: isItalic,
    );
    _addElement(element);
  }

  void updateTextElement(String id, String newText) {
    final el = state.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Element not found'),
    );
    if (el is TextCanvasElement) {
      _modifyElement(id, el.copyWith(text: newText));
    }
  }

  // ──── Sticker Tool ────

  void addSticker(Rect rect) {
    final sticker = StickerElement(
      rect: rect,
      coverColor: state.currentColor,
    );
    _addElement(sticker);
  }

  void revealSticker(String id) {
    final el = state.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Element not found'),
    );
    if (el is StickerElement) {
      _modifyElement(id, el.copyWith(isRevealed: true));
    }
  }

  // ──── Selection ────

  void _startSelection(Offset position) {
    // Hit test - find topmost element containing the point
    for (int i = state.elements.length - 1; i >= 0; i--) {
      if (state.elements[i].containsPoint(position)) {
        state = state.copyWith(
          selectedElementId: () => state.elements[i].id,
        );
        _selectionDragStart = position;
        return;
      }
    }
    // No hit - deselect
    state = state.copyWith(selectedElementId: () => null);
  }

  void _updateSelection(Offset position) {
    if (state.selectedElementId == null || _selectionDragStart == null) return;
    final delta = position - _selectionDragStart!;
    if (delta.distance < 1) return;

    final el = state.selectedElement;
    if (el == null) return;

    CanvasElement moved;
    if (el is StrokeElement) {
      moved = el.copyWith(
        points: el.points
            .map((p) => StrokePoint(p.x + delta.dx, p.y + delta.dy, p.pressure))
            .toList(),
      );
    } else if (el is ShapeElement) {
      moved = el.copyWith(rect: el.rect.shift(delta));
    } else if (el is TextCanvasElement) {
      moved = el.copyWith(position: el.position + delta);
    } else if (el is ImageCanvasElement) {
      moved = ImageCanvasElement(
        id: el.id,
        imageUrl: el.imageUrl,
        rect: el.rect.shift(delta),
        zIndex: el.zIndex,
        rotation: el.rotation,
        timestamp: el.timestamp,
      );
    } else if (el is StickerElement) {
      moved = el.copyWith(rect: el.rect.shift(delta));
    } else {
      return;
    }

    // Direct update without command (command on endStroke)
    final newElements = [...state.elements];
    final idx = newElements.indexWhere((e) => e.id == el.id);
    if (idx != -1) {
      newElements[idx] = moved;
      state = state.copyWith(elements: newElements);
    }
    _selectionDragStart = position;
  }

  void moveElement(String id, Offset delta) {
    final el = state.elements.firstWhere(
      (e) => e.id == id,
      orElse: () => throw StateError('Element not found'),
    );

    CanvasElement moved;
    if (el is StrokeElement) {
      moved = el.copyWith(
        points: el.points
            .map((p) => StrokePoint(p.x + delta.dx, p.y + delta.dy, p.pressure))
            .toList(),
      );
    } else if (el is ShapeElement) {
      moved = el.copyWith(rect: el.rect.shift(delta));
    } else if (el is TextCanvasElement) {
      moved = el.copyWith(position: el.position + delta);
    } else if (el is StickerElement) {
      moved = el.copyWith(rect: el.rect.shift(delta));
    } else {
      return;
    }
    _modifyElement(id, moved);
  }

  void deleteSelected() {
    if (state.selectedElementId == null) return;
    _removeElement(state.selectedElementId!);
    state = state.copyWith(selectedElementId: () => null);
  }

  // ──── Z-Order ────

  void bringForward() {
    if (state.selectedElementId == null) return;
    final idx = state.elements.indexWhere((e) => e.id == state.selectedElementId);
    if (idx == -1 || idx >= state.elements.length - 1) return;
    final newElements = [...state.elements];
    final el = newElements.removeAt(idx);
    newElements.insert(idx + 1, el);
    state = state.copyWith(elements: newElements);
  }

  void sendBackward() {
    if (state.selectedElementId == null) return;
    final idx = state.elements.indexWhere((e) => e.id == state.selectedElementId);
    if (idx <= 0) return;
    final newElements = [...state.elements];
    final el = newElements.removeAt(idx);
    newElements.insert(idx - 1, el);
    state = state.copyWith(elements: newElements);
  }

  // ──── Copy/Paste ────

  CanvasElement? _clipboard;

  void copySelected() {
    if (state.selectedElement != null) {
      _clipboard = state.selectedElement;
    }
  }

  void paste() {
    if (_clipboard == null) return;
    // Create new element with offset and new ID
    CanvasElement pasted;
    const offset = Offset(20, 20);
    if (_clipboard is StrokeElement) {
      final el = _clipboard as StrokeElement;
      pasted = StrokeElement(
        tool: el.tool,
        color: el.color,
        strokeWidth: el.strokeWidth,
        points: el.points
            .map((p) => StrokePoint(p.x + offset.dx, p.y + offset.dy, p.pressure))
            .toList(),
      );
    } else if (_clipboard is ShapeElement) {
      final el = _clipboard as ShapeElement;
      pasted = ShapeElement(
        shapeType: el.shapeType,
        rect: el.rect.shift(offset),
        strokeColor: el.strokeColor,
        fillColor: el.fillColor,
        strokeWidth: el.strokeWidth,
        sides: el.sides,
      );
    } else if (_clipboard is TextCanvasElement) {
      final el = _clipboard as TextCanvasElement;
      pasted = TextCanvasElement(
        text: el.text,
        position: el.position + offset,
        fontSize: el.fontSize,
        color: el.color,
        isBold: el.isBold,
        isItalic: el.isItalic,
        maxWidth: el.maxWidth,
      );
    } else if (_clipboard is StickerElement) {
      final el = _clipboard as StickerElement;
      pasted = StickerElement(
        rect: el.rect.shift(offset),
        coverColor: el.coverColor,
      );
    } else {
      return;
    }
    _addElement(pasted);
    state = state.copyWith(selectedElementId: () => pasted.id);
  }

  // ──── Erasers ────

  void _eraseStrokeAt(Offset position) {
    const hitRadius = 10.0;
    for (int i = state.elements.length - 1; i >= 0; i--) {
      final el = state.elements[i];
      if (el is StrokeElement) {
        for (final point in el.points) {
          final dx = point.x - position.dx;
          final dy = point.y - position.dy;
          if (dx * dx + dy * dy < hitRadius * hitRadius) {
            _removeElement(el.id);
            return;
          }
        }
      } else if (el.containsPoint(position)) {
        _removeElement(el.id);
        return;
      }
    }
  }

  void _detailErase(Offset position) {
    const eraseRadius = 8.0;
    for (int i = state.elements.length - 1; i >= 0; i--) {
      final el = state.elements[i];
      if (el is StrokeElement) {
        // Check if any point is within erase radius
        int eraseIdx = -1;
        for (int j = 0; j < el.points.length; j++) {
          final dx = el.points[j].x - position.dx;
          final dy = el.points[j].y - position.dy;
          if (dx * dx + dy * dy < eraseRadius * eraseRadius) {
            eraseIdx = j;
            break;
          }
        }
        if (eraseIdx == -1) continue;

        // Remove points near the erase point and split stroke
        final commands = <CanvasCommand>[];
        commands.add(RemoveElementCommand(el, i));

        // Find range of points to remove
        int removeStart = eraseIdx;
        int removeEnd = eraseIdx;
        while (removeStart > 0) {
          final dx = el.points[removeStart - 1].x - position.dx;
          final dy = el.points[removeStart - 1].y - position.dy;
          if (dx * dx + dy * dy < eraseRadius * eraseRadius) {
            removeStart--;
          } else {
            break;
          }
        }
        while (removeEnd < el.points.length - 1) {
          final dx = el.points[removeEnd + 1].x - position.dx;
          final dy = el.points[removeEnd + 1].y - position.dy;
          if (dx * dx + dy * dy < eraseRadius * eraseRadius) {
            removeEnd++;
          } else {
            break;
          }
        }

        // Create sub-strokes
        if (removeStart > 1) {
          final leftPoints = el.points.sublist(0, removeStart);
          commands.add(AddElementCommand(StrokeElement(
            tool: el.tool,
            color: el.color,
            strokeWidth: el.strokeWidth,
            points: leftPoints,
          )));
        }
        if (removeEnd < el.points.length - 2) {
          final rightPoints = el.points.sublist(removeEnd + 1);
          commands.add(AddElementCommand(StrokeElement(
            tool: el.tool,
            color: el.color,
            strokeWidth: el.strokeWidth,
            points: rightPoints,
          )));
        }

        _executeCommand(BatchCommand(commands));
        return;
      } else if (el.containsPoint(position)) {
        _removeElement(el.id);
        return;
      }
    }
  }

  // ──── Undo/Redo ────

  void undo() {
    if (state.undoStack.isEmpty) return;
    final cmd = state.undoStack.last;
    final newElements = [...state.elements];
    cmd.undo(newElements);
    state = state.copyWith(
      elements: newElements,
      undoStack: state.undoStack.sublist(0, state.undoStack.length - 1),
      redoStack: [...state.redoStack, cmd],
      selectedElementId: () => null,
    );
  }

  void redo() {
    if (state.redoStack.isEmpty) return;
    final cmd = state.redoStack.last;
    final newElements = [...state.elements];
    cmd.execute(newElements);
    state = state.copyWith(
      elements: newElements,
      undoStack: [...state.undoStack, cmd],
      redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
      selectedElementId: () => null,
    );
  }

  void clearAll() {
    if (state.elements.isEmpty) return;
    final commands = <CanvasCommand>[];
    for (int i = state.elements.length - 1; i >= 0; i--) {
      commands.add(RemoveElementCommand(state.elements[i], i));
    }
    _executeCommand(BatchCommand(commands));
    state = state.copyWith(selectedElementId: () => null);
  }

  // ──── Zoom & Pan ────

  void setZoom(double zoom) {
    state = state.copyWith(zoom: zoom.clamp(0.25, 5.0));
  }

  void setPanOffset(Offset offset) {
    state = state.copyWith(panOffset: offset);
  }

  // ──── Load elements ────

  void loadElements(List<CanvasElement> elements) {
    state = state.copyWith(
      elements: elements,
      undoStack: [],
      redoStack: [],
      selectedElementId: () => null,
    );
  }

  // ──── Select All ────

  void selectAll() {
    // Select first element for now (multi-select is Phase 7+)
    if (state.elements.isNotEmpty) {
      state = state.copyWith(
        selectedElementId: () => state.elements.last.id,
        currentTool: DrawingTool.selection,
      );
    }
  }

  // ──── Internal helpers ────

  void _addElement(CanvasElement element) {
    _executeCommand(AddElementCommand(element));
  }

  void _removeElement(String id) {
    final idx = state.elements.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _executeCommand(RemoveElementCommand(state.elements[idx], idx));
  }

  void _modifyElement(String id, CanvasElement newElement) {
    final idx = state.elements.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _executeCommand(ModifyElementCommand(id, state.elements[idx], newElement));
  }

  void _executeCommand(CanvasCommand cmd) {
    final newElements = [...state.elements];
    cmd.execute(newElements);
    state = state.copyWith(
      elements: newElements,
      undoStack: [...state.undoStack, cmd],
      redoStack: [], // Clear redo on new action
    );
  }

  bool _isStrokeTool(DrawingTool tool) {
    return tool == DrawingTool.pen ||
        tool == DrawingTool.highlighter ||
        tool == DrawingTool.line ||
        tool == DrawingTool.curve;
  }

  bool _isShapeTool(DrawingTool tool) {
    return tool == DrawingTool.rectangle ||
        tool == DrawingTool.circle ||
        tool == DrawingTool.triangle ||
        tool == DrawingTool.polygon;
  }

  StrokeTool _toStrokeTool(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.pen:
        return StrokeTool.pen;
      case DrawingTool.highlighter:
        return StrokeTool.highlighter;
      case DrawingTool.line:
        return StrokeTool.line;
      case DrawingTool.curve:
        return StrokeTool.curve;
      default:
        return StrokeTool.pen;
    }
  }

  ShapeType _toShapeType(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.rectangle:
        return ShapeType.rectangle;
      case DrawingTool.circle:
        return ShapeType.circle;
      case DrawingTool.triangle:
        return ShapeType.triangle;
      case DrawingTool.polygon:
        return ShapeType.polygon;
      default:
        return ShapeType.rectangle;
    }
  }
}

final canvasProvider =
    StateNotifierProvider<CanvasNotifier, CanvasState>((ref) {
  return CanvasNotifier();
});
