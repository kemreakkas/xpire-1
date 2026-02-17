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
    return repo.listSync();
  }

  Future<void> addGoal(Goal goal) async {
    final repo = ref.read(goalRepositoryProvider);
    await repo.upsert(goal);
    AppLog.debug('Goal added', goal.id);
    state = AsyncData(repo.listSync());
  }

  Future<void> addGoals(List<Goal> goals) async {
    final repo = ref.read(goalRepositoryProvider);
    for (final goal in goals) {
      await repo.upsert(goal);
    }
    AppLog.debug('Goals added', goals.length);
    state = AsyncData(repo.listSync());
  }
}
