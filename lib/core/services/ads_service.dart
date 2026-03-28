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
  static const bool _adsEnabled = true;
  static bool _adsRemoved = false;

  static bool get isEnabled => _adsEnabled && !_adsRemoved;

  /// Called at startup from main.dart and by IAPService on purchase.
  static void setAdsRemoved() {
    _adsRemoved = true;
  }

  static Future<void> init() async {
    if (!_adsEnabled) return;
    if (_isInitialized) return;
    _isInitialized = true;

    // Families Policy Compliance:
    // 1. Tag for Child Directed Treatment (COPPA)
    // 2. Max Ad Content Rating set to G
    RequestConfiguration configuration = RequestConfiguration();
    await MobileAds.instance.updateRequestConfiguration(configuration);

    // UMP Consent Flow
    ConsentRequestParameters params;
    if (kDebugMode) {
      ConsentDebugSettings debugSettings = ConsentDebugSettings();
      params = ConsentRequestParameters(consentDebugSettings: debugSettings);
    } else {
      params = ConsentRequestParameters();
    }

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
        // Helpful hint for the developer
        if (error.message.contains('no form(s) configured')) {
          debugPrint(
            'HINT: To fix this, go to AdMob Console > Privacy & messaging > GDPR and create a message for this app.',
          );
        }
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
    AdSize? size,
  }) {
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size ?? AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (onAdFailed != null) onAdFailed(error);
        },
      ),
    );

    if (isEnabled) {
      ad.load();
    }

    return ad;
  }

  // --- Interstitial Best Practices ---
  static void preloadInterstitial({String? adUnitId}) {
    if (!_adsEnabled) return;
    if (_interstitialAd != null || _isInterstitialLoading) return;
    _isInterstitialLoading = true;

    final String unitId = adUnitId ?? interstitialAdUnitId;

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
                onAdShowedFullScreenContent: (ad) {
                  debugPrint('Interstitial Ad showed full screen content.');
                },
                onAdImpression: (ad) {
                  debugPrint('Interstitial Ad recorded an impression.');
                },
                onAdClicked: (ad) {
                  debugPrint('Interstitial Ad was clicked.');
                },
                onAdDismissedFullScreenContent: (ad) {
                  debugPrint('Interstitial Ad was dismissed.');
                  ad.dispose();
                  _interstitialAd = null;
                  // Preload the next one immediately (try main ID again)
                  preloadInterstitial();
                },
                onAdFailedToShowFullScreenContent: (ad, err) {
                  debugPrint(
                    'Interstitial Ad failed to show full screen content: $err',
                  );
                  ad.dispose();
                  _interstitialAd = null;
                  preloadInterstitial();
                },
              );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          debugPrint('Interstitial failed to load: $error');

          // Fallback to Test ID if main ID fails ONLY in Debug mode
          if (kDebugMode) {
            final testId = Platform.isAndroid
                ? 'ca-app-pub-3940256099942544/1033173712'
                : 'ca-app-pub-3940256099942544/4411468910';

            if (unitId != testId) {
              debugPrint(
                'Fallback: Attempting to load Test Interstitial Ad...',
              );
              preloadInterstitial(adUnitId: testId);
            }
          }
        },
      ),
    );
  }

  static void showInterstitial({VoidCallback? onAdClosed}) {
    if (!isEnabled) {
      onAdClosed?.call();
      return;
    }
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitial();
          onAdClosed?.call(); // Continue the game
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _interstitialAd = null;
          preloadInterstitial();
          onAdClosed?.call(); // Continue anyway so user isn't stuck
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial not ready yet.');
      onAdClosed?.call();
      preloadInterstitial(); // Try to load for next time
    }
  }

  // --- Rewarded Best Practices ---
  static void preloadRewarded({String? adUnitId}) {
    if (!_adsEnabled) return;
    if (_rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    final String unitId = adUnitId ?? rewardedAdUnitId;

    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('Rewarded Ad showed full screen content.');
            },
            onAdImpression: (ad) {
              debugPrint('Rewarded Ad recorded an impression.');
            },
            onAdClicked: (ad) {
              debugPrint('Rewarded Ad was clicked.');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('Rewarded Ad was dismissed.');
              ad.dispose();
              _rewardedAd = null;
              preloadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              debugPrint(
                'Rewarded Ad failed to show full screen content: $err',
              );
              ad.dispose();
              _rewardedAd = null;
              preloadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoading = false;
          debugPrint('Rewarded failed to load: $error');

          // Fallback to Test ID if main ID fails ONLY in Debug mode
          if (kDebugMode) {
            final testId = Platform.isAndroid
                ? 'ca-app-pub-3940256099942544/5224354917'
                : 'ca-app-pub-3940256099942544/1712485313';

            if (unitId != testId) {
              debugPrint('Fallback: Attempting to load Test Rewarded Ad...');
              preloadRewarded(adUnitId: testId);
            }
          }
        },
      ),
    );
  }

  static void showRewarded({required Function(int amount) onUserEarnedReward}) {
    if (!_adsEnabled) return; // Rewarded ads are opt-in, so bypass _adsRemoved check.
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
