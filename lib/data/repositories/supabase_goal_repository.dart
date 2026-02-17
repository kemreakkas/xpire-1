import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/goal.dart';

/// Goals repository: Supabase-first with Hive cache.
class SupabaseGoalRepository {
  SupabaseGoalRepository(this._box);

  final Box<Goal> _box;

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> syncFromCloud() async {
    if (!SupabaseConfig.isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await _client
          .from('goals')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>;
      await _box.clear();
      for (final row in list) {
        if (row['deleted_at'] != null) continue;
        final goal = _goalFromRow(row as Map<String, dynamic>);
        await _box.put(goal.id, goal);
      }
      AppLog.debug('Goals synced', list.length);
    } catch (e, st) {
      AppLog.error('Goals sync failed', e, st);
    }
  }

  Goal? getById(String id) => _box.get(id);

  List<Goal> listSync() {
    final goals = _box.values.toList(growable: false);
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  }

  Future<void> upsert(Goal goal) async {
    final uid = _userId;
    if (SupabaseConfig.isConfigured && uid != null) {
      try {
        await _client.from('goals').upsert({
          'id': goal.id,
          'user_id': uid,
          'title': goal.title,
          'category': _categoryToStr(goal.category),
          'difficulty': _difficultyToStr(goal.difficulty),
          'base_xp': goal.baseXp,
          'frequency': null,
          'is_active': goal.isActive,
          'created_at': goal.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'deleted_at': null,
        });
      } catch (e, st) {
        AppLog.error('Goal upsert failed', e, st);
        rethrow;
      }
    }
    await _box.put(goal.id, goal);
    AppLog.debug('Goal upsert', goal.id);
  }

  Future<void> setActive({required String goalId, required bool isActive}) async {
    final existing = _box.get(goalId);
    if (existing == null) return;
    final uid = _userId;
    if (SupabaseConfig.isConfigured && uid != null) {
      try {
        await _client
            .from('goals')
            .update({
              'is_active': isActive,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', goalId)
            .eq('user_id', uid);
      } catch (e, st) {
        AppLog.error('Goal setActive failed', e, st);
        rethrow;
      }
    }
    await _box.put(goalId, existing.copyWith(isActive: isActive));
    AppLog.debug('Goal setActive', {'goalId': goalId, 'isActive': isActive});
  }

  Goal _goalFromRow(Map<String, dynamic> row) {
    return Goal(
      id: row['id'] as String,
      title: row['title'] as String,
      category: _strToCategory(row['category'] as String?),
      difficulty: _strToDifficulty(row['difficulty'] as String?),
      baseXp: (row['base_xp'] as num?)?.toInt() ?? 0,
      isActive: (row['is_active'] as bool?) ?? true,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  String _categoryToStr(GoalCategory c) =>
      c.name;

  GoalCategory _strToCategory(String? s) {
    if (s == null) return GoalCategory.general;
    return GoalCategory.values.firstWhere(
      (e) => e.name == s,
      orElse: () => GoalCategory.general,
    );
  }

  String _difficultyToStr(GoalDifficulty d) => d.name;

  GoalDifficulty _strToDifficulty(String? s) {
    if (s == null) return GoalDifficulty.easy;
    return GoalDifficulty.values.firstWhere(
      (e) => e.name == s,
      orElse: () => GoalDifficulty.easy,
    );
  }
}
