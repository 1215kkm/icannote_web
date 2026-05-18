import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/firebase_status.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only when a real project is configured.
  // With the placeholder template we skip init entirely so the JS SDK
  // never throws/spams the console — the app runs fully offline and the
  // local whiteboard works without any cloud dependency.
  if (DefaultFirebaseOptions.isPlaceholder) {
    isFirebaseReady = false;
    debugPrint(
      'Firebase not configured (placeholder). Running in offline mode: '
      'local whiteboard only, cloud features disabled.',
    );
  } else {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isFirebaseReady = true;
    } catch (e) {
      isFirebaseReady = false;
      debugPrint('Firebase initialization failed: $e');
      debugPrint('Running without Firebase (cloud features disabled).');
    }
  }

  runApp(
    const ProviderScope(
      child: ICanNoteApp(),
    ),
  );
}
