import '../models/challenge.dart';
import '../models/goal.dart';
import '../models/goal_template.dart';
import 'default_challenges.dart';
import 'default_goal_templates.dart';

/// Content layer: templates and challenges. Local static lists for MVP.
class ContentRepository {
  ContentRepository();

  final List<GoalTemplate> _templates = getDefaultGoalTemplates();
  final List<Challenge> _challenges = getDefaultChallenges();

  List<GoalTemplate> getGoalTemplates() => List.unmodifiable(_templates);
  List<GoalTemplate> getTemplates() => getGoalTemplates();
  List<Challenge> getChallenges() => List.unmodifiable(_challenges);

  GoalTemplate? getTemplateById(String id) {
    for (final t in _templates) {
      if (t.id == id) return t;
    }
    return null;
  }

  Challenge? getChallengeById(String id) {
    for (final c in _challenges) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Templates filtered by category. Pass null for all.
  List<GoalTemplate> getTemplatesByCategory(GoalCategory? category) {
    if (category == null) return getGoalTemplates();
    return _templates.where((t) => t.category == category).toList();
  }

  /// Templates filtered by category name (e.g. "fitness", "digitalDetox").
  /// Returns empty list if [category] is invalid.
  List<GoalTemplate> getTemplatesByCategoryName(String category) {
    try {
      final c = GoalCategory.values.byName(category);
      return _templates.where((t) => t.category == c).toList();
    } catch (_) {
      return [];
    }
  }

  /// Templates filtered by difficulty ("easy", "medium", "hard").
  /// Returns empty list if [difficulty] is invalid.
  List<GoalTemplate> getTemplatesByDifficulty(String difficulty) {
    try {
      final d = GoalDifficulty.values.byName(difficulty.toLowerCase());
      return _templates.where((t) => t.difficulty == d).toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns 10 strong starter templates (mix of categories and difficulties).
  List<GoalTemplate> getFeaturedTemplates() {
    const featuredIds = [
      'tpl_morning_walk',
      'tpl_10min_meditation',
      'tpl_30min_reading',
      'tpl_track_expenses',
      'tpl_gratitude_3',
      'tpl_plan_tomorrow',
      'tpl_drink_8_glasses',
      'tpl_learn_one_thing',
      'tpl_one_genuine_compliment',
      'tpl_10min_stretch',
    ];
    final idSet = featuredIds.toSet();
    return _templates.where((t) => idSet.contains(t.id)).toList();
  }

  /// Challenges filtered by category. Pass null for all.
  List<Challenge> getChallengesByCategory(GoalCategory? category) {
    if (category == null) return getChallenges();
    return _challenges.where((c) => c.category == category).toList();
  }
}
