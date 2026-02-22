import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_radius.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

/// SaaS-style shell for web (wide): fixed 260px sidebar, topbar, centered content.
/// No AppBar (no back arrow). No bottom nav. No mobile spacing or transitions.
class WebShell extends ConsumerWidget {
  const WebShell({super.key, required this.routerState, required this.child});

  final GoRouterState routerState;
  final Widget child;

  String _pageTitle(BuildContext context, String location) {
    final l10n = AppLocalizations.of(context)!;
    if (location.startsWith('/challenges')) return l10n.challenges;
    if (location == '/dashboard') return l10n.dashboard;
    if (location == '/leaderboard') return l10n.leaderboard;
    if (location == '/stats') return l10n.stats;
    if (location == '/profile') return l10n.profile;
    return l10n.dashboard;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = routerState.matchedLocation;
    final profile = ref
        .watch(profileControllerProvider)
        .maybeWhen(data: (d) => d, orElse: () => null);

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            location: location,
            l10n: l10n,
            onNavigate: (path) => context.go(path),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(
                  title: _pageTitle(context, location),
                  userLabel: profile?.fullName?.isNotEmpty == true
                      ? profile!.fullName!
                      : (SupabaseConfig.isConfigured
                            ? 'Account'
                            : l10n.profile),
                  onLogout: () => ref.read(logoutAndClearProvider)(),
                  showLogout: true,
                  showNewGoal:
                      location == '/dashboard' && SupabaseConfig.isConfigured,
                  onNewGoal: () => context.go('/goals/create'),
                  l10n: l10n,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.location,
    required this.l10n,
    required this.onNavigate,
  });

  final String location;
  final AppLocalizations l10n;
  final void Function(String path) onNavigate;

  static const _paths = [
    '/dashboard',
    '/challenges',
    '/leaderboard',
    '/stats',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isSelected(path) {
      if (path == '/challenges') return location.startsWith('/challenges');
      return location == path;
    }

    return Material(
      color: AppTheme.sidebarDark,
      child: SizedBox(
        width: Responsive.sideNavWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Xpire',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ..._paths.map((path) {
              final selected = isSelected(path);
              final label = path == '/dashboard'
                  ? l10n.dashboard
                  : path == '/challenges'
                  ? l10n.challenges
                  : path == '/leaderboard'
                  ? l10n.leaderboard
                  : path == '/stats'
                  ? l10n.stats
                  : l10n.profile;
              final icon = path == '/dashboard'
                  ? Icons.dashboard
                  : path == '/challenges'
                  ? Icons.emoji_events
                  : path == '/leaderboard'
                  ? Icons.leaderboard
                  : path == '/stats'
                  ? Icons.insights
                  : Icons.person;
              return _SidebarTile(
                label: label,
                icon: icon,
                selected: selected,
                onTap: () => onNavigate(path),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SidebarTile extends StatefulWidget {
  const _SidebarTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected
        ? AppTheme.accent.withValues(alpha: 0.2)
        : (_hover ? Colors.white.withValues(alpha: 0.06) : Colors.transparent);
    final fg = widget.selected ? AppTheme.accent : Colors.white70;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Material(
          color: bg,
          borderRadius: AppRadius.mdRadius,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.mdRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Icon(widget.icon, size: 22, color: fg),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: fg,
                      fontWeight: widget.selected ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.userLabel,
    required this.onLogout,
    required this.showLogout,
    this.showNewGoal = false,
    this.onNewGoal,
    required this.l10n,
  });

  final String title;
  final String userLabel;
  final VoidCallback onLogout;
  final bool showLogout;
  final bool showNewGoal;
  final VoidCallback? onNewGoal;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: AppTheme.cardElevation,
      color: AppTheme.topbarDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showNewGoal && onNewGoal != null) ...[
                const SizedBox(width: AppSpacing.md),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton.icon(
                    onPressed: onNewGoal,
                    icon: const Icon(Icons.add, size: 20),
                    label: Text(l10n.newGoal),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                userLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (showLogout) ...[
                const SizedBox(width: AppSpacing.md),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: TextButton(
                    onPressed: onLogout,
                    child: Text(l10n.signOut),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
