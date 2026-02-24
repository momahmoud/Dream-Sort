import 'package:equatable/equatable.dart';

class SortingItem extends Equatable {
  final int colorIndex;
  final bool isHidden;
  final bool isStone; // New: Blocker element
  final bool isLocked; // New: Chained ball

  const SortingItem({
    required this.colorIndex,
    this.isHidden = false,
    this.isStone = false,
    this.isLocked = false,
  });

  @override
  List<Object?> get props => [colorIndex, isHidden, isStone, isLocked];

  Map<String, dynamic> toJson() {
    return {
      'colorIndex': colorIndex,
      'isHidden': isHidden,
      'isStone': isStone,
      'isLocked': isLocked,
    };
  }

  factory SortingItem.fromJson(Map<String, dynamic> json) {
    return SortingItem(
      colorIndex: json['colorIndex'] as int,
      isHidden: json['isHidden'] as bool? ?? false,
      isStone: json['isStone'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}

class Tube extends Equatable {
  final List<SortingItem> items;
  final int capacity;

  const Tube({required this.items, this.capacity = 4});

  bool get isFull => items.length >= capacity;
  bool get isEmpty => items.isEmpty;

  SortingItem? get topItem => items.isEmpty ? null : items.last;

  /// Call this when moving an item TO this tube.
  /// Returns a new Tube with the item added, or null if invalid.
  Tube? addItem(SortingItem item) {
    if (isFull) return null;
    return Tube(items: List.from(items)..add(item), capacity: capacity);
  }

  /// Call this when moving an item FROM this tube.
  /// Returns a new Tube with the top item removed.
  Tube removeItem() {
    if (isEmpty) return this;
    final newItems = List<SortingItem>.from(items)..removeLast();
    return Tube(items: newItems, capacity: capacity);
  }

  /// Checks if the tube is "completed" (Full and all same color)
  bool get isCompleted {
    // Empty is considered "sorted"
    if (items.isEmpty) {
      return true;
    }

    // If the tube contains only stones (blockers), it is considered "completed"
    // effectively ignoring it for the win condition.
    if (items.every((item) => item.isStone)) {
      return true;
    }

    // Standard completion: Full AND all items same color
    if (!isFull) return false;

    final firstColor = items.first.colorIndex;
    return items.every(
      (item) => item.colorIndex == firstColor && !item.isHidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => i.toJson()).toList(),
      'capacity': capacity,
    };
  }

  factory Tube.fromJson(Map<String, dynamic> json) {
    return Tube(
      items: (json['items'] as List<dynamic>)
          .map((e) => SortingItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      capacity: json['capacity'] as int? ?? 4,
    );
  }

  @override
  List<Object?> get props => [items, capacity];
}
