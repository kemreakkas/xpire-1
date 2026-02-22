import '../utils/date_only.dart';
import '../../data/models/goal.dart';
import '../../data/models/user_profile.dart';

/// Result of applying a completion: updated profile and whether a streak freeze was used.
class ApplyCompletionResult {
  const ApplyCompletionResult({required this.profile, this.usedFreeze = false});
  final UserProfile profile;
  final bool usedFreeze;
}

class XpService {
  const XpService();

  static const int freezeGrantDays = 7;

  /// XP per difficulty (gamification display).
  static const int xpEasy = 10;
  static const int xpMedium = 25;
  static const int xpHard = 50;

  /// Level up every 250 XP.
  static const int xpPerLevel = 250;

  int earnedXpFor(GoalDifficulty difficulty) {
    return switch (difficulty) {
      GoalDifficulty.easy => xpEasy,
      GoalDifficulty.medium => xpMedium,
      GoalDifficulty.hard => xpHard,
    };
  }

  int requiredXpForLevel(int level) => xpPerLevel;

  /// Grant bonus XP (e.g. challenge completion). Applies level-up logic.
  UserProfile grantBonusXp(UserProfile profile, int amount) {
    var level = profile.level;
    var currentXp = profile.currentXp + amount;
    final totalXp = profile.totalXp + amount;

    while (currentXp >= requiredXpForLevel(level)) {
      currentXp -= requiredXpForLevel(level);
      level += 1;
    }

    return profile.copyWith(
      level: level,
      currentXp: currentXp,
      totalXp: totalXp,
    );
  }

  ApplyCompletionResult applyCompletion({
    required UserProfile profile,
    required int earnedXp,
    required DateTime completionDate,
  }) {
    final date = dateOnly(completionDate);
    UserProfile working = profile;

    // Premium multiplier: Double the XP earned
    final actualEarnedXp = working.isPremium ? earnedXp * 2 : earnedXp;

    // Premium: grant 1 freeze credit every 7 days
    if (working.isPremium) {
      working = _refreshFreezeCredits(working, date);
    }

    final streakResult = _nextStreakOrFreeze(
      currentStreak: working.streak,
      lastActiveDate: working.lastActiveDate,
      completionDate: date,
      freezeCredits: working.freezeCredits,
      isPremium: working.isPremium,
    );

    var level = working.level;
    var currentXp = working.currentXp + actualEarnedXp;
    var totalXp = working.totalXp + actualEarnedXp;

    while (currentXp >= requiredXpForLevel(level)) {
      currentXp -= requiredXpForLevel(level);
      level += 1;
    }

    working = working.copyWith(
      level: level,
      currentXp: currentXp,
      totalXp: totalXp,
      streak: streakResult.newStreak,
      lastActiveDate: date,
      freezeCredits: streakResult.usedFreeze
          ? working.freezeCredits - 1
          : working.freezeCredits,
    );

    return ApplyCompletionResult(
      profile: working,
      usedFreeze: streakResult.usedFreeze,
    );
  }

  UserProfile _refreshFreezeCredits(UserProfile profile, DateTime today) {
    final last = profile.lastFreezeReset;
    if (last == null) {
      return profile.copyWith(lastFreezeReset: today);
    }
    final lastDate = dateOnly(last);
    final daysSince = today.difference(lastDate).inDays;
    if (daysSince >= freezeGrantDays) {
      return profile.copyWith(
        freezeCredits: profile.freezeCredits + 1,
        lastFreezeReset: today,
      );
    }
    return profile;
  }

  _StreakResult _nextStreakOrFreeze({
    required int currentStreak,
    required DateTime lastActiveDate,
    required DateTime completionDate,
    required int freezeCredits,
    required bool isPremium,
  }) {
    final wouldBe = _nextStreak(
      currentStreak: currentStreak,
      lastActiveDate: lastActiveDate,
      completionDate: completionDate,
    );
    final wouldBreak = wouldBe == 1 && currentStreak > 0;
    if (wouldBreak && isPremium && freezeCredits > 0) {
      return _StreakResult(newStreak: currentStreak, usedFreeze: true);
    }
    return _StreakResult(newStreak: wouldBe, usedFreeze: false);
  }

  int _nextStreak({
    required int currentStreak,
    required DateTime lastActiveDate,
    required DateTime completionDate,
  }) {
    final last = dateOnly(lastActiveDate);

    if (lastActiveDate.millisecondsSinceEpoch == 0) {
      return 1;
    }

    if (isSameDay(last, completionDate)) {
      return currentStreak == 0 ? 1 : currentStreak;
    }

    final yesterday = completionDate.subtract(const Duration(days: 1));
    if (isSameDay(last, yesterday)) {
      return (currentStreak == 0 ? 1 : currentStreak) + 1;
    }

    return 1;
  }
}

class _StreakResult {
  _StreakResult({required this.newStreak, this.usedFreeze = false});
  final int newStreak;
  final bool usedFreeze;
}
