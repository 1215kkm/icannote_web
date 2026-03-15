import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/canvas_element.dart';
import '../../services/canvas_export_service.dart';
import '../library/library_panel.dart';
import '../canvas/graph_overlay.dart';
import '../recording/recording_overlay.dart';

/// Provider for auto-label counters
final _autoAlphabetCounterProvider = StateProvider<int>((ref) => 0);
final _autoNumberCounterProvider = StateProvider<int>((ref) => 0);

class BottomToolbar extends ConsumerWidget {
  const BottomToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lectureState = ref.watch(lectureProvider);
    final pageCount = lectureState.lecture?.pages.length ?? 0;
    final currentPage = lectureState.currentPageIndex + 1;

    return Container(
      height: AppDimensions.bottomToolbarHeight,
      color: AppColors.toolbarBackground,
      child: Row(
        children: [
          // Page info
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      size: AppDimensions.iconSizeMD),
                  onPressed: () =>
                      ref.read(lectureProvider.notifier).addPage(),
                  tooltip: 'Add Page',
                  color: AppColors.toolbarIconDefault,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppDimensions.bottomButtonMinSize,
                    minHeight: AppDimensions.bottomButtonMinSize,
                  ),
                ),
                Text(
                  '$currentPage / $pageCount Page',
                  style: const TextStyle(
                    color: AppColors.toolbarIconDefault,
                    fontSize: AppDimensions.fontSizeSM,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: AppDimensions.iconSizeMD),
                  onPressed: () => ref
                      .read(lectureProvider.notifier)
                      .deletePage(lectureState.currentPageIndex),
                  tooltip: 'Delete Page',
                  color: AppColors.toolbarIconDefault,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppDimensions.bottomButtonMinSize,
                    minHeight: AppDimensions.bottomButtonMinSize,
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          // Toolbar actions
          _BottomAction(
            icon: Icons.flip,
            tooltip: 'Invert Colors',
            onTap: () => _invertColors(ref),
          ),
          _BottomAction(
            icon: Icons.arrow_upward,
            tooltip: 'Bring Forward',
            onTap: () => ref.read(canvasProvider.notifier).bringForward(),
          ),
          _BottomAction(
            icon: Icons.arrow_downward,
            tooltip: 'Send Backward',
            onTap: () => ref.read(canvasProvider.notifier).sendBackward(),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.undo,
            tooltip: 'Undo',
            onTap: () => ref.read(canvasProvider.notifier).undo(),
          ),
          _BottomAction(
            icon: Icons.redo,
            tooltip: 'Redo',
            onTap: () => ref.read(canvasProvider.notifier).redo(),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.copy,
            tooltip: 'Copy',
            onTap: () => ref.read(canvasProvider.notifier).copySelected(),
          ),
          _BottomAction(
            icon: Icons.paste,
            tooltip: 'Paste',
            onTap: () => ref.read(canvasProvider.notifier).paste(),
          ),
          _BottomAction(
            icon: Icons.select_all,
            tooltip: 'Select All',
            onTap: () => ref.read(canvasProvider.notifier).selectAll(),
          ),
          _BottomAction(
            icon: Icons.clear_all,
            tooltip: 'Clear All',
            onTap: () => ref.read(canvasProvider.notifier).clearAll(),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.library_books,
            tooltip: 'Library',
            onTap: () => ref.read(libraryProvider.notifier).toggle(),
          ),
          _BottomAction(
            icon: Icons.show_chart,
            tooltip: 'Graph',
            onTap: () => ref.read(graphProvider.notifier).toggle(),
          ),
          const RecordButton(),
          _BottomAction(
            icon: Icons.screenshot,
            tooltip: 'Screen Capture',
            onTap: () => _screenCapture(context, ref),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.abc,
            tooltip: 'Auto Alphabet',
            onTap: () => _autoAlphabet(ref),
          ),
          _BottomAction(
            icon: Icons.onetwothree,
            tooltip: 'Auto Number',
            onTap: () => _autoNumber(ref),
          ),
          const Spacer(),
          // Zoom controls
          _BottomAction(
            icon: Icons.zoom_in,
            tooltip: 'Zoom In',
            onTap: () {
              final current = ref.read(canvasProvider).zoom;
              ref.read(canvasProvider.notifier).setZoom(current + 0.1);
            },
          ),
          _BottomAction(
            icon: Icons.zoom_out,
            tooltip: 'Zoom Out',
            onTap: () {
              final current = ref.read(canvasProvider).zoom;
              ref.read(canvasProvider.notifier).setZoom(current - 0.1);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMD),
            child: Consumer(
              builder: (context, ref, _) {
                final zoom = ref.watch(
                    canvasProvider.select((s) => s.zoom));
                return Text(
                  '${(zoom * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.toolbarIconDefault,
                    fontSize: AppDimensions.fontSizeSM,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Invert colors of all elements on the canvas.
  void _invertColors(WidgetRef ref) {
    final canvasState = ref.read(canvasProvider);
    final elements = canvasState.elements;
    if (elements.isEmpty) return;

    final invertedElements = elements.map((el) {
      if (el is StrokeElement) {
        return el.copyWith(color: _invertColor(el.color));
      } else if (el is ShapeElement) {
        return el.copyWith(
          strokeColor: _invertColor(el.strokeColor),
          fillColor: el.fillColor != null ? _invertColor(el.fillColor!) : null,
        );
      } else if (el is TextCanvasElement) {
        return el.copyWith(color: _invertColor(el.color));
      }
      return el;
    }).toList();

    ref.read(canvasProvider.notifier).loadElements(invertedElements);
    ref.read(lectureProvider.notifier).updateCurrentPageElements(invertedElements);
  }

  Color _invertColor(Color color) {
    return Color.fromARGB(
      color.a.toInt(),
      255 - color.r.toInt(),
      255 - color.g.toInt(),
      255 - color.b.toInt(),
    );
  }

  /// Screen capture - exports the current canvas as an image.
  void _screenCapture(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No canvas to capture.')),
          );
        }
        return;
      }
      final lectureState = ref.read(lectureProvider);
      final bgColor = lectureState.currentPage?.backgroundColor ?? Colors.white;
      final success = await CanvasExportService.exportAsImage(
        elements: ref.read(canvasProvider).elements,
        width: lecture.pageWidth,
        height: lecture.pageHeight,
        backgroundColor: bgColor,
        fileName: 'screenshot_page${lectureState.currentPageIndex + 1}.png',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Screen captured.' : 'Capture cancelled.')),
        );
      }
    });
  }

  /// Auto Alphabet - adds sequential alphabet labels (A, B, C, ...).
  void _autoAlphabet(WidgetRef ref) {
    final counter = ref.read(_autoAlphabetCounterProvider);
    final label = String.fromCharCode(65 + (counter % 26)); // A-Z
    _addAutoLabel(ref, label);
    ref.read(_autoAlphabetCounterProvider.notifier).state = counter + 1;
  }

  /// Auto Number - adds sequential number labels (1, 2, 3, ...).
  void _autoNumber(WidgetRef ref) {
    final counter = ref.read(_autoNumberCounterProvider);
    final label = '${counter + 1}';
    _addAutoLabel(ref, label);
    ref.read(_autoNumberCounterProvider.notifier).state = counter + 1;
  }

  /// Add a label element at the next available position.
  void _addAutoLabel(WidgetRef ref, String label) {
    final canvasState = ref.read(canvasProvider);
    final elements = canvasState.elements;

    // Find a position that doesn't overlap existing elements
    double x = 50.0;
    double y = 50.0;
    for (final el in elements) {
      if (el is TextCanvasElement) {
        if (el.position.dy + 40 > y) {
          y = el.position.dy + 40;
        }
      }
    }

    ref.read(canvasProvider.notifier).addTextElement(
      Offset(x, y),
      label,
      fontSize: 24,
      isBold: true,
    );
    ref.read(lectureProvider.notifier).updateCurrentPageElements(
      ref.read(canvasProvider).elements,
    );
  }
}

class _BottomAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _BottomAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: AppDimensions.actionButtonSize,
          height: AppDimensions.actionButtonSize,
          margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.actionButtonMarginH),
          child: Icon(
            icon,
            size: AppDimensions.iconSizeMD,
            color: AppColors.toolbarIconDefault,
          ),
        ),
      ),
    );
  }
}
