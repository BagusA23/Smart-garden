// lib/cubit/auth/auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_farming/services/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  // Check initial auth state
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    final user = _authService.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      // State akan otomatis update via authStateChanges stream
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // Register
  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      emit(AuthLoading());
      await _authService.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );
      // State akan otomatis update via authStateChanges stream
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      emit(AuthLoading());
      await _authService.signOut();
      // State akan otomatis update via authStateChanges stream
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      emit(AuthLoading());
      await _authService.sendPasswordResetEmail(email);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // Get current user
  User? get currentUser => _authService.currentUser;

  // Check if email is verified
  bool get isEmailVerified => _authService.isEmailVerified;
}