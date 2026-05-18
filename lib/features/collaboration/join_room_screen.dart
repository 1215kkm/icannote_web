import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/sync_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/l10n/app_localizations.dart';

/// Screen that auto-joins a room by invite code from URL route.
class JoinRoomScreen extends ConsumerStatefulWidget {
  final String inviteCode;

  const JoinRoomScreen({super.key, required this.inviteCode});

  @override
  ConsumerState<JoinRoomScreen> createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends ConsumerState<JoinRoomScreen> {
  bool _isJoining = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _joinRoom();
  }

  Future<void> _joinRoom() async {
    final success =
        await ref.read(syncProvider.notifier).joinRoom(widget.inviteCode);

    if (!mounted) return;

    if (success) {
      context.go('/editor');
    } else {
      setState(() {
        _isJoining = false;
        _error = 'room_not_found_invite_code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(settings.language.code);
    return Scaffold(
      body: Center(
        child: _isJoining
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.get('joining_room')),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(l10n.get(_error ?? 'failed_to_join_room')),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.get('go_home')),
                  ),
                ],
              ),
      ),
    );
  }
}
