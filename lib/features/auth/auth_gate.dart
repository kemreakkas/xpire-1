import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/config/supabase_config.dart';
import '../../core/locale/locale_controller.dart';
import '../../state/providers.dart';
import 'auth_controller.dart';

/// Root gate: shows LoginPage when no session, else the main app (Dashboard shell).
/// Listens to auth state changes. No business logic in this widget.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final locale = ref.watch(localeProvider);

    if (!SupabaseConfig.isConfigured) {
      // Previously returned a standalone MaterialApp here which caused multiple
      // Navigator/Router instances. Return the single root app instead.
      return const XpireApp();
    }

    return authSession.when(
      loading: () => const XpireApp(),
      error: (err, stack) => const XpireApp(),
      data: (session) {
        if (session == null) {
          // Use same router app so LoginPage/RegisterPage are inside GoRouter tree.
          return const XpireApp();
        }
        return _AuthenticatedGate(locale: locale);
      },
    );
  }
}

/// When authenticated: load profile; if onboarding not completed show OnboardingPage, else show app.
class _AuthenticatedGate extends ConsumerWidget {
  const _AuthenticatedGate({required this.locale});

  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAv = ref.watch(profileControllerProvider);

    return profileAv.when(
      loading: () => const XpireApp(),
      error: (err, _) => const XpireApp(),
      data: (profile) {
        if (!profile.onboardingCompleted) {
          // Show onboarding via the single app/router rather than creating another
          // MaterialApp here.
          return const XpireApp();
        }
        return const XpireApp();
      },
    );
  }
}
