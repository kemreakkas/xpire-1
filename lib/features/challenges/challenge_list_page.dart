import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../data/models/challenge.dart';
import '../../features/premium/premium_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

class ChallengeListPage extends ConsumerWidget {
  const ChallengeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final content = ref.watch(contentRepositoryProvider);
    final challenges = content.getChallenges();
    final isPremium = ref.watch(PremiumController.isPremiumProvider);

    final isWebWide = Responsive.isWebWide(context);
    final padding = isWebWide ? 24.0 : AppSpacing.grid;

    if (isWebWide) {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Text(
                l10n.challengesIntro,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 360,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final c = challenges[index];
                return _ChallengeCard(
                  challenge: c,
                  isLocked: c.isPremium && !isPremium,
                  l10n: l10n,
                  onTap: () => context.push('/challenges/${c.id}'),
                );
              }, childCount: challenges.length),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.grid),
      children: [
        Text(
          l10n.challengesIntro,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        ...challenges.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _ChallengeCard(
              challenge: c,
              isLocked: c.isPremium && !isPremium,
              l10n: l10n,
              onTap: () => context.push('/challenges/${c.id}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.isLocked,
    required this.l10n,
    required this.onTap,
  });

  final Challenge challenge;
  final bool isLocked;
  final AppLocalizations l10n;
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
                          Icon(
                            Icons.lock_outline,
                            size: 18,
                            color: Theme.of(context).colorScheme.outline,
                          ),
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
                      l10n.daysBonusXp(
                        challenge.durationDays,
                        challenge.bonusXp,
                      ),
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
