import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/challenge_progress.dart';

/// Challenge progress: Supabase-first. One active progress per user.
class SupabaseChallengeProgressRepository {
  SupabaseChallengeProgressRepository();

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Active = not completed, not failed.
  Future<ChallengeProgress?> getActive(String userId) async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      final res = await _client
          .from('challenge_progress')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false);
      final list = res as List<dynamic>;
      for (final row in list) {
        if (row == null) continue;
        final r = row as Map<String, dynamic>;
        if (r['failed_at'] != null) continue;
        return _fromRow(r);
      }
      return null;
    } catch (e, st) {
      AppLog.error('Challenge progress getActive failed', e, st);
      return null;
    }
  }

  Future<void> upsert(ChallengeProgress progress) async {
    if (!SupabaseConfig.isConfigured) return;
    final uid = _userId;
    if (uid == null || progress.userId != uid) return;
    try {
      await _client.from('challenge_progress').upsert({
        'id': progress.id,
        'user_id': progress.userId,
        'challenge_id': progress.challengeId,
        'started_at': progress.startedAt.toIso8601String(),
        'completed_at': progress.completedAt?.toIso8601String(),
        'progress_days': progress.completedDays,
        'is_completed': progress.isCompleted,
        'current_day': progress.currentDay,
        'failed_at': progress.failedAt?.toIso8601String(),
        'goal_ids': progress.goalIds,
      });
      AppLog.debug('Challenge progress upsert', progress.id);
    } catch (e, st) {
      AppLog.error('Challenge progress upsert failed', e, st);
      rethrow;
    }
  }

  /// Count of completed challenges for stats.
  Future<int> countCompleted(String userId) async {
    if (!SupabaseConfig.isConfigured) return 0;
    try {
      final res = await _client
          .from('challenge_progress')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', true);
      final list = res as List<dynamic>;
      return list.length;
    } catch (e, st) {
      AppLog.error('Challenge progress countCompleted failed', e, st);
      return 0;
    }
  }

  ChallengeProgress _fromRow(Map<String, dynamic> row) {
    final goalIdsRaw = row['goal_ids'];
    final goalIds = goalIdsRaw != null && goalIdsRaw is List
        ? List<String>.from(goalIdsRaw.map((e) => e.toString()))
        : null;
    return ChallengeProgress(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      challengeId: row['challenge_id'] as String,
      startedAt: DateTime.parse(row['started_at'] as String),
      currentDay: (row['current_day'] as num?)?.toInt() ?? 1,
      completedDays: (row['progress_days'] as num?)?.toInt() ?? 0,
      isCompleted: (row['is_completed'] as bool?) ?? false,
      failedAt: row['failed_at'] != null
          ? DateTime.parse(row['failed_at'] as String)
          : null,
      completedAt: row['completed_at'] != null
          ? DateTime.parse(row['completed_at'] as String)
          : null,
      goalIds: goalIds,
    );
  }
}
