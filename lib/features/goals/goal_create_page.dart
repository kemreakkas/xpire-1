import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/analytics_service.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_template.dart';
import '../../features/premium/premium_controller.dart';
import '../../features/premium/premium_page.dart';
import '../../state/providers.dart';

class GoalCreatePage extends ConsumerStatefulWidget {
  const GoalCreatePage({super.key});

  @override
  ConsumerState<GoalCreatePage> createState() => _GoalCreatePageState();
}

class _GoalCreatePageState extends ConsumerState<GoalCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  GoalCategory _category = GoalCategory.general;
  GoalDifficulty _difficulty = GoalDifficulty.easy;
  GoalTemplate? _selectedTemplate;
  GoalCategory? _templateCategoryFilter;
  bool _pendingTemplateApplied = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _applyTemplate(GoalTemplate t) {
    setState(() {
      _selectedTemplate = t;
      _titleController.text = t.title;
      _category = t.category;
      _difficulty = t.difficulty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingId = ref.watch(pendingTemplateIdProvider);
    if (pendingId != null && !_pendingTemplateApplied) {
      _pendingTemplateApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final content = ref.read(contentRepositoryProvider);
        final t = content.getTemplateById(pendingId);
        if (t != null && mounted) {
          _applyTemplate(t);
          ref.read(pendingTemplateIdProvider.notifier).set(null);
          DefaultTabController.of(context).animateTo(0);
        } else {
          _pendingTemplateApplied = false;
        }
      });
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New goal'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Create Custom'),
              Tab(text: 'Use Template'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CustomFormTab(
              formKey: _formKey,
              titleController: _titleController,
              category: _category,
              difficulty: _difficulty,
              selectedTemplate: _selectedTemplate,
              onCategoryChanged: (v) => setState(() => _category = v),
              onDifficultyChanged: (v) => setState(() => _difficulty = v),
              onSave: _saveGoal,
            ),
            _TemplateTab(
              categoryFilter: _templateCategoryFilter,
              onCategoryFilterChanged: (v) =>
                  setState(() => _templateCategoryFilter = v),
              onTemplateTap: _applyTemplate,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final canCreate = ref.read(PremiumController.canCreateGoalProvider);
    if (!canCreate) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Goal limit'),
          content: const Text('Upgrade to Premium to create unlimited goals.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push(PremiumPage.routePath);
              },
              child: const Text('Upgrade'),
            ),
          ],
        ),
      );
      return;
    }

    final xpService = ref.read(xpServiceProvider);
    final title = _titleController.text.trim();
    final now = DateTime.now();
    final baseXp =
        _selectedTemplate?.baseXp ?? xpService.earnedXpFor(_difficulty);

    final goal = Goal(
      id: const Uuid().v4(),
      title: title,
      category: _category,
      difficulty: _difficulty,
      baseXp: baseXp,
      isActive: true,
      createdAt: now,
    );

    await ref.read(goalsControllerProvider.notifier).addGoal(goal);
    ref.read(analyticsServiceProvider).track(AnalyticsEvents.goalCreated, {
      'category': goal.category.name,
      'goal_id': goal.id,
    });
    setState(() => _selectedTemplate = null);
    if (!context.mounted) return;
    context.pop();
  }
}

class _CustomFormTab extends StatelessWidget {
  const _CustomFormTab({
    required this.formKey,
    required this.titleController,
    required this.category,
    required this.difficulty,
    required this.selectedTemplate,
    required this.onCategoryChanged,
    required this.onDifficultyChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final GoalCategory category;
  final GoalDifficulty difficulty;
  final GoalTemplate? selectedTemplate;
  final ValueChanged<GoalCategory> onCategoryChanged;
  final ValueChanged<GoalDifficulty> onDifficultyChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.grid),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (selectedTemplate != null)
              Card(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(Icons.flag, size: 20, color: AppTheme.accent),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'From template: ${selectedTemplate!.title}',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (selectedTemplate != null) const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: titleController,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Enter a title';
                if (value.length < 3) return 'Keep it a bit longer';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<GoalCategory>(
              value: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: GoalCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(_categoryLabel(c)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (v) => onCategoryChanged(v ?? category),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<GoalDifficulty>(
              value: difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: GoalDifficulty.values
                  .map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(_difficultyLabel(d)),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (v) => onDifficultyChanged(v ?? difficulty),
            ),
            const Spacer(),
            SizedBox(
              height: 52,
              child: FilledButton(onPressed: onSave, child: const Text('Save')),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateTab extends ConsumerWidget {
  const _TemplateTab({
    required this.categoryFilter,
    required this.onCategoryFilterChanged,
    required this.onTemplateTap,
  });

  final GoalCategory? categoryFilter;
  final ValueChanged<GoalCategory?> onCategoryFilterChanged;
  final ValueChanged<GoalTemplate> onTemplateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final templates = categoryFilter == null
        ? content.getTemplates()
        : content.getTemplatesByCategory(categoryFilter);
    final isPremium = ref.watch(PremiumController.isPremiumProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.grid),
          child: DropdownButtonFormField<GoalCategory?>(
            value: categoryFilter,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              const DropdownMenuItem<GoalCategory?>(
                value: null,
                child: Text('All'),
              ),
              ...GoalCategory.values.map(
                (c) =>
                    DropdownMenuItem(value: c, child: Text(_categoryLabel(c))),
              ),
            ],
            onChanged: onCategoryFilterChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.grid),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final t = templates[index];
              final locked = t.isPremium && !isPremium;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TemplateCard(
                  template: t,
                  isLocked: locked,
                  onTap: () {
                    if (locked) {
                      context.push(PremiumPage.routePath);
                    } else {
                      onTemplateTap(t);
                      DefaultTabController.of(context).animateTo(0);
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.template,
    required this.isLocked,
    required this.onTap,
  });

  final GoalTemplate template;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Opacity(
              opacity: isLocked ? 0.6 : 1,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        if (isLocked)
                          Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        if (!isLocked)
                          Text(
                            '${template.baseXp} XP',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _Chip(text: _categoryLabel(template.category)),
                        _Chip(text: _difficultyLabel(template.difficulty)),
                        _Chip(
                          text: template.frequency == TemplateFrequency.daily
                              ? 'Daily'
                              : 'Weekly',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

String _categoryLabel(GoalCategory c) {
  return switch (c) {
    GoalCategory.fitness => 'Fitness',
    GoalCategory.study => 'Study',
    GoalCategory.work => 'Work',
    GoalCategory.focus => 'Focus',
    GoalCategory.mind => 'Mind',
    GoalCategory.health => 'Health',
    GoalCategory.finance => 'Finance',
    GoalCategory.selfGrowth => 'Self Growth',
    GoalCategory.general => 'General',
  };
}

String _difficultyLabel(GoalDifficulty d) {
  return switch (d) {
    GoalDifficulty.easy => 'Easy (10 XP)',
    GoalDifficulty.medium => 'Medium (25 XP)',
    GoalDifficulty.hard => 'Hard (50 XP)',
  };
}
