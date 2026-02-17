import 'package:hive/hive.dart';

import '../../core/log/app_log.dart';
import '../models/user_profile.dart';

/// Abstract profile storage used by PremiumService and others.
abstract class IProfileRepository {
  Future<UserProfile> loadOrCreate();
  UserProfile? readSync();
  Future<void> save(UserProfile profile);
}

class ProfileRepository implements IProfileRepository {
  ProfileRepository(this._box);

  static const String _key = 'me';

  final Box<UserProfile> _box;

  Future<UserProfile> loadOrCreate() async {
    final existing = _box.get(_key);
    if (existing != null) return existing;

    final created = UserProfile.initial();
    await _box.put(_key, created);
    AppLog.info('Profile created');
    return created;
  }

  UserProfile? readSync() => _box.get(_key);

  Future<void> save(UserProfile profile) async {
    await _box.put(_key, profile);
    AppLog.debug('Profile saved', {
      'level': profile.level,
      'totalXp': profile.totalXp,
    });
  }
}
