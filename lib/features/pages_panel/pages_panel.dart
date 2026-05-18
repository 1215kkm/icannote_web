import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'page_thumbnail.dart';

class PagesPanel extends ConsumerWidget {
  final double width;

  const PagesPanel({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lectureState = ref.watch(lectureProvider);
    final pages = lectureState.lecture?.pages ?? [];

    return Container(
      width: width,
      color: AppColors.panelBackground,
      child: Column(
        children: [
          Expanded(
            child: pages.isEmpty
                ? const Center(
                    child: Text(
                      'No pages',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: AppDimensions.fontSizeMD,
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(AppDimensions.spacingSM),
                    itemCount: pages.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex--;
                      ref
                          .read(lectureProvider.notifier)
                          .reorderPages(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      final isSelected =
                          index == lectureState.currentPageIndex;
                      return PageThumbnail(
                        key: ValueKey(page.id),
                        pageIndex: index,
                        isSelected: isSelected,
                        backgroundColor: page.backgroundColor,
                        onTap: () {
                          final lectureNotifier =
                              ref.read(lectureProvider.notifier);
                          // 1. Flush the current page's canvas edits so
                          //    switching pages never loses unsaved work.
                          lectureNotifier.updateCurrentPageElements(
                            ref.read(canvasProvider).elements,
                          );
                          // 2. Switch to the tapped page.
                          lectureNotifier.setCurrentPage(index);
                          // 3. Load that page's elements (re-read after the
                          //    flush so we get the persisted state).
                          final newPage =
                              ref.read(lectureProvider).currentPage;
                          ref
                              .read(canvasProvider.notifier)
                              .loadElements(
                                newPage?.visibleElements ?? const [],
                              );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
