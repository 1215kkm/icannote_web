import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../services/file_service.dart';
import '../../core/constants/app_constants.dart';

class TopMenuBar extends ConsumerWidget {
  const TopMenuBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 32,
      color: AppColors.menuBarBackground,
      child: Row(
        children: [
          _MenuBarItem(
            label: 'Lecture',
            onTap: () => _showLectureMenu(context, ref),
          ),
          _MenuBarItem(
            label: 'Save/Print',
            onTap: () => _showSaveMenu(context, ref),
          ),
          _MenuBarItem(
            label: 'Page',
            onTap: () => _showPageMenu(context, ref),
          ),
          _MenuBarItem(
            label: 'Insert',
            onTap: () {},
          ),
          _MenuBarItem(
            label: 'Screen/Background',
            onTap: () {},
          ),
          _MenuBarItem(
            label: 'Sound/Video',
            isHighlighted: true,
            onTap: () {},
          ),
          _MenuBarItem(
            label: 'Settings',
            isHighlighted: true,
            onTap: () {},
          ),
          _MenuBarItem(
            label: 'Login',
            isHighlighted: true,
            onTap: () {},
          ),
          _MenuBarItem(
            label: 'Help',
            isHighlighted: true,
            onTap: () {},
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _showLectureMenu(BuildContext context, WidgetRef ref) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, 32, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text('New Lecture'),
          onTap: () => _showNewLectureDialog(context, ref),
        ),
        PopupMenuItem(
          child: const Text('Open Lecture File'),
          onTap: () => _openLectureFile(context, ref),
        ),
        PopupMenuItem(
          child: const Text('Add Textbook File'),
          onTap: () => _openTextbookFile(context),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Text('Close Lecture'),
          onTap: () => ref.read(lectureProvider.notifier).closeLecture(),
        ),
      ],
    );
  }

  void _showSaveMenu(BuildContext context, WidgetRef ref) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(80, 32, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const Text('Save'),
          onTap: () => _saveLecture(context, ref),
        ),
        const PopupMenuItem(child: Text('Save with Protection')),
        PopupMenuItem(
          child: const Text('Save As...'),
          onTap: () => _saveLectureAs(context, ref),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Text('Save as PDF'),
          onTap: () => _showComingSoon(context, 'PDF export'),
        ),
        PopupMenuItem(
          child: const Text('Save as Image'),
          onTap: () => _showComingSoon(context, 'Image export'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const Text('Send by Email'),
          onTap: () => _showComingSoon(context, 'Email'),
        ),
        PopupMenuItem(
          child: const Text('Print'),
          onTap: () => _showComingSoon(context, 'Print'),
        ),
      ],
    );
  }

  void _showPageMenu(BuildContext context, WidgetRef ref) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(160, 32, 0, 0),
      items: [
        PopupMenuItem(
          child: const Text('Add Page'),
          onTap: () => ref.read(lectureProvider.notifier).addPage(),
        ),
        PopupMenuItem(
          child: const Text('Restore Deleted Page'),
          onTap: () =>
              ref.read(lectureProvider.notifier).restoreDeletedPage(),
        ),
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
      // Ensure current page elements are synced
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
    // Defer to next frame so the menu closes first
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
  final VoidCallback onTap;
  final bool isHighlighted;

  const _MenuBarItem({
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: isHighlighted
                ? AppColors.menuBarTextActive
                : AppColors.menuBarText,
            fontSize: 12,
            fontWeight:
                isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const Text('Page Height'),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
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
          const SizedBox(height: 16),
          const Text('Orientation'),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Landscape'),
                selected: _isLandscape,
                onSelected: (_) {
                  if (!_isLandscape) _toggleOrientation();
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Portrait'),
                selected: !_isLandscape,
                onSelected: (_) {
                  if (_isLandscape) _toggleOrientation();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Page size defaults to A4. When printing, the scale is adjusted to fit.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade700,
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
