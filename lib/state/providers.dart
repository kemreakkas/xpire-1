import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../app/app_scaffold.dart';
import '../core/config/supabase_config.dart';
import '../core/services/analytics_service.dart';
import '../core/services/xp_service.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_page.dart';
import '../features/auth/register_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/goals/goal_create_page.dart';
import '../features/challenges/challenge_list_page.dart';
import '../features/challenges/challenge_detail_page.dart';
import '../features/premium/premium_page.dart';
import '../features/profile/profile_page.dart';
import '../features/stats/stats_page.dart';
import '../core/utils/date_only.dart';
import '../data/content/content_repository.dart';
import '../data/models/active_challenge.dart';
import '../data/models/challenge.dart';
import '../data/models/goal.dart';
import '../data/models/goal_completion.dart';
import '../data/models/stats.dart';
import '../data/models/user_profile.dart';
import '../data/repositories/challenge_progress_repository.dart';
import '../data/repositories/supabase_challenge_progress_repository.dart';
import '../data/repositories/supabase_completion_repository.dart';
import '../data/repositories/supabase_goal_repository.dart';
import '../data/repositories/supabase_profile_repository.dart';
import '../features/challenges/challenge_engine.dart';
import '../data/models/challenge_progress.dart';
import 'controllers/completions_controller.dart';
import 'controllers/goal_actions_controller.dart';
import 'controllers/goals_controller.dart';
import 'controllers/profile_controller.dart';

// Hive boxes (injected from main.dart)
final profileBoxProvider = Provider<Box<UserProfile>>((ref) {
  throw UnimplementedError(
    'profileBoxProvider must be overridden in main.dart',
  );
});

final goalsBoxProvider = Provider<Box<Goal>>((ref) {
  throw UnimplementedError('goalsBoxProvider must be overridden in main.dart');
});

final completionsBoxProvider = Provider<Box<GoalCompletion>>((ref) {
  throw UnimplementedError(
    'completionsBoxProvider must be overridden in main.dart',
  );
});

final activeChallengeBoxProvider = Provider<Box<ActiveChallenge>>((ref) {
  throw UnimplementedError(
    'activeChallengeBoxProvider must be overridden in main.dart',
  );
});

// Repositories (Supabase-first with Hive cache when configured)
final profileRepositoryProvider = Provider<SupabaseProfileRepository>((ref) {
  return SupabaseProfileRepository(ref.watch(profileBoxProvider));
});

final goalRepositoryProvider = Provider<SupabaseGoalRepository>((ref) {
  return SupabaseGoalRepository(ref.watch(goalsBoxProvider));
});

final completionRepositoryProvider = Provider<SupabaseCompletionRepository>((
  ref,
) {
  return SupabaseCompletionRepository(ref.watch(completionsBoxProvider));
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository();
});

final challengeProgressRepositoryProvider =
    Provider<ChallengeProgressRepository>((ref) {
      return ChallengeProgressRepository(ref.watch(activeChallengeBoxProvider));
    });

final supabaseChallengeProgressRepositoryProvider =
    Provider<SupabaseChallengeProgressRepository>((ref) {
      return SupabaseChallengeProgressRepository();
    });

final challengeEngineProvider = Provider<ChallengeEngine>((ref) {
  return ChallengeEngine(
    contentRepository: ref.watch(contentRepositoryProvider),
    goalRepository: ref.watch(goalRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    progressRepository: ref.watch(supabaseChallengeProgressRepositoryProvider),
    xpService: ref.watch(xpServiceProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});

/// Active challenge progress from engine (Supabase). Null when not configured or no active.
final activeChallengeProgressModelProvider = FutureProvider<ChallengeProgress?>(
  (ref) async {
    if (!SupabaseConfig.isConfigured) return null;
    final uid = ref.watch(authUserIdProvider);
    if (uid == null) return null;
    final engine = ref.watch(challengeEngineProvider);
    await engine.checkDaySkipped(uid);
    return engine.getActiveProgress(uid);
  },
);

/// Completed challenges count (Supabase). 0 when not configured.
final completedChallengesCountProvider = FutureProvider<int>((ref) async {
  if (!SupabaseConfig.isConfigured) return 0;
  final uid = ref.watch(authUserIdProvider);
  if (uid == null) return 0;
  final engine = ref.watch(challengeEngineProvider);
  return engine.countCompleted(uid);
});

/// When set, GoalCreatePage will open with this template applied (and clear after apply).
final pendingTemplateIdProvider =
    NotifierProvider<PendingTemplateIdNotifier, String?>(
      PendingTemplateIdNotifier.new,
    );

class PendingTemplateIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) => state = id;
}

// Services
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return DefaultAnalyticsService();
});
final xpServiceProvider = Provider<XpService>((ref) => const XpService());

// Computed (UI-friendly)
final requiredXpProvider = Provider<int?>((ref) {
  final profile = ref.watch(profileControllerProvider).asData?.value;
  if (profile == null) return null;
  return ref.watch(xpServiceProvider).requiredXpForLevel(profile.level);
});

final xpProgressRatioProvider = Provider<double?>((ref) {
  final profile = ref.watch(profileControllerProvider).asData?.value;
  final requiredXp = ref.watch(requiredXpProvider);
  if (profile == null || requiredXp == null || requiredXp == 0) return null;
  return profile.currentXp / requiredXp;
});

// Controllers
final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, UserProfile>(
      ProfileController.new,
    );

final goalsControllerProvider =
    AsyncNotifierProvider<GoalsController, List<Goal>>(GoalsController.new);

final completionsControllerProvider =
    AsyncNotifierProvider<CompletionsController, List<GoalCompletion>>(
      CompletionsController.new,
    );

final goalActionsControllerProvider =
    AsyncNotifierProvider<GoalActionsController, void>(
      GoalActionsController.new,
    );

// Derived state
/// Active challenge with progress (0.0–1.0). Null if none.
final activeChallengeProgressProvider = Provider<ActiveChallengeProgress?>((
  ref,
) {
  final progressRepo = ref.watch(challengeProgressRepositoryProvider);
  final content = ref.watch(contentRepositoryProvider);
  final completions =
      ref.watch(completionsControllerProvider).asData?.value ?? [];
  final active = progressRepo.getCurrent();
  if (active == null) return null;
  final challenge = content.getChallengeById(active.challengeId);
  if (challenge == null) return null;

  // One required action per day: count days with at least one completion from challenge goals.
  final start = dateOnly(active.startedAt);
  final end = start.add(Duration(days: challenge.durationDays));
  final goalIdSet = active.goalIds.toSet();
  final completedDays = <DateTime>{};
  for (final c in completions) {
    final d = dateOnly(c.date);
    if ((d.isAfter(start) || isSameDay(d, start)) &&
        d.isBefore(end) &&
        goalIdSet.contains(c.goalId)) {
      completedDays.add(d);
    }
  }
  final daysCompleted = completedDays.length;
  final totalRequired = challenge.durationDays;
  final progress = totalRequired == 0
      ? 1.0
      : (daysCompleted / totalRequired).clamp(0.0, 1.0);
  final completed = daysCompleted >= totalRequired;
  return ActiveChallengeProgress(
    challenge: challenge,
    active: active,
    progress: progress,
    completed: completed,
    completionsCount: daysCompleted,
    totalRequired: totalRequired,
  );
});

/// Helper for dashboard/challenge UI.
class ActiveChallengeProgress {
  const ActiveChallengeProgress({
    required this.challenge,
    required this.active,
    required this.progress,
    required this.completed,
    required this.completionsCount,
    required this.totalRequired,
  });
  final Challenge challenge;
  final ActiveChallenge active;
  final double progress;
  final bool completed;
  final int completionsCount;
  final int totalRequired;
}

final statsProvider = Provider<AsyncValue<Stats>>((ref) {
  final profile = ref.watch(profileControllerProvider);
  final completions = ref.watch(completionsControllerProvider);
  final goals = ref.watch(goalsControllerProvider);

  if (profile.isLoading || completions.isLoading || goals.isLoading) {
    return const AsyncLoading<Stats>();
  }
  if (profile.hasError) return AsyncError(profile.error!, profile.stackTrace!);
  if (completions.hasError) {
    return AsyncError(completions.error!, completions.stackTrace!);
  }
  if (goals.hasError) {
    return AsyncError(goals.error!, goals.stackTrace!);
  }

  final p = profile.requireValue;
  final c = completions.requireValue;
  final goalList = goals.requireValue;
  final goalIdToCategory = <String, String>{};
  for (final g in goalList) {
    goalIdToCategory[g.id] = g.category.name;
  }

  final byCategory = <String, int>{};
  for (final comp in c) {
    final cat = goalIdToCategory[comp.goalId] ?? 'general';
    byCategory[cat] = (byCategory[cat] ?? 0) + 1;
  }

  final today = dateOnly(DateTime.now());
  final completedTodayCount = c.where((x) => isSameDay(x.date, today)).length;

  final isPremium = p.isPremiumEffective;
  int? weeklyXpTotal;
  String? mostProductiveCategoryName;
  List<int>? last30DaysCompletionCounts;

  if (isPremium) {
    final weekAgo = today.subtract(const Duration(days: 7));
    weeklyXpTotal = 0;
    for (final comp in c) {
      final d = dateOnly(comp.date);
      if (!d.isBefore(weekAgo)) weeklyXpTotal = weeklyXpTotal! + comp.earnedXp;
    }
    if (byCategory.isNotEmpty) {
      mostProductiveCategoryName = byCategory.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }
    final start30 = today.subtract(const Duration(days: 30));
    last30DaysCompletionCounts = List.generate(30, (i) {
      final day = start30.add(Duration(days: i));
      return c.where((x) => isSameDay(dateOnly(x.date), day)).length;
    });
  }

  return AsyncData(
    Stats(
      totalXp: p.totalXp,
      totalGoalsCompleted: c.length,
      currentStreak: p.streak,
      completedTodayCount: completedTodayCount,
      completionsByCategory: byCategory,
      weeklyXpTotal: weeklyXpTotal,
      mostProductiveCategoryName: mostProductiveCategoryName,
      last30DaysCompletionCounts: last30DaysCompletionCounts,
    ),
  );
});

// Router
final goRouterProvider = Provider<GoRouter>((ref) {
  final isAuth = ref.watch(isAuthenticatedProvider);
  final hasConfig = SupabaseConfig.isConfigured;

  return GoRouter(
    initialLocation: hasConfig ? '/login' : '/dashboard',
    redirect: (context, state) {
      final path = state.matchedLocation;
      final onAuthScreen = path == '/login' || path == '/register';
      if (!hasConfig) {
        return null; // no redirect when Supabase not configured
      }
      if (isAuth && onAuthScreen) return '/dashboard';
      if (!isAuth && !onAuthScreen) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) => const StatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/goals/create',
        builder: (context, state) => const GoalCreatePage(),
      ),
      GoRoute(
        path: PremiumPage.routePath,
        builder: (context, state) => const PremiumPage(),
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const ChallengeListPage(),
      ),
      GoRoute(
        path: '/challenges/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return ChallengeDetailPage(challengeId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
  );
});

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Something went wrong')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error?.toString() ?? 'Unknown routing error'),
      ),
    );
  }
}
