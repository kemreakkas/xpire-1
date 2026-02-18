import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/premium_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../core/ui/app_theme.dart';
import '../../../core/ui/nav_helpers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/providers.dart';
import 'premium_controller.dart';
import 'premium_service.dart';

class PremiumPage extends ConsumerStatefulWidget {
  const PremiumPage({super.key});

  static const String routePath = '/premium';

  @override
  ConsumerState<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends ConsumerState<PremiumPage> {
  bool _purchasePending = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(PremiumController.isPremiumProvider);
    if (_purchasePending && isPremium && mounted) {
      _purchasePending = false;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        messenger.showSnackBar(SnackBar(content: Text(l10n.premiumActivated)));
        navigator.pop();
      });
    }
    final service = ref.watch(premiumServiceProvider);
    final isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          l10n.premiumPageTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: shouldShowAppBarLeading(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.grid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.unlockPotential,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _BenefitsList(l10n: l10n),
            const SizedBox(height: AppSpacing.xl),
            if (isPremium)
              Card(
                color: const Color(0xFF141414),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: AppTheme.accent),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        l10n.youHavePremium,
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            else if (isWeb) ...[
              Card(
                color: const Color(0xFF141414),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.premiumPurchasesMobileOnly,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (AppEnv.buildMode != 'release')
                        FilledButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await service.setPremiumForTesting(true);
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(l10n.devPremiumEnabled)),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                          ),
                          child: Text(l10n.devEnablePremium),
                        ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              if (service.isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppTheme.accent),
                  ),
                )
              else ...[
                _PriceRow(
                  productId: PremiumConstants.premiumMonthly,
                  label: l10n.monthly,
                  pricePlaceholder: '—',
                  service: service,
                  onPurchaseStarted: () =>
                      setState(() => _purchasePending = true),
                  onBuyPressed: () => ref.read(analyticsServiceProvider).track(
                    AnalyticsEvents.premiumClicked,
                    {'source': 'buy_monthly'},
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PriceRow(
                  productId: PremiumConstants.premiumYearly,
                  label: l10n.yearly,
                  pricePlaceholder: '—',
                  service: service,
                  onPurchaseStarted: () =>
                      setState(() => _purchasePending = true),
                  onBuyPressed: () => ref.read(analyticsServiceProvider).track(
                    AnalyticsEvents.premiumClicked,
                    {'source': 'buy_yearly'},
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: service.purchaseAvailable
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          await service.restorePurchases();
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(l10n.restoreRequested)),
                            );
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: Text(l10n.restorePurchases),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  const _BenefitsList({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF141414),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.benefits,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.flag, color: AppTheme.accent, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.unlimitedGoals,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.insights, color: AppTheme.accent, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.advancedStats,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.ac_unit, color: AppTheme.accent, size: 22),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.streakProtection,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.productId,
    required this.label,
    required this.pricePlaceholder,
    required this.service,
    required this.onPurchaseStarted,
    this.onBuyPressed,
  });

  final String productId;
  final String label;
  final String pricePlaceholder;
  final PremiumService service;
  final VoidCallback onPurchaseStarted;
  final VoidCallback? onBuyPressed;

  @override
  Widget build(BuildContext context) {
    ProductDetails? product;
    for (final p in service.availableProducts) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }
    final price = product?.price ?? pricePlaceholder;

    return Card(
      color: const Color(0xFF141414),
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.white)),
        subtitle: Text(price, style: const TextStyle(color: Colors.white70)),
        trailing: FilledButton(
          onPressed: () async {
            onBuyPressed?.call();
            final ok = await service.buy(productId);
            if (ok && context.mounted) {
              onPurchaseStarted();
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
          child: Text(AppLocalizations.of(context)!.buy),
        ),
      ),
    );
  }
}
