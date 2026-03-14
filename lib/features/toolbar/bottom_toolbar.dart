import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../library/library_panel.dart';
import '../canvas/graph_overlay.dart';
import '../recording/recording_overlay.dart';

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
            tooltip: 'Invert',
            onTap: () {},
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
            onTap: () {},
          ),
          const VerticalDivider(
              width: AppDimensions.dividerHeight,
              color: AppColors.toolbarDivider),
          _BottomAction(
            icon: Icons.abc,
            tooltip: 'Auto Alphabet',
            onTap: () {},
          ),
          _BottomAction(
            icon: Icons.onetwothree,
            tooltip: 'Auto Number',
            onTap: () {},
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
