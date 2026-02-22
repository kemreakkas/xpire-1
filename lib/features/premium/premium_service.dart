import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/constants/premium_constants.dart';
import '../../../core/log/app_log.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../state/providers.dart';

/// In-app purchase service for premium. Isolated from UI; injected via Riverpod.
/// On web, purchases are disabled; use dev toggle for testing.
class PremiumService extends ChangeNotifier {
  PremiumService(this._profileRepo, this._ref);

  final IProfileRepository _profileRepo;
  final Ref _ref;

  final List<ProductDetails> _availableProducts = [];
  bool _isLoading = false;
  bool _purchaseAvailable = true;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  List<ProductDetails> get availableProducts =>
      List.unmodifiable(_availableProducts);
  bool get isLoading => _isLoading;
  bool get purchaseAvailable => _purchaseAvailable;

  /// Call once after creation (e.g. from provider initializer).
  Future<void> init() async {
    if (kIsWeb) {
      _purchaseAvailable = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      AppLog.info('IAP not available');
      _purchaseAvailable = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
    );

    await _loadProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails(
      PremiumConstants.productIds.toSet(),
    );
    if (response.notFoundIDs.isNotEmpty) {
      AppLog.info('IAP products not found', {'ids': response.notFoundIDs});
    }
    _availableProducts.clear();
    _availableProducts.addAll(response.productDetails);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == PremiumConstants.premiumMonthly ||
            purchase.productID == PremiumConstants.premiumWeekly) {
          _grantPremium();
        } else if (purchase.productID == PremiumConstants.freezePack3) {
          _grantFreezePack(3);
        } else if (purchase.productID == PremiumConstants.xpPack500) {
          _grantXpPack(500);
        }

        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantFreezePack(int amount) async {
    final profile =
        _profileRepo.readSync() ?? await _profileRepo.loadOrCreate();
    final updated = profile.copyWith(
      freezeCredits: profile.freezeCredits + amount,
    );
    await _profileRepo.save(updated);
    _ref.invalidate(profileControllerProvider);
    AppLog.info('Freeze pack granted', {'amount': amount});
  }

  Future<void> _grantXpPack(int amount) async {
    final profile =
        _profileRepo.readSync() ?? await _profileRepo.loadOrCreate();
    final xpService = _ref.read(xpServiceProvider);
    final updated = xpService.grantBonusXp(profile, amount);
    await _profileRepo.save(updated);
    _ref.invalidate(profileControllerProvider);
    AppLog.info('XP pack granted', {'amount': amount});
  }

  Future<void> _grantPremium() async {
    final profile =
        _profileRepo.readSync() ?? await _profileRepo.loadOrCreate();
    final updated = profile.copyWith(isPremium: true);
    await _profileRepo.save(updated);
    _ref.invalidate(profileControllerProvider);
    AppLog.info('Premium granted');
  }

  Future<bool> buy(String productId, {bool isConsumable = false}) async {
    if (!_purchaseAvailable) {
      AppLog.error('Purchase not available');
      return false;
    }
    ProductDetails? product;
    for (final p in _availableProducts) {
      if (p.id == productId) {
        product = p;
        break;
      }
    }
    if (product == null) {
      AppLog.error('Product not found for id', productId);
      return false;
    }
    final param = PurchaseParam(productDetails: product);
    if (isConsumable) {
      return InAppPurchase.instance.buyConsumable(purchaseParam: param);
    } else {
      return InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    }
  }

  Future<void> restorePurchases() async {
    if (!_purchaseAvailable) return;
    await InAppPurchase.instance.restorePurchases();
  }

  /// Dev-only: set premium on profile (e.g. for web testing).
  Future<void> setPremiumForTesting(bool value) async {
    final profile =
        _profileRepo.readSync() ?? await _profileRepo.loadOrCreate();
    final updated = profile.copyWith(isPremium: value);
    await _profileRepo.save(updated);
    _ref.invalidate(profileControllerProvider);
    _ref.invalidate(weeklyLeaderboardProvider);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final premiumServiceProvider = ChangeNotifierProvider<PremiumService>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  final service = PremiumService(repo, ref);
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});
