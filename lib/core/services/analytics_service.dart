import '../log/app_log.dart';

/// Analytics event names for retention and product usage. Replace with
/// Firebase/PostHog or other backend when ready.
abstract class AnalyticsEvents {
  static const String userRegistered = 'user_registered';
  static const String goalCreated = 'goal_created';
  static const String goalCompleted = 'goal_completed';
  static const String challengeStarted = 'challenge_started';
  static const String challengeDayCompleted = 'challenge_day_completed';
  static const String challengeFailed = 'challenge_failed';
  static const String challengeCompleted = 'challenge_completed';
  static const String premiumClicked = 'premium_clicked';
}

/// Modular analytics: log events here; swap implementation for Firebase/PostHog later.
abstract class AnalyticsService {
  void track(String event, [Map<String, Object?>? properties]);
}

/// Default implementation: debug log only. Replace with FirebaseAnalytics or PostHog in production.
class DefaultAnalyticsService implements AnalyticsService {
  @override
  void track(String event, [Map<String, Object?>? properties]) {
    AppLog.debug('Analytics: $event', properties ?? {});
  }
}
