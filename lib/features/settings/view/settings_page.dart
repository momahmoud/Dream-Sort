import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/core/locale/locale_cubit.dart';
import 'package:dream_sort/core/services/iap_service.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. Language Section
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

                    return ListTile(
                      leading: const Icon(Icons.language, color: Colors.white),
                      title: Text(
                        languageName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white54,
                        size: 16,
                      ),
                      onTap: () {
                        showLanguageSelectionDialog(context);
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 2. Audio Section
              _SectionHeader(title: l10n.sound),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    // Mute/Unmute Toggle
                    ValueListenableBuilder<bool>(
                      valueListenable: context
                          .read<AudioController>()
                          .isMutedNotifier,
                      builder: (context, isMuted, child) {
                        return ListTile(
                          leading: Icon(
                            isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                          ),
                          title: Text(
                            l10n.sfx,
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Switch(
                            value: !isMuted,
                            onChanged: (_) {
                              context.read<AudioController>().toggleMute();
                            },
                            activeThumbColor: Colors.pinkAccent,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2.5 Accessibility Section
              _SectionHeader(title: l10n.accessibility),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    final repo = context.read<GameRepository>();
                    return ListTile(
                      leading: const Icon(
                        Icons.visibility_rounded,
                        color: Colors.white,
                      ),
                      title: Text(
                        l10n.colorBlindMode,
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: Switch(
                        value: repo.isColorBlindEnabled,
                        onChanged: (val) async {
                          await repo.setColorBlindEnabled(val);
                          setState(() {});
                        },
                        activeThumbColor: Colors.pinkAccent,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

              // 3. Share & Store
              _SectionHeader(title: l10n.shareApp),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share_rounded, color: Colors.white),
                      title: Text(
                        l10n.shareApp,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        Share.share(
                          'https://play.google.com/store/apps/details?id=com.elaskry.dream_sort',
                        );
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    StatefulBuilder(
                      builder: (context, setState) {
                        final repo = context.read<GameRepository>();
                        final removed = repo.adsRemoved;
                        return ListTile(
                          leading: Icon(
                            removed
                                ? Icons.check_circle_rounded
                                : Icons.block_rounded,
                            color:
                                removed ? Colors.greenAccent : Colors.white,
                          ),
                          title: Text(
                            removed
                                ? l10n.removeAdsPurchased
                                : l10n.removeAds,
                            style: TextStyle(
                              color: removed
                                  ? Colors.greenAccent
                                  : Colors.white,
                            ),
                          ),
                          subtitle: removed
                              ? null
                              : const Text(
                                  '\$1.99',
                                  style: TextStyle(color: Colors.white54),
                                ),
                          onTap: removed
                              ? null
                              : () async {
                                  final ok = await IAPService.purchaseRemoveAds();
                                  if (!ok && context.mounted) {
                                    _showStoreUnavailableDialog(context);
                                  } else if (context.mounted) {
                                    setState(() {});
                                  }
                                },
                        );
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.restore_rounded,
                        color: Colors.white,
                      ),
                      title: Text(
                        l10n.restorePurchases,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => IAPService.restorePurchases(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 4. Support the Developer (Tip Jar)
              _SectionHeader(title: l10n.supportDeveloper),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    _TipTile(label: l10n.tipSmall, productId: IAPService.tipSmallId),
                    const Divider(color: Colors.white24, height: 1),
                    _TipTile(label: l10n.tipMedium, productId: IAPService.tipMediumId),
                    const Divider(color: Colors.white24, height: 1),
                    _TipTile(label: l10n.tipLarge, productId: IAPService.tipLargeId),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 5. Danger Zone / About
              _SectionHeader(title: l10n.about),
              const SizedBox(height: 10),
              Container(
                decoration: _cardDecoration,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      title: Text(
                        l10n.about,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        _version.isNotEmpty ? 'v$_version' : 'v1.0.0',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        l10n.resetProgress,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                      onTap: () => _showResetConfirmDialog(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.05),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
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
}

class _TipTile extends StatelessWidget {
  final String label;
  final String productId;

  const _TipTile({required this.label, required this.productId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.favorite_rounded, color: Colors.pinkAccent),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () async {
        final ok = await IAPService.purchaseTip(productId);
        if (!ok && context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF16213E),
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
      },
    );
  }
}
