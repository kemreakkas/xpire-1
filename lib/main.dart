import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'models/goal.dart';
import 'models/goal_completion.dart';
import 'models/user_profile.dart';
import 'state/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive
    ..registerAdapter(UserProfileAdapter())
    ..registerAdapter(GoalAdapter())
    ..registerAdapter(GoalCompletionAdapter());

  final profileBox = await Hive.openBox<UserProfile>('profile');
  final goalsBox = await Hive.openBox<Goal>('goals');
  final completionsBox = await Hive.openBox<GoalCompletion>('completions');

  runApp(
    ProviderScope(
      overrides: [
        profileBoxProvider.overrideWithValue(profileBox),
        goalsBoxProvider.overrideWithValue(goalsBox),
        completionsBoxProvider.overrideWithValue(completionsBox),
      ],
      child: const XpireApp(),
    ),
  );
}
