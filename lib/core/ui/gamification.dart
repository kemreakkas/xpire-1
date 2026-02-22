import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_theme.dart';

/// Thin XP progress bar with subtle blue → cyan gradient. Modern, not childish.
class XpProgressBar extends StatelessWidget {
  const XpProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
    this.animate = true,
  });

  final double progress;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final value = progress.clamp(0.0, 1.0);
    Widget bar = LayoutBuilder(
      builder: (context, constraints) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: Stack(
            children: [
              Container(
                height: height,
                width: constraints.maxWidth,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
              Container(
                height: height,
                width: constraints.maxWidth * value,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppTheme.xpBarGradient,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (animate) {
      bar = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => LayoutBuilder(
          builder: (context, constraints) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(height / 2),
              child: Stack(
                children: [
                  Container(
                    height: height,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                  Container(
                    height: height,
                    width: constraints.maxWidth * v,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppTheme.xpBarGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return bar;
  }
}

/// Minimal circle badge showing level number. No cartoon style.
class LevelBadge extends StatelessWidget {
  const LevelBadge({
    super.key,
    required this.level,
    this.size = 40,
    this.fontSize,
  });

  final int level;
  final double size;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardBackground,
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        '$level',
        style: (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(
          fontSize: fontSize ?? (size * 0.45),
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

/// Small streak indicator with minimal flame icon (not cartoon).
class StreakPill extends StatelessWidget {
  const StreakPill({super.key, required this.days, this.compact = false});

  final int days;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.sm + 4,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppTheme.hoverBackground,
        border: Border.all(
          color: AppTheme.warningAmber.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: compact ? 16 : 18,
            color: AppTheme.warningAmber,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            '${days}d',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rank label e.g. "Focus Rank", "Discipline Rank". Text-only, minimal.
class RankLabel extends StatelessWidget {
  const RankLabel({super.key, required this.label, this.prefix = 'Rank'});

  final String label;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      '$prefix · $label',
      style: theme.textTheme.labelMedium?.copyWith(
        color: AppTheme.textSecondary,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Wrapper that applies soft shadow and optional hover lift for cards (web).
Widget premiumCard({
  required BuildContext context,
  required Widget child,
  bool enableHoverLift = false,
}) {
  final isWeb = MediaQuery.sizeOf(context).width >= 768;
  Widget card = Container(
    decoration: BoxDecoration(
      color: AppTheme.cardBackground,
      borderRadius: AppRadius.lgRadius,
      border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(borderRadius: AppRadius.lgRadius, child: child),
  );
  if (enableHoverLift && isWeb) {
    card = _HoverLiftCard(child: card);
  }
  return card;
}

class _HoverLiftCard extends StatefulWidget {
  const _HoverLiftCard({required this.child});

  final Widget child;

  @override
  State<_HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<_HoverLiftCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _hover ? -2.0 : 0.0, 0.0, 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: widget.child,
        ),
      ),
    );
  }
}
