import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/canvas_element.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../services/file_service.dart';
import '../../providers/settings_provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../widgets/password_prompt.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.canvasBackground,
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HomeCard(
              icon: Icons.note_add,
              iconColor: AppColors.primary,
              title: 'New Lecture',
              subtitle: 'Open a blank page\nand start a lecture',
              onTap: () => _showNewLectureDialog(context, ref),
            ),
            const SizedBox(width: AppDimensions.homeCardGap),
            _HomeCard(
              icon: Icons.folder_open,
              iconColor: AppColors.secondary,
              title: 'Lecture File',
              subtitle: 'Open an ICanNote file\n(*.icn) to start',
              onTap: () => _openIcnFile(context, ref),
            ),
            const SizedBox(width: AppDimensions.homeCardGap),
            _HomeCard(
              icon: Icons.description,
              iconColor: AppColors.textbookCardColor,
              title: 'Open Textbook',
              subtitle: 'Open documents in\nvarious formats',
              onTap: () => _openTextbook(context, ref),
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
      // Load first page elements into canvas
      if (lecture.pages.isNotEmpty) {
        ref.read(canvasProvider.notifier).loadElements(
              lecture.pages.first.visibleElements,
            );
      }
      context.go('/editor');
    }
  }

  Future<void> _openTextbook(BuildContext context, WidgetRef ref) async {
    final fileService = FileService();
    final files = await fileService.pickDocumentFiles();
    if (files == null || files.isEmpty || !context.mounted) return;

    // Separate image files from document files
    final imageExtensions = {'jpg', 'jpeg', 'png'};
    final imageFiles = <PlatformFile>[];
    final docFiles = <PlatformFile>[];

    for (final file in files) {
      final ext = file.extension?.toLowerCase() ?? '';
      if (imageExtensions.contains(ext)) {
        imageFiles.add(file);
      } else {
        docFiles.add(file);
      }
    }

    // Show message for unsupported document files
    if (docFiles.isNotEmpty && imageFiles.isEmpty && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${docFiles.map((f) => f.extension?.toUpperCase()).toSet().join(", ")} '
            'format conversion is coming soon.',
          ),
        ),
      );
      return;
    }

    // Handle image files - load them onto the canvas
    if (imageFiles.isNotEmpty && context.mounted) {
      // Create a new lecture first
      ref.read(lectureProvider.notifier).createNewLecture();

      final elements = <CanvasElement>[];
      double yOffset = 50.0;

      for (final file in imageFiles) {
        if (file.bytes == null) continue;

        // Convert to base64 data URL
        final ext = file.extension?.toLowerCase() ?? 'png';
        final mimeType = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'image/png';
        final base64Data = base64Encode(file.bytes!);
        final dataUrl = 'data:$mimeType;base64,$base64Data';

        // Place image on canvas (default size, user can resize later)
        final imageElement = ImageCanvasElement(
          imageUrl: dataUrl,
          rect: Rect.fromLTWH(50, yOffset, 800, 600),
        );
        elements.add(imageElement);
        yOffset += 650; // Stack images vertically with gap
      }

      // Load elements into canvas
      ref.read(canvasProvider.notifier).loadElements(elements);

      // Show info about doc files if any were also selected
      if (docFiles.isNotEmpty && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loaded ${imageFiles.length} image(s). '
              '${docFiles.length} document file(s) skipped (coming soon).',
            ),
          ),
        );
      }

      if (context.mounted) {
        context.go('/editor');
      }
    }
  }

  void _showNewLectureDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _NewLectureDialogSimple(ref: ref),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
      child: Container(
        width: AppDimensions.homeCardWidth,
        padding: const EdgeInsets.all(AppDimensions.homeCardPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppDimensions.homeIconContainerSize,
              height: AppDimensions.homeIconContainerSize,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusLG),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.3),
                    blurRadius: AppDimensions.shadowBlurLG,
                    offset: const Offset(0, AppDimensions.shadowOffsetYLG),
                  ),
                ],
              ),
              child: Icon(icon, size: AppDimensions.iconSizeLG,
                  color: Colors.white),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeLG,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMD),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppDimensions.fontSizeMD,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewLectureDialogSimple extends StatefulWidget {
  final WidgetRef ref;
  const _NewLectureDialogSimple({required this.ref});

  @override
  State<_NewLectureDialogSimple> createState() =>
      _NewLectureDialogSimpleState();
}

class _NewLectureDialogSimpleState extends State<_NewLectureDialogSimple> {
  final _widthController = TextEditingController(
    text: AppConstants.defaultPageWidth.toInt().toString(),
  );
  final _heightController = TextEditingController(
    text: AppConstants.defaultPageHeight.toInt().toString(),
  );
  bool _isLandscape = true;

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Lecture Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Page Width  '),
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
              const SizedBox(width: AppDimensions.spacingXL),
              const Text('Page Height  '),
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
          Row(
            children: [
              const Text('Orientation  '),
              ChoiceChip(
                label: const Text('Landscape'),
                selected: _isLandscape,
                onSelected: (v) {
                  if (!_isLandscape) {
                    setState(() {
                      _isLandscape = true;
                      final w = _widthController.text;
                      _widthController.text = _heightController.text;
                      _heightController.text = w;
                    });
                  }
                },
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              ChoiceChip(
                label: const Text('Portrait'),
                selected: !_isLandscape,
                onSelected: (v) {
                  if (_isLandscape) {
                    setState(() {
                      _isLandscape = false;
                      final w = _widthController.text;
                      _widthController.text = _heightController.text;
                      _heightController.text = w;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            'Page size defaults to A4. When printing, the scale adjusts to fit paper size.',
            style: TextStyle(
              fontSize: AppDimensions.fontSizeSM,
              color: AppColors.warningText,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            final w = double.tryParse(_widthController.text) ??
                AppConstants.defaultPageWidth;
            final h = double.tryParse(_heightController.text) ??
                AppConstants.defaultPageHeight;
            widget.ref
                .read(lectureProvider.notifier)
                .createNewLecture(width: w, height: h);
            Navigator.pop(context);
            context.go('/editor');
          },
          child: const Text('Apply'),
        ),
        TextButton(
          onPressed: () {
            widget.ref.read(lectureProvider.notifier).createNewLecture();
            Navigator.pop(context);
            context.go('/editor');
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
