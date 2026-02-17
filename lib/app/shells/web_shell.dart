import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/responsive.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

/// SaaS-style shell: fixed sidebar, topbar, centered content.
class WebShell extends ConsumerWidget {
  const WebShell({
    super.key,
    required this.routerState,
    required this.child,
  });

  final GoRouterState routerState;
  final Widget child;

  String _pageTitle(BuildContext context, String location) {
    final l10n = AppLocalizations.of(context)!;
    if (location.startsWith('/challenges')) return l10n.challenges;
    if (location == '/dashboard') return l10n.dashboard;
    if (location == '/stats') return l10n.stats;
    if (location == '/profile') return l10n.profile;
    return l10n.dashboard;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = routerState.matchedLocation;
    final profile = ref.watch(profileControllerProvider).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );

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
                      : (SupabaseConfig.isConfigured ? 'Account' : l10n.profile),
                  onLogout: () => ref.read(logoutAndClearProvider)(),
                  showLogout: SupabaseConfig.isConfigured,
                  showNewGoal: location == '/dashboard' && SupabaseConfig.isConfigured,
                  onNewGoal: () => context.push('/goals/create'),
                  l10n: l10n,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: ResponsiveLayout.contentMaxWidth,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: child,
                        ),
                      ),
                    ),
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

  static const _paths = ['/dashboard', '/challenges', '/stats', '/profile'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected = (path) {
      if (path == '/challenges') return location.startsWith('/challenges');
      return location == path;
    };

    return Material(
      color: const Color(0xFF0F0F0F),
      child: SizedBox(
        width: ResponsiveLayout.sidebarWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Xpire',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ..._paths.map((path) {
              final selected = isSelected(path);
              final label = path == '/dashboard'
                  ? l10n.dashboard
                  : path == '/challenges'
                      ? l10n.challenges
                      : path == '/stats'
                          ? l10n.stats
                          : l10n.profile;
              final icon = path == '/dashboard'
                  ? Icons.dashboard
                  : path == '/challenges'
                      ? Icons.emoji_events
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(widget.icon, size: 22, color: fg),
                  const SizedBox(width: 12),
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
      elevation: 0,
      color: const Color(0xFF141414),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                const SizedBox(width: 16),
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
                const SizedBox(width: 16),
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
