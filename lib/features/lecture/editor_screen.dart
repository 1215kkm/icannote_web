import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../services/file_service.dart';
import '../../core/constants/app_constants.dart';
import '../toolbar/top_menu_bar.dart';
import '../toolbar/right_toolbar.dart';
import '../toolbar/bottom_toolbar.dart';
import '../pages_panel/pages_panel.dart';
import '../canvas/canvas_screen.dart';
import '../../widgets/resizable_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final FileService _fileService = FileService();

  void _saveCurrentLecture() async {
    final lecture = ref.read(lectureProvider).lecture;
    if (lecture == null) return;
    // Sync current page elements to lecture
    ref.read(lectureProvider.notifier).updateCurrentPageElements(
          ref.read(canvasProvider).elements,
        );
    final updatedLecture = ref.read(lectureProvider).lecture!;
    final saved = await _fileService.saveLecture(updatedLecture);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? 'Lecture saved.' : 'Save cancelled.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () =>
            ref.read(canvasProvider.notifier).undo(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () =>
            ref.read(canvasProvider.notifier).redo(),
        const SingleActivator(LogicalKeyboardKey.keyZ,
            control: true, shift: true): () =>
            ref.read(canvasProvider.notifier).redo(),
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () =>
            _saveCurrentLecture(),
        const SingleActivator(LogicalKeyboardKey.keyC, control: true): () =>
            ref.read(canvasProvider.notifier).copySelected(),
        const SingleActivator(LogicalKeyboardKey.keyV, control: true): () =>
            ref.read(canvasProvider.notifier).paste(),
        const SingleActivator(LogicalKeyboardKey.delete): () =>
            ref.read(canvasProvider.notifier).deleteSelected(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: Column(
            children: [
              // Top menu bar
              const TopMenuBar(),
              // Main content area
              Expanded(
                child: Row(
                  children: [
                    // Left panel - page thumbnails (resizable)
                    ResizablePanel(
                      initialWidth: AppConstants.defaultLeftPanelWidth,
                      isLeft: true,
                      child: PagesPanel(
                        width: AppConstants.defaultLeftPanelWidth,
                      ),
                    ),
                    // Canvas area (center)
                    const Expanded(
                      child: CanvasScreen(),
                    ),
                    // Right toolbar
                    const RightToolbar(),
                  ],
                ),
              ),
              // Bottom toolbar
              const BottomToolbar(),
            ],
          ),
        ),
      ),
    );
  }
}
