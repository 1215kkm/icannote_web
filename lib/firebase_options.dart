import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Placeholder Firebase configuration.
/// TODO: Replace with actual Firebase project configuration.
/// Run `flutterfire configure` to generate real options, or
/// manually set values from Firebase Console → Project Settings.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        return web;
    }
  }

  // TODO: Replace these placeholder values with your Firebase project config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'icannote-placeholder',
    authDomain: 'icannote-placeholder.firebaseapp.com',
    storageBucket: 'icannote-placeholder.firebasestorage.app',
    databaseURL: 'https://icannote-placeholder-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'icannote-placeholder',
    storageBucket: 'icannote-placeholder.firebasestorage.app',
    databaseURL: 'https://icannote-placeholder-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'icannote-placeholder',
    storageBucket: 'icannote-placeholder.firebasestorage.app',
    databaseURL: 'https://icannote-placeholder-default-rtdb.firebaseio.com',
    iosBundleId: 'com.icannote.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:000000000000:ios:000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'icannote-placeholder',
    storageBucket: 'icannote-placeholder.firebasestorage.app',
    databaseURL: 'https://icannote-placeholder-default-rtdb.firebaseio.com',
    iosBundleId: 'com.icannote.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: '1:000000000000:web:000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'icannote-placeholder',
    storageBucket: 'icannote-placeholder.firebasestorage.app',
    databaseURL: 'https://icannote-placeholder-default-rtdb.firebaseio.com',
  );
}
