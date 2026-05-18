import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/l10n/app_localizations.dart';

/// Shows a list of participants in the current collaboration room.
class ParticipantPanel extends ConsumerWidget {
  const ParticipantPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);

    if (!syncState.isConnected) return const SizedBox.shrink();

    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppDimensions.spacingMD),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: AppDimensions.shadowBlurMD,
            offset: const Offset(0, AppDimensions.shadowOffsetY),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people, size: AppDimensions.iconSizeMD),
              const SizedBox(width: AppDimensions.spacingMD),
              Text(
                '${l10n.get('participants')} (${syncState.participants.length})',
                style: const TextStyle(
                  fontSize: AppDimensions.fontSizeMD,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(),
          ...syncState.participants.map((p) => Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingXS),
                child: Row(
                  children: [
                    // Online indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: p.isOnline
                            ? AppColors.secondary
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingMD),
                    // Name + role
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.displayName,
                            style: const TextStyle(
                                fontSize: AppDimensions.fontSizeMD),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            p.role,
                            style: TextStyle(
                              fontSize: AppDimensions.fontSizeXS,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Permission toggle (host only, not for self)
                    if (syncState.isHost &&
                        p.role != 'instructor')
                      IconButton(
                        icon: Icon(
                          p.canDraw ? Icons.edit : Icons.edit_off,
                          size: AppDimensions.iconSizeSM,
                          color: p.canDraw
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                        tooltip: p.canDraw
                            ? l10n.get('disable_drawing')
                            : l10n.get('enable_drawing'),
                        onPressed: () => ref
                            .read(syncProvider.notifier)
                            .togglePermission(p.userId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                      ),
                  ],
                ),
              )),
          if (syncState.inviteCode != null) ...[
            const Divider(),
            Text(
              '${l10n.get('code_prefix')} ${syncState.inviteCode}',
              style: TextStyle(
                fontSize: AppDimensions.fontSizeXS,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
