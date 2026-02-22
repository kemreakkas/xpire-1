import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../data/models/challenge_leaderboard_entry.dart';
import '../../features/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

/// Challenge leaderboard: top 10 + current user rank. Premium dark, thin separators, subtle glow top 3.
class ChallengeLeaderboardSection extends ConsumerWidget {
  const ChallengeLeaderboardSection({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentUserId = ref.watch(authUserIdProvider);
    final async = ref.watch(challengeLeaderboardProvider(challengeId));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          l10n.somethingWentWrong,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ),
      data: (data) {
        if (data.top10.isEmpty && data.currentUserEntry == null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              l10n.noLeaderboardYet,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.challengeLeaderboard,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.hoverBackground, width: 1),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < data.top10.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        color: AppTheme.hoverBackground,
                        thickness: 1,
                      ),
                    _ChallengeLeaderboardRow(
                      entry: data.top10[i],
                      isCurrentUser: currentUserId == data.top10[i].userId,
                    ),
                  ],
                ],
              ),
            ),
            if (data.currentUserEntry != null &&
                !data.top10.any(
                  (e) => e.userId == data.currentUserEntry!.userId,
                )) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.yourRank,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.hoverBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: _ChallengeLeaderboardRow(
                  entry: data.currentUserEntry!,
                  isCurrentUser: true,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ChallengeLeaderboardRow extends StatelessWidget {
  const _ChallengeLeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
  });

  final ChallengeLeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isTop3 = entry.position <= 3;
    final glowColor = entry.position == 1
        ? const Color(0xFFEAB308)
        : entry.position == 2
        ? const Color(0xFF94A3B8)
        : const Color(0xFFB45309);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: isTop3
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: glowColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: glowColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${entry.position}',
                      style: theme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: glowColor,
                      ),
                    ),
                  )
                : Text(
                    '${entry.position}',
                    style: theme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    entry.username,
                    style: theme.bodyMedium?.copyWith(
                      color: isCurrentUser
                          ? AppTheme.accent
                          : AppTheme.textPrimary,
                      fontWeight: isCurrentUser ? FontWeight.w600 : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (entry.isPremium) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.workspace_premium,
                    size: 14,
                    color: Color(0xFFEAB308),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${entry.completedDays}',
            style: theme.labelMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
