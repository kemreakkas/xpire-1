import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_config.dart';
import '../../core/services/analytics_service.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../data/content/content_repository.dart';
import '../../data/models/active_challenge.dart';
import '../../data/models/challenge.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_template.dart';
import '../../features/auth/auth_controller.dart';
import '../../state/providers.dart';

class ChallengeDetailPage extends ConsumerWidget {
  const ChallengeDetailPage({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final challenge = content.getChallengeById(challengeId);
    final progressRepo = ref.watch(challengeProgressRepositoryProvider);
    final active = progressRepo.getCurrent();
    final progressState = ref.watch(activeChallengeProgressProvider);
    final progressModelAv = ref.watch(activeChallengeProgressModelProvider);
    final progressModel = progressModelAv.maybeWhen(data: (d) => d, orElse: () => null);
    final isActiveSupabase = SupabaseConfig.isConfigured &&
        progressModel != null &&
        progressModel.challengeId == challengeId &&
        !progressModel.isCompleted &&
        progressModel.failedAt == null;
    final isActive = SupabaseConfig.isConfigured ? isActiveSupabase : (active?.challengeId == challengeId);
    final isCompleted = SupabaseConfig.isConfigured
        ? (progressModel != null && progressModel.challengeId == challengeId && progressModel.isCompleted)
        : (progressState?.completed ?? false);

    if (challenge == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Challenge')),
        body: const Center(child: Text('Challenge not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(challenge.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.grid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _Chip(label: '${challenge.durationDays} days'),
                        const SizedBox(width: AppSpacing.sm),
                        _Chip(label: '${challenge.bonusXp} bonus XP'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Goals in this challenge',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            _GoalListFromTemplates(
              content: content,
              templateIds: challenge.templateGoalIds,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (isActive && isCompleted)
              SupabaseConfig.isConfigured
                  ? Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Challenge completed!',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '+${challenge.bonusXp} XP was added when you finished.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : _ClaimBonusSection(
                      challenge: challenge,
                      onClaim: () => _claimBonus(context, ref, challenge),
                    )
            else if (isActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (progressState != null) ...[
                    Text(
                      'Progress: ${(progressState.progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(value: progressState.progress),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'You are doing this challenge',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else
              FilledButton(
                onPressed: () => _startChallenge(context, ref, challenge, content),
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Start challenge'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChallenge(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
    ContentRepository content,
  ) async {
    if (SupabaseConfig.isConfigured) {
      final uid = ref.read(authUserIdProvider);
      if (uid == null) return;
      final engine = ref.read(challengeEngineProvider);
      final progress = await engine.startChallenge(userId: uid, challenge: challenge);
      if (progress == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already have an active challenge.')),
        );
        return;
      }
      ref.invalidate(activeChallengeProgressModelProvider);
      ref.invalidate(goalsControllerProvider);
      ref.invalidate(profileControllerProvider);
      ref.read(analyticsServiceProvider).track(
            AnalyticsEvents.challengeStarted,
            {'challenge_id': challenge.id, 'duration_days': challenge.durationDays},
          );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${challenge.title} started! Complete 1 goal per day to earn ${challenge.bonusXp} bonus XP.')),
      );
      context.pop();
      context.push('/dashboard');
      return;
    }

    final templates = <GoalTemplate>[];
    for (final id in challenge.templateGoalIds) {
      final t = content.getTemplateById(id);
      if (t != null) templates.add(t);
    }
    if (templates.isEmpty) return;

    final now = DateTime.now();
    final goals = <Goal>[];
    final goalIds = <String>[];

    for (final t in templates) {
      final goalId = const Uuid().v4();
      goalIds.add(goalId);
      goals.add(Goal(
        id: goalId,
        title: t.title,
        category: t.category,
        difficulty: t.difficulty,
        baseXp: t.baseXp,
        isActive: true,
        createdAt: now,
      ));
    }

    await ref.read(goalsControllerProvider.notifier).addGoals(goals);
    await ref
        .read(challengeProgressRepositoryProvider)
        .setCurrent(ActiveChallenge(
          challengeId: challenge.id,
          startedAt: now,
          goalIds: goalIds,
        ));
    ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.challengeStarted,
          {'challenge_id': challenge.id, 'duration_days': challenge.durationDays},
        );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${challenge.title} started! Complete goals to earn ${challenge.bonusXp} bonus XP.')),
    );
    context.pop();
    context.push('/dashboard');
  }

  Future<void> _claimBonus(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile =
        profileRepo.readSync() ?? await profileRepo.loadOrCreate();
    final xpService = ref.read(xpServiceProvider);
    final updated = xpService.grantBonusXp(profile, challenge.bonusXp);
    await profileRepo.save(updated);
    await ref.read(challengeProgressRepositoryProvider).clear();
    ref.read(analyticsServiceProvider).track(
          AnalyticsEvents.challengeCompleted,
          {'challenge_id': challenge.id, 'bonus_xp': challenge.bonusXp},
        );
    ref.invalidate(profileControllerProvider);
    ref.invalidate(activeChallengeProgressProvider);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('+${challenge.bonusXp} bonus XP claimed!')),
    );
    context.pop();
    context.push('/dashboard');
  }
}

class _GoalListFromTemplates extends StatelessWidget {
  const _GoalListFromTemplates({
    required this.content,
    required this.templateIds,
  });

  final ContentRepository content;
  final List<String> templateIds;

  @override
  Widget build(BuildContext context) {
    final items = <GoalTemplate>[];
    for (final id in templateIds) {
      final t = content.getTemplateById(id);
      if (t != null) items.add(t);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items
              .map(
                (t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 18, color: Theme.of(context).colorScheme.outline),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          t.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Text(
                        '${t.baseXp} XP',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _ClaimBonusSection extends StatelessWidget {
  const _ClaimBonusSection({
    required this.challenge,
    required this.onClaim,
  });

  final Challenge challenge;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Challenge complete!',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Claim ${challenge.bonusXp} bonus XP',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onClaim,
              style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Claim bonus'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
