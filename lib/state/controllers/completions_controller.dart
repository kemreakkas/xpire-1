import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/goal_completion.dart';
import '../../features/auth/auth_controller.dart';
import '../providers.dart';

class CompletionsController extends AsyncNotifier<List<GoalCompletion>> {
  @override
  Future<List<GoalCompletion>> build() async {
    ref.watch(authUserIdProvider);
    final repo = ref.read(completionRepositoryProvider);
    await repo.syncFromCloud();
    return repo.listSync();
  }
}
