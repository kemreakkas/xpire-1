import '../../data/models/goal_template.dart';
import 'user_profile_analyzer.dart';

/// Cached "Today's AI Plan": 3 smart goals + motivation. No external API.
class TodaySmartPlan {
  const TodaySmartPlan({
    required this.motivationMessage,
    required this.goalTemplates,
    required this.smartProfile,
  });

  final String motivationMessage;
  final List<GoalTemplate> goalTemplates;
  final SmartProfile smartProfile;
}
