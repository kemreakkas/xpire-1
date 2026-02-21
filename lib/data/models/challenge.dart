import 'package:flutter/foundation.dart';

import 'goal.dart';

/// A challenge pack: multiple template goals over a fixed duration. Completion gives bonus XP.
@immutable
class Challenge {
  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.durationDays,
    required this.category,
    required this.templateGoalIds,
    this.isPremium = false,
    this.bonusXp = 0,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final int durationDays;
  final GoalCategory category;

  /// Template IDs to instantiate as goals when user starts this challenge.
  final List<String> templateGoalIds;
  final bool isPremium;

  /// XP awarded when challenge is completed.
  final int bonusXp;
  final DateTime? createdAt;

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    int? durationDays,
    GoalCategory? category,
    List<String>? templateGoalIds,
    bool? isPremium,
    int? bonusXp,
    DateTime? createdAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationDays: durationDays ?? this.durationDays,
      category: category ?? this.category,
      templateGoalIds: templateGoalIds ?? this.templateGoalIds,
      isPremium: isPremium ?? this.isPremium,
      bonusXp: bonusXp ?? this.bonusXp,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
