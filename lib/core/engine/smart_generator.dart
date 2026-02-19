import 'dart:math';

import '../../data/content/content_repository.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_template.dart';
import 'user_profile_analyzer.dart';

/// One day in a 7-day smart challenge plan.
class SmartChallengeDay {
  const SmartChallengeDay({
    required this.dayIndex,
    required this.intensity,
    required this.label,
  });
  final int dayIndex;
  final GoalDifficulty intensity;
  final String label;
}

/// 7-day smart challenge plan (rule-based, no external API).
class SmartChallengePlan {
  const SmartChallengePlan({
    required this.focus,
    required this.days,
    required this.title,
  });
  final GoalCategory focus;
  final List<SmartChallengeDay> days;
  final String title;
}

final _rng = Random();

/// Rule-based daily goal generator. Picks category from profile, adjusts
/// difficulty by consistency, selects 3 goals, avoids overusing last 3 days' categories.
List<GoalTemplate> generateDailyGoals(
  SmartProfile profile,
  ContentRepository content,
  Set<GoalCategory> last3DaysCategories,
) {
  final difficulty = _difficultyForConsistency(profile.consistencyLevel);
  final category = profile.primaryFocus;
  var pool = content.getTemplatesByCategory(category);
  if (pool.isEmpty) pool = content.getGoalTemplates();

  final byDifficulty =
      pool.where((t) => t.difficulty == difficulty).toList();
  var candidates = byDifficulty.isNotEmpty ? byDifficulty : pool;

  // Prefer templates whose category was NOT in last 3 days (variety).
  final avoidCategories = last3DaysCategories;
  final preferred = candidates
      .where((t) => !avoidCategories.contains(t.category))
      .toList();
  if (preferred.length >= 3) {
    candidates = preferred;
  }

  candidates = List.from(candidates)..shuffle(_rng);
  final selected = <GoalTemplate>[];
  final usedIds = <String>{};
  for (final t in candidates) {
    if (selected.length >= 3) break;
    if (usedIds.contains(t.id)) continue;
    usedIds.add(t.id);
    selected.add(t);
  }
  return selected;
}

GoalDifficulty _difficultyForConsistency(ConsistencyLevel c) {
  switch (c) {
    case ConsistencyLevel.low:
      return GoalDifficulty.easy;
    case ConsistencyLevel.medium:
      return GoalDifficulty.medium;
    case ConsistencyLevel.high:
      return GoalDifficulty.hard;
  }
}

/// Builds a 7-day smart challenge plan by focus.
/// Fitness: increasing intensity. Study: short → longer. Discipline: digital detox + habit stacking.
SmartChallengePlan generateSmartChallenge(SmartProfile profile) {
  final focus = profile.primaryFocus;
  final days = <SmartChallengeDay>[];

  final intensityByDay = [
    GoalDifficulty.easy,
    GoalDifficulty.easy,
    GoalDifficulty.medium,
    GoalDifficulty.medium,
    GoalDifficulty.medium,
    GoalDifficulty.hard,
    GoalDifficulty.hard,
  ];

  String title;
  List<String> dayLabels;

  switch (focus) {
    case GoalCategory.fitness:
      title = '7-Day Fitness Build';
      dayLabels = [
        'Light movement',
        'Stretch & steps',
        'Strength intro',
        'Cardio + strength',
        'Full workout',
        'Peak day',
        'Finish strong',
      ];
      break;
    case GoalCategory.study:
      title = '7-Day Study Sprint';
      dayLabels = [
        'Short session',
        'Short session',
        'Medium focus',
        'Deep work',
        'Review + new',
        'Long session',
        'Capstone',
      ];
      break;
    case GoalCategory.discipline:
      title = '7-Day Discipline Reset';
      dayLabels = [
        'Digital detox start',
        'Habit stack 1',
        'Detox + habit',
        'Routine lock',
        'Stack + focus',
        'Full discipline',
        'Lock it in',
      ];
      break;
    default:
      title = '7-Day Focus Plan';
      dayLabels = List.generate(7, (i) => 'Day ${i + 1}');
  }

  for (var i = 0; i < 7; i++) {
    days.add(SmartChallengeDay(
      dayIndex: i + 1,
      intensity: intensityByDay[i],
      label: dayLabels[i],
    ));
  }

  return SmartChallengePlan(focus: focus, days: days, title: title);
}
