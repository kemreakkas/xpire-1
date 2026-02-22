import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/nav_helpers.dart';
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
          final isWebWide = Responsive.isWebWide(context);

          if (isWebWide) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _HeroStatsGrid(stats: stats, l10n: l10n, columns: 4),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _ActiveChallengeIndicator(),
                            const SizedBox(height: AppSpacing.sm),
                            _CompletedChallengesCard(),
                            const SizedBox(height: AppSpacing.sm),
                            _CompletionsByCategorySection(
                              byCategory: stats.completionsByCategory,
                              l10n: l10n,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: _AdvancedStatsSection(stats: stats, l10n: l10n),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HeroStatsGrid(stats: stats, l10n: l10n, columns: 2),
                const SizedBox(height: AppSpacing.md),
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
            ),
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Hero Stats Grid — Gradient cards with icons
// ──────────────────────────────────────────────────
class _HeroStatsGrid extends StatelessWidget {
  const _HeroStatsGrid({
    required this.stats,
    required this.l10n,
    required this.columns,
  });

  final Stats stats;
  final AppLocalizations l10n;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final items = [
      _HeroItem(
        icon: Icons.bolt_rounded,
        label: l10n.totalXp,
        value: '${stats.totalXp}',
        gradient: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
      ),
      _HeroItem(
        icon: Icons.check_circle_outline_rounded,
        label: l10n.goalsCompleted,
        value: '${stats.totalGoalsCompleted}',
        gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
      ),
      _HeroItem(
        icon: Icons.local_fire_department_rounded,
        label: l10n.currentStreak,
        value: '${stats.currentStreak}',
        suffix: l10n.daysSuffix,
        gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
      _HeroItem(
        icon: Icons.today_rounded,
        label: l10n.completedToday,
        value: '${stats.completedTodayCount}',
        gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      ),
    ];

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += columns) {
      final rowChildren = <Widget>[];
      for (var j = 0; j < columns; j++) {
        final idx = i + j;
        if (idx < items.length) {
          rowChildren.add(Expanded(child: items[idx]));
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
        if (j < columns - 1) {
          rowChildren.add(const SizedBox(width: AppSpacing.sm));
        }
      }
      rows.add(Row(children: rowChildren));
      if (i + columns < items.length) {
        rows.add(const SizedBox(height: AppSpacing.sm));
      }
    }
    return Column(children: rows);
  }
}

class _HeroItem extends StatelessWidget {
  const _HeroItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.gradient,
    this.suffix,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradient;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            gradient[0].withValues(alpha: 0.15),
            gradient[1].withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: gradient[0].withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: gradient[0].withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: gradient[0]),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: theme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Text(
                  '$v',
                  style: theme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: 4),
                Text(
                  suffix!,
                  style: theme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Active Challenge Indicator
// ──────────────────────────────────────────────────
class _ActiveChallengeIndicator extends ConsumerWidget {
  const _ActiveChallengeIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) return const SizedBox.shrink();
    final progressAv = ref.watch(activeChallengeProgressModelProvider);
    return progressAv.when(
      data: (progress) {
        if (progress == null ||
            progress.isCompleted ||
            progress.failedAt != null) {
          return const SizedBox.shrink();
        }
        final content = ref.read(contentRepositoryProvider);
        final challenge = content.getChallengeById(progress.challengeId);
        if (challenge == null) return const SizedBox.shrink();
        final fraction = challenge.durationDays > 0
            ? progress.currentDay / challenge.durationDays
            : 0.0;
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                AppTheme.warningAmber.withValues(alpha: 0.12),
                AppTheme.warningAmber.withValues(alpha: 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: AppTheme.warningAmber.withValues(alpha: 0.25),
            ),
          ),
          child: InkWell(
            onTap: () =>
                goOrPush(context, '/challenges/${progress.challengeId}'),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        color: AppTheme.warningAmber,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.activeChallenge,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.warningAmber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        l10n.dayProgress(
                          progress.currentDay,
                          challenge.durationDays,
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: fraction.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: const Color(
                        0xFFF59E0B,
                      ).withValues(alpha: 0.15),
                      color: AppTheme.warningAmber,
                    ),
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

// ──────────────────────────────────────────────────
// Completed Challenges Card
// ──────────────────────────────────────────────────
class _CompletedChallengesCard extends ConsumerWidget {
  const _CompletedChallengesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (!SupabaseConfig.isConfigured) return const SizedBox.shrink();
    final countAv = ref.watch(completedChallengesCountProvider);
    return countAv.when(
      data: (count) => _HeroItem(
        icon: Icons.flag_rounded,
        label: l10n.challengesCompleted,
        value: '$count',
        gradient: const [Color(0xFFEC4899), Color(0xFFF472B6)],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ──────────────────────────────────────────────────
// Completions by Category — Horizontal bars
// ──────────────────────────────────────────────────
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
    'digitaldetox' => l10n.digitalDetox,
    'social' => l10n.social,
    'creativity' => l10n.creativity,
    'discipline' => l10n.discipline,
    _ =>
      name.isEmpty
          ? l10n.general
          : '${name[0].toUpperCase()}${name.substring(1)}',
  };
}

IconData _categoryIcon(String name) {
  return switch (name.toLowerCase()) {
    'fitness' => Icons.fitness_center_rounded,
    'study' => Icons.menu_book_rounded,
    'work' => Icons.work_rounded,
    'focus' => Icons.center_focus_strong_rounded,
    'mind' => Icons.self_improvement_rounded,
    'health' => Icons.favorite_rounded,
    'finance' => Icons.account_balance_wallet_rounded,
    'selfgrowth' => Icons.trending_up_rounded,
    'general' => Icons.category_rounded,
    'digitaldetox' => Icons.phone_disabled_rounded,
    'social' => Icons.people_rounded,
    'creativity' => Icons.palette_rounded,
    'discipline' => Icons.military_tech_rounded,
    _ => Icons.circle_outlined,
  };
}

final _categoryColors = [
  AppTheme.xpBlue,
  AppTheme.successGreen,
  AppTheme.warningAmber,
  AppTheme.premiumPurple,
  AppTheme.pinkAccent,
  AppTheme.xpBlueSoft,
  AppTheme.errorRed,
  AppTheme.tealAccent,
];

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
    final maxVal = entries.first.value;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart_rounded,
                size: 18,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.completionsByCategory,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...entries.asMap().entries.map((mapEntry) {
            final i = mapEntry.key;
            final e = mapEntry.value;
            final color = _categoryColors[i % _categoryColors.length];
            final fraction = maxVal > 0 ? e.value / maxVal : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_categoryIcon(e.key), size: 14, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _categoryDisplayName(l10n, e.key),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ),
                      Text(
                        '${e.value}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: Duration(milliseconds: 600 + i * 100),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: v.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: color.withValues(alpha: 0.1),
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Advanced Stats (Premium) — Sparkline chart
// ──────────────────────────────────────────────────
class _AdvancedStatsSection extends ConsumerWidget {
  const _AdvancedStatsSection({required this.stats, required this.l10n});

  final Stats stats;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUse = ref.watch(PremiumController.canUseAdvancedStatsProvider);

    if (canUse) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.insights_rounded,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.advancedStats,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.streakGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFEAB308),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _StatRow(
              icon: Icons.bolt_rounded,
              iconColor: AppTheme.xpBlue,
              label: l10n.weeklyXp,
              value: '${stats.weeklyXpTotal ?? 0}',
            ),
            _StatRow(
              icon: Icons.star_rounded,
              iconColor: AppTheme.warningAmber,
              label: l10n.mostProductiveCategory,
              value: stats.mostProductiveCategoryName != null
                  ? _categoryDisplayName(
                      l10n,
                      stats.mostProductiveCategoryName!,
                    )
                  : '—',
            ),
            if (stats.last30DaysCompletionCounts != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.last30Days,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SparklinePainter(
                    data: stats.last30DaysCompletionCounts!,
                    lineColor: AppTheme.accent,
                    fillColor: AppTheme.accent.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Locked state
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lock_outline, size: 32, color: AppTheme.accent),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.premiumFeature,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.advancedStatsDesc,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: () => goOrPush(context, PremiumPage.routePath),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.accent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.workspace_premium, size: 18),
            label: Text(l10n.upgrade),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Stat Row with icon
// ──────────────────────────────────────────────────
class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: iconColor ?? AppTheme.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────
// Sparkline Painter — smooth area chart
// ──────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
  });

  final List<int> data;
  final Color lineColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce((a, b) => math.max(a, b));
    if (maxVal <= 0) return;

    final w = size.width;
    final h = size.height;
    final step = w / (data.length - 1).clamp(1, data.length);

    final points = <Offset>[];
    for (var i = 0; i < data.length; i++) {
      final x = i * step;
      final y = h - (data[i] / maxVal) * (h - 4);
      points.add(Offset(x, y));
    }

    // Fill area
    final fillPath = Path()..moveTo(0, h);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(w, h);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor, fillColor.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path();
    for (var i = 0; i < points.length; i++) {
      if (i == 0) {
        linePath.moveTo(points[i].dx, points[i].dy);
      } else {
        linePath.lineTo(points[i].dx, points[i].dy);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Last dot
    if (points.isNotEmpty) {
      final last = points.last;
      canvas.drawCircle(last, 3, Paint()..color = lineColor);
      canvas.drawCircle(
        last,
        5,
        Paint()..color = lineColor.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.data != data || old.lineColor != lineColor;
}
