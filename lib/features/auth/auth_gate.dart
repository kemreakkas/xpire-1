import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/config/app_env.dart';
import '../../core/config/supabase_config.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/ui/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';
import 'auth_controller.dart';
import 'login_page.dart';
import 'register_page.dart';
import '../onboarding/onboarding_page.dart';

/// Root gate: shows LoginPage when no session, else the main app (Dashboard shell).
/// Listens to auth state changes. No business logic in this widget.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final locale = ref.watch(localeProvider);

    if (!SupabaseConfig.isConfigured) {
      return MaterialApp(
        title: AppEnv.appName,
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.supabaseNotConfigured,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return authSession.when(
      loading: () => MaterialApp(
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, stack) => MaterialApp(
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Scaffold(
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.authError, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      SelectableText(err.toString()),
                      const SizedBox(height: 16),
                      SelectableText(stack.toString()),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      data: (session) {
        if (session == null) {
          return MaterialApp(
            title: AppEnv.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const LoginPage(),
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
            },
          );
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
      loading: () => MaterialApp(
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => MaterialApp(
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(child: Text(err.toString())),
        ),
      ),
      data: (profile) {
        if (!profile.onboardingCompleted) {
          return MaterialApp(
            title: AppEnv.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dark,
            darkTheme: AppTheme.dark,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const OnboardingPage(),
          );
        }
        return const XpireApp();
      },
    );
  }
}
