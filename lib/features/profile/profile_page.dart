import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/ui/app_spacing.dart';
import '../../data/models/goal.dart';
import '../../features/auth/auth_controller.dart';
import '../../features/premium/premium_page.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _occupationController;
  GoalCategory? _focusCategory;
  bool _controllersInitialized = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _initFromProfile(dynamic p) {
    if (_controllersInitialized) return;
    _controllersInitialized = true;
    _fullNameController =
        TextEditingController(text: p.fullName ?? '');
    _usernameController =
        TextEditingController(text: p.username ?? '');
    _ageController = TextEditingController(
        text: p.age != null ? '${p.age}' : '');
    _occupationController =
        TextEditingController(text: p.occupation ?? '');
    _focusCategory = p.focusCategory;
  }

  Future<void> _saveProfile() async {
    final p = ref.read(profileControllerProvider).value;
    if (p == null) return;
    final ageStr = _ageController.text.trim();
    int? age;
    if (ageStr.isNotEmpty) {
      age = int.tryParse(ageStr);
    }
    final updated = p.copyWith(
      fullName: _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim(),
      username: _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim(),
      age: age,
      occupation: _occupationController.text.trim().isEmpty
          ? null
          : _occupationController.text.trim(),
      focusCategory: _focusCategory,
    );
    await ref.read(profileControllerProvider.notifier).save(updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAv = ref.watch(profileControllerProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.grid),
        child: profileAv.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (p) {
            _initFromProfile(p);
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLanguageSection(context, l10n, currentLocale),
                    const SizedBox(height: AppSpacing.sm),
                    _buildEditableSection(context, p, l10n),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.level,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p.level}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.totalXp,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${p.totalXp}',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.premium,
                                    style: Theme.of(context).textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.isPremiumEffective ? l10n.premiumActive : l10n.premiumNotActive,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              p.isPremiumEffective ? Icons.verified : Icons.lock_outline,
                              color: p.isPremiumEffective
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () => context.push(PremiumPage.routePath),
                        child: Text(l10n.upgradeToPremium),
                      ),
                    ),
                    if (SupabaseConfig.isConfigured) ...[
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        onPressed: () async {
                          await ref.read(authControllerProvider).logout();
                        },
                        child: Text(l10n.signOut),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations l10n, Locale? currentLocale) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<Locale?>(
              value: currentLocale,
              decoration: InputDecoration(
                labelText: l10n.language,
                hintText: l10n.language,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.systemDefault)),
                DropdownMenuItem(value: const Locale('en'), child: Text(l10n.english)),
                DropdownMenuItem(value: const Locale('tr'), child: Text(l10n.turkish)),
              ],
              onChanged: (v) {
                ref.read(localeProvider.notifier).setLocale(v);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSection(BuildContext context, dynamic p, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.yourInfo,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: l10n.fullName,
                hintText: l10n.optional,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.username,
                hintText: l10n.optional,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.age,
                hintText: l10n.optional,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _occupationController,
              decoration: InputDecoration(
                labelText: l10n.occupation,
                hintText: l10n.optional,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<GoalCategory?>(
              value: _focusCategory,
              decoration: InputDecoration(
                labelText: l10n.focusCategory,
                hintText: l10n.optional,
              ),
              items: [
                DropdownMenuItem<GoalCategory?>(
                  value: null,
                  child: Text(l10n.none),
                ),
                ...GoalCategory.values.map(
                  (c) => DropdownMenuItem<GoalCategory?>(
                    value: c,
                    child: Text(_categoryLabel(c, l10n)),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _focusCategory = v),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _saveProfile,
                child: Text(l10n.saveProfile),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _categoryLabel(GoalCategory c, AppLocalizations l10n) {
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
    };
  }
}
