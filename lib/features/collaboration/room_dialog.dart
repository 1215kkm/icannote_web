import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sync_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

/// Dialog to create a new collaboration room.
class CreateRoomDialog extends ConsumerStatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  ConsumerState<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends ConsumerState<CreateRoomDialog> {
  final _titleController = TextEditingController(text: 'My Lecture Room');
  bool _isCreating = false;
  String? _inviteCode;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create room. Check Firebase config.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inviteCode != null) {
      return AlertDialog(
        title: const Text('Room Created'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this invite code with participants:'),
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
                  const SnackBar(content: Text('Invite code copied!')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy Code'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Done'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Create Room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Room Title',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createRoom,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room not found. Check the code.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Room'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Enter the 6-character invite code:'),
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isJoining ? null : _joinRoom,
          child: _isJoining
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Join'),
        ),
      ],
    );
  }
}
