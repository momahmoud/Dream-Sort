import 'dart:ui' as ui;

import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/core/locale/locale_cubit.dart';
import 'package:dream_sort/core/services/iap_service.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import 'package:dream_sort/core/locale/language_selection_dialog.dart';
import '../../../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
    IAPService.purchaseMessage.addListener(_onPurchaseMessage);
  }

  @override
  void dispose() {
    IAPService.purchaseMessage.removeListener(_onPurchaseMessage);
    super.dispose();
  }

  void _onPurchaseMessage() {
    final key = IAPService.purchaseMessage.value;
    if (key == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final String msg;
    switch (key) {
      case 'purchase_success':
        msg = l10n.purchaseSuccess;
        break;
      case 'purchase_failed':
        msg = l10n.purchaseFailed;
        break;
      default:
        msg = l10n.purchasePending;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    IAPService.purchaseMessage.value = null;
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${info.version} +${info.buildNumber}';
    });
  }

  void _showStoreUnavailableDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.purchaseFailed,
          style: const TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Store is not available right now. Please check your connection and try again.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.resetConfirmTitle,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.resetConfirmMessage,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<GameRepository>().resetProgress();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.progressReset)));
              }
            },
            child: Text(
              l10n.reset,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveAdsDialog(BuildContext context, StateSetter parentSetState) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => _SettingsActionDialog(
        title: l10n.removeAds,
        description: l10n.removeAdsDesc,
        iconData: Icons.visibility_off_rounded,
        iconBgColor: const Color(0xFFE74C3C),
        actionLabel: 'Buy — \$1.99',
        actionIconData: Icons.shopping_cart_rounded,
        actionGradientColors: const [Color(0xFFE74C3C), Color(0xFFC0392B)],
        actionShadowColor: Colors.redAccent,
        cancelLabel: l10n.cancel,
        onAction: () async {
          Navigator.pop(context);
          final ok = await IAPService.purchaseRemoveAds();
          if (!ok && context.mounted) {
            _showStoreUnavailableDialog(context);
          } else if (context.mounted) {
            parentSetState(() {});
          }
        },
      ),
    );
  }

  void _showRestoreDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.restorePurchases,
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          l10n.restorePurchasesDesc,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              IAPService.restorePurchases();
            },
            child: Text(
              l10n.restorePurchases,
              style: const TextStyle(color: Colors.purpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showDonationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.pinkAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.pinkAccent, width: 2),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.pinkAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.supportDeveloper,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.supportDeveloperDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _DonationButton(
                label: l10n.tipSmall,
                productId: IAPService.tipSmallId,
                gradient: const [Color(0xFF27AE60), Color(0xFF2ECC71)],
                shadowColor: const Color(0xFF27AE60),
              ),
              const SizedBox(height: 10),
              _DonationButton(
                label: l10n.tipMedium,
                productId: IAPService.tipMediumId,
                gradient: const [Color(0xFF2980B9), Color(0xFF3498DB)],
                shadowColor: const Color(0xFF2980B9),
              ),
              const SizedBox(height: 10),
              _DonationButton(
                label: l10n.tipLarge,
                productId: IAPService.tipLargeId,
                gradient: const [Color(0xFF8E44AD), Color(0xFF9B59B6)],
                shadowColor: const Color(0xFF8E44AD),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => _SettingsActionDialog(
        title: l10n.rateApp,
        description: l10n.rateAppDesc,
        iconData: Icons.star_rounded,
        iconBgColor: const Color(0xFFF39C12),
        actionLabel: l10n.rateNow,
        actionIconData: Icons.star_rounded,
        actionGradientColors: const [Color(0xFFF39C12), Color(0xFFE67E22)],
        actionShadowColor: Colors.orange,
        cancelLabel: l10n.cancel,
        onAction: () async {
          Navigator.pop(context);
          final review = InAppReview.instance;
          if (await review.isAvailable()) {
            review.requestReview();
          } else {
            review.openStoreListing();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: BouncingScrollPhysics(),
            children: [
              // 1. Language
              _SectionHeader(title: l10n.language),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: BlocBuilder<LocaleCubit, Locale>(
                  builder: (context, locale) {
                    String languageName;
                    switch (locale.languageCode) {
                      case 'en':
                        languageName = 'English';
                        break;
                      case 'ar':
                        languageName = 'العربية (Arabic)';
                        break;
                      case 'es':
                        languageName = 'Español (Spanish)';
                        break;
                      case 'fr':
                        languageName = 'Français (French)';
                        break;
                      case 'hi':
                        languageName = 'हिंदी (Hindi)';
                        break;
                      default:
                        languageName = locale.languageCode.toUpperCase();
                    }
                    return _SettingsTile(
                      title: languageName,
                      iconData: Icons.language_rounded,
                      iconBgColor: const Color(0xFF2980B9),
                      onTap: () => showLanguageSelectionDialog(context),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 2. Sound
              _SectionHeader(title: l10n.sound),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: ValueListenableBuilder<bool>(
                  valueListenable: context
                      .read<AudioController>()
                      .isMutedNotifier,
                  builder: (context, isMuted, child) {
                    return _SettingsTile(
                      title: l10n.sfx,
                      iconData: isMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      iconBgColor: const Color(0xFF8E44AD),
                      showArrow: false,
                      trailing: Switch(
                        value: !isMuted,
                        onChanged: (_) {
                          context.read<AudioController>().toggleMute();
                        },
                        activeThumbColor: Colors.pinkAccent,
                        activeTrackColor: Colors.pinkAccent.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 3. Accessibility
              _SectionHeader(title: l10n.accessibility),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final repo = context.read<GameRepository>();
                    return _SettingsTile(
                      title: l10n.colorBlindMode,
                      iconData: Icons.visibility_rounded,
                      iconBgColor: const Color(0xFF16A085),
                      showArrow: false,
                      trailing: Switch(
                        value: repo.isColorBlindEnabled,
                        onChanged: (val) async {
                          await repo.setColorBlindEnabled(val);
                          setState(() {});
                        },
                        activeThumbColor: Colors.pinkAccent,
                        activeTrackColor: Colors.pinkAccent.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 4. Premium
              _SectionHeader(
                title: l10n.premium,
                iconData: Icons.star_rounded,
                iconBgColor: const Color(0xFFE67E22),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    StatefulBuilder(
                      builder: (context, setState) {
                        final repo = context.read<GameRepository>();
                        final removed = repo.adsRemoved;
                        return _SettingsTile(
                          title: removed
                              ? l10n.removeAdsPurchased
                              : l10n.removeAds,
                          subtitle: removed ? null : l10n.removeAdsDesc,
                          iconData: removed
                              ? Icons.check_circle_rounded
                              : Icons.visibility_off_rounded,
                          iconColor: removed
                              ? Colors.greenAccent
                              : Colors.white,
                          iconBgColor: removed
                              ? const Color(0xFF27AE60)
                              : const Color(0xFFE74C3C),
                          onTap: removed
                              ? null
                              : () => _showRemoveAdsDialog(context, setState),
                        );
                      },
                    ),
                    const Divider(
                      color: Colors.white12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _SettingsTile(
                      title: l10n.restorePurchases,
                      subtitle: l10n.restorePurchasesDesc,
                      iconData: Icons.history_rounded,
                      iconBgColor: const Color(0xFF795548),
                      onTap: () => _showRestoreDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. Support
              _SectionHeader(
                title: l10n.support,
                iconData: Icons.favorite_rounded,
                iconBgColor: const Color(0xFFE91E63),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _SettingsTile(
                      title: l10n.supportDeveloper,
                      subtitle: l10n.supportDeveloperDesc,
                      iconData: Icons.favorite_rounded,
                      iconBgColor: const Color(0xFFE91E63),
                      onTap: () => _showDonationDialog(context),
                    ),
                    const Divider(
                      color: Colors.white12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _SettingsTile(
                      title: l10n.rateApp,
                      iconData: Icons.star_rounded,
                      iconBgColor: const Color(0xFFF39C12),
                      onTap: () => _showRateDialog(context),
                    ),
                    const Divider(
                      color: Colors.white12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _SettingsTile(
                      title: l10n.shareApp,
                      iconData: Icons.share_rounded,
                      iconBgColor: const Color(0xFF16A085),
                      onTap: () {
                        Share.share(
                          'https://play.google.com/store/apps/details?id=com.elaskry.dream_sort',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 6. About
              _SectionHeader(title: l10n.about),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _SettingsTile(
                      title: l10n.about,
                      subtitle: _version.isNotEmpty ? 'v$_version' : 'v1.0.0',
                      iconData: Icons.info_outline_rounded,
                      iconBgColor: const Color(0xFF4A4A6A),
                      showArrow: false,
                    ),
                    const Divider(
                      color: Colors.white12,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                    _SettingsTile(
                      title: l10n.resetProgress,
                      iconData: Icons.delete_forever_rounded,
                      iconBgColor: const Color(0xFFC0392B),
                      titleColor: Colors.redAccent,
                      onTap: () => _showResetConfirmDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
  );
}

// ─────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? iconData;
  final Color iconBgColor;

  const _SectionHeader({
    required this.title,
    this.iconData,
    this.iconBgColor = const Color(0xFF4A4A6A),
  });

  @override
  Widget build(BuildContext context) {
    if (iconData == null) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Settings Tile
// ─────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData iconData;
  final Color iconColor;
  final Color iconBgColor;
  final Color? titleColor;
  final VoidCallback? onTap;
  final bool showArrow;
  final Widget? trailing;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.iconData,
    this.iconColor = Colors.white,
    required this.iconBgColor,
    this.titleColor,
    this.onTap,
    this.showArrow = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    Widget? trailingWidget = trailing;
    if (trailingWidget == null && showArrow && onTap != null) {
      trailingWidget = Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white38,
        size: 14,
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(iconData, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            )
          : null,
      trailing: trailingWidget,
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────
// Settings Action Dialog (local styled dialog)
// ─────────────────────────────────────────────

class _SettingsActionDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final Color iconBgColor;
  final String actionLabel;
  final IconData? actionIconData;
  final List<Color> actionGradientColors;
  final Color actionShadowColor;
  final String cancelLabel;
  final VoidCallback onAction;

  const _SettingsActionDialog({
    required this.title,
    required this.description,
    required this.iconData,
    required this.iconBgColor,
    required this.actionLabel,
    this.actionIconData,
    required this.actionGradientColors,
    required this.actionShadowColor,
    required this.cancelLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 52, 24, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    GestureDetector(
                      onTap: onAction,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: actionGradientColors,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: actionShadowColor.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (actionIconData != null) ...[
                              Icon(
                                actionIconData,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              actionLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white38,
                      ),
                      child: Text(cancelLabel),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -28,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: iconBgColor.withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(iconData, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Donation Button (used inside donation dialog)
// ─────────────────────────────────────────────

class _DonationButton extends StatelessWidget {
  final String label;
  final String productId;
  final List<Color> gradient;
  final Color shadowColor;

  const _DonationButton({
    required this.label,
    required this.productId,
    required this.gradient,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        final ok = await IAPService.purchaseTip(productId);
        if (!ok && context.mounted) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF16213E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                l10n.purchaseFailed,
                style: const TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Store is not available right now. Please check your connection.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n.gotIt),
                ),
              ],
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
