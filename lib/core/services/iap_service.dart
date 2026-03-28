import 'dart:async';

import 'package:dream_sort/core/services/ads_service.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class IAPService {
  IAPService._();

  static const String removeAdsId = 'com.fluxy.dream_sort.remove_ads';
  static const String tipSmallId = 'com.fluxy.dream_sort.tip_small';
  static const String tipMediumId = 'com.fluxy.dream_sort.tip_medium';
  static const String tipLargeId = 'com.fluxy.dream_sort.tip_large';

  static const Set<String> _productIds = {
    removeAdsId,
    tipSmallId,
    tipMediumId,
    tipLargeId,
  };

  static late GameRepository _repo;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Loaded product details after init — used by the UI to show real prices.
  static final ValueNotifier<List<ProductDetails>> products =
      ValueNotifier([]);

  /// Notifier UI can listen to for purchase status messages.
  static final ValueNotifier<String?> purchaseMessage = ValueNotifier(null);

  static Future<void> init({required GameRepository repo}) async {
    _repo = repo;

    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (e) => debugPrint('IAPService stream error: $e'),
    );

    await _loadProducts();

    // Restore on init so the flag is set correctly after re-install.
    if (!_repo.adsRemoved) {
      await InAppPurchase.instance.restorePurchases();
    }
  }

  static Future<void> _loadProducts() async {
    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);
    if (response.error != null) {
      debugPrint('IAPService: product query error: ${response.error}');
    }
    products.value = response.productDetails;
  }

  /// Returns false if the product is not available (not yet loaded from store).
  static Future<bool> purchaseRemoveAds() async {
    final detail = _productById(removeAdsId);
    if (detail == null) return false;
    final param = PurchaseParam(productDetails: detail);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    return true;
  }

  /// Returns false if the product is not available (not yet loaded from store).
  static Future<bool> purchaseTip(String productId) async {
    final detail = _productById(productId);
    if (detail == null) return false;
    final param = PurchaseParam(productDetails: detail);
    await InAppPurchase.instance.buyConsumable(purchaseParam: param);
    return true;
  }

  static Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  static ProductDetails? _productById(String id) {
    try {
      return products.value.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static void _handlePurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _onPurchaseSuccess(purchase);
          break;
        case PurchaseStatus.error:
          purchaseMessage.value = 'purchase_failed';
          break;
        case PurchaseStatus.pending:
          purchaseMessage.value = 'purchase_pending';
          break;
        case PurchaseStatus.canceled:
          break;
      }

      if (purchase.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  static void _onPurchaseSuccess(PurchaseDetails purchase) {
    if (purchase.productID == removeAdsId) {
      _repo.setAdsRemoved();
      AdsService.setAdsRemoved();
    }
    purchaseMessage.value = 'purchase_success';
  }

  static void dispose() {
    _subscription?.cancel();
  }
}
