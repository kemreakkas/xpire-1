import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/config/app_env.dart';
import '../../../core/constants/premium_constants.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/ui/app_spacing.dart';
import '../../../state/providers.dart';
import '../../../core/ui/app_theme.dart';
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
    final isPremium = ref.watch(PremiumController.isPremiumProvider);
    if (_purchasePending && isPremium && mounted) {
      _purchasePending = false;
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Premium activated')),
        );
        navigator.pop();
      });
    }
    final service = ref.watch(premiumServiceProvider);
    final isWeb = kIsWeb;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Premium', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.grid),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Unlock your full potential',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _BenefitsList(),
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
                        'You have Premium',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                            ),
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
                        'Premium purchases available on mobile only.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (AppEnv.buildMode != 'release')
                        FilledButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            await service.setPremiumForTesting(true);
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Dev: Premium enabled')),
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                          ),
                          child: const Text('Dev: Enable Premium'),
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
                  label: 'Monthly',
                  pricePlaceholder: '—',
                  service: service,
                  onPurchaseStarted: () => setState(() => _purchasePending = true),
                  onBuyPressed: () => ref.read(analyticsServiceProvider).track(
                        AnalyticsEvents.premiumClicked,
                        {'source': 'buy_monthly'},
                      ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PriceRow(
                  productId: PremiumConstants.premiumYearly,
                  label: 'Yearly',
                  pricePlaceholder: '—',
                  service: service,
                  onPurchaseStarted: () => setState(() => _purchasePending = true),
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
                              const SnackBar(
                                  content: Text('Restore requested')),
                            );
                          }
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('Restore purchases'),
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
  @override
  Widget build(BuildContext context) {
    const items = [
      ('Unlimited Goals', Icons.flag),
      ('Advanced Stats', Icons.insights),
      ('Streak Protection', Icons.ac_unit),
    ];
    return Card(
      color: const Color(0xFF141414),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Benefits',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(e.$2, color: AppTheme.accent, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      e.$1,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
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
        title: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          price,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: FilledButton(
          onPressed: () async {
            onBuyPressed?.call();
            final ok = await service.buy(productId);
            if (ok && context.mounted) {
              onPurchaseStarted();
            }
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.accent),
          child: const Text('Buy'),
        ),
      ),
    );
  }
}
