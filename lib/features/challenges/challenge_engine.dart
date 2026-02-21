import 'package:uuid/uuid.dart';

import '../../core/services/analytics_service.dart';
import '../../core/services/xp_service.dart';
import '../../core/utils/date_only.dart';
import '../../data/content/content_repository.dart';
import '../../data/models/challenge.dart';
import '../../data/models/challenge_progress.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_template.dart';
import '../../data/repositories/supabase_challenge_progress_repository.dart';
import '../../data/repositories/supabase_goal_repository.dart';
import '../../data/repositories/supabase_profile_repository.dart';

/// Simple 7-day challenge engine. All logic here; UI only calls service.
/// Rules: one active challenge; one goal completion per day advances; skip day = fail.
class ChallengeEngine {
  ChallengeEngine({
    required this.contentRepository,
    required this.goalRepository,
    required this.profileRepository,
    required this.progressRepository,
    required this.xpService,
    AnalyticsService? analytics,
  }) : _analytics = analytics;

  final ContentRepository contentRepository;
  final SupabaseGoalRepository goalRepository;
  final SupabaseProfileRepository profileRepository;
  final SupabaseChallengeProgressRepository progressRepository;
  final XpService xpService;
  final AnalyticsService? _analytics;

  static const _uuid = Uuid();

  /// Start a challenge: create goals from templates, create progress (currentDay=1, completedDays=0).
  /// Returns the new ChallengeProgress or null if user already has an active challenge.
  Future<ChallengeProgress?> startChallenge({
    required String userId,
    required Challenge challenge,
  }) async {
    final active = await progressRepository.getActive(userId);
    if (active != null) return null;

    final templates = <GoalTemplate>[];
    for (final id in challenge.templateGoalIds) {
      final t = contentRepository.getTemplateById(id);
      if (t != null) templates.add(t);
    }
    if (templates.isEmpty) return null;

    final now = DateTime.now();
    final goalIds = <String>[];
    for (final t in templates) {
      final goalId = _uuid.v4();
      goalIds.add(goalId);
      final goal = Goal(
        id: goalId,
        title: t.title,
        category: t.category,
        difficulty: t.difficulty,
        baseXp: t.baseXp,
        isActive: true,
        createdAt: now,
      );
      await goalRepository.upsert(goal);
    }

    final progress = ChallengeProgress(
      id: _uuid.v4(),
      userId: userId,
      challengeId: challenge.id,
      startedAt: now,
      currentDay: 1,
      completedDays: 0,
      isCompleted: false,
      failedAt: null,
      completedAt: null,
      goalIds: goalIds,
    );
    await progressRepository.upsert(progress);
    return progress;
  }

  /// Call when user completes a goal. If this goal belongs to active challenge and completes
  /// the current day, advance progress. If all days done, complete challenge and grant bonus XP.
  Future<void> recordDayCompleted({
    required String userId,
    required String goalId,
    required DateTime completionDate,
  }) async {
    final active = await progressRepository.getActive(userId);
    if (active == null) return;
    final goalIds = active.goalIds ?? [];
    if (!goalIds.contains(goalId)) return;

    final challenge = contentRepository.getChallengeById(active.challengeId);
    if (challenge == null) return;

    final completionDay = dateOnly(completionDate);
    final startDay = dateOnly(active.startedAt);
    final dayIndex = completionDay.difference(startDay).inDays;
    // currentDay is 1-based; dayIndex 0 = day 1.
    if (dayIndex != active.currentDay - 1) {
      return; // not the current expected day
    }

    var completedDays = active.completedDays + 1;
    var currentDay = active.currentDay + 1;
    var isCompleted = false;
    DateTime? completedAt;

    if (currentDay > challenge.durationDays) {
      isCompleted = true;
      completedAt = DateTime.now();
      final profile =
          profileRepository.readSync() ??
          await profileRepository.loadOrCreate();
      final updated = xpService.grantBonusXp(profile, challenge.bonusXp);
      await profileRepository.save(updated);
      _analytics?.track(AnalyticsEvents.challengeCompleted, {
        'challenge_id': active.challengeId,
        'bonus_xp': challenge.bonusXp,
      });
    }

    final updated = active.copyWith(
      currentDay: currentDay,
      completedDays: completedDays,
      isCompleted: isCompleted,
      completedAt: completedAt,
    );
    await progressRepository.upsert(updated);
  }

  /// Call on app open or when entering dashboard. If user skipped yesterday, mark challenge failed.
  Future<void> checkDaySkipped(String userId) async {
    final active = await progressRepository.getActive(userId);
    if (active == null) return;

    final challenge = contentRepository.getChallengeById(active.challengeId);
    if (challenge == null) return;

    final now = DateTime.now();
    final today = dateOnly(now);
    final startDay = dateOnly(active.startedAt);
    final expectedDayIndex = active.currentDay - 1;
    final expectedDay = startDay.add(Duration(days: expectedDayIndex));

    // If we're past the expected day (i.e. on or after expectedDay+1) and completedDays
    // hasn't reached currentDay, they skipped.
    if (today.isAfter(expectedDay) &&
        active.completedDays < active.currentDay) {
      final failed = active.copyWith(failedAt: now);
      await progressRepository.upsert(failed);
      _analytics?.track(AnalyticsEvents.challengeFailed, {
        'challenge_id': active.challengeId,
      });
    }
  }

  /// Get active progress for user (from Supabase).
  Future<ChallengeProgress?> getActiveProgress(String userId) =>
      progressRepository.getActive(userId);

  /// Quits the current active challenge.
  Future<void> quitChallenge(String userId) async {
    final active = await progressRepository.getActive(userId);
    if (active == null) return;

    final now = DateTime.now();
    // Mark as failed to consider it "quit" or cancelled.
    final failed = active.copyWith(failedAt: now);
    await progressRepository.upsert(failed);
    _analytics?.track(AnalyticsEvents.challengeFailed, {
      'challenge_id': active.challengeId,
      'quit': true,
    });
  }

  /// Count completed challenges for stats.
  Future<int> countCompleted(String userId) =>
      progressRepository.countCompleted(userId);
}
