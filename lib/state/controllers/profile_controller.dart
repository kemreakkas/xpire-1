import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/log/app_log.dart';
import '../../data/models/user_profile.dart';
import '../../features/auth/auth_controller.dart';
import '../providers.dart';

class ProfileController extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    ref.watch(authUserIdProvider);
    final repo = ref.watch(profileRepositoryProvider);
    return repo.loadOrCreate();
  }

  Future<void> save(UserProfile profile) async {
    state = const AsyncLoading<UserProfile>();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.save(profile);
      AppLog.debug('Profile saved', profile.totalXp);
      return profile;
    });
  }
}
