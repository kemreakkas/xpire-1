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

  /// Challenges filtered by category. Pass null for all.
  List<Challenge> getChallengesByCategory(GoalCategory? category) {
    if (category == null) return getChallenges();
    return _challenges.where((c) => c.category == category).toList();
  }
}
