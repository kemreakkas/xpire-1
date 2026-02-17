import 'package:flutter/foundation.dart';

import 'goal.dart';

/// Frequency for template-based goals.
enum TemplateFrequency { daily, weekly }

/// Built-in goal template for structured content. Maps to Goal when user creates from template.
@immutable
class GoalTemplate {
  const GoalTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.baseXp,
    required this.frequency,
    this.isPremium = false,
  });

  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalDifficulty difficulty;
  final int baseXp;
  final TemplateFrequency frequency;
  final bool isPremium;

  GoalTemplate copyWith({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    GoalDifficulty? difficulty,
    int? baseXp,
    TemplateFrequency? frequency,
    bool? isPremium,
  }) {
    return GoalTemplate(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      baseXp: baseXp ?? this.baseXp,
      frequency: frequency ?? this.frequency,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
