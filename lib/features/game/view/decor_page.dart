import 'package:dream_sort/core/audio/audio_controller.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';
import 'package:dream_sort/features/game/repo/game_repository.dart';
import 'package:dream_sort/features/game/widgets/decor_category_tabs.dart';
import 'package:dream_sort/features/game/widgets/decor_item_card.dart';
import 'package:dream_sort/features/game/widgets/room_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/flutter_svg.dart';
import '../../../l10n/app_localizations.dart';

class DecorPage extends StatefulWidget {
  const DecorPage({super.key});

  @override
  State<DecorPage> createState() => _DecorPageState();
}

class _DecorPageState extends State<DecorPage> {
  late GameRepository _repo;
  int _coins = 0;
  List<String> _unlocked = [];
  Map<String, String> _equipped = {};

  DecorType _selectedType = DecorType.tube;

  @override
  void initState() {
    super.initState();
    _repo = context.read<GameRepository>();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _coins = _repo.getCoins();
      _unlocked = _repo.getUnlockedItems();
      _equipped = _repo.getEquippedItems();
    });
  }

  void _buyItem(DecorItem item) async {
    final l10n = AppLocalizations.of(context)!;
    if (_coins >= item.cost) {
      await _repo.spendCoins(item.cost);
      await _repo.unlockItem(item.id);
      await _repo.equipItem(item.type.name, item.id);
      if (mounted) context.read<AudioController>().playBuy();
      _refreshData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notEnoughCoins(item.cost)),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _equipItem(DecorItem item) async {
    await _repo.equipItem(item.type.name, item.id);
    if (mounted) context.read<AudioController>().playEquip();
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black, // Base color
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.renovateRoom,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 2)),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/images/coin.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Full Screen Room View (Background)
          Positioned.fill(child: RoomView(equipped: _equipped)),

          // 2. Gradient Overlay for Bottom Panel
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                  stops: const [0.0, 0.5, 0.8, 1.0],
                ),
              ),
            ),
          ),

          // 3. Bottom Control Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Tabs
                DecorCategoryTabs(
                  selectedType: _selectedType,
                  onSelect: (type) => setState(() => _selectedType = type),
                ),

                const SizedBox(height: 24),

                // Items List
                Expanded(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    children: DecorationData.items
                        .where((i) => i.type == _selectedType)
                        .map((item) {
                          final isUnlocked =
                              item.isDefault || _unlocked.contains(item.id);
                          final isEquipped =
                              _equipped[item.type.name] == item.id;
                          return DecorItemCard(
                            item: item,
                            isUnlocked: isUnlocked,
                            isEquipped: isEquipped,
                            onTap: () {
                              if (isUnlocked) {
                                _equipItem(item);
                              } else {
                                _buyItem(item);
                              }
                            },
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 30), // Bottom Safe Area
              ],
            ),
          ),
        ],
      ),
    );
  }
}
