import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/challenge_participant.dart';

/// Challenge participants: list my active, join, count by challenge.
class SupabaseChallengeParticipantsRepository {
  SupabaseChallengeParticipantsRepository();

  SupabaseClient? get _client =>
      SupabaseConfig.isConfigured ? Supabase.instance.client : null;

  String? get _userId => _client?.auth.currentUser?.id;

  static const _uuid = Uuid();

  /// My active participants (is_completed = false).
  Future<List<ChallengeParticipant>> listMyActive(String userId) async {
    if (!SupabaseConfig.isConfigured) return [];
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client
          .from('challenge_participants')
          .select()
          .eq('user_id', userId)
          .eq('is_completed', false)
          .order('joined_at', ascending: false);
      final list = res as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_fromRow)
          .toList(growable: false);
    } catch (e, st) {
      AppLog.error('Challenge participants listMyActive failed', e, st);
      return [];
    }
  }

  /// Participant counts per challenge_id (for community list).
  Future<Map<String, int>> getParticipantCounts(
    List<String> challengeIds,
  ) async {
    if (!SupabaseConfig.isConfigured || challengeIds.isEmpty) {
      return {for (final id in challengeIds) id: 0};
    }
    final client = _client;
    if (client == null) return {for (final id in challengeIds) id: 0};
    try {
      final counts = <String, int>{for (final id in challengeIds) id: 0};
      final res = await client
          .from('challenge_participants')
          .select('challenge_id')
          .inFilter('challenge_id', challengeIds);
      final list = res as List<dynamic>;
      for (final row in list) {
        if (row == null) continue;
        final r = row as Map<String, dynamic>;
        final cid = r['challenge_id'] as String?;
        if (cid != null && counts.containsKey(cid)) {
          counts[cid] = counts[cid]! + 1;
        }
      }
      return counts;
    } catch (e, st) {
      AppLog.error('Challenge participants getParticipantCounts failed', e, st);
      return {for (final id in challengeIds) id: 0};
    }
  }

  /// Join a challenge: insert into challenge_participants.
  Future<ChallengeParticipant?> join(String userId, String challengeId) async {
    if (!SupabaseConfig.isConfigured) return null;
    final client = _client;
    final uid = _userId;
    if (client == null || uid == null || userId != uid) return null;
    try {
      final id = _uuid.v4();
      final now = DateTime.now().toUtc().toIso8601String();
      await client.from('challenge_participants').insert({
        'id': id,
        'challenge_id': challengeId,
        'user_id': userId,
        'current_day': 1,
        'completed_days': 0,
        'joined_at': now,
        'is_completed': false,
      });
      return ChallengeParticipant(
        id: id,
        challengeId: challengeId,
        userId: userId,
        currentDay: 1,
        completedDays: 0,
        joinedAt: DateTime.parse(now),
        isCompleted: false,
      );
    } catch (e, st) {
      AppLog.error('Challenge participants join failed', e, st);
      rethrow;
    }
  }

  /// Leave a challenge: delete from challenge_participants.
  Future<void> leave(String userId, String challengeId) async {
    if (!SupabaseConfig.isConfigured) return;
    final client = _client;
    final uid = _userId;
    if (client == null || uid == null || userId != uid) return;
    try {
      await client
          .from('challenge_participants')
          .delete()
          .eq('user_id', userId)
          .eq('challenge_id', challengeId);
    } catch (e, st) {
      AppLog.error('Challenge participants leave failed', e, st);
      rethrow;
    }
  }

  /// Check if user has already joined a challenge (any row for user_id + challenge_id).
  Future<bool> hasJoined(String userId, String challengeId) async {
    if (!SupabaseConfig.isConfigured) return false;
    final client = _client;
    if (client == null) return false;
    try {
      final res = await client
          .from('challenge_participants')
          .select('id')
          .eq('user_id', userId)
          .eq('challenge_id', challengeId)
          .limit(1);
      final list = res as List<dynamic>;
      return list.isNotEmpty;
    } catch (e, st) {
      AppLog.error('Challenge participants hasJoined failed', e, st);
      return false;
    }
  }

  ChallengeParticipant _fromRow(Map<String, dynamic> row) {
    return ChallengeParticipant(
      id: row['id'] as String,
      challengeId: row['challenge_id'] as String,
      userId: row['user_id'] as String,
      currentDay: (row['current_day'] as num?)?.toInt() ?? 1,
      completedDays: (row['completed_days'] as num?)?.toInt() ?? 0,
      joinedAt: DateTime.parse(row['joined_at'] as String),
      isCompleted: (row['is_completed'] as bool?) ?? false,
    );
  }
}
