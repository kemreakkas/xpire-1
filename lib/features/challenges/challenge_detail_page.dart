import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/nav_helpers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../data/content/content_repository.dart';
import '../../data/models/active_challenge.dart';
import '../../data/models/challenge.dart';
import '../../data/models/community_challenge.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_template.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/leaderboard/challenge_leaderboard_section.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

class ChallengeDetailPage extends ConsumerWidget {
  const ChallengeDetailPage({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final content = ref.watch(contentRepositoryProvider);
    final challenge = content.getChallengeById(challengeId);
    final communityAsync = ref.watch(
      communityChallengeByIdProvider(challengeId),
    );
    final progressRepo = ref.watch(challengeProgressRepositoryProvider);
    final active = progressRepo.getCurrent();
    final progressState = ref.watch(activeChallengeProgressProvider);
    final progressModelAv = ref.watch(activeChallengeProgressModelProvider);
    final progressModel = progressModelAv.maybeWhen(
      data: (d) => d,
      orElse: () => null,
    );
    final isActiveSupabase =
        SupabaseConfig.isConfigured &&
        progressModel != null &&
        progressModel.challengeId == challengeId &&
        !progressModel.isCompleted &&
        progressModel.failedAt == null;
    final isActive = SupabaseConfig.isConfigured
        ? isActiveSupabase
        : (active?.challengeId == challengeId);
    final isCompleted = SupabaseConfig.isConfigured
        ? (progressModel != null &&
              progressModel.challengeId == challengeId &&
              progressModel.isCompleted)
        : (progressState?.completed ?? false);

    if (challenge == null) {
      return communityAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(
            title: Text(l10n.challenges),
            automaticallyImplyLeading: shouldShowAppBarLeading(context),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.challenges),
            automaticallyImplyLeading: shouldShowAppBarLeading(context),
          ),
          body: Center(child: Text(l10n.challengeNotFound)),
        ),
        data: (community) {
          if (community == null) {
            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.challenges),
                automaticallyImplyLeading: shouldShowAppBarLeading(context),
              ),
              body: Center(child: Text(l10n.challengeNotFound)),
            );
          }
          return _CommunityChallengeDetailView(
            challenge: community,
            challengeId: challengeId,
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
        automaticallyImplyLeading: shouldShowAppBarLeading(context),
      ),
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
                        _Chip(label: l10n.daysCount(challenge.durationDays)),
                        const SizedBox(width: AppSpacing.sm),
                        _Chip(label: l10n.bonusXpLabel(challenge.bonusXp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.goalsInThisChallenge,
              style: Theme.of(context).textTheme.titleSmall,
            ),
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
                              l10n.challengeCompleted,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              l10n.bonusXpAddedWhenFinished(challenge.bonusXp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    )
                  : _ClaimBonusSection(
                      challenge: challenge,
                      l10n: l10n,
                      onClaim: () => _claimBonus(context, ref, challenge),
                    )
            else if (isActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (progressState != null) ...[
                    Text(
                      l10n.progressPercent(
                        (progressState.progress * 100).toStringAsFixed(0),
                      ),
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
                          Icon(
                            Icons.check_circle_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.youAreDoingThisChallenge,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton(
                    onPressed: () => _quitChallenge(context, ref, challenge),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(l10n.quitChallenge),
                  ),
                ],
              )
            else
              FilledButton(
                onPressed: () =>
                    _startChallenge(context, ref, challenge, content),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.startChallenge),
              ),
            if (SupabaseConfig.isConfigured)
              ChallengeLeaderboardSection(challengeId: challengeId),
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
      final progress = await engine.startChallenge(
        userId: uid,
        challenge: challenge,
      );
      if (progress == null) {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.alreadyHaveActiveChallenge)),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.challengeStartedMessage(challenge.title, challenge.bonusXp),
          ),
        ),
      );
      if (shouldShowAppBarLeading(context)) {
        context.pop();
        context.push('/dashboard');
      } else {
        context.go('/dashboard');
      }
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
      goals.add(
        Goal(
          id: goalId,
          title: t.title,
          category: t.category,
          difficulty: t.difficulty,
          baseXp: t.baseXp,
          isActive: true,
          createdAt: now,
        ),
      );
    }

    await ref.read(goalsControllerProvider.notifier).addGoals(goals);
    await ref
        .read(challengeProgressRepositoryProvider)
        .setCurrent(
          ActiveChallenge(
            challengeId: challenge.id,
            startedAt: now,
            goalIds: goalIds,
          ),
        );
    ref.read(analyticsServiceProvider).track(AnalyticsEvents.challengeStarted, {
      'challenge_id': challenge.id,
      'duration_days': challenge.durationDays,
    });

    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.challengeStartedMessageOffline(
            challenge.title,
            challenge.bonusXp,
          ),
        ),
      ),
    );
    if (shouldShowAppBarLeading(context)) {
      context.pop();
      context.push('/dashboard');
    } else {
      context.go('/dashboard');
    }
  }

  Future<void> _claimBonus(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile = profileRepo.readSync() ?? await profileRepo.loadOrCreate();
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.bonusXpClaimed(challenge.bonusXp))),
    );
    if (shouldShowAppBarLeading(context)) {
      context.pop();
      context.push('/dashboard');
    } else {
      context.go('/dashboard');
    }
  }

  Future<void> _quitChallenge(
    BuildContext context,
    WidgetRef ref,
    Challenge challenge,
  ) async {
    final l10n = AppLocalizations.of(context)!;
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
      if (SupabaseConfig.isConfigured) {
        final uid = ref.read(authUserIdProvider);
        if (uid != null) {
          final engine = ref.read(challengeEngineProvider);
          await engine.quitChallenge(uid);
        }
      } else {
        await ref.read(challengeProgressRepositoryProvider).clear();
      }

      ref.invalidate(activeChallengeProgressModelProvider);
      ref.invalidate(activeChallengeProgressProvider);

      if (!context.mounted) return;
      if (shouldShowAppBarLeading(context)) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }
}

/// Detail view for a community challenge: title, description, join, leaderboard.
class _CommunityChallengeDetailView extends ConsumerStatefulWidget {
  const _CommunityChallengeDetailView({
    required this.challenge,
    required this.challengeId,
  });

  final CommunityChallenge challenge;
  final String challengeId;

  @override
  ConsumerState<_CommunityChallengeDetailView> createState() =>
      _CommunityChallengeDetailViewState();
}

class _CommunityChallengeDetailViewState
    extends ConsumerState<_CommunityChallengeDetailView> {
  bool _isJoining = false;

  Future<void> _join() async {
    if (_isJoining) return;
    final uid = ref.read(authUserIdProvider);
    if (uid == null) return;
    setState(() => _isJoining = true);
    try {
      final repo = ref.read(supabaseChallengeParticipantsRepositoryProvider);
      await repo.join(uid, widget.challengeId);
      ref.invalidate(myActiveParticipantsProvider);
      ref.invalidate(communityChallengesWithMetaProvider);
      ref.invalidate(challengeLeaderboardProvider(widget.challengeId));
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.challenge.title}: ${l10n.joined}')),
      );
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _leave() async {
    final l10n = AppLocalizations.of(context)!;
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
      setState(() => _isJoining = true);
      try {
        final repo = ref.read(supabaseChallengeParticipantsRepositoryProvider);
        await repo.leave(uid, widget.challengeId);
        ref.invalidate(myActiveParticipantsProvider);
        ref.invalidate(communityChallengesWithMetaProvider);
        ref.invalidate(challengeLeaderboardProvider(widget.challengeId));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
      } finally {
        if (mounted) setState(() => _isJoining = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final metaAsync = ref.watch(communityChallengesWithMetaProvider);
    final hasJoined = metaAsync.maybeWhen(
      data: (list) =>
          list
              .where((e) => e.challenge.id == widget.challengeId)
              .map((e) => e.hasJoined)
              .firstOrNull ??
          false,
      orElse: () => false,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.challenge.title),
        automaticallyImplyLeading: shouldShowAppBarLeading(context),
      ),
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
                      widget.challenge.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _Chip(
                          label: l10n.daysCount(widget.challenge.durationDays),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _Chip(
                          label: l10n.bonusXpLabel(widget.challenge.rewardXp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!hasJoined)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: OutlinedButton(
                  onPressed: _isJoining ? null : _join,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: AppTheme.accent.withValues(alpha: 0.6),
                    ),
                  ),
                  child: _isJoining
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.joinChallenge),
                ),
              )
            else ...[
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.youAreDoingThisChallenge,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(
                onPressed: _isJoining ? null : _leave,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.quitChallenge),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            ChallengeLeaderboardSection(challengeId: widget.challengeId),
          ],
        ),
      ),
    );
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
                      Icon(
                        Icons.flag_outlined,
                        size: 18,
                        color: Theme.of(context).colorScheme.outline,
                      ),
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
    required this.l10n,
    required this.onClaim,
  });

  final Challenge challenge;
  final AppLocalizations l10n;
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
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.challengeCompleted,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.claimBonusXp(challenge.bonusXp),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onClaim,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(l10n.claimBonus),
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
