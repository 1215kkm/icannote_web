import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/canvas_provider.dart';
import '../../providers/lecture_provider.dart';
import '../../providers/sync_provider.dart';
import '../../services/file_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_colors.dart';
import '../toolbar/top_menu_bar.dart';
import '../toolbar/right_toolbar.dart';
import '../toolbar/bottom_toolbar.dart';
import '../pages_panel/pages_panel.dart';
import '../canvas/canvas_screen.dart';
import '../collaboration/participant_panel.dart';
import '../recording/recording_overlay.dart';
import '../library/library_panel.dart';
import '../../widgets/resizable_panel.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  final FileService _fileService = FileService();
  bool _showParticipants = false;

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
    final syncState = ref.watch(syncProvider);

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
              // Collaboration status bar (when connected)
              if (syncState.isConnected)
                _CollaborationBar(
                  participantCount: syncState.participants.length,
                  inviteCode: syncState.inviteCode ?? '',
                  isHost: syncState.isHost,
                  onToggleParticipants: () {
                    setState(() {
                      _showParticipants = !_showParticipants;
                    });
                  },
                  onLeave: () =>
                      ref.read(syncProvider.notifier).leaveRoom(),
                ),
              // Main content area
              Expanded(
                child: Stack(
                  children: [
                    Row(
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
                    // Participant panel overlay
                    if (_showParticipants && syncState.isConnected)
                      Positioned(
                        top: AppDimensions.spacingMD,
                        right: AppDimensions.rightToolbarWidth +
                            AppDimensions.spacingMD,
                        child: const ParticipantPanel(),
                      ),
                    // Library panel overlay
                    const LibraryPanel(),
                    // Recording overlay
                    const RecordingOverlay(),
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

class _CollaborationBar extends StatelessWidget {
  final int participantCount;
  final String inviteCode;
  final bool isHost;
  final VoidCallback onToggleParticipants;
  final VoidCallback onLeave;

  const _CollaborationBar({
    required this.participantCount,
    required this.inviteCode,
    required this.isHost,
    required this.onToggleParticipants,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: AppColors.primary.withValues(alpha: 0.15),
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLG),
      child: Row(
        children: [
          const Icon(Icons.people, size: 14, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spacingSM),
          Text(
            'Live Session  |  $participantCount participants  |  Code: $inviteCode',
            style: const TextStyle(
              fontSize: AppDimensions.fontSizeSM,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onToggleParticipants,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD),
              child: Text(
                'Participants',
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeSM,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onLeave,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMD),
              child: Text(
                isHost ? 'Close Room' : 'Leave Room',
                style: TextStyle(
                  fontSize: AppDimensions.fontSizeSM,
                  color: AppColors.warningText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
