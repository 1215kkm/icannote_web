import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/firebase_status.dart';
import '../models/user_model.dart';

const _cloudNotConfiguredMsg =
    'Cloud login is not configured on this build. '
    'The local whiteboard works fully offline.';

enum AuthStatus { unauthenticated, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _listenAuthChanges();
  }

  void _listenAuthChanges() {
    if (!isFirebaseReady) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: UserModel(
              uid: user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? '',
              photoUrl: user.photoURL,
              createdAt: user.metadata.creationTime ?? DateTime.now(),
            ),
          );
        } else {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      });
    } catch (e) {
      debugPrint('Firebase Auth not available: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (!isFirebaseReady) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: _cloudNotConfiguredMsg,
      );
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _mapAuthError(e.code),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    if (!isFirebaseReady) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: _cloudNotConfiguredMsg,
      );
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(displayName);
    } on FirebaseAuthException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: _mapAuthError(e.code),
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(errorMessage: _mapAuthError(e.code));
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication error: $code';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
