import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/engine/motivation_engine.dart';
import '../../data/models/goal.dart';
import '../../core/engine/smart_generator.dart';
import '../../core/engine/today_smart_plan.dart';
import '../../core/engine/user_profile_analyzer.dart';
import '../../core/utils/date_key.dart';
import '../../core/utils/date_only.dart';
import '../../data/models/goal_completion.dart';
import '../providers.dart';

/// Categories of goals completed in the last 3 days (for variety).
Set<GoalCategory> _last3DaysCategories(
  List<GoalCompletion> completions,
  List<Goal> goals,
) {
  final today = dateOnly(DateTime.now());
  final threeDaysAgo = today.subtract(const Duration(days: 3));
  final goalIdToCategory = <String, GoalCategory>{};
  for (final g in goals) {
    goalIdToCategory[g.id] = g.category;
  }
  final categories = <GoalCategory>{};
  for (final c in completions) {
    final d = dateOnly(c.date);
    if (!d.isBefore(threeDaysAgo) && !d.isAfter(today)) {
      final cat = goalIdToCategory[c.goalId];
      if (cat != null) categories.add(cat);
    }
  }
  return categories;
}

/// Provides "Today's AI Plan" (3 smart goals + motivation). Cached per day;
/// does not regenerate multiple times per day when completions change.
class TodaySmartPlanNotifier extends AsyncNotifier<TodaySmartPlan> {
  String? _cachedDateKey;
  TodaySmartPlan? _cachedPlan;

  @override
  Future<TodaySmartPlan> build() async {
    await ref.watch(profileControllerProvider.future);
    await ref.watch(goalsControllerProvider.future);
    await ref.watch(completionsControllerProvider.future);

    final profile = ref.read(profileControllerProvider).requireValue;
    final goals = ref.read(goalsControllerProvider).requireValue;
    final completions = ref.read(completionsControllerProvider).requireValue;

    final dateKey = yyyymmdd(DateTime.now());
    if (_cachedDateKey == dateKey && _cachedPlan != null) {
      return _cachedPlan!;
    }

    final content = ref.read(contentRepositoryProvider);

    final smartProfile = UserProfileAnalyzer.analyze(profile, goals, completions);
    final last3 = _last3DaysCategories(completions, goals);
    final goalTemplates = generateDailyGoals(smartProfile, content, last3);
    final motivationMessage =
        MotivationEngine.generateMotivation(smartProfile, profile.streak);

    final plan = TodaySmartPlan(
      motivationMessage: motivationMessage,
      goalTemplates: goalTemplates,
      smartProfile: smartProfile,
    );
    _cachedDateKey = dateKey;
    _cachedPlan = plan;
    return plan;
  }
}

final todaySmartPlanProvider =
    AsyncNotifierProvider<TodaySmartPlanNotifier, TodaySmartPlan>(
  TodaySmartPlanNotifier.new,
);
