import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_controller.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/gamification.dart';
import '../../core/ui/responsive.dart';
import '../../data/models/challenge_participant.dart';
import '../../data/models/community_challenge.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

const double _webSectionSpacing = 24;
const double _maxContentWidth = 1100;

class ChallengeListPage extends ConsumerStatefulWidget {
  const ChallengeListPage({super.key});

  @override
  ConsumerState<ChallengeListPage> createState() => _ChallengeListPageState();
}

class _ChallengeListPageState extends ConsumerState<ChallengeListPage> {
  final GlobalKey _communitySectionKey = GlobalKey();

  void _scrollToCommunity() {
    final context = _communitySectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWebWide = Responsive.isWebWide(context);
    final padding = isWebWide ? _webSectionSpacing : AppSpacing.grid;

    // Supabase not configured check removed to allow offline usage.

    final myActiveAsync = ref.watch(myActiveChallengesWithDetailsProvider);
    final communityAsync = ref.watch(communityChallengesWithMetaProvider);
    final createdTodayAsync = ref.watch(challengesCreatedTodayCountProvider);
    final createdToday = createdTodayAsync.maybeWhen(
      data: (v) => v,
      orElse: () => 0,
    );

    // Check if user is premium to completely bypass and hide limit reached restrictions
    final isPremium = ref
        .watch(profileControllerProvider)
        .maybeWhen(data: (p) => p.isPremium, orElse: () => false);

    final createLimitReached =
        !isPremium && createdToday >= 50; // Use increased limit if not premium

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- Section 1: My Active Challenges ----------
                Text(
                  l10n.myActiveChallengesSection,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: isWebWide ? _webSectionSpacing : AppSpacing.md,
                ),
                myActiveAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => _SectionError(
                    message: l10n.challengesLoadError,
                    onRetry: () => ref.invalidate(myActiveParticipantsProvider),
                    l10n: l10n,
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return _ActiveEmptyState(
                        l10n: l10n,
                        onScrollToCommunity: _scrollToCommunity,
                      );
                    }
                    return _MyActiveSectionContent(
                      isWebWide: isWebWide,
                      items: list,
                      l10n: l10n,
                    );
                  },
                ),
                SizedBox(height: isWebWide ? 32 : AppSpacing.lg),

                // ---------- Section 2: Community Challenges ----------
                KeyedSubtree(
                  key: _communitySectionKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.communityChallengesSection,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Tooltip(
                            message: createLimitReached
                                ? l10n.dailyChallengeLimitReached
                                : l10n.createChallenge,
                            child: FilledButton.tonal(
                              onPressed: createLimitReached
                                  ? null
                                  : () => context.push('/challenges/create'),
                              child: Text(l10n.createChallenge),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: isWebWide ? _webSectionSpacing : AppSpacing.md,
                      ),
                      communityAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (err, _) => _SectionError(
                          message: l10n.challengesLoadError,
                          onRetry: () => ref.invalidate(
                            communityChallengesWithMetaProvider,
                          ),
                          l10n: l10n,
                        ),
                        data: (list) {
                          if (list.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                l10n.challengesEmpty,
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return _CommunitySectionContent(
                            isWebWide: isWebWide,
                            items: list,
                            l10n: l10n,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActiveEmptyState extends StatelessWidget {
  const _ActiveEmptyState({
    required this.l10n,
    required this.onScrollToCommunity,
  });

  final AppLocalizations l10n;
  final VoidCallback onScrollToCommunity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: 48,
              color: AppTheme.accent,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.challengesNoActiveTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.challengesNoActiveSubtitleShort,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onScrollToCommunity,
              icon: const Icon(Icons.group, size: 20),
              label: Text(l10n.scrollToTemplates),
            ),
          ],
        ),
      ),
    );
  }
}

class _MyActiveSectionContent extends StatelessWidget {
  const _MyActiveSectionContent({
    required this.isWebWide,
    required this.items,
    required this.l10n,
  });

  final bool isWebWide;
  final List<({ChallengeParticipant p, CommunityChallenge c})> items;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (isWebWide && items.length > 1) {
      const crossAxisCount = 2;
      final rows = <Widget>[];
      for (var i = 0; i < items.length; i += crossAxisCount) {
        final rowChildren = <Widget>[];
        for (var j = 0; j < crossAxisCount; j++) {
          final idx = i + j;
          if (idx < items.length) {
            rowChildren.add(
              Expanded(
                child: _MyActiveCard(item: items[idx], l10n: l10n),
              ),
            );
            if (j < crossAxisCount - 1) {
              rowChildren.add(SizedBox(width: _webSectionSpacing));
            }
          } else {
            rowChildren.add(const Expanded(child: SizedBox.shrink()));
            if (j < crossAxisCount - 1) {
              rowChildren.add(SizedBox(width: _webSectionSpacing));
            }
          }
        }
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        );
        if (i + crossAxisCount < items.length) {
          rows.add(SizedBox(height: _webSectionSpacing));
        }
      }
      return Column(children: rows);
    }
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _MyActiveCard(item: item, l10n: l10n),
            ),
          )
          .toList(),
    );
  }
}

class _MyActiveCard extends ConsumerWidget {
  const _MyActiveCard({required this.item, required this.l10n});

  final ({ChallengeParticipant p, CommunityChallenge c}) item;
  final AppLocalizations l10n;

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.quitChallenge),
        content: Text(l10n.quitChallengeConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final uid = ref.read(authUserIdProvider);
      if (uid == null) return;
      try {
        final repo = ref.read(supabaseChallengeParticipantsRepositoryProvider);
        await repo.leave(uid, item.c.id);
        ref.invalidate(myActiveParticipantsProvider);
        ref.invalidate(communityChallengesWithMetaProvider);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final progressFraction = item.c.durationDays > 0
        ? item.p.completedDays / item.c.durationDays
        : 0.0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium_outlined,
                  size: 24,
                  color: AppTheme.accent,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(item.c.title, style: theme.textTheme.titleMedium),
                ),
                InkWell(
                  onTap: () => _leave(context, ref),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.error.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.dayProgress(item.p.currentDay, item.c.durationDays),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(value: progressFraction),
            const SizedBox(height: 4),
            Text(
              l10n.bonusXp(item.c.rewardXp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunitySectionContent extends StatelessWidget {
  const _CommunitySectionContent({
    required this.isWebWide,
    required this.items,
    required this.l10n,
  });

  final bool isWebWide;
  final List<
    ({CommunityChallenge challenge, int participantCount, bool hasJoined})
  >
  items;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    const crossAxisCount = 3;
    if (isWebWide) {
      final rows = <Widget>[];
      for (var i = 0; i < items.length; i += crossAxisCount) {
        final rowChildren = <Widget>[];
        for (var j = 0; j < crossAxisCount; j++) {
          final idx = i + j;
          if (idx < items.length) {
            rowChildren.add(
              Expanded(
                child: _CommunityCard(item: items[idx], l10n: l10n),
              ),
            );
            if (j < crossAxisCount - 1) {
              rowChildren.add(SizedBox(width: _webSectionSpacing));
            }
          } else {
            rowChildren.add(const Expanded(child: SizedBox.shrink()));
            if (j < crossAxisCount - 1) {
              rowChildren.add(SizedBox(width: _webSectionSpacing));
            }
          }
        }
        rows.add(
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rowChildren,
          ),
        );
        if (i + crossAxisCount < items.length) {
          rows.add(SizedBox(height: _webSectionSpacing));
        }
      }
      return Column(children: rows);
    }
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CommunityCard(item: item, l10n: l10n),
            ),
          )
          .toList(),
    );
  }
}

class _CommunityCard extends ConsumerStatefulWidget {
  const _CommunityCard({required this.item, required this.l10n});

  final ({CommunityChallenge challenge, int participantCount, bool hasJoined})
  item;
  final AppLocalizations l10n;

  @override
  ConsumerState<_CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends ConsumerState<_CommunityCard> {
  bool _isJoining = false;

  Future<void> _join() async {
    if (widget.item.hasJoined || _isJoining) return;
    final uid = ref.read(authUserIdProvider);
    if (uid == null) return;
    setState(() => _isJoining = true);
    try {
      final repo = ref.read(supabaseChallengeParticipantsRepositoryProvider);
      await repo.join(uid, widget.item.challenge.id);
      ref.invalidate(myActiveParticipantsProvider);
      ref.invalidate(communityChallengesWithMetaProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.item.challenge.title}: ${widget.l10n.joined}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.l10n.somethingWentWrong)));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.item.challenge;
    final l10n = widget.l10n;
    final hasJoined = widget.item.hasJoined;
    final theme = Theme.of(context);
    return premiumCard(
      context: context,
      enableHoverLift: true,
      child: InkWell(
        onTap: () => context.push('/challenges/${c.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                c.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                c.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    l10n.daysCount(c.durationDays),
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    l10n.xpCount(c.rewardXp),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.participantsCount(widget.item.participantCount),
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: hasJoined || _isJoining ? null : _join,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: hasJoined
                        ? theme.colorScheme.outline
                        : AppTheme.accent.withValues(alpha: 0.6),
                  ),
                ),
                child: _isJoining
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(hasJoined ? l10n.joined : l10n.joinChallenge),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({
    required this.message,
    required this.onRetry,
    required this.l10n,
  });

  final String message;
  final VoidCallback onRetry;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          FilledButton.tonal(onPressed: onRetry, child: Text(l10n.tryAgain)),
        ],
      ),
    );
  }
}
