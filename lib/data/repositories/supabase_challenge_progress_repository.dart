import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/challenge_progress.dart';

/// Challenge progress backed by `challenge_participants` (schema has no challenge_progress table).
/// One active participation per user; maps to ChallengeProgress for engine compatibility.
class SupabaseChallengeProgressRepository {
  SupabaseChallengeProgressRepository();

  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Active = not completed. From challenge_participants.
  Future<ChallengeProgress?> getActive(String userId) async {
    if (!SupabaseConfig.isConfigured) return null;
    try {
      final res = await _client
          .from('challenge_participants')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('joined_at', ascending: false)
          .limit(1);
      final list = res as List<dynamic>;
      if (list.isEmpty) return null;
      final row = list.first;
      if (row == null) return null;
      return _fromParticipantRow(row as Map<String, dynamic>);
    } catch (e, st) {
      AppLog.error('Challenge progress getActive failed', e, st);
      return null;
    }
  }

  /// Update existing challenge_participants row (e.g. after day completed). No insert for template challenges.
  Future<void> upsert(ChallengeProgress progress) async {
    if (!SupabaseConfig.isConfigured) return;
    final uid = _userId;
    if (uid == null || progress.userId != uid) return;
    try {
      await _client.from('challenge_participants').update({
        'current_day': progress.currentDay,
        'completed_days': progress.completedDays,
        'is_completed': progress.isCompleted,
      }).eq('id', progress.id).eq('user_id', uid);
      AppLog.debug('Challenge progress upsert', progress.id);
    } catch (e, st) {
      AppLog.error('Challenge progress upsert failed', e, st);
      rethrow;
    }
  }

  /// Count completed from challenge_participants.
  Future<int> countCompleted(String userId) async {
    if (!SupabaseConfig.isConfigured) return 0;
    try {
      final res = await _client
          .from('challenge_participants')
          .select('id')
          .eq('user_id', userId)
          .eq('is_completed', true);
      final list = res as List<dynamic>;
      return list.length;
    } catch (e, st) {
      AppLog.error('Challenge progress countCompleted failed', e, st);
      return 0;
    }
  }

  ChallengeProgress _fromParticipantRow(Map<String, dynamic> row) {
    return ChallengeProgress(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      challengeId: row['challenge_id'] as String,
      startedAt: DateTime.parse(row['joined_at'] as String),
      currentDay: (row['current_day'] as num?)?.toInt() ?? 1,
      completedDays: (row['completed_days'] as num?)?.toInt() ?? 0,
      isCompleted: (row['is_completed'] as bool?) ?? false,
      failedAt: null,
      completedAt: null,
      goalIds: null,
    );
  }
}
