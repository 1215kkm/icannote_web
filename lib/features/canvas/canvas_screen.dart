import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../models/stroke.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import 'canvas_painter.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  final TransformationController _transformController =
      TransformationController();

  // Text input state
  bool _showTextInput = false;
  Offset _textInputPosition = Offset.zero;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  @override
  void dispose() {
    _transformController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Offset _toCanvasPosition(Offset globalPosition, BuildContext context) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return globalPosition;
    final local = box.globalToLocal(globalPosition);
    final matrix = _transformController.value;
    final inverse = Matrix4.inverted(matrix);
    final transformed = MatrixUtils.transformPoint(inverse, local);
    return transformed;
  }

  void _handlePointerDown(PointerDownEvent event) {
    final pos = _toCanvasPosition(event.position, context);
    final tool = ref.read(canvasProvider).currentTool;

    if (tool == DrawingTool.text) {
      _showTextInputAt(pos);
      return;
    }

    ref.read(canvasProvider.notifier).startStroke(pos);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    final pos = _toCanvasPosition(event.position, context);
    ref.read(canvasProvider.notifier).updateStroke(pos);
  }

  void _handlePointerUp(PointerUpEvent event) {
    ref.read(canvasProvider.notifier).endStroke();
    // Sync elements to lecture
    ref
        .read(lectureProvider.notifier)
        .updateCurrentPageElements(
          ref.read(canvasProvider).elements,
        );
  }

  void _showTextInputAt(Offset position) {
    setState(() {
      _showTextInput = true;
      _textInputPosition = position;
      _textController.clear();
    });
    // Delay focus to next frame
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
      // Sync
      ref
          .read(lectureProvider.notifier)
          .updateCurrentPageElements(
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
        child: InteractiveViewer(
          transformationController: _transformController,
          panEnabled: isPanMode,
          scaleEnabled: true,
          minScale: AppDimensions.canvasMinScale,
          maxScale: AppDimensions.canvasMaxScale,
          boundaryMargin:
              const EdgeInsets.all(AppDimensions.canvasBoundaryMargin),
          child: SizedBox(
            width: pageWidth,
            height: pageHeight,
            child: Listener(
              onPointerDown: isPanMode ? null : _handlePointerDown,
              onPointerMove: isPanMode ? null : _handlePointerMove,
              onPointerUp: isPanMode ? null : _handlePointerUp,
              child: Stack(
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
                          offset: const Offset(
                              0, AppDimensions.shadowOffsetY),
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
                            selectedElementId: canvasState.selectedElementId,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Text input overlay
                  if (_showTextInput)
                    Positioned(
                      left: _textInputPosition.dx,
                      top: _textInputPosition.dy,
                      child: _TextInputOverlay(
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
    );
  }
}

class _TextInputOverlay extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color color;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _TextInputOverlay({
    required this.controller,
    required this.focusNode,
    required this.color,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: AppDimensions.textInputMinWidth,
        maxWidth: AppDimensions.textInputMaxWidth,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: AppColors.textInputBorder,
          width: AppDimensions.borderWidthMedium,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: AppDimensions.shadowBlurSM,
            offset: const Offset(0, AppDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IntrinsicWidth(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                  color: color, fontSize: AppDimensions.fontSizeLG),
              maxLines: null,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.all(AppDimensions.textInputPadding),
                border: InputBorder.none,
                hintText: 'Type text...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel',
                    style: TextStyle(fontSize: AppDimensions.fontSizeSM)),
              ),
              TextButton(
                onPressed: onSubmit,
                child: const Text('OK',
                    style: TextStyle(fontSize: AppDimensions.fontSizeSM)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
