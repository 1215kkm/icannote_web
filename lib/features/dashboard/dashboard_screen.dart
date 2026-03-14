import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../services/file_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import 'lecture_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final lectureState = ref.watch(lectureProvider);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        title: const Text('ICanNote'),
        backgroundColor: AppColors.menuBarBackground,
        foregroundColor: Colors.white,
        actions: [
          if (authState.isAuthenticated) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD),
              child: Center(
                child: Text(
                  authState.user?.displayName ?? authState.user?.email ?? '',
                  style: const TextStyle(
                      fontSize: AppDimensions.fontSizeMD),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign Out',
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/login');
              },
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'My Lectures',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openIcnFile(context, ref),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open File'),
                ),
                const SizedBox(width: AppDimensions.spacingMD),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(lectureProvider.notifier).createNewLecture();
                    context.go('/editor');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Lecture'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXXL),

            // Lecture grid
            Expanded(
              child: lectureState.lecture == null
                  ? _EmptyState()
                  : GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: AppDimensions.spacingXL,
                      crossAxisSpacing: AppDimensions.spacingXL,
                      childAspectRatio: 1.4,
                      children: [
                        LectureCard(
                          title: lectureState.lecture!.title,
                          pageCount: lectureState.lecture!.pages.length,
                          lastModified: lectureState.lecture!.updatedAt,
                          onTap: () => context.go('/editor'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openIcnFile(BuildContext context, WidgetRef ref) async {
    final fileService = FileService();
    final lecture = await fileService.openIcnFile();
    if (lecture != null && context.mounted) {
      ref.read(lectureProvider.notifier).loadLecture(lecture);
      if (lecture.pages.isNotEmpty) {
        ref.read(canvasProvider.notifier).loadElements(
              lecture.pages.first.visibleElements,
            );
      }
      context.go('/editor');
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          Text(
            'No lectures yet',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeLG,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Text(
            'Create a new lecture or open an existing file to get started.',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeMD,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
