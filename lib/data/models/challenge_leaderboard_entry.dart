import 'package:flutter/foundation.dart';

/// One row from `challenge_leaderboard` for a given challenge.
@immutable
class ChallengeLeaderboardEntry {
  const ChallengeLeaderboardEntry({
    required this.position,
    required this.userId,
    required this.username,
    required this.completedDays,
    required this.joinedAt,
  });

  final int position;
  final String userId;
  final String username;
  final int completedDays;
  final DateTime joinedAt;
}
