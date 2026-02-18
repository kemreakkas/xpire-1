import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/supabase_config.dart';
import '../../core/services/xp_service.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/nav_helpers.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../core/utils/date_key.dart';
import '../../core/utils/date_only.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_complete_result.dart';
import '../../data/models/goal_completion.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/challenge_progress.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

bool _hasActiveFromModel(ChallengeProgress? p) =>
    p != null && !p.isCompleted && p.failedAt == null;

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAv = ref.watch(profileControllerProvider);
    final goalsAv = ref.watch(goalsControllerProvider);
    final completionsAv = ref.watch(completionsControllerProvider);
    final xpService = ref.watch(xpServiceProvider);

    if (profileAv.isLoading || goalsAv.isLoading) {
      return const Center(child: _Loading());
    }
    if (profileAv.hasError) {
      return Center(child: _Error(error: profileAv.error.toString()));
    }
    if (goalsAv.hasError) {
      return Center(child: _Error(error: goalsAv.error.toString()));
    }

    final profile = profileAv.requireValue;
    final goals = goalsAv.requireValue;

    final l10n = AppLocalizations.of(context)!;
    final isWebWide = Responsive.isWebWide(context);
    final content = _DashboardContent(
      profile: profile,
      goals: goals.where((g) => g.isActive).toList(growable: false),
      xpService: xpService,
      completionsAv: completionsAv,
      l10n: l10n,
    );
    if (isWebWide) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: content,
      );
    }
    return ResponsiveCenter(
      padding: const EdgeInsets.all(AppSpacing.grid),
      maxWidth: 820,
      child: content,
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent({
    required this.profile,
    required this.goals,
    required this.xpService,
    required this.completionsAv,
    required this.l10n,
  });

  final UserProfile profile;
  final List<Goal> goals;
  final XpService xpService;
  final AsyncValue<List<GoalCompletion>> completionsAv;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requiredXp = xpService.requiredXpForLevel(profile.level);
    final progress = requiredXp == 0 ? 0.0 : profile.currentXp / requiredXp;

    final today = dateOnly(DateTime.now());
    final todayKey = yyyymmdd(today);

    final completedTodayIds = completionsAv.maybeWhen(
      data: (list) {
        final ids = <String>{};
        for (final c in list) {
          if (yyyymmdd(c.date) == todayKey) {
            ids.add(c.goalId);
          }
        }
        return ids;
      },
      orElse: () => <String>{},
    );

    final isWebWide = Responsive.isWebWide(context);
    final spacing = isWebWide ? AppSpacing.lg : AppSpacing.md;

    Widget levelCard = Card(
      child: Padding(
        padding: EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  l10n.levelLabel(profile.level),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  '${profile.currentXp} / $requiredXp XP',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(value: progress.clamp(0, 1)),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _StatPill(
                  label: l10n.streak,
                  value: '${profile.streak}d',
                  icon: Icons.local_fire_department_outlined,
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatPill(
                  label: l10n.totalXp,
                  value: '${profile.totalXp}',
                  icon: Icons.auto_awesome_outlined,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isWebWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  levelCard,
                  SizedBox(height: spacing),
                  _ActiveChallengeSection(),
                ],
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RecommendedChallengesSection(),
                      SizedBox(height: spacing),
                      _RecommendedGoalsSection(),
                      SizedBox(height: spacing),
                      _StartChallengeCta(),
                      SizedBox(height: spacing),
                      Text(
                        l10n.activeGoals,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
                Expanded(
                  child: goals.isEmpty
                      ? const _EmptyGoals()
                      : ListView.separated(
                          itemCount: goals.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final goal = goals[index];
                            final doneToday = completedTodayIds.contains(
                              goal.id,
                            );
                            return _GoalCard(goal: goal, doneToday: doneToday);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        levelCard,
        SizedBox(height: spacing),
        _ActiveChallengeSection(),
        SizedBox(height: spacing),
        _RecommendedChallengesSection(),
        SizedBox(height: spacing),
        _RecommendedGoalsSection(),
        SizedBox(height: spacing),
        _StartChallengeCta(),
        SizedBox(height: spacing),
        Text(l10n.activeGoals, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: goals.isEmpty
              ? const _EmptyGoals()
              : ListView.separated(
                  itemCount: goals.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final goal = goals[index];
                    final doneToday = completedTodayIds.contains(goal.id);
                    return _GoalCard(goal: goal, doneToday: doneToday);
                  },
                ),
        ),
      ],
    );
  }
}

class _ActiveChallengeSection extends ConsumerWidget {
  const _ActiveChallengeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (SupabaseConfig.isConfigured) {
      final progressAv = ref.watch(activeChallengeProgressModelProvider);
      return progressAv.when(
        data: (progress) {
          if (progress == null ||
              progress.isCompleted ||
              progress.failedAt != null) {
            return const SizedBox.shrink();
          }
          final challenge = ref
              .read(contentRepositoryProvider)
              .getChallengeById(progress.challengeId);
          if (challenge == null) return const SizedBox.shrink();
          final daysRemaining = challenge.durationDays - progress.currentDay;
          final progressFraction = challenge.durationDays == 0
              ? 0.0
              : (progress.completedDays / challenge.durationDays).clamp(
                  0.0,
                  1.0,
                );
          return Card(
            child: InkWell(
              onTap: () =>
                  goOrPush(context, '/challenges/${progress.challengeId}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 20,
                          color: AppTheme.accent,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            challenge.title,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          l10n.dayProgress(
                            progress.currentDay,
                            challenge.durationDays,
                          ),
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(value: progressFraction),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          l10n.daysCompleted(progress.completedDays),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          l10n.daysLeft(daysRemaining > 0 ? daysRemaining : 0),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          l10n.bonusXp(challenge.bonusXp),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      );
    }
    final progress = ref.watch(activeChallengeProgressProvider);
    if (progress == null || progress.completed) return const SizedBox.shrink();
    final daysRemaining =
        progress.challenge.durationDays - progress.completionsCount;
    return Card(
      child: InkWell(
        onTap: () => goOrPush(context, '/challenges/${progress.challenge.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 20,
                    color: AppTheme.accent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      progress.challenge.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    l10n.dayProgress(
                      progress.completionsCount,
                      progress.challenge.durationDays,
                    ),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: progress.progress),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    l10n.daysLeft(daysRemaining),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    l10n.bonusXp(progress.challenge.bonusXp),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendedChallengesSection extends ConsumerWidget {
  const _RecommendedChallengesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final modelValue = ref
        .watch(activeChallengeProgressModelProvider)
        .maybeWhen(data: (d) => d, orElse: () => null);
    final progress = ref.watch(activeChallengeProgressProvider);
    final hasActive = SupabaseConfig.isConfigured
        ? _hasActiveFromModel(modelValue)
        : (progress != null && !progress.completed);
    if (hasActive) return const SizedBox.shrink();
    final content = ref.watch(contentRepositoryProvider);
    final challenges = content
        .getChallenges()
        .where((c) => !c.isPremium)
        .take(3)
        .toList();
    if (challenges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recommendedChallenges,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: challenges.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final ch = challenges[index];
              return ActionChip(
                avatar: Icon(
                  Icons.emoji_events_outlined,
                  size: 18,
                  color: AppTheme.accent,
                ),
                label: Text(
                  '${ch.title} · +${ch.bonusXp} XP',
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => goOrPush(context, '/challenges/${ch.id}'),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendedGoalsSection extends ConsumerWidget {
  const _RecommendedGoalsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final content = ref.watch(contentRepositoryProvider);
    final templates = content
        .getTemplates()
        .where((t) => !t.isPremium)
        .take(6)
        .toList();
    if (templates.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recommendedGoals,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final t = templates[index];
              return ActionChip(
                label: Text(t.title, overflow: TextOverflow.ellipsis),
                onPressed: () {
                  ref.read(pendingTemplateIdProvider.notifier).set(t.id);
                  goOrPush(context, '/goals/create');
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StartChallengeCta extends StatelessWidget {
  const _StartChallengeCta();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return OutlinedButton.icon(
      onPressed: () => goOrPush(context, '/challenges'),
      icon: const Icon(Icons.emoji_events_outlined, size: 20),
      label: Text(l10n.startChallenge),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal, required this.doneToday});

  final Goal goal;
  final bool doneToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(text: _categoryLabel(l10n, goal.category)),
                      _Chip(text: _difficultyLabel(l10n, goal.difficulty)),
                      _Chip(text: '${goal.baseXp} XP'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton(
              onPressed: doneToday
                  ? null
                  : () async {
                      final result = await ref
                          .read(goalActionsControllerProvider.notifier)
                          .completeGoal(goalId: goal.id);
                      if (!context.mounted) return;
                      final msg = switch (result.status) {
                        GoalCompleteStatus.success =>
                          result.leveledUp
                              ? l10n.xpEarnedLevelUp(
                                  result.earnedXp,
                                  result.newLevel,
                                )
                              : l10n.xpEarned(result.earnedXp),
                        GoalCompleteStatus.alreadyCompleted =>
                          l10n.todayAlreadyCompleted,
                        GoalCompleteStatus.goalNotFound => l10n.goalNotFound,
                      };
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(msg)));
                    },
              child: Text(doneToday ? l10n.done : l10n.complete),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text('$label: ', style: Theme.of(context).textTheme.labelLarge),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(
        l10n.noActiveGoals,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(error));
  }
}

String _categoryLabel(AppLocalizations l10n, GoalCategory c) {
  return switch (c) {
    GoalCategory.fitness => l10n.fitness,
    GoalCategory.study => l10n.study,
    GoalCategory.work => l10n.work,
    GoalCategory.focus => l10n.focus,
    GoalCategory.mind => l10n.mind,
    GoalCategory.health => l10n.health,
    GoalCategory.finance => l10n.finance,
    GoalCategory.selfGrowth => l10n.selfGrowth,
    GoalCategory.general => l10n.general,
    GoalCategory.digitalDetox => l10n.digitalDetox,
    GoalCategory.social => l10n.social,
    GoalCategory.creativity => l10n.creativity,
    GoalCategory.discipline => l10n.discipline,
  };
}

String _difficultyLabel(AppLocalizations l10n, GoalDifficulty d) {
  return switch (d) {
    GoalDifficulty.easy => l10n.easy,
    GoalDifficulty.medium => l10n.medium,
    GoalDifficulty.hard => l10n.hard,
  };
}
