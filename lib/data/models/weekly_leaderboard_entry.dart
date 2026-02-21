import 'package:flutter/foundation.dart';

/// One row from `weekly_leaderboard` (top N by weekly XP).
@immutable
class WeeklyLeaderboardEntry {
  const WeeklyLeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.level,
    required this.streak,
    required this.totalXp,
  });

  final int rank;
  final String userId;
  final String username;
  final int level;
  final int streak;
  final int totalXp;
}
