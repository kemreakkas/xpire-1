import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'app_spacing.dart';
import 'app_theme.dart';

/// Level-up effect: soft glow + small confetti burst. Premium, not childish.
void showLevelUpOverlay(BuildContext context, {required int newLevel}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    barrierDismissible: true,
    builder: (context) => _LevelUpOverlay(newLevel: newLevel),
  );
}

class _LevelUpOverlay extends StatefulWidget {
  const _LevelUpOverlay({required this.newLevel});

  final int newLevel;

  @override
  State<_LevelUpOverlay> createState() => _LevelUpOverlayState();
}

class _LevelUpOverlayState extends State<_LevelUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowOpacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _glowOpacity = Tween<double>(begin: 0, end: 0.6).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.4, curve: Curves.easeOut),
      ),
    );
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _levelUpTitle(BuildContext context) =>
      AppLocalizations.of(context)?.levelUpTitle ?? 'Level up!';
  String _levelUpMessage(BuildContext context, int level) =>
      AppLocalizations.of(context)?.levelUpMessage(level) ??
      'You reached level $level.';
  String _saveLabel(BuildContext context) =>
      AppLocalizations.of(context)?.save ?? 'Continue';

  @override
  Widget build(BuildContext context) {
    final levelUpTitle = _levelUpTitle(context);
    final levelUpMessage = _levelUpMessage(context, widget.newLevel);
    final saveLabel = _saveLabel(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(
                        alpha: _glowOpacity.value,
                      ),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(
                        alpha: _glowOpacity.value * 0.6,
                      ),
                      blurRadius: 80,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),
            ),
            ScaleTransition(
              scale: _scale,
              child: Material(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                elevation: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  constraints: const BoxConstraints(minWidth: 260),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppTheme.accent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '${widget.newLevel}',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        levelUpTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        levelUpMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _ConfettiBurst(progress: _controller.value),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(saveLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Small confetti burst: a few particles, minimal.
class _ConfettiBurst extends StatelessWidget {
  const _ConfettiBurst({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress < 0.3) return const SizedBox.shrink();
    final count = 12;
    return SizedBox(
      height: 40,
      child: CustomPaint(
        painter: _ConfettiPainter(
          progress: ((progress - 0.3) / 0.4).clamp(0.0, 1.0),
          count: count,
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress, required this.count});

  final double progress;
  final int count;
  static const _colors = [
    AppTheme.accent,
    AppTheme.accentCyan,
    Color(0xFFF59E0B),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rnd = math.Random(42);
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi + rnd.nextDouble() * 0.5;
      final dist = 20 + progress * 24 + rnd.nextDouble() * 8;
      final x = center.dx + math.cos(angle) * dist;
      final y = center.dy + math.sin(angle) * dist - progress * 10;
      final color = _colors[i % _colors.length];
      final paint = Paint()
        ..color = color.withValues(alpha: (1 - progress).clamp(0.0, 1.0));
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, y), width: 4, height: 4),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) =>
      old.progress != progress;
}
