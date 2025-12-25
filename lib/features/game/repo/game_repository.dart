import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:dream_sort/features/game/models/decor_models.dart';

class GameRepository {
  static const String boxName = 'game_data';
  static const String maxLevelKey = 'max_level';
  static const String starsKey = 'stars';

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

  int getStars() {
    return _box?.get(starsKey, defaultValue: 100) ?? 100;
  }

  Future<void> addStars(int amount) async {
    final current = getStars();
    await _box?.put(starsKey, current + amount);
  }

  Future<void> spendStars(int amount) async {
    final current = getStars();
    if (current >= amount) {
      await _box?.put(starsKey, current - amount);
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

  // --- Settings ---
  bool get isMuted => _box?.get('is_muted', defaultValue: false) ?? false;

  Future<void> setMuted(bool muted) async {
    await _box?.put('is_muted', muted);
  }

  Future<void> resetProgress() async {
    await _box?.clear();
    // Re-initialize any defaults if necessary, though clear often suffices for this use case
    // assuming 'init' opened the box and we just cleared the values.
  }
}
