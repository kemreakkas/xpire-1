import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Minimal abstract avatar: circular profile aura with level glow.
/// No armor, no character art — premium SaaS style.
class AvatarAura extends StatelessWidget {
  const AvatarAura({
    super.key,
    required this.level,
    this.size = 80,
    this.showGlow = true,
    this.child,
  });

  final int level;
  final double size;
  final bool showGlow;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + (showGlow ? 24 : 0),
      height: size + (showGlow ? 24 : 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showGlow) ...[
            Container(
              width: size + 16,
              height: size + 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: AppTheme.accentCyan.withValues(alpha: 0.1),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cardBackground,
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  child ??
                  Center(
                    child: Text(
                      '$level',
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
