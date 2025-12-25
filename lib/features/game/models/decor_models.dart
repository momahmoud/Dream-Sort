import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

enum DecorType { wall, floor, plant, lamp, rug, painting, tube }

class DecorItem extends Equatable {
  final String id;
  final DecorType type;
  final String name;
  final int cost;
  final String assetPath; // Color hex for Wall/Floor/Tube
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
    DecorItem(
      id: 'tube_default',
      type: DecorType.tube,
      name: 'Glass Tube',
      cost: 0,
      assetPath: '0xFFFFFFFF', // White constant
      isDefault: true,
    ),
    DecorItem(
      id: 'tube_gold',
      type: DecorType.tube,
      name: 'Gold Rim',
      cost: 500,
      assetPath: '0xFFFFD700',
    ),
    DecorItem(
      id: 'tube_neon',
      type: DecorType.tube,
      name: 'Neon Blue',
      cost: 800,
      assetPath: '0xFF00E5FF',
    ),
    DecorItem(
      id: 'tube_rose',
      type: DecorType.tube,
      name: 'Rose Gold',
      cost: 600,
      assetPath: '0xFFFF4081',
    ),

    // --- WALLS ---
    DecorItem(
      id: 'wall_default',
      type: DecorType.wall,
      name: 'Midnight Blue',
      cost: 0,
      assetPath: '0xFF1A1A2E',
      isDefault: true,
    ),
    DecorItem(
      id: 'wall_purple',
      type: DecorType.wall,
      name: 'Royal Purple',
      cost: 50,
      assetPath: '0xFF2E003E',
    ),
    DecorItem(
      id: 'wall_teal',
      type: DecorType.wall,
      name: 'Deep Teal',
      cost: 100,
      assetPath: '0xFF004D40',
    ),
    DecorItem(
      id: 'wall_red',
      type: DecorType.wall,
      name: 'Velvet Red',
      cost: 150,
      assetPath: '0xFF3E0000',
    ),
    DecorItem(
      id: 'wall_grey',
      type: DecorType.wall,
      name: 'Slate Grey',
      cost: 200,
      assetPath: '0xFF37474F',
    ),
    DecorItem(
      id: 'wall_black',
      type: DecorType.wall,
      name: 'Inky Black',
      cost: 300,
      assetPath: '0xFF000000',
    ),
    DecorItem(
      id: 'wall_sunset',
      type: DecorType.wall,
      name: 'Sunset',
      cost: 400,
      assetPath: '0xFF4A148C',
    ),
    DecorItem(
      id: 'wall_matrix',
      type: DecorType.wall,
      name: 'Matrix',
      cost: 600,
      assetPath: '0xFF002200',
    ),

    // --- FLOORS ---
    DecorItem(
      id: 'floor_default',
      type: DecorType.floor,
      name: 'Wood Floor',
      cost: 0,
      assetPath: '0xFF3E2723',
      isDefault: true,
    ),
    DecorItem(
      id: 'floor_marble',
      type: DecorType.floor,
      name: 'White Marble',
      cost: 100,
      assetPath: '0xFFECEFF1',
    ),
    DecorItem(
      id: 'floor_stone',
      type: DecorType.floor,
      name: 'Dark Stone',
      cost: 150,
      assetPath: '0xFF212121',
    ),
    DecorItem(
      id: 'floor_carpet',
      type: DecorType.floor,
      name: 'Red Carpet',
      cost: 250,
      assetPath: '0xFF5D1010',
    ),
    DecorItem(
      id: 'floor_gold',
      type: DecorType.floor,
      name: 'Gold Tiles',
      cost: 500,
      assetPath: '0xFFFFD700',
    ),
    DecorItem(
      id: 'floor_grass',
      type: DecorType.floor,
      name: 'Grass',
      cost: 300,
      assetPath: '0xFF1B5E20',
    ),

    // --- PLANTS ---
    DecorItem(
      id: 'plant_none',
      type: DecorType.plant,
      name: 'No Plant',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'plant_fern',
      type: DecorType.plant,
      name: 'Fern',
      cost: 150,
      iconData: IconData(0xe3ae, fontFamily: 'MaterialIcons'), // local_florist
    ),
    DecorItem(
      id: 'plant_bamboo',
      type: DecorType.plant,
      name: 'Bamboo',
      cost: 250,
      iconData: IconData(0xe337, fontFamily: 'MaterialIcons'), // grass
    ),
    DecorItem(
      id: 'plant_tree',
      type: DecorType.plant,
      name: 'Ficus',
      cost: 400,
      iconData: IconData(0xe3e4, fontFamily: 'MaterialIcons'), // nature
    ),
    DecorItem(
      id: 'plant_lotus',
      type: DecorType.plant,
      name: 'Lotus',
      cost: 600,
      iconData: IconData(0xeb3f, fontFamily: 'MaterialIcons'), // spa
    ),
    DecorItem(
      id: 'plant_cactus',
      type: DecorType.plant,
      name: 'Cactus',
      cost: 350,
      iconData: IconData(0xeecb, fontFamily: 'MaterialIcons'), // texture
    ),

    // --- LAMPS ---
    DecorItem(
      id: 'lamp_none',
      type: DecorType.lamp,
      name: 'No Lamp',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'lamp_classic',
      type: DecorType.lamp,
      name: 'Table Lamp',
      cost: 150,
      iconData: IconData(0xe363, fontFamily: 'MaterialIcons'), // light
    ),
    DecorItem(
      id: 'lamp_modern',
      type: DecorType.lamp,
      name: 'Modern Bulb',
      cost: 300,
      iconData: IconData(0xe364, fontFamily: 'MaterialIcons'), // lightbulb
    ),
    DecorItem(
      id: 'lamp_sun',
      type: DecorType.lamp,
      name: 'Sun Lamp',
      cost: 500,
      iconData: IconData(0xe6e6, fontFamily: 'MaterialIcons'), // wb_sunny
    ),
    DecorItem(
      id: 'lamp_torch',
      type: DecorType.lamp,
      name: 'Torch',
      cost: 450,
      iconData: IconData(
        0xef4b,
        fontFamily: 'MaterialIcons',
      ), // local_fire_department
    ),

    // --- RUGS ---
    DecorItem(
      id: 'rug_none',
      type: DecorType.rug,
      name: 'No Rug',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'rug_shag',
      type: DecorType.rug,
      name: 'Shag Rug',
      cost: 100,
      iconData: IconData(0xe395, fontFamily: 'MaterialIcons'), // layers
    ),
    DecorItem(
      id: 'rug_round',
      type: DecorType.rug,
      name: 'Circle Rug',
      cost: 200,
      iconData: IconData(0xef4a, fontFamily: 'MaterialIcons'), // circle
    ),
    DecorItem(
      id: 'rug_royal',
      type: DecorType.rug,
      name: 'Royal Rug',
      cost: 450,
      iconData: IconData(0xe660, fontFamily: 'MaterialIcons'), // widgets
    ),
    DecorItem(
      id: 'rug_persian',
      type: DecorType.rug,
      name: 'Persian',
      cost: 600,
      iconData: IconData(0xe2eb, fontFamily: 'MaterialIcons'), // grid_on
    ),

    // --- PAINTINGS ---
    DecorItem(
      id: 'paint_none',
      type: DecorType.painting,
      name: 'No Art',
      cost: 0,
      isDefault: true,
    ),
    DecorItem(
      id: 'paint_abstract',
      type: DecorType.painting,
      name: 'Abstract',
      cost: 300,
      iconData: IconData(0xe332, fontFamily: 'MaterialIcons'), // image
    ),
    DecorItem(
      id: 'paint_portrait',
      type: DecorType.painting,
      name: 'Portrait',
      cost: 500,
      iconData: IconData(0xe853, fontFamily: 'MaterialIcons'), // account_box
    ),
    DecorItem(
      id: 'paint_landscape',
      type: DecorType.painting,
      name: 'Landscape',
      cost: 800,
      iconData: IconData(0xe336, fontFamily: 'MaterialIcons'), // landscape
    ),
    DecorItem(
      id: 'paint_starry',
      type: DecorType.painting,
      name: 'Starry',
      cost: 1000,
      iconData: IconData(0xe43d, fontFamily: 'MaterialIcons'), // shutter_speed
    ),
  ];
}
