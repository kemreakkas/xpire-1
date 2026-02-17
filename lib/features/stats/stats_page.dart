import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../data/models/stats.dart';
import '../../features/premium/premium_controller.dart';
import '../../features/premium/premium_page.dart';
import '../../state/providers.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAv = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.grid),
        child: statsAv.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (stats) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total XP',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalXp}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Goals completed',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.totalGoalsCompleted}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current streak',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.currentStreak} days',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completed today',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${stats.completedTodayCount}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _ActiveChallengeIndicator(),
                const SizedBox(height: AppSpacing.sm),
                _CompletedChallengesCard(),
                const SizedBox(height: AppSpacing.sm),
                _CompletionsByCategorySection(
                  byCategory: stats.completionsByCategory,
                ),
                const SizedBox(height: AppSpacing.sm),
                _AdvancedStatsSection(stats: stats),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActiveChallengeIndicator extends ConsumerWidget {
  const _ActiveChallengeIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                          'Active challenge',
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
                    'Day ${progress.currentDay}/${challenge.durationDays}',
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
                'Challenges completed',
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

String _categoryDisplayName(String name) {
  if (name == 'selfGrowth') return 'Self Growth';
  return name.isEmpty
      ? 'General'
      : '${name[0].toUpperCase()}${name.substring(1)}';
}

class _CompletionsByCategorySection extends StatelessWidget {
  const _CompletionsByCategorySection({required this.byCategory});

  final Map<String, int> byCategory;

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
              'Completions by category',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...entries.map(
              (e) => _StatRow(
                label: _categoryDisplayName(e.key),
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
  const _AdvancedStatsSection({required this.stats});

  final Stats stats;

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
                'Advanced stats',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: 'Weekly XP',
                value: '${stats.weeklyXpTotal ?? 0}',
              ),
              _StatRow(
                label: 'Most productive category',
                value: stats.mostProductiveCategoryName != null
                    ? _categoryDisplayName(stats.mostProductiveCategoryName!)
                    : '—',
              ),
              if (stats.last30DaysCompletionCounts != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Last 30 days',
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
              'Premium Feature',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Weekly average, most productive category, 30-day trend',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(
              onPressed: () => context.push(PremiumPage.routePath),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
              child: const Text('Upgrade'),
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
