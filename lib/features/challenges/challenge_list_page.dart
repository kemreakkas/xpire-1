import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../data/models/challenge.dart';
import '../../features/premium/premium_controller.dart';
import '../../state/providers.dart';

class ChallengeListPage extends ConsumerWidget {
  const ChallengeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final challenges = content.getChallenges();
    final isPremium = ref.watch(PremiumController.isPremiumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.grid),
        children: [
          Text(
            'Build habits with structured challenges. Complete all goals to earn bonus XP.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...challenges.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _ChallengeCard(
                challenge: c,
                isLocked: c.isPremium && !isPremium,
                onTap: () => context.push('/challenges/${c.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.isLocked,
    required this.onTap,
  });

  final Challenge challenge;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          challenge.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.lock_outline,
                              size: 18, color: Theme.of(context).colorScheme.outline),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${challenge.durationDays} days · ${challenge.bonusXp} bonus XP',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isLocked
                    ? Theme.of(context).colorScheme.outline
                    : AppTheme.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

