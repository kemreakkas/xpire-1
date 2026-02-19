import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/log/app_log.dart';
import '../../data/models/goal.dart';
import '../../features/auth/auth_controller.dart';
import '../providers.dart';

class GoalsController extends AsyncNotifier<List<Goal>> {
  @override
  Future<List<Goal>> build() async {
    ref.watch(authUserIdProvider);
    final repo = ref.read(goalRepositoryProvider);
    await repo.syncFromCloud();
    final goals = repo.listSync();
    // ignore: avoid_print
    print('Loaded goals count: ${goals.length}');
    return goals;
  }

  Future<void> addGoal(Goal goal) async {
    final repo = ref.read(goalRepositoryProvider);
    await repo.upsert(goal);
    // Re-sync from Supabase so the state reflects the server''s truth.
    await repo.syncFromCloud();
    final goals = repo.listSync();
    // ignore: avoid_print
    print('Loaded goals count: ${goals.length}');
    AppLog.debug('Goal added', goal.id);
    state = AsyncData(goals);
  }

  Future<void> addGoals(List<Goal> goals) async {
    final repo = ref.read(goalRepositoryProvider);
    for (final goal in goals) {
      await repo.upsert(goal);
    }
    await repo.syncFromCloud();
    final fresh = repo.listSync();
    // ignore: avoid_print
    print('Loaded goals count: ${fresh.length}');
    AppLog.debug('Goals added', goals.length);
    state = AsyncData(fresh);
  }
}