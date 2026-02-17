import 'package:flutter/foundation.dart';

@immutable
class Stats {
  const Stats({
    required this.totalXp,
    required this.totalGoalsCompleted,
    required this.currentStreak,
    required this.completedTodayCount,
    required this.completionsByCategory,
    this.weeklyXpTotal,
    this.mostProductiveCategoryName,
    this.last30DaysCompletionCounts,
  });

  final int totalXp;
  final int totalGoalsCompleted;
  final int currentStreak;
  final int completedTodayCount;

  /// Simple count of completions per category (category name -> count).
  final Map<String, int> completionsByCategory;

  /// Premium: total XP earned in the last 7 days.
  final int? weeklyXpTotal;

  /// Premium: category name with most completions.
  final String? mostProductiveCategoryName;

  /// Premium: completions per day for the last 30 days (oldest first).
  final List<int>? last30DaysCompletionCounts;
}
