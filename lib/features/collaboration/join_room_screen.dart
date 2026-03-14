import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/sync_provider.dart';

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
        _error = 'Room not found. Check the invite code.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isJoining
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Joining room...'),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error ?? 'Failed to join room.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
      ),
    );
  }
}
