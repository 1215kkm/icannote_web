import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/l10n/app_localizations.dart';
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
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);
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
                  onPressed: () => _addPage(ref),
                  tooltip: l10n.addPage,
                  color: AppColors.toolbarIconDefault,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: AppDimensions.bottomButtonMinSize,
                    minHeight: AppDimensions.bottomButtonMinSize,
                  ),
                ),
                Text(
                  '$currentPage / $pageCount ${l10n.get('page_info')}',
                  style: const TextStyle(
                    color: AppColors.toolbarIconDefault,
                    fontSize: AppDimensions.fontSizeSM,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: AppDimensions.iconSizeMD),
                  onPressed: () => _deletePage(ref),
                  tooltip: l10n.deletePage,
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
            tooltip: l10n.invertColors,
            onTap: () => _invertColors(ref),
          ),
          _BottomAction(
            icon: Icons.arrow_upward,
            tooltip: l10n.bringForward,
            onTap: () => ref.read(canvasProvider.notifier).bringForward(),
          ),
          _BottomAction(
            icon: Icons.arrow_downward,
            tooltip: l10n.sendBackward,
            onTap: () => ref.read(canvasProvider.notifier).sendBackward(),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.undo,
            tooltip: l10n.undo,
            onTap: () => ref.read(canvasProvider.notifier).undo(),
          ),
          _BottomAction(
            icon: Icons.redo,
            tooltip: l10n.redo,
            onTap: () => ref.read(canvasProvider.notifier).redo(),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.copy,
            tooltip: l10n.copy,
            onTap: () => ref.read(canvasProvider.notifier).copySelected(),
          ),
          _BottomAction(
            icon: Icons.paste,
            tooltip: l10n.paste,
            onTap: () => ref.read(canvasProvider.notifier).paste(),
          ),
          _BottomAction(
            icon: Icons.select_all,
            tooltip: l10n.selectAll,
            onTap: () => ref.read(canvasProvider.notifier).selectAll(),
          ),
          _BottomAction(
            icon: Icons.clear_all,
            tooltip: l10n.clearAll,
            onTap: () => ref.read(canvasProvider.notifier).clearAll(),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.library_books,
            tooltip: l10n.library,
            onTap: () => ref.read(libraryProvider.notifier).toggle(),
          ),
          _BottomAction(
            icon: Icons.show_chart,
            tooltip: l10n.graph,
            onTap: () => ref.read(graphProvider.notifier).toggle(),
          ),
          const RecordButton(),
          _BottomAction(
            icon: Icons.screenshot,
            tooltip: l10n.screenCapture,
            onTap: () => _screenCapture(context, ref),
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.abc,
            tooltip: l10n.autoAlphabet,
            onTap: () => _autoAlphabet(ref),
          ),
          _BottomAction(
            icon: Icons.onetwothree,
            tooltip: l10n.autoNumber,
            onTap: () => _autoNumber(ref),
          ),
          const Spacer(),
          // Zoom controls
          _BottomAction(
            icon: Icons.zoom_in,
            tooltip: l10n.zoomIn,
            onTap: () {
              final current = ref.read(canvasProvider).zoom;
              ref.read(canvasProvider.notifier).setZoom(current + 0.1);
            },
          ),
          _BottomAction(
            icon: Icons.zoom_out,
            tooltip: l10n.zoomOut,
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

  /// Add a new page: flush the current page's edits first, then add the
  /// blank page and clear the canvas so it reflects the new empty page.
  void _addPage(WidgetRef ref) {
    final lectureNotifier = ref.read(lectureProvider.notifier);
    lectureNotifier.updateCurrentPageElements(
      ref.read(canvasProvider).elements,
    );
    lectureNotifier.addPage();
    final newPage = ref.read(lectureProvider).currentPage;
    ref
        .read(canvasProvider.notifier)
        .loadElements(newPage?.visibleElements ?? const []);
  }

  /// Delete the current page (read the index fresh inside the callback,
  /// never from a stale build closure), then sync the canvas to the
  /// page that becomes current.
  void _deletePage(WidgetRef ref) {
    final lectureNotifier = ref.read(lectureProvider.notifier);
    final index = ref.read(lectureProvider).currentPageIndex;
    lectureNotifier.deletePage(index);
    final newPage = ref.read(lectureProvider).currentPage;
    ref
        .read(canvasProvider.notifier)
        .loadElements(newPage?.visibleElements ?? const []);
  }

  /// Invert colors of all elements on the canvas (single undoable action).
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

    // Undoable: keeps undo/redo history and repaints the canvas.
    ref.read(canvasProvider.notifier).replaceElements(invertedElements);
    ref
        .read(lectureProvider.notifier)
        .updateCurrentPageElements(ref.read(canvasProvider).elements);
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
    final l10n =
        AppLocalizations.of(ref.read(settingsProvider).language.code);
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.get('no_canvas_to_capture'))),
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
          SnackBar(
            content: Text(success
                ? l10n.get('screen_captured')
                : l10n.get('capture_cancelled')),
          ),
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
