import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/l10n/app_localizations.dart';

/// Dialog to create a new collaboration room.
class CreateRoomDialog extends ConsumerStatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  ConsumerState<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends ConsumerState<CreateRoomDialog> {
  final _titleController = TextEditingController();
  bool _isCreating = false;
  String? _inviteCode;

  @override
  void initState() {
    super.initState();
    final l10n = AppLocalizations.of(
        ref.read(settingsProvider).language.code);
    _titleController.text = l10n.get('my_lecture_room');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);

    final code = await ref.read(syncProvider.notifier).createRoom(
          _titleController.text.trim(),
        );

    if (mounted) {
      if (code != null) {
        setState(() {
          _inviteCode = code;
          _isCreating = false;
        });
      } else {
        setState(() => _isCreating = false);
        final l10n = AppLocalizations.of(
            ref.read(settingsProvider).language.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.get('failed_to_create_room'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);
    if (_inviteCode != null) {
      return AlertDialog(
        title: Text(l10n.get('room_created')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.get('share_invite_code')),
            const SizedBox(height: AppDimensions.spacingXL),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXXL,
                vertical: AppDimensions.spacingLG,
              ),
              decoration: BoxDecoration(
                color: AppColors.canvasBackground,
                borderRadius:
                    BorderRadius.circular(AppDimensions.borderRadiusMD),
                border: Border.all(color: AppColors.primary, width: AppDimensions.borderWidthThick),
              ),
              child: SelectableText(
                _inviteCode!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXL),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _inviteCode!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.get('invite_code_copied'))),
                );
              },
              icon: const Icon(Icons.copy),
              label: Text(l10n.get('copy_code')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.get('done')),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(l10n.get('create_room')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: l10n.get('room_title'),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.get('cancel')),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createRoom,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.get('create')),
        ),
      ],
    );
  }
}

/// Dialog to join an existing room by invite code.
class JoinRoomDialog extends ConsumerStatefulWidget {
  const JoinRoomDialog({super.key});

  @override
  ConsumerState<JoinRoomDialog> createState() => _JoinRoomDialogState();
}

class _JoinRoomDialogState extends ConsumerState<JoinRoomDialog> {
  final _codeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isJoining = true);
    final success = await ref.read(syncProvider.notifier).joinRoom(code);

    if (mounted) {
      setState(() => _isJoining = false);
      if (success) {
        Navigator.pop(context, true);
      } else {
        final l10n = AppLocalizations.of(
            ref.read(settingsProvider).language.code);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.get('room_not_found_code'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);
    return AlertDialog(
      title: Text(l10n.get('join_room')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.get('enter_6_char_code')),
          const SizedBox(height: AppDimensions.spacingXL),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              counterText: '',
            ),
            onSubmitted: (_) => _joinRoom(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.get('cancel')),
        ),
        ElevatedButton(
          onPressed: _isJoining ? null : _joinRoom,
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.get('join')),
        ),
      ],
    );
  }
}
