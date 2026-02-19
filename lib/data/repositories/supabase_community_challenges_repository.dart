import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../models/community_challenge.dart';

/// Thrown when user has reached the daily challenge creation limit (2 per day).
class DailyChallengeLimitException implements Exception {
  @override
  String toString() => 'DailyChallengeLimitException';
}

/// Max challenges a user can create per day (UTC).
const int maxChallengesCreatedPerDay = 2;

/// Fetches public community challenges from Supabase `challenges` table.
class SupabaseCommunityChallengesRepository {
  SupabaseCommunityChallengesRepository();

  SupabaseClient get _client => Supabase.instance.client;
  String? get _userId => _client.auth.currentUser?.id;

  /// Count challenges created by [userId] today (UTC).
  Future<int> countCreatedTodayByUser(String userId) async {
    if (!SupabaseConfig.isConfigured) return 0;
    try {
      final now = DateTime.now().toUtc();
      final startOfToday = DateTime.utc(now.year, now.month, now.day);
      final startStr = startOfToday.toIso8601String();
      final res = await _client
          .from('challenges')
          .select('id')
          .eq('created_by', userId)
          .gte('created_at', startStr);
      final list = res as List<dynamic>;
      return list.length;
    } catch (e, st) {
      AppLog.error('Community challenges countCreatedToday failed', e, st);
      rethrow;
    }
  }

  /// Create a community challenge. Throws if user has already created 2 today (UTC).
  Future<CommunityChallenge> createChallenge({
    required String userId,
    required String title,
    required String description,
    required int durationDays,
    required int rewardXp,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw StateError('Supabase not configured');
    }
    if (userId != _userId) throw StateError('Not signed in');
    final count = await countCreatedTodayByUser(userId);
    if (count >= maxChallengesCreatedPerDay) {
      throw DailyChallengeLimitException();
    }
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final res = await _client.from('challenges').insert({
        'title': title,
        'description': description,
        'duration_days': durationDays,
        'reward_xp': rewardXp,
        'created_by': userId,
        'is_public': true,
        'created_at': now,
      }).select().single();
      AppLog.debug('Community challenge created', res['id']);
      return _fromRow(res);
    } catch (e, st) {
      if (e is DailyChallengeLimitException) rethrow;
      AppLog.error('Community challenges create failed', e, st);
      rethrow;
    }
  }

  /// Get challenges by ids (for resolving my active participants).
  Future<Map<String, CommunityChallenge>> getByIds(List<String> ids) async {
    if (!SupabaseConfig.isConfigured || ids.isEmpty) return {};
    try {
      final res = await _client
          .from('challenges')
          .select()
          .inFilter('id', ids);
      final list = res as List<dynamic>;
      final map = <String, CommunityChallenge>{};
      for (final row in list) {
        if (row == null) continue;
        final r = row as Map<String, dynamic>;
        final c = _fromRow(r);
        map[c.id] = c;
      }
      return map;
    } catch (e, st) {
      AppLog.error('Community challenges getByIds failed', e, st);
      return {};
    }
  }

  /// List public challenges (from challenges table).
  Future<List<CommunityChallenge>> listPublic() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final res = await _client
          .from('challenges')
          .select()
          .eq('is_public', true)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(_fromRow)
          .toList(growable: false);
    } catch (e, st) {
      AppLog.error('Community challenges listPublic failed', e, st);
      rethrow;
    }
  }

  /// List public challenges with participant count from challenge_with_counts view.
  Future<List<({CommunityChallenge challenge, int participantCount})>> listPublicWithCounts() async {
    if (!SupabaseConfig.isConfigured) return [];
    try {
      final res = await _client
          .from('challenge_with_counts')
          .select()
          .eq('is_public', true)
          .order('created_at', ascending: false);
      final list = res as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map((row) {
            final c = _fromRow(row);
            final count = (row['participant_count'] as num?)?.toInt() ?? (row['count'] as num?)?.toInt() ?? 0;
            return (challenge: c, participantCount: count);
          })
          .toList(growable: false);
    } catch (e, st) {
      AppLog.error('Community challenges listPublicWithCounts failed', e, st);
      return [];
    }
  }

  CommunityChallenge _fromRow(Map<String, dynamic> row) {
    return CommunityChallenge(
      id: row['id'] as String,
      title: row['title'] as String,
      description: row['description'] as String? ?? '',
      durationDays: (row['duration_days'] as num?)?.toInt() ?? 7,
      rewardXp: (row['reward_xp'] as num?)?.toInt() ?? 0,
      createdBy: row['created_by'] as String?,
      isPublic: (row['is_public'] as bool?) ?? true,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : null,
    );
  }
}
