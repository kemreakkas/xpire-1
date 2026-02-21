import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/goal.dart';

/// Goals repository: Supabase-first with Hive cache.
class SupabaseGoalRepository {
  SupabaseGoalRepository(this._box);

  final Box<Goal> _box;

  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  String? get _userId => _client?.auth.currentUser?.id;

  Future<void> syncFromCloud() async {
    if (!SupabaseConfig.isConfigured) return;
    final uid = _userId;
    final client = _client;
    if (uid == null || client == null) return;
    try {
      final res = await client
          .from('goals')
          .select()
          .eq('user_id', uid)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>;
      // Only clear and replace if we actually got data or if we are sure we want to sync.
      // For now, we update local Hive with what's on the server.
      for (final row in list) {
        if (row['deleted_at'] != null) {
          await _box.delete(row['id']);
          continue;
        }
        final goal = _goalFromRow(row as Map<String, dynamic>);
        await _box.put(goal.id, goal);
      }
      AppLog.debug('Goals synced from cloud', list.length);
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
    if (SupabaseConfig.isConfigured) {
      final client = _client;
      final uid = _userId;
      if (client == null || uid == null) {
        AppLog.error(
          'Goal upsert failed: no user/client',
          null,
          StackTrace.current,
        );
        throw StateError('Not signed in. Sign in to save goals.');
      }
      try {
        await client.from('goals').upsert({
          'id': goal.id,
          'user_id': uid,
          'title': goal.title,
          'category': _categoryToStr(goal.category),
          'difficulty': _difficultyToStr(goal.difficulty),
          'base_xp': goal.baseXp,
          'frequency': 'daily',
          'is_active': goal.isActive,
          'created_at': goal.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'deleted_at': null,
        });
      } catch (e, st) {
        final errStr = e.toString();
        // If it's a foreign key error due to missing public.users row, auto create the row and retry
        if (errStr.contains('goals_user_id_fkey') &&
            errStr.contains('not present in table "users"')) {
          AppLog.info(
            'Missing user row detected during goal insert. Creating now...',
          );
          try {
            await client.from('users').upsert({
              'id': uid,
              'email': client.auth.currentUser?.email,
            });
            // Retry goal upsert
            await client.from('goals').upsert({
              'id': goal.id,
              'user_id': uid,
              'title': goal.title,
              'category': _categoryToStr(goal.category),
              'difficulty': _difficultyToStr(goal.difficulty),
              'base_xp': goal.baseXp,
              'frequency': 'daily',
              'is_active': goal.isActive,
              'created_at': goal.createdAt.toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
              'deleted_at': null,
            });
            AppLog.info('Goal upsert retry successful.');
          } catch (retryE) {
            AppLog.error('Goal upsert retry failed', retryE, st);
            rethrow;
          }
        } else {
          AppLog.error('Goal upsert failed', e, st);
          if (e is Exception) {
            debugPrint('Supabase goal error: $e');
          }
          rethrow;
        }
      }
    }
    await _box.put(goal.id, goal);
    AppLog.debug('Goal upsert', goal.id);
  }

  Future<void> setActive({
    required String goalId,
    required bool isActive,
  }) async {
    final existing = _box.get(goalId);
    if (existing == null) return;
    final client = _client;
    final uid = _userId;
    if (client != null && uid != null) {
      try {
        await client
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

  String _categoryToStr(GoalCategory c) => c.name;

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
