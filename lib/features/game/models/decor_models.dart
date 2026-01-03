import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

enum DecorType { tube, ball, wall, floor, plant, lamp, rug, painting }

class DecorItem extends Equatable {
  final String id;
  final DecorType type;
  final String name;
  final int cost;
  final String assetPath; // Color hex or ID for skins
  final IconData? iconData; // Icon for Props
  final bool isDefault;

  const DecorItem({
    required this.id,
    required this.type,
    required this.name,
    required this.cost,
    this.assetPath = '',
    this.iconData,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, type, name, cost, assetPath, iconData];
}

class DecorationData {
  static const List<DecorItem> items = [
    // --- TUBES ---
    // Tubes affect the aesthetic of the containers holding the balls.
    DecorItem(
      id: 'tube_default',
      type: DecorType.tube,
      name: 'Glass Vials',
      cost: 0,
      assetPath: 'glass',
      isDefault: true,
    ),
    DecorItem(
      id: 'tube_bamboo',
      type: DecorType.tube,
      name: 'Zen Bamboo',
      cost: 400,
      assetPath: 'bamboo',
    ),
    DecorItem(
      id: 'tube_metal',
      type: DecorType.tube,
      name: 'Cyber Alloy',
      cost: 800,
      assetPath: 'metal',
    ),
    DecorItem(
      id: 'tube_gold_rim',
      type: DecorType.tube,
      name: 'Royal Gold',
      cost: 1200,
      assetPath: 'gold_rim',
    ),
    DecorItem(
      id: 'tube_crystal',
      type: DecorType.tube,
      name: 'Ice Crystal',
      cost: 2000,
      assetPath: 'crystal',
    ),
    DecorItem(
      id: 'tube_magma',
      type: DecorType.tube,
      name: 'Magma Forge',
      cost: 3000,
      assetPath: 'magma',
    ),

    // --- BALLS ---
    // Ball skins change the core gameplay pieces.
    DecorItem(
      id: 'ball_default',
      type: DecorType.ball,
      name: 'Smooth Spheres',
      cost: 0,
      assetPath: 'classic',
      isDefault: true,
    ),
    DecorItem(
      id: 'ball_neon',
      type: DecorType.ball,
      name: 'Neon Orbs',
      cost: 600,
      assetPath: 'neon',
    ),
    DecorItem(
      id: 'ball_emoji',
      type: DecorType.ball,
      name: 'Emoji Faces',
      cost: 1000,
      assetPath: 'emoji',
    ),
    DecorItem(
      id: 'ball_jewel',
      type: DecorType.ball,
      name: 'Precious Jewels',
      cost: 1500,
      assetPath: 'jewel',
    ),
    DecorItem(
      id: 'ball_planets',
      type: DecorType.ball,
      name: 'Galaxy Planets',
      cost: 2500,
      assetPath: 'planets',
    ),
    DecorItem(
      id: 'ball_sports',
      type: DecorType.ball,
      name: 'Sports Pack',
      cost: 2000,
      assetPath: 'sports',
    ),

    // --- WALLS ---
    // Background colors for the room.
    DecorItem(
      id: 'wall_default',
      type: DecorType.wall,
      name: 'Midnight Sky',
      cost: 0,
      assetPath: '0xFF1A1A2E',
      isDefault: true,
    ),
    DecorItem(
      id: 'wall_purple',
      type: DecorType.wall,
      name: 'Nebula Purple',
      cost: 150,
      assetPath: '0xFF2E003E',
    ),
    DecorItem(
      id: 'wall_teal',
      type: DecorType.wall,
      name: 'Deep Abyss',
      cost: 250,
      assetPath: '0xFF004D40',
    ),
    DecorItem(
      id: 'wall_red',
      type: DecorType.wall,
      name: 'Crimson Velvet',
      cost: 350,
      assetPath: '0xFF3E0000',
    ),
    DecorItem(
      id: 'wall_grey',
      type: DecorType.wall,
      name: 'Dark Slate',
      cost: 450,
      assetPath: '0xFF37474F',
    ),
    DecorItem(
      id: 'wall_black',
      type: DecorType.wall,
      name: 'Void Black',
      cost: 600,
      assetPath: '0xFF000000',
    ),
    DecorItem(
      id: 'wall_sunset',
      type: DecorType.wall,
      name: 'Warm Sunset',
      cost: 800,
      assetPath: '0xFF4A148C',
    ),
    DecorItem(
      id: 'wall_matrix',
      type: DecorType.wall,
      name: 'Binary Green',
      cost: 1500,
      assetPath: '0xFF002200',
    ),

    // --- FLOORS ---
    // Room base styling.
    DecorItem(
      id: 'floor_default',
      type: DecorType.floor,
      name: 'Polished Oak',
      cost: 0,
      assetPath: '0xFF3E2723',
      isDefault: true,
    ),
    DecorItem(
      id: 'floor_marble',
      type: DecorType.floor,
      name: 'Ice Marble',
      cost: 300,
      assetPath: '0xFFECEFF1',
    ),
    DecorItem(
      id: 'floor_stone',
      type: DecorType.floor,
      name: 'Volcanic Rock',
      cost: 500,
      assetPath: '0xFF212121',
    ),
    DecorItem(
      id: 'floor_carpet',
      type: DecorType.floor,
      name: 'Plush Velvet',
      cost: 800,
      assetPath: '0xFF5D1010',
    ),
    DecorItem(
      id: 'floor_gold',
      type: DecorType.floor,
      name: 'Gilded Floor',
      cost: 2000,
      assetPath: '0xFFFFD700',
    ),
    DecorItem(
      id: 'floor_grass',
      type: DecorType.floor,
      name: 'Overgrown',
      cost: 1200,
      assetPath: '0xFF1B5E20',
    ),

    // --- PLANTS ---
    DecorItem(
      id: 'plant_none',
      type: DecorType.plant,
      name: 'No Decor',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'plant_fern',
      type: DecorType.plant,
      name: 'Forest Fern',
      cost: 400,
      iconData: IconData(0xe3ae, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'plant_bamboo',
      type: DecorType.plant,
      name: 'Zen Stalks',
      cost: 600,
      iconData: IconData(0xe337, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'plant_tree',
      type: DecorType.plant,
      name: 'Ancient Bonsai',
      cost: 1200,
      iconData: IconData(0xe3e4, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'plant_lotus',
      type: DecorType.plant,
      name: 'Sacred Lotus',
      cost: 1800,
      iconData: IconData(0xeb3f, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'plant_cactus',
      type: DecorType.plant,
      name: 'Desert Spike',
      cost: 900,
      iconData: IconData(0xeecb, fontFamily: 'MaterialIcons'),
    ),

    // --- LAMPS ---
    DecorItem(
      id: 'lamp_none',
      type: DecorType.lamp,
      name: 'Natural Light',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'lamp_classic',
      type: DecorType.lamp,
      name: 'Ambient Shade',
      cost: 300,
      iconData: IconData(0xe363, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'lamp_modern',
      type: DecorType.lamp,
      name: 'Plasma Bulb',
      cost: 800,
      iconData: IconData(0xe364, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'lamp_sun',
      type: DecorType.lamp,
      name: 'Solar Flare',
      cost: 2000,
      iconData: IconData(0xe6e6, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'lamp_torch',
      type: DecorType.lamp,
      name: 'Dungeon Fire',
      cost: 1500,
      iconData: IconData(0xef4b, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'lamp_neon',
      type: DecorType.lamp,
      name: 'Neon Vibes',
      cost: 2500,
      iconData: IconData(0xe0b3, fontFamily: 'MaterialIcons'), // Bolt/Electric
    ),

    // --- RUGS ---
    DecorItem(
      id: 'rug_none',
      type: DecorType.rug,
      name: 'Bare Floor',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'rug_shag',
      type: DecorType.rug,
      name: 'Comfy Shag',
      cost: 200,
      iconData: IconData(0xe395, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'rug_round',
      type: DecorType.rug,
      name: 'Mystic Circle',
      cost: 600,
      iconData: IconData(0xef4a, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'rug_geometric',
      type: DecorType.rug,
      name: 'Geometric Mat',
      cost: 1200,
      iconData: IconData(0xe02f, fontFamily: 'MaterialIcons'), // Dashboard/Grid
    ),
    DecorItem(
      id: 'rug_royal',
      type: DecorType.rug,
      name: 'Royal Tapestry',
      cost: 1500,
      iconData: IconData(0xe660, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'rug_persian',
      type: DecorType.rug,
      name: 'Grand Persian',
      cost: 2500,
      iconData: IconData(0xe2eb, fontFamily: 'MaterialIcons'),
    ),

    // --- PAINTINGS ---
    DecorItem(
      id: 'paint_none',
      type: DecorType.painting,
      name: 'Empty Wall',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'paint_abstract',
      type: DecorType.painting,
      name: 'Modern Chaos',
      cost: 700,
      iconData: IconData(0xe332, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'paint_surreal',
      type: DecorType.painting,
      name: 'Surreal Dream',
      cost: 1500,
      iconData: IconData(0xe0cd, fontFamily: 'MaterialIcons'), // Filter/Art
    ),
    DecorItem(
      id: 'paint_portrait',
      type: DecorType.painting,
      name: 'Noble Ancestor',
      cost: 1200,
      iconData: IconData(0xe853, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'paint_landscape',
      type: DecorType.painting,
      name: 'Mountain Peak',
      cost: 2500,
      iconData: IconData(0xe336, fontFamily: 'MaterialIcons'),
    ),
    DecorItem(
      id: 'paint_starry',
      type: DecorType.painting,
      name: 'Deep Cosmos',
      cost: 5000,
      iconData: IconData(0xe43d, fontFamily: 'MaterialIcons'),
    ),
  ];
}
