import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/sync_provider.dart';
import '../../models/stroke.dart';
import '../../models/canvas_element.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import 'canvas_painter.dart';
import 'graph_overlay.dart';
import '../collaboration/cursor_overlay.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen>
    with TickerProviderStateMixin {
  final TransformationController _transformController =
      TransformationController();
  final GlobalKey _canvasKey = GlobalKey();

  // Text input state
  bool _showTextInput = false;
  Offset _textInputPosition = Offset.zero;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  // Sticker drag state
  Offset? _stickerDragStart;
  Rect? _stickerDragRect;

  // Sticker animation controllers (id -> controller)
  final Map<String, AnimationController> _stickerAnimControllers = {};

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    for (final c in _stickerAnimControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis();
    ref.read(canvasProvider.notifier).setZoom(scale);
  }

  Offset _toCanvasPosition(Offset globalPosition) {
    final RenderBox? box =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return globalPosition;
    return box.globalToLocal(globalPosition);
  }

  void _handlePointerDown(PointerDownEvent event) {
    final pos = _toCanvasPosition(event.position);
    final tool = ref.read(canvasProvider).currentTool;

    // Check canDraw permission for collaboration
    final syncState = ref.read(syncProvider);
    if (syncState.isConnected && !syncState.canDraw) return;

    if (tool == DrawingTool.text) {
      _showTextInputAt(pos);
      return;
    }

    // Sticker tool - drag to create
    if (tool == DrawingTool.sticker) {
      setState(() {
        _stickerDragStart = pos;
        _stickerDragRect = Rect.fromPoints(pos, pos);
      });
      return;
    }

    // Check for sticker click to toggle (works with selection tool)
    if (tool == DrawingTool.selection) {
      final elements = ref.read(canvasProvider).elements;
      for (int i = elements.length - 1; i >= 0; i--) {
        if (elements[i] is StickerElement &&
            elements[i].boundingBox.contains(pos)) {
          final sticker = elements[i] as StickerElement;
          _toggleStickerWithAnimation(sticker);
          return;
        }
      }
    }

    ref.read(canvasProvider.notifier).startStroke(pos);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final pos = _toCanvasPosition(event.position);

    final tool = ref.read(canvasProvider).currentTool;
    if (tool == DrawingTool.sticker && _stickerDragStart != null) {
      setState(() {
        _stickerDragRect = Rect.fromPoints(_stickerDragStart!, pos);
      });
      return;
    }

    ref.read(canvasProvider.notifier).updateStroke(pos);
    ref.read(syncProvider.notifier).sendCursorPosition(pos.dx, pos.dy);
  }

  void _handlePointerUp(PointerUpEvent event) {
    final tool = ref.read(canvasProvider).currentTool;

    if (tool == DrawingTool.sticker && _stickerDragStart != null) {
      final rect = _stickerDragRect;
      if (rect != null && rect.width.abs() > 5 && rect.height.abs() > 5) {
        final normalized = Rect.fromLTRB(
          rect.left < rect.right ? rect.left : rect.right,
          rect.top < rect.bottom ? rect.top : rect.bottom,
          rect.left < rect.right ? rect.right : rect.left,
          rect.top < rect.bottom ? rect.bottom : rect.top,
        );
        ref.read(canvasProvider.notifier).addSticker(normalized);
        ref.read(lectureProvider.notifier).updateCurrentPageElements(
              ref.read(canvasProvider).elements,
            );
      }
      setState(() {
        _stickerDragStart = null;
        _stickerDragRect = null;
      });
      return;
    }

    ref.read(canvasProvider.notifier).endStroke();
    ref.read(lectureProvider.notifier).updateCurrentPageElements(
          ref.read(canvasProvider).elements,
        );
  }

  void _toggleStickerWithAnimation(StickerElement sticker) {
    var controller = _stickerAnimControllers[sticker.id];
    if (controller == null) {
      controller = AnimationController(
        duration: const Duration(milliseconds: 350),
        vsync: this,
      );
      _stickerAnimControllers[sticker.id] = controller;
    }

    if (sticker.isRevealed) {
      // Slide back in (cover again)
      controller.reverse().then((_) {
        ref.read(canvasProvider.notifier).toggleSticker(sticker.id);
        ref.read(lectureProvider.notifier).updateCurrentPageElements(
              ref.read(canvasProvider).elements,
            );
      });
    } else {
      // Slide away (reveal)
      ref.read(canvasProvider.notifier).toggleSticker(sticker.id);
      ref.read(lectureProvider.notifier).updateCurrentPageElements(
            ref.read(canvasProvider).elements,
          );
      controller.forward();
    }
    setState(() {});
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final isCtrlPressed =
          HardwareKeyboard.instance.logicalKeysPressed.any((key) =>
              key == LogicalKeyboardKey.controlLeft ||
              key == LogicalKeyboardKey.controlRight ||
              key == LogicalKeyboardKey.metaLeft ||
              key == LogicalKeyboardKey.metaRight);

      if (isCtrlPressed) {
        // Zoom with Ctrl+Wheel
        final delta = event.scrollDelta.dy;
        final zoomFactor = delta > 0 ? 0.92 : 1.08;

        final focalPoint = _toCanvasPosition(event.position);
        final currentMatrix = _transformController.value.clone();

        // ignore: deprecated_member_use
        currentMatrix.translate(focalPoint.dx, focalPoint.dy);
        // ignore: deprecated_member_use
        currentMatrix.scale(zoomFactor, zoomFactor);
        // ignore: deprecated_member_use
        currentMatrix.translate(-focalPoint.dx, -focalPoint.dy);

        final scale = currentMatrix.getMaxScaleOnAxis();
        if (scale >= AppDimensions.canvasMinScale &&
            scale <= AppDimensions.canvasMaxScale) {
          _transformController.value = currentMatrix;
        }
      }
      // If Ctrl not pressed, let InteractiveViewer handle it (panning)
    }
  }

  void _showTextInputAt(Offset position) {
    setState(() {
      _showTextInput = true;
      _textInputPosition = position;
      _textController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
    });
  }

  void _commitText() {
    if (_textController.text.isNotEmpty) {
      ref.read(canvasProvider.notifier).addTextElement(
            _textInputPosition,
            _textController.text,
          );
      ref.read(lectureProvider.notifier).updateCurrentPageElements(
            ref.read(canvasProvider).elements,
          );
    }
    setState(() {
      _showTextInput = false;
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final canvasState = ref.watch(canvasProvider);
    final lectureState = ref.watch(lectureProvider);

    final pageWidth =
        lectureState.lecture?.pageWidth ?? AppConstants.defaultPageWidth;
    final pageHeight =
        lectureState.lecture?.pageHeight ?? AppConstants.defaultPageHeight;

    final isPanMode = canvasState.currentTool == DrawingTool.pan;

    return Container(
      color: AppColors.canvasBackground,
      child: Center(
        child: Listener(
          onPointerSignal: _handlePointerSignal,
          child: InteractiveViewer(
            transformationController: _transformController,
            panEnabled: isPanMode,
            scaleEnabled: false, // We handle zoom via Ctrl+wheel
            minScale: AppDimensions.canvasMinScale,
            maxScale: AppDimensions.canvasMaxScale,
            boundaryMargin:
                const EdgeInsets.all(AppDimensions.canvasBoundaryMargin),
            child: SizedBox(
              key: _canvasKey,
              width: pageWidth,
              height: pageHeight,
              child: Listener(
                onPointerDown: isPanMode ? null : _handlePointerDown,
                onPointerMove: isPanMode ? null : _handlePointerMove,
                onPointerUp: isPanMode ? null : _handlePointerUp,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Canvas layer
                    Container(
                      decoration: BoxDecoration(
                        color: lectureState.currentPage?.backgroundColor ??
                            AppColors.pageBackground,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: AppDimensions.shadowBlurMD,
                            offset:
                                const Offset(0, AppDimensions.shadowOffsetY),
                          ),
                        ],
                      ),
                      child: ClipRect(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            size: Size(pageWidth, pageHeight),
                            painter: CanvasPainter(
                              elements: canvasState.elements,
                              activeElement: canvasState.activeElement,
                              selectedElementId:
                                  canvasState.selectedElementId,
                              backgroundPattern: _getBackgroundPattern(lectureState),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Image overlays (rendered as widgets for async loading)
                    ..._buildImageOverlays(canvasState),
                    // Sticker overlays (for animation)
                    ..._buildStickerOverlays(canvasState),
                    // Sticker drag preview
                    if (_stickerDragRect != null)
                      Positioned(
                        left: _stickerDragRect!.left < _stickerDragRect!.right
                            ? _stickerDragRect!.left
                            : _stickerDragRect!.right,
                        top: _stickerDragRect!.top < _stickerDragRect!.bottom
                            ? _stickerDragRect!.top
                            : _stickerDragRect!.bottom,
                        width: _stickerDragRect!.width.abs(),
                        height: _stickerDragRect!.height.abs(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: canvasState.currentColor
                                .withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: canvasState.currentColor,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    // Graph overlay
                    const GraphOverlay(),
                    // Remote cursor overlay
                    const CursorOverlay(),
                    // Text input overlay (inline)
                    if (_showTextInput)
                      Positioned(
                        left: _textInputPosition.dx,
                        top: _textInputPosition.dy,
                        child: _InlineTextInput(
                          controller: _textController,
                          focusNode: _textFocusNode,
                          color: canvasState.currentColor,
                          onSubmit: _commitText,
                          onCancel: () {
                            setState(() {
                              _showTextInput = false;
                              _textController.clear();
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _getBackgroundPattern(LectureState lectureState) {
    final bgImage = lectureState.currentPage?.backgroundImageUrl;
    if (bgImage != null && bgImage.startsWith('pattern:')) {
      return bgImage.substring('pattern:'.length);
    }
    return null;
  }

  List<Widget> _buildImageOverlays(CanvasState canvasState) {
    final images = canvasState.elements
        .whereType<ImageCanvasElement>()
        .where((e) => !e.isDeleted)
        .toList();

    return images.map((img) {
      Widget imageWidget;
      if (img.imageUrl.startsWith('data:')) {
        // Base64 data URL
        try {
          final dataUri = Uri.parse(img.imageUrl);
          final base64Str = img.imageUrl.split(',').last;
          final bytes = base64Decode(base64Str);
          imageWidget = Image.memory(
            Uint8List.fromList(bytes),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
        } catch (_) {
          imageWidget = const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          );
        }
      } else {
        imageWidget = Image.network(
          img.imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
        );
      }

      return Positioned(
        left: img.rect.left,
        top: img.rect.top,
        width: img.rect.width,
        height: img.rect.height,
        child: IgnorePointer(
          child: imageWidget,
        ),
      );
    }).toList();
  }

  List<Widget> _buildStickerOverlays(CanvasState canvasState) {
    final stickers = canvasState.elements
        .whereType<StickerElement>()
        .where((s) => !s.isDeleted)
        .toList();

    return stickers.map((sticker) {
      final controller = _stickerAnimControllers[sticker.id];
      final animation = controller != null
          ? CurvedAnimation(parent: controller, curve: Curves.easeInOut)
          : null;

      if (sticker.isRevealed && animation != null) {
        // Animating away - slide to the right
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Positioned(
              left: sticker.rect.left +
                  (sticker.rect.width * animation.value),
              top: sticker.rect.top,
              width: sticker.rect.width,
              height: sticker.rect.height,
              child: Opacity(
                opacity: 1.0 - animation.value,
                child: _StickerCover(sticker: sticker),
              ),
            );
          },
        );
      } else if (!sticker.isRevealed) {
        // Visible sticker cover - drawn as widget overlay
        // (CanvasPainter also draws it, but we use widget for click handling)
        return Positioned(
          left: sticker.rect.left,
          top: sticker.rect.top,
          width: sticker.rect.width,
          height: sticker.rect.height,
          child: _StickerCover(sticker: sticker),
        );
      }
      return const SizedBox.shrink();
    }).toList();
  }
}

class _StickerCover extends StatelessWidget {
  final StickerElement sticker;
  const _StickerCover({required this.sticker});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: sticker.coverColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.touch_app,
          color: Colors.white.withValues(alpha: 0.7),
          size: sticker.rect.height * 0.3,
        ),
      ),
    );
  }
}

/// Inline text input that appears directly on canvas - no border/popup
class _InlineTextInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color color;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _InlineTextInput({
    required this.controller,
    required this.focusNode,
    required this.color,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 40,
          maxWidth: 400,
        ),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape) {
              onCancel();
            }
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: TextStyle(
              color: color,
              fontSize: AppDimensions.fontSizeLG,
            ),
            maxLines: null,
            cursorColor: color,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(2),
              border: InputBorder.none,
              hintText: '...',
              hintStyle: TextStyle(
                color: color.withValues(alpha: 0.3),
              ),
              isDense: true,
            ),
            onSubmitted: (_) => onSubmit(),
            onTapOutside: (_) => onSubmit(),
          ),
        ),
      ),
    );
  }
}

/// AnimatedBuilder workaround since it doesn't exist - use AnimatedBuilder name
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
