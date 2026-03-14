import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../core/constants/app_colors.dart';
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
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(4),
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
                          ref
                              .read(lectureProvider.notifier)
                              .setCurrentPage(index);
                          // Load the elements for this page
                          ref
                              .read(canvasProvider.notifier)
                              .loadElements(page.visibleElements);
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
