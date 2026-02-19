import 'package:flutter/foundation.dart';

/// User's participation in a community challenge (Supabase `challenge_participants`).
@immutable
class ChallengeParticipant {
  const ChallengeParticipant({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.currentDay,
    required this.completedDays,
    required this.joinedAt,
    required this.isCompleted,
  });

  final String id;
  final String challengeId;
  final String userId;
  final int currentDay;
  final int completedDays;
  final DateTime joinedAt;
  final bool isCompleted;
}
