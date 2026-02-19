import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_config.dart';
import '../../core/log/app_log.dart';
import '../../data/models/goal.dart';
import '../../features/auth/auth_controller.dart';
import '../../state/providers.dart';

/// Onboarding area options (Step 1). Maps to [GoalCategory] for starter goals.
enum OnboardingArea {
  fitness,
  study,
  career,
  discipline,
  mentalHealth,
}

/// Daily time commitment (Step 2). Stored for future use; not yet used in logic.
enum OnboardingTimeCommitment {
  tenToTwenty,
  thirtyToFortyFive,
  oneHourPlus,
}

/// State for the multi-step onboarding flow.
class OnboardingState {
  const OnboardingState({
    this.step = 1,
    this.area,
    this.timeCommitment,
    this.mainGoalText,
    this.isSubmitting = false,
    this.error,
  });

  final int step;
  final OnboardingArea? area;
  final OnboardingTimeCommitment? timeCommitment;
  final String? mainGoalText;
  final bool isSubmitting;
  final String? error;

  OnboardingState copyWith({
    int? step,
    OnboardingArea? area,
    OnboardingTimeCommitment? timeCommitment,
    String? mainGoalText,
    bool? isSubmitting,
    String? error,
  }) {
    return OnboardingState(
      step: step ?? this.step,
      area: area ?? this.area,
      timeCommitment: timeCommitment ?? this.timeCommitment,
      mainGoalText: mainGoalText ?? this.mainGoalText,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

/// Maps onboarding area to GoalCategory for starter content.
GoalCategory _areaToCategory(OnboardingArea area) {
  return switch (area) {
    OnboardingArea.fitness => GoalCategory.fitness,
    OnboardingArea.study => GoalCategory.study,
    OnboardingArea.career => GoalCategory.work,
    OnboardingArea.discipline => GoalCategory.discipline,
    OnboardingArea.mentalHealth => GoalCategory.mind,
  };
}

/// Starter content: 3 template IDs + 1 challenge ID per onboarding category.
final Map<OnboardingArea, ({List<String> templateIds, String challengeId})>
    _starterContent = {
  OnboardingArea.fitness: (
    templateIds: ['tpl_10k_steps', 'tpl_drink_8_glasses', 'tpl_50_pushups'],
    challengeId: 'ch_7day_fitness_reset',
  ),
  OnboardingArea.study: (
    templateIds: ['tpl_30min_reading', 'tpl_1hr_deep_work', 'tpl_flashcards_review'],
    challengeId: 'ch_7day_study_sprint',
  ),
  OnboardingArea.career: (
    templateIds: ['tpl_plan_tomorrow', 'tpl_pomodoro_4', 'tpl_complete_top_3'],
    challengeId: 'ch_14day_deep_work',
  ),
  OnboardingArea.discipline: (
    templateIds: ['tpl_wake_no_snooze', 'tpl_make_bed', 'tpl_one_thing_before_screen'],
    challengeId: 'ch_7day_discipline',
  ),
  OnboardingArea.mentalHealth: (
    templateIds: ['tpl_10min_meditation', 'tpl_gratitude_3', 'tpl_breathing_5min'],
    challengeId: 'ch_7day_digital_detox',
  ),
};

/// Custom titles for starter goals (optional overrides).
final Map<OnboardingArea, List<String?>> _starterGoalTitleOverrides = {
  OnboardingArea.fitness: ['8k Steps', '2L Water', '20 Push-Ups'],
  OnboardingArea.study: [null, null, null],
  OnboardingArea.career: [null, null, null],
  OnboardingArea.discipline: [null, null, null],
  OnboardingArea.mentalHealth: [null, null, null],
};

class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setStep(int step) {
    state = state.copyWith(step: step, error: null);
  }

  void setArea(OnboardingArea area) {
    state = state.copyWith(area: area, error: null);
  }

  void setTimeCommitment(OnboardingTimeCommitment value) {
    state = state.copyWith(timeCommitment: value, error: null);
  }

  void setMainGoalText(String? text) {
    state = state.copyWith(mainGoalText: text, error: null);
  }

  void nextStep() {
    if (state.step < 3) {
      state = state.copyWith(step: state.step + 1, error: null);
    }
  }

  void previousStep() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1, error: null);
    }
  }

  /// Completes onboarding: saves onboarding_completed + focus_category, creates 3 goals + 1 challenge, then invalidates profile/goals.
  Future<void> completeOnboarding() async {
    final area = state.area;
    if (area == null) {
      state = state.copyWith(error: 'Please select an area.');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final profile = ref.read(profileControllerProvider).value;
      if (profile == null) {
        state = state.copyWith(isSubmitting: false, error: 'Profile not loaded.');
        return;
      }

      final category = _areaToCategory(area);
      final updatedProfile = profile.copyWith(
        onboardingCompleted: true,
        focusCategory: category,
      );
      await profileRepo.save(updatedProfile);

      if (SupabaseConfig.isConfigured) {
        await _createStarterGoalsAndChallenge(area, category);
      }
      ref.invalidate(profileControllerProvider);
      ref.invalidate(goalsControllerProvider);
      ref.invalidate(activeChallengeProgressModelProvider);
      state = state.copyWith(isSubmitting: false);
    } catch (e, st) {
      AppLog.error('Onboarding complete failed', e, st);
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _createStarterGoalsAndChallenge(
    OnboardingArea area,
    GoalCategory category,
  ) async {
    final content = ref.read(contentRepositoryProvider);
    final goalRepo = ref.read(goalRepositoryProvider);
    final engine = ref.read(challengeEngineProvider);
    final userId = ref.read(authUserIdProvider);
    if (userId == null) return;

    final config = _starterContent[area];
    if (config == null) return;

    final overrides = _starterGoalTitleOverrides[area] ?? [null, null, null];
    final now = DateTime.now();
    const uuid = Uuid();
    for (var i = 0; i < config.templateIds.length; i++) {
      final t = content.getTemplateById(config.templateIds[i]);
      if (t == null) continue;
      final title = i < overrides.length && overrides[i] != null
          ? overrides[i]!
          : t.title;
      final goal = Goal(
        id: uuid.v4(),
        title: title,
        category: t.category,
        difficulty: t.difficulty,
        baseXp: t.baseXp,
        isActive: true,
        createdAt: now,
      );
      await goalRepo.upsert(goal);
    }

    final challenge = content.getChallengeById(config.challengeId);
    if (challenge != null) {
      await engine.startChallenge(userId: userId, challenge: challenge);
    }
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);
