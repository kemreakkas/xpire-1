import '../../data/models/goal.dart';
import '../../data/models/goal_completion.dart';
import '../../data/models/user_profile.dart';
import '../utils/date_only.dart';

/// Energy level derived from streak and activity.
enum EnergyLevel { low, medium, high }

/// Time commitment tier for daily capacity.
enum CommitmentLevel { light, medium, intense }

/// Consistency tier from completion history.
enum ConsistencyLevel { low, medium, high }

/// Result of analyzing user signals for the smart generator.
class SmartProfile {
  const SmartProfile({
    required this.primaryFocus,
    required this.energyLevel,
    required this.commitmentLevel,
    required this.consistencyLevel,
  });

  final GoalCategory primaryFocus;
  final EnergyLevel energyLevel;
  final CommitmentLevel commitmentLevel;
  final ConsistencyLevel consistencyLevel;

  /// 0–1 score for consistency (low=0–0.33, medium=0.34–0.66, high=0.67–1).
  double get consistencyScore => switch (consistencyLevel) {
        ConsistencyLevel.low => 0.2,
        ConsistencyLevel.medium => 0.5,
        ConsistencyLevel.high => 0.85,
      };
}

/// Rule-based analyzer: no external API. Uses profile + completion history.
class UserProfileAnalyzer {
  UserProfileAnalyzer._();

  /// Builds [SmartProfile] from [profile], [goals], [completions].
  /// [dailyTimeCommitmentMinutes] is optional (not stored in profile); when null,
  /// commitment is inferred from total_xp/streak.
  static SmartProfile analyze(
    UserProfile profile,
    List<Goal> goals,
    List<GoalCompletion> completions, {
    int? dailyTimeCommitmentMinutes,
  }) {
    final primaryFocus = _primaryFocus(profile, completions, goals);
    final energyLevel = _energyLevel(profile.streak);
    final commitmentLevel = _commitmentLevel(
      profile,
      dailyTimeCommitmentMinutes,
    );
    final consistencyLevel = _consistencyLevel(completions, goals);
    return SmartProfile(
      primaryFocus: primaryFocus,
      energyLevel: energyLevel,
      commitmentLevel: commitmentLevel,
      consistencyLevel: consistencyLevel,
    );
  }

  static GoalCategory _primaryFocus(
    UserProfile profile,
    List<GoalCompletion> completions,
    List<Goal> goals,
  ) {
    if (completions.isEmpty) {
      return profile.focusCategory ?? GoalCategory.general;
    }
    final goalIdToCategory = <String, GoalCategory>{};
    for (final g in goals) {
      goalIdToCategory[g.id] = g.category;
    }
    final categoryCounts = <GoalCategory, int>{};
    for (final c in completions) {
      final cat = goalIdToCategory[c.goalId];
      if (cat != null) {
        categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
      }
    }
    if (categoryCounts.isEmpty) {
      return profile.focusCategory ?? GoalCategory.general;
    }
    GoalCategory? top;
    var maxCount = 0;
    for (final e in categoryCounts.entries) {
      if (e.value > maxCount) {
        maxCount = e.value;
        top = e.key;
      }
    }
    return top ?? profile.focusCategory ?? GoalCategory.general;
  }

  /// streak >= 7 → high; streak < 3 → low; else medium.
  static EnergyLevel _energyLevel(int streak) {
    if (streak >= 7) return EnergyLevel.high;
    if (streak < 3) return EnergyLevel.low;
    return EnergyLevel.medium;
  }

  /// daily_time_commitment < 20 → light; > 45 → intense; else medium.
  /// When [dailyTimeCommitmentMinutes] is null, infer from totalXp/streak.
  static CommitmentLevel _commitmentLevel(
    UserProfile profile,
    int? dailyTimeCommitmentMinutes,
  ) {
    final minutes = dailyTimeCommitmentMinutes ?? _inferDailyMinutes(profile);
    if (minutes < 20) return CommitmentLevel.light;
    if (minutes > 45) return CommitmentLevel.intense;
    return CommitmentLevel.medium;
  }

  static int _inferDailyMinutes(UserProfile profile) {
    if (profile.totalXp < 50 && profile.streak < 2) return 15;
    if (profile.totalXp > 400 || profile.streak >= 7) return 50;
    return 35;
  }

  /// Consistency from last 7 days: days with at least one completion / 7.
  static ConsistencyLevel _consistencyLevel(
    List<GoalCompletion> completions,
    List<Goal> goals,
  ) {
    if (completions.isEmpty) return ConsistencyLevel.low;
    final today = dateOnly(DateTime.now());
    final weekAgo = today.subtract(const Duration(days: 7));
    final daysWithCompletion = <DateTime>{};
    for (final c in completions) {
      final d = dateOnly(c.date);
      if (!d.isBefore(weekAgo) && !d.isAfter(today)) {
        daysWithCompletion.add(d);
      }
    }
    final ratio = daysWithCompletion.length / 7.0;
    if (ratio >= 0.7) return ConsistencyLevel.high;
    if (ratio >= 0.35) return ConsistencyLevel.medium;
    return ConsistencyLevel.low;
  }
}
