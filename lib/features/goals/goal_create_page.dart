import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/analytics_service.dart';
import '../../core/ui/nav_helpers.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/responsive.dart';
import '../../core/ui/app_theme.dart';
import '../../data/models/goal.dart';
import '../../data/models/goal_template.dart';
import '../../l10n/app_localizations.dart';
import '../../core/ui/app_radius.dart';
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
  bool _isSaving = false;

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
    final l10n = AppLocalizations.of(context)!;
    final pendingId = ref.watch(pendingTemplateIdProvider);
    if (pendingId != null && !_pendingTemplateApplied) {
      _pendingTemplateApplied = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Can't call DefaultTabController.of(context) here because context doesn't contain it yet.
        // Needs a builder or we just ignore animating to 0 since custom form is already index 0.
        final content = ref.read(contentRepositoryProvider);
        final t = content.getTemplateById(pendingId);
        if (t != null && mounted) {
          _applyTemplate(t);
          ref.read(pendingTemplateIdProvider.notifier).set(null);
        } else {
          _pendingTemplateApplied = false;
        }
      });
    }
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.newGoal),
          automaticallyImplyLeading: shouldShowAppBarLeading(context),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.createCustom),
              Tab(text: l10n.useTemplate),
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
              l10n: l10n,
              isSaving: _isSaving,
              onCategoryChanged: (v) => setState(() => _category = v),
              onDifficultyChanged: (v) => setState(() => _difficulty = v),
              onSave: _saveGoal,
            ),
            _TemplateTab(
              categoryFilter: _templateCategoryFilter,
              l10n: l10n,
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
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
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
      ref.invalidate(goalsControllerProvider);
      if (!mounted) return;
      context.go('/dashboard');
    } catch (e, st) {
      debugPrint('Create goal error: $e');
      debugPrint('$st');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final message = e is Exception
            ? '${l10n.somethingWentWrong}: ${e.toString()}'
            : l10n.somethingWentWrong;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _CustomFormTab extends StatelessWidget {
  const _CustomFormTab({
    required this.formKey,
    required this.titleController,
    required this.category,
    required this.difficulty,
    required this.selectedTemplate,
    required this.l10n,
    required this.isSaving,
    required this.onCategoryChanged,
    required this.onDifficultyChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final GoalCategory category;
  final GoalDifficulty difficulty;
  final GoalTemplate? selectedTemplate;
  final AppLocalizations l10n;
  final bool isSaving;
  final ValueChanged<GoalCategory> onCategoryChanged;
  final ValueChanged<GoalDifficulty> onDifficultyChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isWebWide = Responsive.isWebWide(context);
    final formContent = Form(
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
                        l10n.fromTemplate(selectedTemplate!.title),
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
            decoration: InputDecoration(
              labelText: l10n.title,
              prefixIcon: const Icon(Icons.edit_note),
              border: OutlineInputBorder(borderRadius: AppRadius.mdRadius),
            ),
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return l10n.enterTitle;
              if (value.length < 3) return l10n.keepLonger;
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<GoalCategory>(
            initialValue: category,
            decoration: InputDecoration(
              labelText: l10n.category,
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(borderRadius: AppRadius.mdRadius),
            ),
            items: GoalCategory.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(_categoryLabel(l10n, c)),
                  ),
                )
                .toList(growable: false),
            onChanged: (v) => onCategoryChanged(v ?? category),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<GoalDifficulty>(
            initialValue: difficulty,
            decoration: InputDecoration(
              labelText: l10n.difficulty,
              prefixIcon: const Icon(Icons.speed_outlined),
              border: OutlineInputBorder(borderRadius: AppRadius.mdRadius),
            ),
            items: GoalDifficulty.values
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(_difficultyLabel(l10n, d)),
                  ),
                )
                .toList(growable: false),
            onChanged: (v) => onDifficultyChanged(v ?? difficulty),
          ),
          const Spacer(),
          if (isWebWide)
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 180,
                height: 52,
                child: FilledButton(
                  onPressed: isSaving ? null : onSave,
                  child: isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ),
            )
          else
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: isSaving ? null : onSave,
                child: isSaving
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ),
        ],
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.grid),
          child: formContent,
        ),
      ),
    );
  }
}

class _TemplateTab extends ConsumerWidget {
  const _TemplateTab({
    required this.categoryFilter,
    required this.l10n,
    required this.onCategoryFilterChanged,
    required this.onTemplateTap,
  });

  final GoalCategory? categoryFilter;
  final AppLocalizations l10n;
  final ValueChanged<GoalCategory?> onCategoryFilterChanged;
  final ValueChanged<GoalTemplate> onTemplateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentRepositoryProvider);
    final templates = categoryFilter == null
        ? content.getTemplates()
        : content.getTemplatesByCategory(categoryFilter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.grid),
          child: DropdownButtonFormField<GoalCategory?>(
            initialValue: categoryFilter,
            decoration: InputDecoration(labelText: l10n.category),
            items: [
              DropdownMenuItem<GoalCategory?>(
                value: null,
                child: Text(l10n.all),
              ),
              ...GoalCategory.values.map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(_categoryLabel(l10n, c)),
                ),
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
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _TemplateCard(
                  template: t,
                  l10n: l10n,
                  onTap: () {
                    onTemplateTap(t);
                    DefaultTabController.of(context).animateTo(0);
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
    required this.l10n,
    required this.onTap,
  });

  final GoalTemplate template;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                  Text(
                    l10n.xpCount(template.baseXp),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                    ),
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
                  _Chip(text: _categoryLabel(l10n, template.category)),
                  _Chip(text: _difficultyLabel(l10n, template.difficulty)),
                  _Chip(
                    text: template.frequency == TemplateFrequency.daily
                        ? l10n.daily
                        : l10n.weekly,
                  ),
                ],
              ),
            ],
          ),
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

String _categoryLabel(AppLocalizations l10n, GoalCategory c) {
  return switch (c) {
    GoalCategory.fitness => l10n.fitness,
    GoalCategory.study => l10n.study,
    GoalCategory.work => l10n.work,
    GoalCategory.focus => l10n.focus,
    GoalCategory.mind => l10n.mind,
    GoalCategory.health => l10n.health,
    GoalCategory.finance => l10n.finance,
    GoalCategory.selfGrowth => l10n.selfGrowth,
    GoalCategory.general => l10n.general,
    GoalCategory.digitalDetox => l10n.digitalDetox,
    GoalCategory.social => l10n.social,
    GoalCategory.creativity => l10n.creativity,
    GoalCategory.discipline => l10n.discipline,
  };
}

String _difficultyLabel(AppLocalizations l10n, GoalDifficulty d) {
  return switch (d) {
    GoalDifficulty.easy => l10n.easyXp,
    GoalDifficulty.medium => l10n.mediumXp,
    GoalDifficulty.hard => l10n.hardXp,
  };
}
