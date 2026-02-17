import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/providers.dart';

/// Premium business logic exposed via Riverpod. UI uses these, not raw profile/goals.
abstract final class PremiumController {
  static const int maxActiveGoalsFree = 3;

  /// Whether the user has an active premium subscription (server subscription_status or local isPremium).
  static final isPremiumProvider = Provider<bool>((ref) {
    final profile = ref.watch(profileControllerProvider).asData?.value;
    return profile?.isPremiumEffective ?? false;
  });

  /// Number of currently active goals.
  static final activeGoalCountProvider = Provider<int>((ref) {
    final goals = ref.watch(goalsControllerProvider).asData?.value ?? [];
    return goals.where((g) => g.isActive).length;
  });

  /// True if user can create a new goal (premium = unlimited, free = max 3 active).
  static final canCreateGoalProvider = Provider<bool>((ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final count = ref.watch(activeGoalCountProvider);
    return isPremium || count < maxActiveGoalsFree;
  });

  /// Advanced stats (weekly average, most productive category, 30-day trend) are premium-only.
  static final canUseAdvancedStatsProvider = Provider<bool>((ref) {
    return ref.watch(isPremiumProvider);
  });

  /// Premium users get 1 freeze credit per 7 days; when streak would break, use 1 if available.
  static final hasStreakFreezeAvailableProvider = Provider<bool>((ref) {
    final profile = ref.watch(profileControllerProvider).asData?.value;
    if (profile == null || !profile.isPremiumEffective) return false;
    return profile.freezeCredits > 0;
  });
}
