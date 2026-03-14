import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/recording_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Floating recording/playback controls overlay on the canvas.
class RecordingOverlay extends ConsumerWidget {
  const RecordingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recState = ref.watch(recordingProvider);

    if (recState.isIdle && !recState.hasRecording) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: AppDimensions.spacingXL,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXL,
            vertical: AppDimensions.spacingMD,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: AppDimensions.shadowBlurMD,
                offset: const Offset(0, AppDimensions.shadowOffsetY),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Recording indicator
              if (recState.isRecording) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMD),
                Text(
                  'REC ${recState.currentTimeDisplay}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppDimensions.fontSizeMD,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXL),
                _ControlButton(
                  icon: Icons.stop,
                  color: Colors.red,
                  tooltip: 'Stop Recording',
                  onTap: () =>
                      ref.read(recordingProvider.notifier).stopRecording(),
                ),
              ],

              // Playback controls
              if (recState.isPlaying ||
                  recState.isPaused ||
                  (recState.isIdle && recState.hasRecording)) ...[
                // Time display
                Text(
                  '${recState.currentTimeDisplay} / ${recState.totalTimeDisplay}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppDimensions.fontSizeSM,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingLG),

                // Play/Pause
                _ControlButton(
                  icon: recState.isPlaying ? Icons.pause : Icons.play_arrow,
                  tooltip: recState.isPlaying ? 'Pause' : 'Play',
                  onTap: () {
                    if (recState.isPlaying) {
                      ref.read(recordingProvider.notifier).pause();
                    } else {
                      ref.read(recordingProvider.notifier).play();
                    }
                  },
                ),

                // Stop
                _ControlButton(
                  icon: Icons.stop,
                  tooltip: 'Stop',
                  onTap: () => ref.read(recordingProvider.notifier).stop(),
                ),

                const SizedBox(width: AppDimensions.spacingMD),

                // Progress bar
                SizedBox(
                  width: 200,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.grey.shade700,
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primary.withValues(alpha: 0.3),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
                    ),
                    child: Slider(
                      value: recState.progress.clamp(0.0, 1.0),
                      onChanged: (v) =>
                          ref.read(recordingProvider.notifier).seekTo(v),
                    ),
                  ),
                ),

                const SizedBox(width: AppDimensions.spacingMD),

                // Speed control
                _SpeedButton(currentSpeed: recState.playbackSpeed),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: const EdgeInsets.all(AppDimensions.spacingSM),
    );
  }
}

class _SpeedButton extends ConsumerWidget {
  final double currentSpeed;

  const _SpeedButton({required this.currentSpeed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<double>(
      tooltip: 'Playback Speed',
      onSelected: (speed) =>
          ref.read(recordingProvider.notifier).setPlaybackSpeed(speed),
      itemBuilder: (_) => [
        _speedItem(0.5, currentSpeed),
        _speedItem(1.0, currentSpeed),
        _speedItem(1.5, currentSpeed),
        _speedItem(2.0, currentSpeed),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMD,
          vertical: AppDimensions.spacingSM,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSM),
        ),
        child: Text(
          '${currentSpeed}x',
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppDimensions.fontSizeSM,
          ),
        ),
      ),
    );
  }

  PopupMenuItem<double> _speedItem(double speed, double current) {
    return PopupMenuItem(
      value: speed,
      child: Text(
        '${speed}x',
        style: TextStyle(
          fontWeight: speed == current ? FontWeight.bold : FontWeight.normal,
          color: speed == current ? AppColors.primary : null,
        ),
      ),
    );
  }
}

/// Start recording button — shown in bottom toolbar.
class RecordButton extends ConsumerWidget {
  const RecordButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recState = ref.watch(recordingProvider);

    return IconButton(
      icon: Icon(
        recState.isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
        color: recState.isRecording ? Colors.red : AppColors.toolbarIconDefault,
        size: AppDimensions.iconSizeMD,
      ),
      tooltip: recState.isRecording ? 'Stop Recording' : 'Record',
      onPressed: () {
        if (recState.isRecording) {
          ref.read(recordingProvider.notifier).stopRecording();
        } else {
          ref.read(recordingProvider.notifier).startRecording('');
        }
      },
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: AppDimensions.bottomButtonMinSize,
        minHeight: AppDimensions.bottomButtonMinSize,
      ),
    );
  }
}
