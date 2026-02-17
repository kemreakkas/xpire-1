import 'package:hive/hive.dart';

import '../../core/log/app_log.dart';
import '../models/active_challenge.dart';

class ChallengeProgressRepository {
  ChallengeProgressRepository(this._box);

  static const String _currentKey = 'current';

  final Box<ActiveChallenge> _box;

  ActiveChallenge? getCurrent() => _box.get(_currentKey);

  Future<void> setCurrent(ActiveChallenge? value) async {
    if (value == null) {
      await _box.delete(_currentKey);
    } else {
      await _box.put(_currentKey, value);
    }
    AppLog.debug('Active challenge updated', value?.challengeId);
  }

  Future<void> clear() async => setCurrent(null);
}
