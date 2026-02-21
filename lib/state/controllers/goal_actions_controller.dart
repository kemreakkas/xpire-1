import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../../core/services/analytics_service.dart';
import '../../core/utils/date_key.dart';
import '../../core/utils/date_only.dart';
import '../../data/models/goal_complete_result.dart';
import '../../data/models/goal_completion.dart';
import '../../features/auth/auth_controller.dart';
import '../providers.dart';

class GoalActionsController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // No-op state; this controller is for actions.
  }

  Future<GoalCompleteResult> completeGoal({
    required String goalId,
    DateTime? date,
  }) async {
    final completionDate = dateOnly(date ?? DateTime.now());
    final completionId = '${goalId}_${yyyymmdd(completionDate)}';
    final todayKey = yyyymmdd(completionDate);

    final completionRepo = ref.read(completionRepositoryProvider);
    final completionsBefore = completionRepo.listSync();
    final wasFirstCompletionToday = !completionsBefore.any(
      (c) => yyyymmdd(c.date) == todayKey,
    );

    if (completionRepo.containsId(completionId)) {
      return const GoalCompleteResult(
        status: GoalCompleteStatus.alreadyCompleted,
        earnedXp: 0,
        leveledUp: false,
        newLevel: 0,
      );
    }

    final goalRepo = ref.read(goalRepositoryProvider);
    final goal = goalRepo.getById(goalId);
    if (goal == null) {
      return const GoalCompleteResult(
        status: GoalCompleteStatus.goalNotFound,
        earnedXp: 0,
        leveledUp: false,
        newLevel: 0,
      );
    }

    state = const AsyncLoading<void>();
    GoalCompleteResult? response;
    final op = await AsyncValue.guard(() async {
      final xpService = ref.read(xpServiceProvider);
      final earnedXp = xpService.earnedXpFor(goal.difficulty);

      AppLog.info('Complete goal', {'goalId': goalId, 'earnedXp': earnedXp});

      final completion = GoalCompletion(
        id: completionId,
        goalId: goalId,
        date: completionDate,
        earnedXp: earnedXp,
        completedAt: DateTime.now(),
      );

      final profileRepo = ref.read(profileRepositoryProvider);
      final currentProfile =
          profileRepo.readSync() ?? await profileRepo.loadOrCreate();
      final beforeLevel = currentProfile.level;
      final result = xpService.applyCompletion(
        profile: currentProfile,
        earnedXp: earnedXp,
        completionDate: completionDate,
      );

      final progressRepo = ref.read(challengeProgressRepositoryProvider);
      final content = ref.read(contentRepositoryProvider);
      final active = progressRepo.getCurrent();
      final goalIdSet = active?.goalIds.toSet() ?? <String>{};
      final completionsBefore = completionRepo.listSync();
      final challenge = active != null
          ? content.getChallengeById(active.challengeId)
          : null;
      final oldDaysCompleted =
          active != null && goalIdSet.contains(goalId) && challenge != null
          ? _daysCompletedForChallenge(
              active.startedAt,
              challenge.durationDays,
              goalIdSet,
              completionsBefore,
            )
          : 0;

      await completionRepo.upsert(completion);
      try {
        await profileRepo.save(result.profile);
      } catch (e, st) {
        AppLog.error('Failed to save profile after goal completion', e, st);
      }

      ref.read(analyticsServiceProvider).track(AnalyticsEvents.goalCompleted, {
        'goal_id': goalId,
        'category': goal.category.name,
      });
      final newCompletions = completionRepo.listSync();
      if (active != null &&
          goalIdSet.contains(goalId) &&
          content.getChallengeById(active.challengeId) != null) {
        final newDaysCompleted = _daysCompletedForChallenge(
          active.startedAt,
          content.getChallengeById(active.challengeId)!.durationDays,
          goalIdSet,
          newCompletions,
        );
        if (newDaysCompleted > oldDaysCompleted) {
          ref.read(analyticsServiceProvider).track(
            AnalyticsEvents.challengeDayCompleted,
            {'challenge_id': active.challengeId, 'day': newDaysCompleted},
          );
        }
      }

      ref.invalidate(profileControllerProvider);
      ref.invalidate(completionsControllerProvider);
      ref.invalidate(statsProvider);
      if (SupabaseConfig.isConfigured) {
        final uid = ref.read(authUserIdProvider);
        if (uid != null) {
          await ref
              .read(challengeEngineProvider)
              .recordDayCompleted(
                userId: uid,
                goalId: goalId,
                completionDate: completionDate,
              );
          ref.invalidate(activeChallengeProgressModelProvider);
        }
      }

      if (wasFirstCompletionToday) {
        final profileRepo = ref.read(profileRepositoryProvider);
        final updatedProfile = result.profile.copyWith(
          lastNotificationSent: completionDate,
        );
        await profileRepo.save(updatedProfile);
        ref.invalidate(profileControllerProvider);
        await ref.read(notificationServiceProvider).cancelDailyReminder();
      }

      response = GoalCompleteResult(
        status: GoalCompleteStatus.success,
        earnedXp: earnedXp,
        leveledUp: result.profile.level > beforeLevel,
        newLevel: result.profile.level,
      );
    });

    state = op;

    return response ??
        const GoalCompleteResult(
          status: GoalCompleteStatus.failure,
          earnedXp: 0,
          leveledUp: false,
          newLevel: 0,
        );
  }

  static int _daysCompletedForChallenge(
    DateTime startedAt,
    int durationDays,
    Set<String> goalIds,
    List<GoalCompletion> completions,
  ) {
    final start = DateTime(startedAt.year, startedAt.month, startedAt.day);
    final end = start.add(Duration(days: durationDays));
    final days = <DateTime>{};
    for (final c in completions) {
      final d = DateTime(c.date.year, c.date.month, c.date.day);
      if ((d.isAfter(start) || _isSameDay(d, start)) &&
          d.isBefore(end) &&
          goalIds.contains(c.goalId)) {
        days.add(d);
      }
    }
    return days.length;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
