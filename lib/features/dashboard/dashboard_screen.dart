import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/file_service.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/l10n/app_localizations.dart';
import '../../widgets/password_prompt.dart';
import 'lecture_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final lectureState = ref.watch(lectureProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);

    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      appBar: AppBar(
        title: const Text('ICanNote'),
        backgroundColor: AppColors.menuBarBackground,
        foregroundColor: Colors.white,
        actions: [
          _SubscriptionBadge(),
          const SizedBox(width: AppDimensions.spacingMD),
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
              tooltip: l10n.get('sign_out'),
              onPressed: () {
                ref.read(authProvider.notifier).signOut();
                context.go('/');
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
                Text(
                  l10n.get('my_lectures'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _openIcnFile(context, ref),
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.get('open_file')),
                ),
                const SizedBox(width: AppDimensions.spacingMD),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(lectureProvider.notifier).createNewLecture();
                    context.go('/editor');
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.get('new_lecture')),
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
                  ? _EmptyState(l10n: l10n)
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
                          l10n: l10n,
                          firstPage: lectureState.lecture!.pages.isNotEmpty
                              ? lectureState.lecture!.pages.first
                              : null,
                          pageWidth: lectureState.lecture!.pageWidth,
                          pageHeight: lectureState.lecture!.pageHeight,
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
    final l10n =
        AppLocalizations.of(ref.read(settingsProvider).language.code);
    final lecture = await fileService.openIcnFile(
      onPasswordRequired: () => context.mounted
          ? showPasswordPrompt(context, l10n)
          : Future.value(null),
    );
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

class _SubscriptionBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subState = ref.watch(subscriptionProvider);
    final planName = subState.currentPlan.name.toUpperCase();
    final isActive = subState.isActive;

    return InkWell(
      onTap: () => context.go('/subscription'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLG,
          vertical: AppDimensions.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.secondary.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.star : Icons.star_border,
              size: 14,
              color: isActive ? AppColors.secondary : Colors.grey.shade400,
            ),
            const SizedBox(width: AppDimensions.spacingSM),
            Text(
              planName,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeSM,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.secondary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppLocalizations l10n;

  const _EmptyState({required this.l10n});

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
            l10n.get('no_lectures'),
            style: TextStyle(
              fontSize: AppDimensions.fontSizeLG,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMD),
          Text(
            l10n.get('empty_lectures_hint'),
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
