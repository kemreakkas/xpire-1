import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_spacing.dart';
import '../../l10n/app_localizations.dart';

/// Mobile-first shell: bottom nav, app bar, compact padding.
class MobileShell extends ConsumerWidget {
  const MobileShell({
    super.key,
    required this.routerState,
    required this.child,
  });

  final GoRouterState routerState;
  final Widget child;

  static const _navPaths = ['/dashboard', '/challenges', '/stats', '/profile'];

  int _selectedIndex(String location) {
    if (location.startsWith('/challenges')) return 1;
    final i = _navPaths.indexOf(location);
    return i >= 0 ? i : 0;
  }

  String _title(BuildContext context, String location) {
    final l10n = AppLocalizations.of(context)!;
    if (location == '/challenges') return l10n.challenges;
    if (location.startsWith('/challenges/')) return l10n.challenges;
    if (location == '/dashboard') return l10n.dashboard;
    if (location == '/stats') return l10n.stats;
    if (location == '/profile') return l10n.profile;
    return l10n.dashboard;
  }

  bool _isDetailRoute(String location) {
    return location.startsWith('/challenges/') && location != '/challenges';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final location = routerState.matchedLocation;
    final index = _selectedIndex(location);
    final title = _title(context, location);
    final isDetail = _isDetailRoute(location);

    return Scaffold(
      appBar: isDetail
          ? null
          : AppBar(
              title: Text(title),
              actions: [
                if (SupabaseConfig.isConfigured)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => context.push('/goals/create'),
                    tooltip: l10n.newGoal,
                  ),
              ],
            ),
      body: isDetail
          ? child
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.grid),
              child: child,
            ),
      floatingActionButton: !isDetail && location == '/dashboard' && SupabaseConfig.isConfigured
          ? FloatingActionButton(
              onPressed: () => context.push('/goals/create'),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          final path = _navPaths[i];
          if (path == location && !location.contains('/challenges/')) return;
          context.go(path);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.emoji_events_outlined),
            selectedIcon: const Icon(Icons.emoji_events),
            label: l10n.challenges,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l10n.stats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
