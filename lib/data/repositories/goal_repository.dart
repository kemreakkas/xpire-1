import 'package:hive/hive.dart';

import '../../core/log/app_log.dart';
import '../models/goal.dart';

class GoalRepository {
  GoalRepository(this._box);

  final Box<Goal> _box;

  Goal? getById(String id) => _box.get(id);

  List<Goal> listSync() {
    final goals = _box.values.toList(growable: false);
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  Future<void> upsert(Goal goal) async {
    await _box.put(goal.id, goal);
    AppLog.debug('Goal upsert', goal.id);
  }

  Future<void> setActive({
    required String goalId,
    required bool isActive,
  }) async {
    final existing = _box.get(goalId);
    if (existing == null) return;
    await _box.put(goalId, existing.copyWith(isActive: isActive));
    AppLog.debug('Goal setActive', {'goalId': goalId, 'isActive': isActive});
  }
}
