import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';

/// For OAuth or magic-link flows on web, use redirectTo: Uri.base.origin so
/// production (e.g. Vercel) redirects back to the app. Also set Site URL and
/// Redirect URLs in Supabase Dashboard to your production domain.

/// Current auth session. Null if not configured or not logged in.
final authSessionProvider = StreamProvider<Session?>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return Stream.value(null);
  }
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return event.session;
  });
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

/// Auth actions: login, register, logout. No UI; use from widgets via ref.read.
class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  static SupabaseClient get _client => Supabase.instance.client;

  Future<void> signInWithPassword({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
    AppLog.info('Signed in', email);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
    AppLog.info('Signed up', email);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    AppLog.info('Signed out');
  }
}

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});
