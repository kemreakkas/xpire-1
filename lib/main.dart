import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'features/auth/auth_gate.dart';
import 'core/log/app_log.dart';
import 'data/models/active_challenge.dart';
import 'data/models/goal.dart';
import 'data/models/goal_completion.dart';
import 'data/models/user_profile.dart';
import 'state/providers.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      // Same zone as runApp to avoid "Zone mismatch" (bindings vs runApp).
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        AppLog.error('FlutterError', details.exception, details.stack);
      };

      if (kIsWeb) {
        usePathUrlStrategy();
      }

      // Do NOT hardcode keys. Set via --dart-define or Vercel env.
      if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
        await Supabase.initialize(
          url: supabaseUrl,
          anonKey: supabaseAnonKey,
        );
      }

      await Hive.initFlutter();

      if (!Hive.isAdapterRegistered(UserProfileAdapter().typeId)) {
        Hive.registerAdapter(UserProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(GoalAdapter().typeId)) {
        Hive.registerAdapter(GoalAdapter());
      }
      if (!Hive.isAdapterRegistered(GoalCompletionAdapter().typeId)) {
        Hive.registerAdapter(GoalCompletionAdapter());
      }
      if (!Hive.isAdapterRegistered(ActiveChallengeAdapter().typeId)) {
        Hive.registerAdapter(ActiveChallengeAdapter());
      }

      final profileBox = await Hive.openBox<UserProfile>('profile');
      final goalsBox = await Hive.openBox<Goal>('goals');
      final completionsBox = await Hive.openBox<GoalCompletion>('completions');
      final activeChallengeBox =
          await Hive.openBox<ActiveChallenge>('active_challenge');

      runApp(
        ProviderScope(
          overrides: [
            profileBoxProvider.overrideWithValue(profileBox),
            goalsBoxProvider.overrideWithValue(goalsBox),
            completionsBoxProvider.overrideWithValue(completionsBox),
            activeChallengeBoxProvider.overrideWithValue(activeChallengeBox),
          ],
          child: const AuthGate(),
        ),
      );
    },
    (error, stack) {
      AppLog.error('Uncaught', error, stack);
    },
  );
}
