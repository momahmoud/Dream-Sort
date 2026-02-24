import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:dream_sort/features/game/constants/reward_constants.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';

class GameRepository {
  static const String boxName = 'game_data';
  static const String maxLevelKey = 'max_level';
  static const String coinsKey = 'stars';
  static const String lastLoginKey = 'last_login';
  static const String streakKey = 'login_streak';

  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(boxName);
  }

  int getMaxLevel() {
    return _box?.get(maxLevelKey, defaultValue: 1) ?? 1;
  }

  Future<void> unlockLevel(int level) async {
    final currentMax = getMaxLevel();
    if (level > currentMax) {
      await _box?.put(maxLevelKey, level);
    }
  }

  int getCoins() {
    return _box?.get(coinsKey, defaultValue: RewardConstants.startingCoins) ??
      RewardConstants.startingCoins;
  }

  Future<void> addCoins(int amount) async {
    final current = getCoins();
    await _box?.put(coinsKey, current + amount);
  }

  Future<void> spendCoins(int amount) async {
    final current = getCoins();
    if (current >= amount) {
      await _box?.put(coinsKey, current - amount);
    }
  }

  // Decor Logic
  List<String> getUnlockedItems() {
    return _box
            ?.get('unlocked_items', defaultValue: <String>[])
            ?.cast<String>() ??
        [];
  }

  Future<void> unlockItem(String itemId) async {
    final current = getUnlockedItems();
    if (!current.contains(itemId)) {
      current.add(itemId);
      await _box?.put('unlocked_items', current);
    }
  }

  // Type -> ItemID map
  Map<String, String> getEquippedItems() {
    final map = _box?.get('equipped_items', defaultValue: {});
    if (map is Map) {
      return map.cast<String, String>();
    }
    return {};
  }

  Future<void> equipItem(String type, String itemId) async {
    final current = getEquippedItems();
    current[type] = itemId;
    await _box?.put('equipped_items', current);
  }

  Color getWallColor() {
    final equipped = getEquippedItems();
    final wallId = equipped[DecorType.wall.name] ?? 'wall_default';

    // Find item in static data
    final item = DecorationData.items.firstWhere(
      (i) => i.id == wallId,
      orElse: () => DecorationData.items.first, // default
    );

    if (item.assetPath.startsWith('0xff') ||
        item.assetPath.startsWith('0xFF')) {
      return Color(int.parse(item.assetPath));
    }
    return const Color(0xFF1A1A2E); // Fallback default
  }

  String getTubeSkin() {
    final equipped = getEquippedItems();
    final tubeId = equipped[DecorType.tube.name] ?? 'tube_default';
    final item = DecorationData.items.firstWhere(
      (i) => i.id == tubeId,
      orElse: () =>
          DecorationData.items.firstWhere((i) => i.type == DecorType.tube),
    );
    return item.assetPath;
  }

  String getBallSkin() {
    final equipped = getEquippedItems();
    final ballId = equipped[DecorType.ball.name] ?? 'ball_default';
    final item = DecorationData.items.firstWhere(
      (i) => i.id == ballId,
      orElse: () =>
          DecorationData.items.firstWhere((i) => i.type == DecorType.ball),
    );
    return item.assetPath;
  }

  // --- Settings ---
  bool get isMuted => _box?.get('is_muted', defaultValue: false) ?? false;

  Future<void> setMuted(bool muted) async {
    await _box?.put('is_muted', muted);
  }

  bool get isColorBlindEnabled =>
      _box?.get('is_color_blind', defaultValue: true) ?? true;

  Future<void> setColorBlindEnabled(bool enabled) async {
    await _box?.put('is_color_blind', enabled);
  }

  // --- Daily Rewards ---
  int getLoginStreak() {
    return _box?.get(streakKey, defaultValue: 0) ?? 0;
  }

  DateTime? getLastLogin() {
    final timestamp = _box?.get(lastLoginKey);
    if (timestamp != null) return DateTime.parse(timestamp);
    return null;
  }

  Future<void> updateLoginData(int newStreak, DateTime lastLogin) async {
    await _box?.put(streakKey, newStreak);
    await _box?.put(lastLoginKey, lastLogin.toIso8601String());
  }

  Future<void> resetProgress() async {
    await _box?.clear();
    // Re-initialize any defaults if necessary, though clear often suffices for this use case
    // assuming 'init' opened the box and we just cleared the values.
  }
}
