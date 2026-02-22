import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../data/models/weekly_leaderboard_entry.dart';
import '../../features/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

/// Global leaderboard page at /leaderboard.
/// Section 1: All-time top 10 by total XP.
/// Section 2: This week's top 10 by XP earned this week.
class LeaderboardPage extends ConsumerWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final allTimeAsync = ref.watch(weeklyLeaderboardProvider);
    final weeklyAsync = ref.watch(thisWeekLeaderboardProvider);
    final currentUserId = ref.watch(authUserIdProvider);
    final isWebWide = Responsive.isWebWide(context);

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weeklyLeaderboardProvider);
          ref.invalidate(thisWeekLeaderboardProvider);
          await Future.wait([
            ref.read(weeklyLeaderboardProvider.future),
            ref.read(thisWeekLeaderboardProvider.future),
          ]);
        },
        color: AppTheme.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(isWebWide ? 24 : AppSpacing.grid),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Section 1: All-Time Top 10 ──
                  _SectionHeader(
                    icon: Icons.emoji_events_rounded,
                    iconColor: AppTheme.streakGold,
                    title: l10n.leaderboard,
                    subtitle: 'Tüm Zamanlar – En Yüksek XP',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  allTimeAsync.when(
                    loading: () => const _LoadingShimmer(),
                    error: (_, __) => _ErrorCard(l10n: l10n),
                    data: (list) {
                      if (list.isEmpty) return _EmptyCard(l10n: l10n);
                      return _LeaderboardList(
                        entries: list,
                        currentUserId: currentUserId,
                        showWeeklyXp: false,
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── Section 2: This Week's Top 10 ──
                  _SectionHeader(
                    icon: Icons.trending_up_rounded,
                    iconColor: AppTheme.successGreen,
                    title: 'Bu Hafta',
                    subtitle: 'Bu Hafta En Çok XP Kazanan',
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  weeklyAsync.when(
                    loading: () => const _LoadingShimmer(),
                    error: (_, __) => _ErrorCard(l10n: l10n),
                    data: (list) {
                      if (list.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.hoverBackground),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.hourglass_empty_rounded,
                                size: 32,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Bu hafta henüz XP kazanılmamış',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }
                      return _LeaderboardList(
                        entries: list,
                        currentUserId: currentUserId,
                        showWeeklyXp: true,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Section header with icon
// ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────
// Leaderboard list (shared between both sections)
// ──────────────────────────────────────────────────
class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({
    required this.entries,
    required this.currentUserId,
    required this.showWeeklyXp,
  });

  final List<WeeklyLeaderboardEntry> entries;
  final String? currentUserId;
  final bool showWeeklyXp;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.hoverBackground, width: 1),
      ),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: AppTheme.hoverBackground, thickness: 1),
            _LeaderboardRow(
              entry: entries[i],
              isCurrentUser: currentUserId == entries[i].userId,
              showWeeklyXp: showWeeklyXp,
            ),
          ],
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Single leaderboard row
// ──────────────────────────────────────────────────
class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    required this.showWeeklyXp,
  });

  final WeeklyLeaderboardEntry entry;
  final bool isCurrentUser;
  final bool showWeeklyXp;

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
                    color: AppTheme.streakGold,
                  )
                : isTop3
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rankColor(entry.rank).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _rankColor(entry.rank).withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${entry.rank}',
                      style: theme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _rankColor(entry.rank),
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
                Row(
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.totalXp} XP',
                style: theme.labelMedium?.copyWith(
                  color: isTop3 ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: isTop3 ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (showWeeklyXp)
                Text(
                  'bu hafta',
                  style: theme.labelSmall?.copyWith(
                    color: AppTheme.successGreen,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.streakGold;
      case 2:
        return AppTheme.textSecondary;
      case 3:
        return const Color(0xFFB45309);
      default:
        return AppTheme.textSecondary;
    }
  }
}

// ──────────────────────────────────────────────────
// Loading / Error / Empty helpers
// ──────────────────────────────────────────────────
class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.hoverBackground),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.hoverBackground),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            l10n.somethingWentWrong,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.hoverBackground),
      ),
      child: Center(
        child: Text(
          l10n.noLeaderboardYet,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
