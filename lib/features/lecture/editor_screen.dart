import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../core/constants/app_constants.dart';
import '../toolbar/top_menu_bar.dart';
import '../toolbar/right_toolbar.dart';
import '../toolbar/bottom_toolbar.dart';
import '../pages_panel/pages_panel.dart';
import '../canvas/canvas_screen.dart';
import '../../widgets/resizable_panel.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () =>
            ref.read(canvasProvider.notifier).undo(),
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () =>
            ref.read(canvasProvider.notifier).redo(),
        const SingleActivator(LogicalKeyboardKey.keyZ,
            control: true, shift: true): () =>
            ref.read(canvasProvider.notifier).redo(),
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
