import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../data/models/stats.dart';
import '../../features/premium/premium_controller.dart';
import '../../features/premium/premium_page.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statsAv = ref.watch(statsProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.grid),
      child: statsAv.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (stats) {
            final isDesktop = Responsive.isDesktop(context);
            final pad = isDesktop ? 24.0 : AppSpacing.md;
            Widget card(String label, String value) => Card(
                  child: Padding(
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                );
            final topCards = [
              card(l10n.totalXp, '${stats.totalXp}'),
              card(l10n.goalsCompleted, '${stats.totalGoalsCompleted}'),
              card(l10n.currentStreak, '${stats.currentStreak} ${l10n.daysSuffix}'),
              card(l10n.completedToday, '${stats.completedTodayCount}'),
            ];
            if (isDesktop) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  topCards[0],
                                  const SizedBox(height: AppSpacing.sm),
                                  topCards[1],
                                  const SizedBox(height: AppSpacing.lg),
                                  _ActiveChallengeIndicator(),
                                  const SizedBox(height: AppSpacing.sm),
                                  _CompletedChallengesCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                children: [
                                  topCards[2],
                                  const SizedBox(height: AppSpacing.sm),
                                  topCards[3],
                                  const SizedBox(height: AppSpacing.lg),
                                  _CompletionsByCategorySection(
                                    byCategory: stats.completionsByCategory,
                                    l10n: l10n,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  _AdvancedStatsSection(stats: stats, l10n: l10n),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...topCards.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: c,
                    )),
                _ActiveChallengeIndicator(),
                const SizedBox(height: AppSpacing.sm),
                _CompletedChallengesCard(),
                const SizedBox(height: AppSpacing.sm),
                _CompletionsByCategorySection(
                  byCategory: stats.completionsByCategory,
                  l10n: l10n,
                ),
                const SizedBox(height: AppSpacing.sm),
                _AdvancedStatsSection(stats: stats, l10n: l10n),
              ],
            );
          },
        ),
    );
  }
}

class _ActiveChallengeIndicator extends ConsumerWidget {
  const _ActiveChallengeIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) return const SizedBox.shrink();
    final progressAv = ref.watch(activeChallengeProgressModelProvider);
    return progressAv.when(
      data: (progress) {
        if (progress == null || progress.isCompleted || progress.failedAt != null) {
          return const SizedBox.shrink();
        }
        final content = ref.read(contentRepositoryProvider);
        final challenge = content.getChallengeById(progress.challengeId);
        if (challenge == null) return const SizedBox.shrink();
        return Card(
          child: InkWell(
            onTap: () => context.push('/challenges/${progress.challengeId}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_outlined, color: AppTheme.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.activeChallenge,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.dayProgress(progress.currentDay, challenge.durationDays),
                    style: Theme.of(context).textTheme.labelLarge,
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
}

class _CompletedChallengesCard extends ConsumerWidget {
  const _CompletedChallengesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) return const SizedBox.shrink();
    final countAv = ref.watch(completedChallengesCountProvider);
    return countAv.when(
      data: (count) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.challengesCompleted,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

String _categoryDisplayName(AppLocalizations l10n, String name) {
  return switch (name.toLowerCase()) {
    'fitness' => l10n.fitness,
    'study' => l10n.study,
    'work' => l10n.work,
    'focus' => l10n.focus,
    'mind' => l10n.mind,
    'health' => l10n.health,
    'finance' => l10n.finance,
    'selfgrowth' => l10n.selfGrowth,
    'general' => l10n.general,
    _ => name.isEmpty ? l10n.general : '${name[0].toUpperCase()}${name.substring(1)}',
  };
}

class _CompletionsByCategorySection extends StatelessWidget {
  const _CompletionsByCategorySection({
    required this.byCategory,
    required this.l10n,
  });

  final Map<String, int> byCategory;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (byCategory.isEmpty) return const SizedBox.shrink();
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.completionsByCategory,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...entries.map(
              (e) => _StatRow(
                label: _categoryDisplayName(l10n, e.key),
                value: '${e.value}',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdvancedStatsSection extends ConsumerWidget {
  const _AdvancedStatsSection({required this.stats, required this.l10n});

  final Stats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUse = ref.watch(PremiumController.canUseAdvancedStatsProvider);

    if (canUse) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.advancedStats,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: l10n.weeklyXp,
                value: '${stats.weeklyXpTotal ?? 0}',
              ),
              _StatRow(
                label: l10n.mostProductiveCategory,
                value: stats.mostProductiveCategoryName != null
                    ? _categoryDisplayName(l10n, stats.mostProductiveCategoryName!)
                    : '—',
              ),
              if (stats.last30DaysCompletionCounts != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.last30Days,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 60,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                      stats.last30DaysCompletionCounts!.length,
                      (i) {
                        final counts = stats.last30DaysCompletionCounts!;
                        final maxVal = counts.isEmpty
                            ? 1
                            : counts.reduce((a, b) => a > b ? a : b);
                        final h = maxVal <= 0
                            ? 4.0
                            : 4.0 + 56.0 * (counts[i] / maxVal);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            height: h,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.premiumFeature,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.advancedStatsDesc,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () => context.push(PremiumPage.routePath),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
              child: Text(l10n.upgrade),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
