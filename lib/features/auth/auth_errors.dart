import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';

/// User-friendly messages for Supabase auth errors. Pass [l10n] for localized messages.
String authErrorMessage(Object error, [AppLocalizations? l10n]) {
  final L = l10n;
  if (error is AuthException) {
    final msg = error.message;
    final code = error.statusCode;
    if (msg.contains('Invalid login credentials') ||
        code == 'invalid_credentials') {
      return L?.invalidEmailPassword ?? 'Invalid email or password.';
    }
    if (msg.contains('Email not confirmed')) {
      return L?.confirmEmailFirst ?? 'Please confirm your email before signing in.';
    }
    if (msg.contains('already registered') || code == 'signup_disabled') {
      return L?.emailAlreadyRegistered ?? 'This email is already registered.';
    }
    if (msg.contains('Password')) {
      return L?.passwordMinLength ?? 'Password should be at least 6 characters.';
    }
    if (code == 'weak_password') {
      return L?.passwordTooWeak ?? 'Password is too weak. Use at least 6 characters.';
    }
    if (msg.contains('rate limit') || msg.contains('rate_limit')) {
      return L?.tooManyAttempts ?? 'Too many attempts. Please try again in a few minutes.';
    }
    return msg.isNotEmpty ? msg : (L?.tryAgain ?? 'Something went wrong. Try again.');
  }
  return error.toString().replaceFirst('Exception: ', '');
}
