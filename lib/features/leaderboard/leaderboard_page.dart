import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../data/models/weekly_leaderboard_entry.dart';
import '../../features/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

/// Weekly global leaderboard page at /leaderboard. Top 20, premium dark, minimal.
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final async = ref.watch(weeklyLeaderboardProvider);
    final currentUserId = ref.watch(authUserIdProvider);
    final isWebWide = Responsive.isWebWide(context);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: async.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.somethingWentWrong,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  l10n.noLeaderboardYet,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWebWide ? 24 : AppSpacing.grid),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.leaderboard,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Tüm Zamanlar – En Yüksek XP',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.hoverBackground,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < list.length; i++) ...[
                            if (i > 0)
                              Divider(
                                height: 1,
                                color: AppTheme.hoverBackground,
                                thickness: 1,
                              ),
                            _WeeklyLeaderboardRow(
                              entry: list[i],
                              isCurrentUser: currentUserId == list[i].userId,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyLeaderboardRow extends StatelessWidget {
  const _WeeklyLeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
  });

  final WeeklyLeaderboardEntry entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isTop3 = entry.rank <= 3;
    final isFirst = entry.rank == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isFirst
                ? Icon(
                    Icons.workspace_premium,
                    size: 20,
                    color: const Color(0xFFEAB308),
                  )
                : isTop3
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rankHighlightColor(
                        entry.rank,
                      ).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rankHighlightColor(
                          entry.rank,
                        ).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${entry.rank}',
                      style: theme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _rankHighlightColor(entry.rank),
                      ),
                    ),
                  )
                : Text(
                    '${entry.rank}',
                    style: theme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.username,
                  style: theme.bodyMedium?.copyWith(
                    color: isCurrentUser
                        ? AppTheme.accent
                        : AppTheme.textPrimary,
                    fontWeight: isCurrentUser ? FontWeight.w600 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Sev. ${entry.level} • ${entry.streak} gün seri',
                  style: theme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.totalXp} XP',
            style: theme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: isTop3 ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  static Color _rankHighlightColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFEAB308);
      case 2:
        return const Color(0xFF94A3B8);
      case 3:
        return const Color(0xFFB45309);
      default:
        return AppTheme.textSecondary;
    }
  }
}
