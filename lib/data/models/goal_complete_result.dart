import 'package:flutter/foundation.dart';

enum GoalCompleteStatus { success, alreadyCompleted, goalNotFound }

@immutable
class GoalCompleteResult {
  const GoalCompleteResult({
    required this.status,
    required this.earnedXp,
    required this.leveledUp,
    required this.newLevel,
  });

  final GoalCompleteStatus status;
  final int earnedXp;
  final bool leveledUp;
  final int newLevel;
}
