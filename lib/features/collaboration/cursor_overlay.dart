import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../../models/room_model.dart';
import '../../core/constants/app_dimensions.dart';

/// Renders remote users' cursors on the canvas.
class CursorOverlay extends ConsumerWidget {
  const CursorOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);

    if (!syncState.isConnected || syncState.remoteCursors.isEmpty) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    return Stack(
      children: syncState.remoteCursors
          .where((c) => now - c.timestamp < 3000) // Hide after 3s
          .map((cursor) => _RemoteCursor(cursor: cursor))
          .toList(),
    );
  }
}

class _RemoteCursor extends StatelessWidget {
  final CursorEvent cursor;

  const _RemoteCursor({required this.cursor});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: cursor.x - 4,
      top: cursor.y - 4,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cursor dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cursor.color,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: AppDimensions.shadowBlurSM,
                  ),
                ],
              ),
            ),
            // Name label
            Container(
              margin: const EdgeInsets.only(
                  left: AppDimensions.spacingSM,
                  top: AppDimensions.spacingXS),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSM,
                vertical: AppDimensions.spacingXS,
              ),
              decoration: BoxDecoration(
                color: cursor.color,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusSM),
              ),
              child: Text(
                cursor.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppDimensions.fontSizeXS,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
