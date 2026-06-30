import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  AuthService._();

  static SupabaseClient get _client => SupabaseService.client;

  static User? get currentUser => _client.auth.currentUser;

  static Session? get currentSession => _client.auth.currentSession;

  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw const AuthException('Email dan kata laluan diperlukan.');
    }

    return _client.auth.signInWithPassword(
      email: normalizedEmail,
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      throw const AuthException('Email dan kata laluan diperlukan.');
    }

    if (!normalizedEmail.contains('@')) {
      throw const AuthException('Sila masukkan email yang sah.');
    }

    if (password.length < 6) {
      throw const AuthException('Kata laluan mesti sekurang-kurangnya 6 aksara.');
    }

    return _client.auth.signUp(
      email: normalizedEmail,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static String getReadableError(Object error) {
    if (error is AuthException) {
      final message = error.message;

      if (message.toLowerCase().contains('invalid login credentials')) {
        return 'Email atau kata laluan tidak betul.';
      }

      if (message.toLowerCase().contains('email not confirmed')) {
        return 'Email belum disahkan. Sila semak inbox email anda.';
      }

      if (message.toLowerCase().contains('user already registered')) {
        return 'Email ini sudah pernah didaftarkan. Sila log masuk.';
      }

      return message;
    }

    if (error is PostgrestException) {
      return error.message;
    }

    return 'Ralat tidak dijangka. Sila cuba lagi.';
  }
}