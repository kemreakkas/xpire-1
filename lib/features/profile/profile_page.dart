import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/config/supabase_config.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/app_theme.dart';
import '../../core/ui/avatar_aura.dart';
import '../../core/ui/gamification.dart';
import '../../core/ui/nav_helpers.dart';
import '../../core/ui/responsive.dart';
import '../../data/models/goal.dart';
import '../../data/models/user_profile.dart';
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
    _fullNameController = TextEditingController(text: p.fullName ?? '');
    _usernameController = TextEditingController(text: p.username ?? '');
    _ageController = TextEditingController(
      text: p.age != null ? '${p.age}' : '',
    );
    _occupationController = TextEditingController(text: p.occupation ?? '');
    _focusCategory = p.focusCategory;
  }

  Future<void> _saveProfile() async {
    final p = ref.read(profileControllerProvider).value;
    if (p == null) return;
    final ageStr = _ageController.text.trim();
    int? age;
    if (ageStr.isNotEmpty) {
      final parsed = int.tryParse(ageStr);
      if (parsed != null && parsed >= 0 && parsed <= 99) {
        age = parsed;
      }
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

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.grid),
      child: profileAv.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (p) {
          _initFromProfile(p);
          final formContent = SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileHeader(context, p, l10n),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLanguageSection(context, l10n, currentLocale),
                  const SizedBox(height: AppSpacing.sm),
                  _buildEditableSection(context, p, l10n),
                  const SizedBox(height: AppSpacing.sm),
                  _buildReminderSection(context, p, l10n),
                  const SizedBox(height: AppSpacing.lg),
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
                                  p.isPremiumEffective
                                      ? l10n.premiumActive
                                      : l10n.premiumNotActive,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            p.isPremiumEffective
                                ? Icons.verified
                                : Icons.lock_outline,
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
                      onPressed: () => goOrPush(context, PremiumPage.routePath),
                      child: Text(l10n.upgradeToPremium),
                    ),
                  ),
                  if (SupabaseConfig.isConfigured) ...[
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(logoutAndClearProvider)();
                      },
                      child: Text(l10n.signOut),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final version = snapshot.data?.version ?? '—';
                      final build = snapshot.data?.buildNumber ?? '';
                      final versionStr = build.isEmpty
                          ? version
                          : '$version ($build)';
                      return Text(
                        versionStr,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
          if (Responsive.isWebWide(context)) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: formContent,
                  ),
                ),
              ),
            );
          }
          return formContent;
        },
      ),
    );
  }

  Future<void> _saveReminderSettings({
    required bool reminderEnabled,
    required String reminderTime,
  }) async {
    final p = ref.read(profileControllerProvider).value;
    if (p == null) return;

    final profileNotifier = ref.read(profileControllerProvider.notifier);
    final notificationService = ref.read(notificationServiceProvider);

    final updated = p.copyWith(
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
    );
    await profileNotifier.save(updated);
    if (notificationService.isSupported) {
      if (reminderEnabled) {
        await notificationService.scheduleDailyReminder(
          reminderTime: reminderTime,
          streak: p.streak,
        );
      } else {
        await notificationService.cancelDailyReminder();
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profileSaved)),
      );
    }
  }

  Widget _buildReminderSection(
    BuildContext context,
    dynamic p,
    AppLocalizations l10n,
  ) {
    final parts = (p.reminderTime as String).split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 20 : 20;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final initialTime = TimeOfDay(hour: hour, minute: minute);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyReminders,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: Text(l10n.enableDailyReminder),
              value: p.reminderEnabled as bool,
              onChanged: (value) => _saveReminderSettings(
                reminderEnabled: value,
                reminderTime: p.reminderTime as String,
              ),
            ),
            ListTile(
              title: Text(l10n.reminderTime),
              subtitle: Text(p.reminderTime as String),
              trailing: const Icon(Icons.schedule),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: initialTime,
                );
                if (picked != null && mounted) {
                  final h = picked.hour.toString().padLeft(2, '0');
                  final m = picked.minute.toString().padLeft(2, '0');
                  await _saveReminderSettings(
                    reminderEnabled: p.reminderEnabled as bool,
                    reminderTime: '$h:$m',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfile p,
    AppLocalizations l10n,
  ) {
    final xpService = ref.read(xpServiceProvider);
    final requiredXp = xpService.requiredXpForLevel(p.level);
    final progress = requiredXp == 0 ? 0.0 : p.currentXp / requiredXp;
    return premiumCard(
      context: context,
      enableHoverLift: false,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Row(
              children: [
                AvatarAura(level: p.level, size: 72, showGlow: true),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.levelLabel(p.level),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      StreakPill(days: p.streak),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${p.totalXp} ${l10n.totalXp}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            XpProgressBar(progress: progress, height: 6),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    AppLocalizations l10n,
    Locale? currentLocale,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<Locale?>(
              initialValue: currentLocale,
              decoration: InputDecoration(
                labelText: l10n.language,
                hintText: l10n.language,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.systemDefault)),
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.english),
                ),
                DropdownMenuItem(
                  value: const Locale('tr'),
                  child: Text(l10n.turkish),
                ),
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

  Widget _buildEditableSection(
    BuildContext context,
    dynamic p,
    AppLocalizations l10n,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.yourInfo, style: Theme.of(context).textTheme.titleMedium),
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
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              decoration: InputDecoration(
                labelText: l10n.age,
                hintText: l10n.optional,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final val = int.tryParse(v);
                if (val == null || val < 0 || val > 99) {
                  return '0-99';
                }
                return null;
              },
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
              initialValue: _focusCategory,
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
      GoalCategory.digitalDetox => l10n.digitalDetox,
      GoalCategory.social => l10n.social,
      GoalCategory.creativity => l10n.creativity,
      GoalCategory.discipline => l10n.discipline,
    };
  }
}
