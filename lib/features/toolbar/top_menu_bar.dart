import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/file_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../collaboration/room_dialog.dart';

class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);

    return Container(
      height: AppDimensions.topMenuBarHeight,
      color: AppColors.menuBarBackground,
      child: Row(
        children: [
          _MenuBarItem(
            label: l10n.lecture,
            onTapWithContext: (ctx) => _showLectureMenu(ctx, ref, l10n),
          ),
          _MenuBarItem(
            label: l10n.savePrint,
            onTapWithContext: (ctx) => _showSaveMenu(ctx, ref, l10n),
          ),
          _MenuBarItem(
            label: l10n.page,
            onTapWithContext: (ctx) => _showPageMenu(ctx, ref, l10n),
          ),
          _MenuBarItem(
            label: l10n.insert,
            onTapWithContext: (_) {},
          ),
          _MenuBarItem(
            label: l10n.screenBackground,
            onTapWithContext: (_) {},
          ),
          _CollaborateMenuBarItem(),
          _MenuBarItem(
            label: l10n.soundVideo,
            isHighlighted: true,
            onTapWithContext: (_) {},
          ),
          _MenuBarItem(
            label: l10n.settings,
            isHighlighted: true,
            onTapWithContext: (_) => context.go('/settings'),
          ),
          _LoginMenuBarItem(),
          _MenuBarItem(
            label: l10n.help,
            isHighlighted: true,
            onTapWithContext: (ctx) => _showHelpMenu(ctx, ref, l10n),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _showLectureMenu(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Text(l10n.newLecture),
          onTap: () => _showNewLectureDialog(buttonContext, ref),
        ),
        PopupMenuItem(
          child: Text(l10n.openLectureFile),
          onTap: () => _openLectureFile(buttonContext, ref),
        ),
        PopupMenuItem(
          child: Text(l10n.addTextbook),
          onTap: () => _openTextbookFile(buttonContext),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(l10n.closeLecture),
          onTap: () => ref.read(lectureProvider.notifier).closeLecture(),
        ),
      ],
    );
  }

  void _showSaveMenu(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Text(l10n.save),
          onTap: () => _saveLecture(buttonContext, ref),
        ),
        PopupMenuItem(child: Text('${l10n.save} (Protected)')),
        PopupMenuItem(
          child: Text(l10n.saveAs),
          onTap: () => _saveLectureAs(buttonContext, ref),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(l10n.saveAsPdf),
          onTap: () => _showComingSoon(buttonContext, 'PDF export'),
        ),
        PopupMenuItem(
          child: Text(l10n.saveAsImage),
          onTap: () => _showComingSoon(buttonContext, 'Image export'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(l10n.sendByEmail),
          onTap: () => _showComingSoon(buttonContext, 'Email'),
        ),
        PopupMenuItem(
          child: Text(l10n.print_),
          onTap: () => _showComingSoon(buttonContext, 'Print'),
        ),
      ],
    );
  }

  void _showPageMenu(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: [
        PopupMenuItem(
          child: Text(l10n.addPage),
          onTap: () => ref.read(lectureProvider.notifier).addPage(),
        ),
        PopupMenuItem(
          child: Text(l10n.get('restore_deleted_page') != 'restore_deleted_page' ? l10n.get('restore_deleted_page') : 'Restore Deleted Page'),
          onTap: () =>
              ref.read(lectureProvider.notifier).restoreDeletedPage(),
        ),
      ],
    );
  }

  void _showHelpMenu(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    final currentLang = ref.read(settingsProvider).language;

    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text('About ICanNote'),
          onTap: () {},
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Text(
            l10n.language,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...AppLanguage.values.map((lang) => PopupMenuItem(
          child: Row(
            children: [
              Icon(
                currentLang == lang ? Icons.check : Icons.check,
                size: 16,
                color: currentLang == lang ? AppColors.primary : Colors.transparent,
              ),
              const SizedBox(width: 8),
              Text(lang.label),
            ],
          ),
          onTap: () {
            ref.read(settingsProvider.notifier).setLanguage(lang);
          },
        )),
      ],
    );
  }

  void _openLectureFile(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final fileService = FileService();
      final lecture = await fileService.openIcnFile();
      if (lecture != null && context.mounted) {
        ref.read(lectureProvider.notifier).loadLecture(lecture);
        if (lecture.pages.isNotEmpty) {
          ref.read(canvasProvider.notifier).loadElements(
                lecture.pages.first.visibleElements,
              );
        }
      }
    });
  }

  void _openTextbookFile(BuildContext context) {
    Future.microtask(() async {
      final fileService = FileService();
      final files = await fileService.pickDocumentFiles();
      if (files != null && files.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Selected ${files.length} file(s). '
              'Document conversion requires backend server (coming soon).',
            ),
          ),
        );
      }
    });
  }

  void _saveLecture(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) return;
      ref.read(lectureProvider.notifier).updateCurrentPageElements(
            ref.read(canvasProvider).elements,
          );
      final updatedLecture = ref.read(lectureProvider).lecture!;
      final fileService = FileService();
      final saved = await fileService.saveLecture(updatedLecture);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved ? 'Lecture saved.' : 'Save cancelled.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _saveLectureAs(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) return;
      ref.read(lectureProvider.notifier).updateCurrentPageElements(
            ref.read(canvasProvider).elements,
          );
      final updatedLecture = ref.read(lectureProvider).lecture!;
      final fileService = FileService();
      final saved = await fileService.saveLectureAs(updatedLecture);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved ? 'Lecture saved.' : 'Save cancelled.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _showComingSoon(BuildContext context, String feature) {
    Future.microtask(() {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$feature coming soon.'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _showNewLectureDialog(BuildContext context, WidgetRef ref) {
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => _NewLectureDialog(ref: ref),
      );
    });
  }
}

class _MenuBarItem extends StatelessWidget {
  final String label;
  final void Function(BuildContext context) onTapWithContext;
  final bool isHighlighted;

  const _MenuBarItem({
    required this.label,
    required this.onTapWithContext,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTapWithContext(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.menuItemPaddingH,
          vertical: AppDimensions.menuItemPaddingV,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isHighlighted
                ? AppColors.menuBarTextActive
                : AppColors.menuBarText,
            fontSize: AppDimensions.fontSizeMD,
            fontWeight:
                isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LoginMenuBarItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return Builder(
        builder: (buttonContext) => InkWell(
          onTap: () => _showUserMenu(buttonContext, ref, authState),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.menuItemPaddingH,
              vertical: AppDimensions.menuItemPaddingV,
            ),
            child: Text(
              authState.user?.displayName ?? authState.user?.email ?? 'User',
              style: const TextStyle(
                color: AppColors.menuBarTextActive,
                fontSize: AppDimensions.fontSizeMD,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return _MenuBarItem(
      label: 'Login',
      isHighlighted: true,
      onTapWithContext: (_) => context.go('/login'),
    );
  }

  void _showUserMenu(
      BuildContext buttonContext, WidgetRef ref, AuthState authState) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu<String>(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Text(authState.user?.email ?? ''),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          onTap: () => buttonContext.go('/dashboard'),
          child: const Text('Dashboard'),
        ),
        PopupMenuItem<String>(
          onTap: () {
            ref.read(authProvider.notifier).signOut();
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}

class _CollaborateMenuBarItem extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);

    return _MenuBarItem(
      label: syncState.isConnected ? '${l10n.collaborate} (Live)' : l10n.collaborate,
      isHighlighted: syncState.isConnected,
      onTapWithContext: (ctx) => _showCollaborateMenu(ctx, ref, syncState, l10n),
    );
  }

  void _showCollaborateMenu(
      BuildContext buttonContext, WidgetRef ref, SyncState syncState, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry>[
        if (!syncState.isConnected) ...[
          PopupMenuItem(
            child: Text(l10n.createRoom),
            onTap: () {
              Future.microtask(() {
                if (!buttonContext.mounted) return;
                showDialog(
                  context: buttonContext,
                  builder: (_) => const CreateRoomDialog(),
                );
              });
            },
          ),
          PopupMenuItem(
            child: Text(l10n.joinRoom),
            onTap: () {
              Future.microtask(() {
                if (!buttonContext.mounted) return;
                showDialog(
                  context: buttonContext,
                  builder: (_) => const JoinRoomDialog(),
                );
              });
            },
          ),
        ],
        if (syncState.isConnected) ...[
          PopupMenuItem(
            enabled: false,
            child: Text(
              'Room: ${syncState.inviteCode ?? ""}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuItem(
            enabled: false,
            child: Text('${syncState.participants.length} ${l10n.participants}'),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            child: Text(
              syncState.isHost ? l10n.closeRoom : l10n.leaveRoom,
              style: TextStyle(color: AppColors.warningText),
            ),
            onTap: () => ref.read(syncProvider.notifier).leaveRoom(),
          ),
        ],
      ],
    );
  }
}

class _NewLectureDialog extends StatefulWidget {
  final WidgetRef ref;
  const _NewLectureDialog({required this.ref});

  @override
  State<_NewLectureDialog> createState() => _NewLectureDialogState();
}

class _NewLectureDialogState extends State<_NewLectureDialog> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  bool _isLandscape = true;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: AppConstants.defaultPageWidth.toInt().toString(),
    );
    _heightController = TextEditingController(
      text: AppConstants.defaultPageHeight.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _toggleOrientation() {
    setState(() {
      _isLandscape = !_isLandscape;
      final w = _widthController.text;
      final h = _heightController.text;
      _widthController.text = h;
      _heightController.text = w;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Lecture Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Page Width'),
              const SizedBox(width: AppDimensions.spacingLG),
              SizedBox(
                width: AppDimensions.textFieldWidth,
                child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingXXL),
              const Text('Page Height'),
              const SizedBox(width: AppDimensions.spacingLG),
              SizedBox(
                width: AppDimensions.textFieldWidth,
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXL),
          const Text('Orientation'),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Landscape'),
                selected: _isLandscape,
                onSelected: (_) {
                  if (!_isLandscape) _toggleOrientation();
                },
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              ChoiceChip(
                label: const Text('Portrait'),
                selected: !_isLandscape,
                onSelected: (_) {
                  if (_isLandscape) _toggleOrientation();
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            'Page size defaults to A4. When printing, the scale is adjusted to fit.',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeMD,
              color: AppColors.warningText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final width = double.tryParse(_widthController.text) ??
                AppConstants.defaultPageWidth;
            final height = double.tryParse(_heightController.text) ??
                AppConstants.defaultPageHeight;
            widget.ref.read(lectureProvider.notifier).createNewLecture(
                  width: width,
                  height: height,
                );
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
        TextButton(
          onPressed: () {
            widget.ref.read(lectureProvider.notifier).createNewLecture();
            Navigator.pop(context);
          },
          child: const Text('Use Defaults'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
