import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_radius.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import 'onboarding_controller.dart';

/// Breakpoint for web two-panel layout (left branding, right form).
const double _kWebWideBreakpoint = 900;

/// Smart Onboarding: shown on first login when onboarding_completed == false.
/// Steps: area → time commitment → main goal (optional). On complete: save flag, create 3 goals + 1 challenge.
/// Web (wide): Center > ConstrainedBox(900) > Row(left branding, right form Card). No FAB. Mobile: unchanged.
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _mainGoalController = TextEditingController();

  @override
  void dispose() {
    _mainGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final width = MediaQuery.sizeOf(context).width;
    final isWebWide = width >= _kWebWideBreakpoint;

    return Scaffold(
      body: SafeArea(
        child: isWebWide
            ? _buildWebWideLayout(context, state)
            : _buildMobileLayout(context, state),
      ),
    );
  }

  /// Web: Center > ConstrainedBox(900) > Row(left branding, right form Card). No floating button.
  Widget _buildWebWideLayout(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl + AppSpacing.lg,
            vertical: AppSpacing.xxl + AppSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildLeftPanel(context, theme),
              ),
              const SizedBox(width: AppSpacing.xxl + AppSpacing.lg),
              Expanded(
                flex: 1,
                child: _buildRightPanelCard(context, state, theme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Xpire',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Level up your life. Set goals, earn XP, and build habits that stick.',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl + AppSpacing.lg),
        _buildMinimalGraphic(theme),
      ],
    );
  }

  Widget _buildMinimalGraphic(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.lgRadius,
      ),
      child: Icon(
        Icons.rocket_launch_rounded,
        size: 80,
        color: AppTheme.accent.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildRightPanelCard(
    BuildContext context,
    OnboardingState state,
    ThemeData theme,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lgRadius,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _stepSubtitle(state.step),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            if (state.error != null) ...[
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: AppRadius.mdRadius,
                ),
                child: Text(
                  state.error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            _buildStepContent(context, state),
            const SizedBox(height: AppSpacing.xxl),
            _buildBottomActions(context, state, alignRight: true),
          ],
        ),
      ),
    );
  }

  /// Mobile: unchanged single-column layout.
  Widget _buildMobileLayout(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Welcome to Xpire',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _stepSubtitle(state.step),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (state.error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: AppRadius.mdRadius,
              ),
              child: Text(
                state.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Expanded(
            child: SingleChildScrollView(
              child: _buildStepContent(context, state),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildBottomActions(context, state, alignRight: false),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  String _stepSubtitle(int step) {
    return switch (step) {
      1 => "What area do you want to improve?",
      2 => "How much time can you commit daily?",
      3 => "What is your main goal? (optional)",
      _ => "",
    };
  }

  Widget _buildStepContent(BuildContext context, OnboardingState state) {
    final theme = Theme.of(context);
    switch (state.step) {
      case 1:
        return _buildAreaStep(theme);
      case 2:
        return _buildTimeStep(theme);
      case 3:
        return _buildMainGoalStep(theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAreaStep(ThemeData theme) {
    final state = ref.watch(onboardingControllerProvider);
    final areas = [
      (OnboardingArea.fitness, 'Fitness', Icons.fitness_center),
      (OnboardingArea.study, 'Study', Icons.school_outlined),
      (OnboardingArea.career, 'Career', Icons.work_outline),
      (
        OnboardingArea.discipline,
        'Discipline',
        Icons.self_improvement_outlined,
      ),
      (OnboardingArea.mentalHealth, 'Mental Health', Icons.psychology_outlined),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: areas.map((e) {
        final selected = state.area == e.$1;
        return FilterChip(
          selected: selected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(e.$3, size: 20, color: selected ? AppTheme.accent : null),
              const SizedBox(width: 8),
              Text(e.$2),
            ],
          ),
          onSelected: (_) =>
              ref.read(onboardingControllerProvider.notifier).setArea(e.$1),
        );
      }).toList(),
    );
  }

  Widget _buildTimeStep(ThemeData theme) {
    final state = ref.watch(onboardingControllerProvider);
    final options = [
      (OnboardingTimeCommitment.tenToTwenty, '10–20 min'),
      (OnboardingTimeCommitment.thirtyToFortyFive, '30–45 min'),
      (OnboardingTimeCommitment.oneHourPlus, '1+ hour'),
    ];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: options.map((e) {
        final selected = state.timeCommitment == e.$1;
        return ChoiceChip(
          selected: selected,
          label: Text(e.$2),
          onSelected: (_) => ref
              .read(onboardingControllerProvider.notifier)
              .setTimeCommitment(e.$1),
        );
      }).toList(),
    );
  }

  Widget _buildMainGoalStep(ThemeData theme) {
    return TextField(
      controller: _mainGoalController,
      decoration: const InputDecoration(
        hintText: "e.g. Build a daily reading habit",
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      onChanged: (v) => ref
          .read(onboardingControllerProvider.notifier)
          .setMainGoalText(v.isEmpty ? null : v),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    OnboardingState state, {
    required bool alignRight,
  }) {
    final isFirst = state.step == 1;
    final isLast = state.step == 3;

    final nextOrSubmit = isLast
        ? FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => ref
                      .read(onboardingControllerProvider.notifier)
                      .completeOnboarding(),
            child: state.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Get started'),
          )
        : FilledButton(
            onPressed: state.isSubmitting
                ? null
                : () => ref
                      .read(onboardingControllerProvider.notifier)
                      .nextStep(),
            child: const Text('Next'),
          );

    if (alignRight) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isFirst)
            TextButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => ref
                        .read(onboardingControllerProvider.notifier)
                        .previousStep(),
              child: const Text('Back'),
            ),
          if (!isFirst) const SizedBox(width: AppSpacing.sm),
          nextOrSubmit,
        ],
      );
    }

    return Row(
      children: [
        if (!isFirst)
          TextButton(
            onPressed: state.isSubmitting
                ? null
                : () => ref
                      .read(onboardingControllerProvider.notifier)
                      .previousStep(),
            child: const Text('Back'),
          ),
        const Spacer(),
        nextOrSubmit,
      ],
    );
  }
}
