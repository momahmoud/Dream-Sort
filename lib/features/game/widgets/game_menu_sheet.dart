import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/core/locale/locale_cubit.dart';
import 'package:dream_sort/core/services/ads_service.dart';
import 'package:dream_sort/features/game/bloc/game_bloc.dart';
import 'package:dream_sort/features/game/constants/reward_constants.dart';
import 'package:dream_sort/features/game/view/decor_page.dart';
import 'package:dream_sort/features/game/view/help_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dream_sort/core/locale/language_selection_dialog.dart';
import '../../../l10n/app_localizations.dart';

class GameMenuSheet extends StatelessWidget {
  const GameMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.read<AudioController>();
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          // REWARDED AD BUTTON
          if (AdsService.isEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(
                    Icons.monetization_on_rounded,
                    color: Colors.yellowAccent,
                  ),
                  label: Text(l10n.watchAdPlus50Coins),
                  onPressed: () {
                    final gameBloc = context.read<GameBloc>();
                    final messenger = ScaffoldMessenger.of(context);

                    Navigator.pop(context);

                    AdsService.showRewarded(
                      onUserEarnedReward: (amount) {
                        final reward = RewardConstants.rewardedAdCoins;
                        gameBloc.add(AddCurrency(reward));
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n.earnedCoins(reward))),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          // LANGUAGE TOGGLE
          BlocBuilder<LocaleCubit, Locale>(
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
                onTap: () {
                  showLanguageSelectionDialog(context);
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: audio.isMutedNotifier,
            builder: (_, isMuted, __) {
              return ListTile(
                leading: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                ),
                title: Text(
                  isMuted ? l10n.unmuteSound : l10n.muteSound,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  audio.toggleMute();
                  Navigator.pop(context);
                },
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined, color: Colors.white),
            title: Text(
              l10n.decorShop,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DecorPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.white),
            title: Text(
              l10n.howToPlay,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _showHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: Text(
              l10n.quitGame,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context); // close the bottom sheet
              Navigator.maybePop(
                context,
              ); // triggers PopScope → shows quit dialog
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          l10n.howToPlay,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HelpItem(icon: Icons.touch_app, text: l10n.tapToPick),
            const SizedBox(height: 12),
            HelpItem(icon: Icons.save_alt, text: l10n.tapToDrop),
            const SizedBox(height: 12),
            HelpItem(icon: Icons.block, text: l10n.sameColorStack),
            const SizedBox(height: 12),
            HelpItem(icon: Icons.check_circle_outline, text: l10n.sortToWin),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }
}
