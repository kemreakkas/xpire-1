import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/goal_completion.dart';

/// Completions repository: Supabase-first with Hive cache.
class SupabaseCompletionRepository {
  SupabaseCompletionRepository(this._box);

  final Box<GoalCompletion> _box;

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  Future<void> syncFromCloud() async {
    if (!SupabaseConfig.isConfigured) return;
    final uid = _userId;
    if (uid == null) return;
    try {
      final res = await _client
          .from('completions')
          .select()
          .eq('user_id', uid)
          .order('completed_at', ascending: false);
      final list = res as List<dynamic>;
      await _box.clear();
      for (final row in list) {
        final c = _completionFromRow(row as Map<String, dynamic>);
        await _box.put(c.id, c);
      }
      AppLog.debug('Completions synced', list.length);
    } catch (e, st) {
      AppLog.error('Completions sync failed', e, st);
    }
  }

  List<GoalCompletion> listSync() {
    final items = _box.values.toList(growable: false);
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  bool containsId(String id) => _box.containsKey(id);

  Future<void> upsert(GoalCompletion completion) async {
    final uid = _userId;
    if (SupabaseConfig.isConfigured && uid != null) {
      try {
        await _client.from('completions').upsert({
          'id': completion.id,
          'goal_id': completion.goalId,
          'user_id': uid,
          'earned_xp': completion.earnedXp,
          'completed_at': (completion.completedAt ?? completion.date).toIso8601String(),
        });
      } catch (e, st) {
        AppLog.error('Completion upsert failed', e, st);
        rethrow;
      }
    }
    await _box.put(completion.id, completion);
    AppLog.debug('Completion upsert', completion.id);
  }

  GoalCompletion _completionFromRow(Map<String, dynamic> row) {
    final completedAt = DateTime.parse(row['completed_at'] as String);
    return GoalCompletion(
      id: row['id'] as String,
      goalId: row['goal_id'] as String,
      date: DateTime(completedAt.year, completedAt.month, completedAt.day),
      earnedXp: (row['earned_xp'] as num?)?.toInt() ?? 0,
      completedAt: completedAt,
    );
  }
}
