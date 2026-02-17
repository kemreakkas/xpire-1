import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../state/providers.dart';

/// Premium business logic. Free users have full core features (unlimited goals, XP, streak, challenges).
/// Premium only adds: advanced analytics, exclusive challenges, future AI features. No blocking.
abstract final class PremiumController {
  /// Whether the user has an active premium subscription (server subscription_status or local isPremium).
  static final isPremiumProvider = Provider<bool>((ref) {
    final profile = ref.watch(profileControllerProvider).asData?.value;
    return profile?.isPremiumEffective ?? false;
  });

  /// Free users can create unlimited goals. No hard limits.
  static final canCreateGoalProvider = Provider<bool>((ref) => true);

  /// Advanced analytics (weekly average, most productive category, 30-day trend) are premium-only.
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
