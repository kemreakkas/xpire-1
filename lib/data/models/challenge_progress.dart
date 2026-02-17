import 'package:flutter/foundation.dart';

/// One user's progress on a challenge. One active challenge per user.
@immutable
class ChallengeProgress {
  const ChallengeProgress({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.startedAt,
    required this.currentDay,
    required this.completedDays,
    required this.isCompleted,
    this.failedAt,
    this.completedAt,
    this.goalIds,
  });

  final String id;
  final String userId;
  final String challengeId;
  final DateTime startedAt;
  /// 1-based day user is on (1..durationDays).
  final int currentDay;
  /// Number of days successfully completed.
  final int completedDays;
  final bool isCompleted;
  /// Set when user skips a day (challenge failed).
  final DateTime? failedAt;
  /// Set when challenge completed successfully.
  final DateTime? completedAt;
  /// Goal IDs created for this challenge (for daily completion check).
  final List<String>? goalIds;

  ChallengeProgress copyWith({
    String? id,
    String? userId,
    String? challengeId,
    DateTime? startedAt,
    int? currentDay,
    int? completedDays,
    bool? isCompleted,
    DateTime? failedAt,
    DateTime? completedAt,
    List<String>? goalIds,
  }) {
    return ChallengeProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      startedAt: startedAt ?? this.startedAt,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      isCompleted: isCompleted ?? this.isCompleted,
      failedAt: failedAt ?? this.failedAt,
      completedAt: completedAt ?? this.completedAt,
      goalIds: goalIds ?? this.goalIds,
    );
  }
}
