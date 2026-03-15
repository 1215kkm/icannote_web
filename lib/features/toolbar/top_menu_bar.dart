import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/canvas_element.dart';
import '../../models/stroke.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/file_service.dart';
import '../../services/canvas_export_service.dart';
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
            onTapWithContext: (ctx) => _showInsertMenu(ctx, ref, l10n),
          ),
          _MenuBarItem(
            label: l10n.screenBackground,
            onTapWithContext: (ctx) => _showScreenBackgroundMenu(ctx, ref, l10n),
          ),
          _CollaborateMenuBarItem(),
          _MenuBarItem(
            label: l10n.soundVideo,
            isHighlighted: true,
            onTapWithContext: (ctx) => _showSoundVideoDialog(ctx, ref, l10n),
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
          onTap: () => _openTextbookFile(buttonContext, ref),
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
        PopupMenuItem(
          child: Text(l10n.get('save_with_protection')),
          onTap: () => _saveWithProtection(buttonContext, ref),
        ),
        PopupMenuItem(
          child: Text(l10n.saveAs),
          onTap: () => _saveLectureAs(buttonContext, ref),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(l10n.saveAsPdf),
          onTap: () => _exportAsPdf(buttonContext, ref),
        ),
        PopupMenuItem(
          child: Text(l10n.saveAsImage),
          onTap: () => _exportAsImage(buttonContext, ref),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: Text(l10n.sendByEmail),
          onTap: () => _sendByEmail(buttonContext, ref),
        ),
        PopupMenuItem(
          child: Text(l10n.print_),
          onTap: () => _printLecture(buttonContext, ref),
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

  // ──── Insert Menu ────
  void _showInsertMenu(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.image, size: 18),
              const SizedBox(width: 8),
              Text(l10n.insertImage),
            ],
          ),
          onTap: () => _insertImage(buttonContext, ref),
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.title, size: 18),
              const SizedBox(width: 8),
              Text(l10n.insertText),
            ],
          ),
          onTap: () {
            ref.read(canvasProvider.notifier).setTool(DrawingTool.text);
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.crop_square, size: 18),
              const SizedBox(width: 8),
              Text(l10n.insertShape),
            ],
          ),
          onTap: () {
            ref.read(canvasProvider.notifier).setTool(DrawingTool.rectangle);
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.show_chart, size: 18),
              const SizedBox(width: 8),
              Text(l10n.insertLine),
            ],
          ),
          onTap: () {
            ref.read(canvasProvider.notifier).setTool(DrawingTool.line);
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              const Icon(Icons.note, size: 18),
              const SizedBox(width: 8),
              Text(l10n.insertSticker),
            ],
          ),
          onTap: () {
            ref.read(canvasProvider.notifier).setTool(DrawingTool.sticker);
          },
        ),
      ],
    );
  }

  void _insertImage(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      try {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true,
        );
        if (result == null || result.files.isEmpty) return;
        final file = result.files.first;
        if (file.bytes == null) return;

        final ext = file.extension?.toLowerCase() ?? 'png';
        final mimeType = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'image/png';
        final base64Data = base64Encode(file.bytes!);
        final dataUrl = 'data:$mimeType;base64,$base64Data';

        final currentElements = ref.read(canvasProvider).elements;
        double yOffset = 50.0;
        for (final el in currentElements) {
          final bottom = el.boundingBox.bottom;
          if (bottom + 50 > yOffset) yOffset = bottom + 50;
        }

        final imageElement = ImageCanvasElement(
          imageUrl: dataUrl,
          rect: Rect.fromLTWH(50, yOffset, 800, 600),
        );

        final newElements = [...currentElements, imageElement];
        ref.read(canvasProvider.notifier).loadElements(newElements);
        ref.read(lectureProvider.notifier).updateCurrentPageElements(newElements);
      } catch (e) {
        debugPrint('Error inserting image: $e');
      }
    });
  }

  // ──── Screen/Background Menu ────
  void _showScreenBackgroundMenu(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final offset = button.localToGlobal(Offset.zero);
    final size = button.size;
    showMenu(
      context: buttonContext,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy + size.height, offset.dx + 200, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          enabled: false,
          child: Text(l10n.backgroundColor, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        ..._backgroundColorItems(ref, l10n),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          child: Text(l10n.backgroundPattern, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        PopupMenuItem(
          child: Row(children: [const Icon(Icons.grid_on, size: 18), const SizedBox(width: 8), Text(l10n.patternGrid)]),
          onTap: () => _setBackgroundPattern(buttonContext, ref, 'grid'),
        ),
        PopupMenuItem(
          child: Row(children: [const Icon(Icons.horizontal_rule, size: 18), const SizedBox(width: 8), Text(l10n.patternRuled)]),
          onTap: () => _setBackgroundPattern(buttonContext, ref, 'ruled'),
        ),
        PopupMenuItem(
          child: Row(children: [const Icon(Icons.circle_outlined, size: 18), const SizedBox(width: 8), Text(l10n.patternDots)]),
          onTap: () => _setBackgroundPattern(buttonContext, ref, 'dots'),
        ),
        PopupMenuItem(
          child: Row(children: [const Icon(Icons.block, size: 18), const SizedBox(width: 8), Text(l10n.patternNone)]),
          onTap: () => _setBackgroundPattern(buttonContext, ref, 'none'),
        ),
      ],
    );
  }

  List<PopupMenuItem> _backgroundColorItems(WidgetRef ref, AppLocalizations l10n) {
    final colors = [
      (Colors.white, l10n.bgWhite),
      (const Color(0xFFFFF9C4), l10n.bgLightYellow),
      (const Color(0xFFE8F5E9), l10n.bgLightGreen),
      (const Color(0xFFE3F2FD), l10n.bgLightBlue),
      (const Color(0xFFF3E5F5), l10n.bgLightPurple),
      (const Color(0xFFFBE9E7), l10n.bgLightCoral),
      (const Color(0xFF263238), l10n.bgDark),
      (Colors.black, l10n.bgBlack),
    ];
    return colors.map((entry) {
      return PopupMenuItem(
        child: Row(
          children: [
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                color: entry.$1,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Text(entry.$2),
          ],
        ),
        onTap: () {
          _setBackgroundColor(ref, entry.$1);
        },
      );
    }).toList();
  }

  void _setBackgroundColor(WidgetRef ref, Color color) {
    final lectureState = ref.read(lectureProvider);
    if (lectureState.lecture == null || lectureState.currentPage == null) return;
    final pages = [...lectureState.lecture!.pages];
    pages[lectureState.currentPageIndex] =
        lectureState.currentPage!.copyWith(backgroundColor: color);
    ref.read(lectureProvider.notifier).loadLecture(
      lectureState.lecture!.copyWith(pages: pages),
    );
    // Restore page index
    ref.read(lectureProvider.notifier).setCurrentPage(lectureState.currentPageIndex);
  }

  void _setBackgroundPattern(BuildContext context, WidgetRef ref, String pattern) {
    // Store pattern as background image URL marker for the canvas painter
    final lectureState = ref.read(lectureProvider);
    if (lectureState.lecture == null || lectureState.currentPage == null) return;
    final pages = [...lectureState.lecture!.pages];
    pages[lectureState.currentPageIndex] = lectureState.currentPage!.copyWith(
      backgroundImageUrl: pattern == 'none' ? null : 'pattern:$pattern',
    );
    ref.read(lectureProvider.notifier).loadLecture(
      lectureState.lecture!.copyWith(pages: pages),
    );
    ref.read(lectureProvider.notifier).setCurrentPage(lectureState.currentPageIndex);
    // Reload canvas elements to trigger repaint
    ref.read(canvasProvider.notifier).loadElements(
      ref.read(canvasProvider).elements,
    );
  }

  // ──── Sound/Video Dialog ────
  void _showSoundVideoDialog(BuildContext buttonContext, WidgetRef ref, AppLocalizations l10n) {
    Future.microtask(() {
      if (!buttonContext.mounted) return;
      showDialog(
        context: buttonContext,
        builder: (ctx) => _SoundVideoDialog(ref: ref),
      );
    });
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
          child: Text(l10n.get('about')),
          onTap: () => _showAboutDialog(buttonContext, ref),
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
                Icons.check,
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

  void _showAboutDialog(BuildContext context, WidgetRef ref) {
    Future.microtask(() {
      if (!context.mounted) return;
      final lang = ref.read(settingsProvider).language.code;
      final isKo = lang == 'ko';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(isKo ? 'ICanNote 정보' : 'About ICanNote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ICanNote',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${isKo ? "버전" : "Version"} 1.0.0'),
              const SizedBox(height: 16),
              Text(isKo
                ? '인터랙티브 교육 및 협업 학습을 위한 SaaS 화이트보드 & 강의 플랫폼.'
                : 'A SaaS Whiteboard & Lecture Platform for interactive '
                  'teaching and collaborative learning.',
              ),
              const SizedBox(height: 16),
              Text(
                isKo
                  ? '주요 기능:\n'
                    '- 펜, 형광펜으로 자유 그리기\n'
                    '- 도형, 선, 곡선\n'
                    '- 텍스트 주석\n'
                    '- 퀴즈용 스티커 커버\n'
                    '- 실시간 협업\n'
                    '- 녹화 및 재생\n'
                    '- PDF/이미지 내보내기\n'
                    '- 다중 페이지 강의'
                  : 'Features:\n'
                    '- Free drawing with pen, highlighter\n'
                    '- Shapes, lines, curves\n'
                    '- Text annotations\n'
                    '- Sticker covers for quizzes\n'
                    '- Real-time collaboration\n'
                    '- Recording & playback\n'
                    '- PDF/Image export\n'
                    '- Multi-page lectures',
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isKo ? '닫기' : 'Close'),
            ),
          ],
        ),
      );
    });
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

  void _openTextbookFile(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final fileService = FileService();
      final files = await fileService.pickDocumentFiles();
      if (files == null || files.isEmpty || !context.mounted) return;

      final imageExtensions = {'jpg', 'jpeg', 'png'};
      final pdfExtensions = {'pdf'};
      final imageFiles = <PlatformFile>[];
      final pdfFiles = <PlatformFile>[];
      final docFiles = <PlatformFile>[];

      for (final file in files) {
        final ext = file.extension?.toLowerCase() ?? '';
        if (imageExtensions.contains(ext)) {
          imageFiles.add(file);
        } else if (pdfExtensions.contains(ext)) {
          pdfFiles.add(file);
        } else {
          docFiles.add(file);
        }
      }

      final currentElements = ref.read(canvasProvider).elements;
      final newElements = <CanvasElement>[...currentElements];
      double yOffset = 50.0;

      // Find existing bottom position
      for (final el in currentElements) {
        final bottom = el.boundingBox.bottom;
        if (bottom + 50 > yOffset) yOffset = bottom + 50;
      }

      // Process image files
      for (final file in imageFiles) {
        if (file.bytes == null) continue;
        final ext = file.extension?.toLowerCase() ?? 'png';
        final mimeType = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'image/png';
        final base64Data = base64Encode(file.bytes!);
        final dataUrl = 'data:$mimeType;base64,$base64Data';

        final imageElement = ImageCanvasElement(
          imageUrl: dataUrl,
          rect: Rect.fromLTWH(50, yOffset, 800, 600),
        );
        newElements.add(imageElement);
        yOffset += 650;
      }

      // Process PDF files - add each page as separate image pages in the lecture
      for (final file in pdfFiles) {
        if (file.bytes == null) continue;
        // Store PDF raw data as a base64 data URL for now
        // Each PDF is added as an image element showing the first page
        final base64Data = base64Encode(file.bytes!);
        final dataUrl = 'data:application/pdf;base64,$base64Data';
        final imageElement = ImageCanvasElement(
          imageUrl: dataUrl,
          rect: Rect.fromLTWH(50, yOffset, 800, 600),
        );
        newElements.add(imageElement);
        yOffset += 650;
      }

      if (newElements.length > currentElements.length) {
        ref.read(canvasProvider.notifier).loadElements(newElements);
        ref.read(lectureProvider.notifier).updateCurrentPageElements(newElements);
      }

      // Show summary messages
      if (context.mounted) {
        final messages = <String>[];
        if (imageFiles.isNotEmpty) messages.add('${imageFiles.length} image(s) loaded');
        if (pdfFiles.isNotEmpty) messages.add('${pdfFiles.length} PDF(s) loaded');
        if (docFiles.isNotEmpty) {
          messages.add('${docFiles.length} document(s) skipped (${docFiles.map((f) => f.extension?.toUpperCase()).toSet().join(", ")} format not yet supported)');
        }
        if (messages.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(messages.join('. '))),
          );
        }
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
            content: Text(saved ? AppLocalizations.of(ref.read(settingsProvider).language.code).lectureSaved : AppLocalizations.of(ref.read(settingsProvider).language.code).saveCancelled),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _saveWithProtection(BuildContext context, WidgetRef ref) {
    Future.microtask(() {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => _PasswordProtectionDialog(ref: ref),
      );
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
            content: Text(saved ? AppLocalizations.of(ref.read(settingsProvider).language.code).lectureSaved : AppLocalizations.of(ref.read(settingsProvider).language.code).saveCancelled),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _exportAsPdf(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(ref.read(settingsProvider).language.code).noLectureToExport)),
          );
        }
        return;
      }
      ref.read(lectureProvider.notifier).updateCurrentPageElements(
            ref.read(canvasProvider).elements,
          );
      final updatedLecture = ref.read(lectureProvider).lecture!;
      final success = await CanvasExportService.exportAsPdf(
        lecture: updatedLecture,
        currentPageElements: ref.read(canvasProvider).elements,
        currentPageIndex: ref.read(lectureProvider).currentPageIndex,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(ref.read(settingsProvider).language.code).get(success ? 'pdf_exported' : 'pdf_export_cancelled'))),
        );
      }
    });
  }

  void _exportAsImage(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(ref.read(settingsProvider).language.code).noLectureToExport)),
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
        fileName: '${lecture.title}_page${lectureState.currentPageIndex + 1}.png',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(ref.read(settingsProvider).language.code).get(success ? 'image_exported' : 'image_export_cancelled'))),
        );
      }
    });
  }

  void _sendByEmail(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      final title = lecture?.title ?? 'ICanNote Lecture';
      final uri = Uri(
        scheme: 'mailto',
        query: 'subject=${Uri.encodeComponent(title)}&body=${Uri.encodeComponent('Please find the attached lecture file.')}',
      );
      try {
        await launchUrl(uri);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(ref.read(settingsProvider).language.code).get('could_not_open_email'))),
          );
        }
      }
    });
  }

  void _printLecture(BuildContext context, WidgetRef ref) {
    Future.microtask(() async {
      final lecture = ref.read(lectureProvider).lecture;
      if (lecture == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(ref.read(settingsProvider).language.code).get('no_lecture_to_print'))),
          );
        }
        return;
      }
      ref.read(lectureProvider.notifier).updateCurrentPageElements(
            ref.read(canvasProvider).elements,
          );
      final updatedLecture = ref.read(lectureProvider).lecture!;
      await CanvasExportService.printLecture(
        lecture: updatedLecture,
        currentPageElements: ref.read(canvasProvider).elements,
        currentPageIndex: ref.read(lectureProvider).currentPageIndex,
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

// ──────────────────── Sound/Video Dialog ────────────────────

class _SoundVideoDialog extends StatefulWidget {
  final WidgetRef ref;
  const _SoundVideoDialog({required this.ref});

  @override
  State<_SoundVideoDialog> createState() => _SoundVideoDialogState();
}

class _SoundVideoDialogState extends State<_SoundVideoDialog> {
  final _urlController = TextEditingController();
  String _mediaType = 'video'; // 'video' or 'audio'

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(widget.ref.read(settingsProvider).language.code);

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return AlertDialog(
      title: Text(l10n.insertSoundVideo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: [
              ButtonSegment(value: 'video', label: Text(l10n.get('video')), icon: const Icon(Icons.videocam)),
              ButtonSegment(value: 'audio', label: Text(l10n.get('audio')), icon: const Icon(Icons.audiotrack)),
            ],
            selected: {_mediaType},
            onSelectionChanged: (v) => setState(() => _mediaType = v.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: _mediaType == 'video' ? l10n.videoUrl : l10n.audioUrl,
              hintText: 'https://...',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_mediaType == 'video' ? Icons.video_library : Icons.music_note),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pasteUrlHint,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final url = _urlController.text.trim();
            if (url.isEmpty) return;
            final currentElements = widget.ref.read(canvasProvider).elements;
            double yOffset = 50.0;
            for (final el in currentElements) {
              final bottom = el.boundingBox.bottom;
              if (bottom + 50 > yOffset) yOffset = bottom + 50;
            }
            widget.ref.read(canvasProvider.notifier).addTextElement(
              Offset(50, yOffset),
              '[$_mediaType] $url',
              fontSize: 14,
            );
            widget.ref.read(lectureProvider.notifier).updateCurrentPageElements(
              widget.ref.read(canvasProvider).elements,
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.get(_mediaType == 'video' ? 'video_link_added' : 'audio_link_added'))),
            );
          },
          child: Text(l10n.insert),
        ),
      ],
    );
  }
}

// ──────────────────── Password Protection Dialog ────────────────────

class _PasswordProtectionDialog extends StatefulWidget {
  final WidgetRef ref;
  const _PasswordProtectionDialog({required this.ref});

  @override
  State<_PasswordProtectionDialog> createState() => _PasswordProtectionDialogState();
}

class _PasswordProtectionDialogState extends State<_PasswordProtectionDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  AppLocalizations get _l10n => AppLocalizations.of(widget.ref.read(settingsProvider).language.code);

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return AlertDialog(
      title: Text(l10n.get('save_with_protection_title')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.get('set_password_hint')),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.get('password'),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.get('confirm_password'),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (_passwordController.text != _confirmController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.get('passwords_not_match'))),
              );
              return;
            }
            if (_passwordController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.get('password_empty'))),
              );
              return;
            }
            final lecture = widget.ref.read(lectureProvider).lecture;
            if (lecture == null) return;
            widget.ref.read(lectureProvider.notifier).updateCurrentPageElements(
              widget.ref.read(canvasProvider).elements,
            );
            final updatedLecture = widget.ref.read(lectureProvider).lecture!;
            final fileService = FileService();
            await fileService.saveLectureAs(updatedLecture);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.get('saved_with_protection'))),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// ──────────────────── Menu Bar Item ────────────────────

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
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);

    if (authState.isAuthenticated) {
      return Builder(
        builder: (buttonContext) => InkWell(
          onTap: () => _showUserMenu(buttonContext, ref, authState, l10n),
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
      label: l10n.login,
      isHighlighted: true,
      onTapWithContext: (_) => context.go('/login'),
    );
  }

  void _showUserMenu(
      BuildContext buttonContext, WidgetRef ref, AuthState authState, AppLocalizations l10n) {
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
          child: Text(l10n.dashboard),
        ),
        PopupMenuItem<String>(
          onTap: () {
            ref.read(authProvider.notifier).signOut();
          },
          child: Text(l10n.signOut),
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

  AppLocalizations get _l10n => AppLocalizations.of(widget.ref.read(settingsProvider).language.code);

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return AlertDialog(
      title: Text(l10n.newLectureSettings),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l10n.pageWidth),
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
              Text(l10n.pageHeight),
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
          Text(l10n.orientation),
          const SizedBox(height: AppDimensions.spacingMD),
          Row(
            children: [
              ChoiceChip(
                label: Text(l10n.landscape),
                selected: _isLandscape,
                onSelected: (_) {
                  if (!_isLandscape) _toggleOrientation();
                },
              ),
              const SizedBox(width: AppDimensions.spacingMD),
              ChoiceChip(
                label: Text(l10n.portrait),
                selected: !_isLandscape,
                onSelected: (_) {
                  if (_isLandscape) _toggleOrientation();
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingLG),
          Text(
            l10n.languageCode == 'ko'
              ? '페이지 크기는 A4 기본. 인쇄 시 스케일 자동 조정.'
              : 'Page size defaults to A4. When printing, the scale is adjusted to fit.',
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
          child: Text(l10n.apply),
        ),
        TextButton(
          onPressed: () {
            widget.ref.read(lectureProvider.notifier).createNewLecture();
            Navigator.pop(context);
          },
          child: Text(l10n.useDefaults),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
