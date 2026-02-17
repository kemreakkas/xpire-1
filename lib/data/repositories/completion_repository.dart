import 'package:hive/hive.dart';

import '../../core/log/app_log.dart';
import '../models/goal_completion.dart';

class CompletionRepository {
  CompletionRepository(this._box);

  final Box<GoalCompletion> _box;

  List<GoalCompletion> listSync() {
    final items = _box.values.toList(growable: false);
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  bool containsId(String id) => _box.containsKey(id);

  Future<void> upsert(GoalCompletion completion) async {
    await _box.put(completion.id, completion);
    AppLog.debug('Completion upsert', completion.id);
  }
}
