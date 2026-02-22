import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/supabase_config.dart';
import '../../core/ui/app_spacing.dart';
import '../../core/ui/nav_helpers.dart';
import '../../core/ui/responsive.dart';
import '../../data/repositories/supabase_community_challenges_repository.dart';
import '../../features/auth/auth_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../state/providers.dart';

class CommunityChallengeCreatePage extends ConsumerStatefulWidget {
  const CommunityChallengeCreatePage({super.key});

  @override
  ConsumerState<CommunityChallengeCreatePage> createState() =>
      _CommunityChallengeCreatePageState();
}

class _CommunityChallengeCreatePageState
    extends ConsumerState<CommunityChallengeCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _durationDays = 7;
  int _rewardXp = 100;
  bool _isPublic = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isSubmitting) return;
    final uid = ref.read(authUserIdProvider);
    if (uid == null || !SupabaseConfig.isConfigured) return;

    // Check if user is premium to bypass limits
    final profileProviderValue = ref.read(profileControllerProvider);
    final isPremium = profileProviderValue.maybeWhen(
      data: (p) => p.isPremium,
      orElse: () => false,
    );

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(supabaseCommunityChallengesRepositoryProvider);
      final newChallenge = await repo.createChallenge(
        userId: uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        durationDays: _durationDays,
        rewardXp: _rewardXp,
        isPublic: _isPublic,
        isPremium: isPremium,
      );
      if (!_isPublic) {
        final participantsRepo = ref.read(
          supabaseChallengeParticipantsRepositoryProvider,
        );
        await participantsRepo.join(uid, newChallenge.id);
        ref.invalidate(myActiveParticipantsProvider);
      }
      ref.invalidate(communityChallengesWithMetaProvider);
      ref.invalidate(challengesCreatedTodayCountProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.challengeCreated)),
      );
      if (shouldShowAppBarLeading(context)) {
        context.pop();
      } else {
        context.go('/challenges');
      }
    } on DailyChallengeLimitException {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.dailyChallengeLimitReached)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.somethingWentWrong),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWebWide = Responsive.isWebWide(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createChallenge),
        automaticallyImplyLeading: shouldShowAppBarLeading(context),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isWebWide ? 24 : AppSpacing.grid),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: l10n.title,
                      hintText: l10n.enterTitle,
                    ),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return l10n.enterTitle;
                      if (s.length < 3) return l10n.keepLonger;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.challengeDescription,
                      hintText: l10n.challengeDescriptionHint,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    validator: (v) {
                      if ((v ?? '').trim().isEmpty) {
                        return l10n.enterDescription;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<int>(
                    initialValue: _durationDays,
                    decoration: InputDecoration(labelText: l10n.durationDays),
                    items: [7, 14, 21, 30]
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(l10n.daysCount(d)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _durationDays = v ?? 7),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<int>(
                    initialValue: _rewardXp,
                    decoration: InputDecoration(labelText: l10n.rewardXp),
                    items: [50, 100, 150, 200, 250]
                        .map(
                          (x) => DropdownMenuItem(
                            value: x,
                            child: Text(l10n.xpCount(x)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _rewardXp = v ?? 100),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    title: Text(l10n.publicRoutine),
                    subtitle: Text(l10n.publicRoutineDesc),
                    value: _isPublic,
                    onChanged: (v) => setState(() => _isPublic = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.createChallenge),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
