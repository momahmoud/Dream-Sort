import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static InterstitialAd? _interstitialAd;
  static RewardedAd? _rewardedAd;
  static bool _isInterstitialLoading = false;
  static bool _isRewardedLoading = false;

  static bool _isInitialized = false;
  static const bool _adsEnabled = true; // Ads disabled for now

  static bool get isEnabled => _adsEnabled;

  static Future<void> init() async {
    if (!_adsEnabled) return;
    if (_isInitialized) return;
    _isInitialized = true;

    // Families Policy Compliance:
    // 1. Tag for Child Directed Treatment (COPPA)
    // 2. Max Ad Content Rating set to G
    RequestConfiguration configuration = RequestConfiguration(
      tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
      maxAdContentRating: MaxAdContentRating.g,
    );
    await MobileAds.instance.updateRequestConfiguration(configuration);

    // UMP Consent Flow
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          _loadConsentForm();
        } else {
          _initializeMobileAdsSdk();
        }
      },
      (FormError error) {
        debugPrint('Consent info update failed: ${error.message}');
        _initializeMobileAdsSdk();
      },
    );
  }

  static void _loadConsentForm() {
    ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
      if (error != null) {
        debugPrint('Consent form error: ${error.message}');
      }
      _initializeMobileAdsSdk();
    });
  }

  static Future<void> _initializeMobileAdsSdk() async {
    await MobileAds.instance.initialize();

    // Preload ads immediately upon init
    preloadInterstitial();
    preloadRewarded();
  }

  // --- IDs ---
  static String get bannerAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    }
    return Platform.isAndroid
        ? (dotenv.env['ADMOB_ANDROID_BANNER_ID'] ??
              'ca-app-pub-3940256099942544/6300978111')
        : (dotenv.env['ADMOB_IOS_BANNER_ID'] ??
              'ca-app-pub-3940256099942544/2934735716');
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/1033173712';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    }
    return Platform.isAndroid
        ? (dotenv.env['ADMOB_ANDROID_INTERSTITIAL_ID'] ??
              'ca-app-pub-3940256099942544/1033173712')
        : (dotenv.env['ADMOB_IOS_INTERSTITIAL_ID'] ??
              'ca-app-pub-3940256099942544/4411468910');
  }

  static String get rewardedAdUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/5224354917';
      if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    }
    return Platform.isAndroid
        ? (dotenv.env['ADMOB_ANDROID_REWARDED_ID'] ??
              'ca-app-pub-3940256099942544/5224354917')
        : (dotenv.env['ADMOB_IOS_REWARDED_ID'] ??
              'ca-app-pub-3940256099942544/1712485313');
  }

  // --- Banner Helper ---
  static BannerAd loadBanner({
    required Function(Ad) onAdLoaded,
    Function(LoadAdError)? onAdFailed,
  }) {
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize
          .banner, // Standard banner. For best practice, consider AnchoredAdaptiveBanner in UI.
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (onAdFailed != null) onAdFailed(error);
        },
      ),
    );

    if (_adsEnabled) {
      ad.load();
    }

    return ad;
  }

  // --- Interstitial Best Practices ---
  static void preloadInterstitial() {
    if (!_adsEnabled) return;
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdDismissedFullScreenContent: (ad) {
                  ad.dispose();
                  _interstitialAd = null;
                  // Preload the next one immediately
                  preloadInterstitial();
                },
                onAdFailedToShowFullScreenContent: (ad, err) {
                  ad.dispose();
                  _interstitialAd = null;
                  preloadInterstitial();
                },
              );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          debugPrint('Interstitial failed to load: $error');
          // Optional: Retry after delay
        },
      ),
    );
  }

  static void showInterstitial() {
    if (!_adsEnabled) return;
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial not ready yet.');
      preloadInterstitial(); // Try to load for next time
    }
  }

  // --- Rewarded Best Practices ---
  static void preloadRewarded() {
    if (!_adsEnabled) return;
    if (_rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              preloadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              _rewardedAd = null;
              preloadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          debugPrint('Rewarded failed to load: $error');
        },
      ),
    );
  }

  static void showRewarded({required Function(int amount) onUserEarnedReward}) {
    if (!_adsEnabled) return;
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          onUserEarnedReward(reward.amount.toInt());
        },
      );
    } else {
      debugPrint('Rewarded Ad not ready yet.');
      preloadRewarded();
    }
  }
}
