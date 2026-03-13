import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../models/stroke.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'canvas_painter.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  const CanvasScreen({super.key});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
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
          minScale: 0.25,
          maxScale: 5.0,
          boundaryMargin: const EdgeInsets.all(200),
          child: SizedBox(
            width: pageWidth,
            height: pageHeight,
            child: Listener(
              onPointerDown: isPanMode
                  ? null
                  : (event) {
                      final pos =
                          _toCanvasPosition(event.position, context);
                      ref.read(canvasProvider.notifier).startStroke(pos);
                    },
              onPointerMove: isPanMode
                  ? null
                  : (event) {
                      final pos =
                          _toCanvasPosition(event.position, context);
                      ref.read(canvasProvider.notifier).updateStroke(pos);
                    },
              onPointerUp: isPanMode
                  ? null
                  : (event) {
                      ref.read(canvasProvider.notifier).endStroke();
                      // Sync strokes to lecture
                      ref
                          .read(lectureProvider.notifier)
                          .updateCurrentPageStrokes(
                            ref.read(canvasProvider).strokes,
                          );
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: lectureState.currentPage?.backgroundColor ??
                      AppColors.pageBackground,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: Size(pageWidth, pageHeight),
                      painter: CanvasPainter(
                        strokes: canvasState.strokes,
                        activeStroke: canvasState.activeStroke,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
