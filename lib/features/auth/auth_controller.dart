import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

// For web OAuth or magic link: use redirectTo: Uri.base.origin (or window.location.origin).
// Set Site URL and Redirect URLs in Supabase Dashboard to your deployed origin.
import '../../core/log/app_log.dart';

/// Current auth session. Null if not configured or not logged in.
/// Emits current session first so we don't stay on loading; then listens to changes.
final authSessionProvider = StreamProvider<Session?>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(null);
  }
  try {
    final client = Supabase.instance.client;
    final current = client.auth.currentSession;
    final stream = client.auth.onAuthStateChange.map((event) => event.session);
    return Stream.value(current).asyncExpand((_) => stream);
  } catch (_) {
    return Stream.value(null);
  }
});

/// Current user id when logged in. Null otherwise.
final authUserIdProvider = Provider<String?>((ref) {
  final session = ref.watch(authSessionProvider).asData?.value;
  return session?.user.id;
});

/// True when Supabase is configured and user is logged in.
final isAuthenticatedProvider = Provider<bool>((ref) {
  if (!SupabaseConfig.isConfigured) return false;
  return ref.watch(authSessionProvider).asData?.value != null;
});

/// Auth actions: register, login, logout. No UI; use from widgets via ref.read.
/// Register creates auth user then inserts row into public.users.
class AuthController {
  AuthController(Ref _);

  static SupabaseClient get _client => Supabase.instance.client;

  /// Stream of auth state changes (session or null).
  Stream<Session?> authStateChanges() {
    if (!SupabaseConfig.isConfigured) return Stream.value(null);
    return _client.auth.onAuthStateChange.map((e) => e.session);
  }

  Future<void> register(String email, String password) async {
    final res = await _client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) {
      throw Exception('Sign up did not return a user');
    }
    await _client.from('public.users').insert({
      'id': user.id,
      'email': user.email ?? email,
      'level': 1,
      'xp': 0,
      'total_xp': 0,
      'streak': 0,
    });
    AppLog.info('Registered and created user row', {'email': email});
  }

  Future<void> login(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    AppLog.info('Signed in', {'email': email});
  }

  Future<void> logout() async {
    await _client.auth.signOut();
    AppLog.info('Signed out');
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});
