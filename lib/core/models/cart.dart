import 'package:le_livreur_pro/core/models/menu_item.dart';

class Cart {
  final String id;
  final String customerId;
  final String? restaurantId; // All items must be from same restaurant
  final List<CartItem> items;
  final int subtotalXof;
  final int deliveryFeeXof;
  final int serviceFeeXof; // Platform commission (10%)
  final int totalXof;
  final String? notes; // Special instructions
  final DateTime createdAt;
  final DateTime updatedAt;

  const Cart({
    required this.id,
    required this.customerId,
    this.restaurantId,
    this.items = const [],
    this.subtotalXof = 0,
    this.deliveryFeeXof = 0,
    this.serviceFeeXof = 0,
    this.totalXof = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      restaurantId: json['restaurant_id'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotalXof: json['subtotal_xof'] as int? ?? 0,
      deliveryFeeXof: json['delivery_fee_xof'] as int? ?? 0,
      serviceFeeXof: json['service_fee_xof'] as int? ?? 0,
      totalXof: json['total_xof'] as int? ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'restaurant_id': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal_xof': subtotalXof,
      'delivery_fee_xof': deliveryFeeXof,
      'service_fee_xof': serviceFeeXof,
      'total_xof': totalXof,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cart copyWith({
    String? id,
    String? customerId,
    String? restaurantId,
    List<CartItem>? items,
    int? subtotalXof,
    int? deliveryFeeXof,
    int? serviceFeeXof,
    int? totalXof,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      subtotalXof: subtotalXof ?? this.subtotalXof,
      deliveryFeeXof: deliveryFeeXof ?? this.deliveryFeeXof,
      serviceFeeXof: serviceFeeXof ?? this.serviceFeeXof,
      totalXof: totalXof ?? this.totalXof,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Business logic getters
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  // Calculate totals
  int get calculatedSubtotal =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  int get calculatedServiceFee =>
      (calculatedSubtotal * 0.10).round(); // 10% commission

  int get calculatedTotal =>
      calculatedSubtotal + deliveryFeeXof + calculatedServiceFee;

  // Validate cart (all items from same restaurant)
  bool get isValid {
    if (items.isEmpty) return true;
    final firstRestaurantId = items.first.menuItem.restaurantId;
    return items.every(
      (item) => item.menuItem.restaurantId == firstRestaurantId,
    );
  }
}

class CartItem {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final List<MenuItemVariation> selectedVariations;
  final List<CartItemAddon> selectedAddons;
  final String? specialInstructions;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.selectedVariations = const [],
    this.selectedAddons = const [],
    this.specialInstructions,
    required this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      menuItem: MenuItem.fromJson(json['menu_item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      selectedVariations: (json['selected_variations'] as List<dynamic>? ?? [])
          .map((v) => MenuItemVariation.fromJson(v as Map<String, dynamic>))
          .toList(),
      selectedAddons: (json['selected_addons'] as List<dynamic>? ?? [])
          .map((a) => CartItemAddon.fromJson(a as Map<String, dynamic>))
          .toList(),
      specialInstructions: json['special_instructions'] as String?,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item': menuItem.toJson(),
      'quantity': quantity,
      'selected_variations': selectedVariations.map((v) => v.toJson()).toList(),
      'selected_addons': selectedAddons.map((a) => a.toJson()).toList(),
      'special_instructions': specialInstructions,
      'added_at': addedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    String? id,
    MenuItem? menuItem,
    int? quantity,
    List<MenuItemVariation>? selectedVariations,
    List<CartItemAddon>? selectedAddons,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      selectedVariations: selectedVariations ?? this.selectedVariations,
      selectedAddons: selectedAddons ?? this.selectedAddons,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // Calculate item total price including variations and addons
  int get totalPrice {
    final int basePrice = menuItem.priceXof * quantity;

    // Add variation costs
    final int variationCost = selectedVariations.fold(
          0,
          (sum, variation) => sum + variation.priceAdjustmentXof,
        ) *
        quantity;

    // Add addon costs
    final int addonCost = selectedAddons.fold(
      0,
      (sum, addon) => sum + (addon.priceXof * addon.quantity),
    );

    return basePrice + variationCost + addonCost;
  }

  int get unitPrice {
    final int basePrice = menuItem.priceXof;

    // Add variation costs
    final int variationCost = selectedVariations.fold(
      0,
      (sum, variation) => sum + variation.priceAdjustmentXof,
    );

    // Add addon costs per unit
    final int addonCostPerUnit = selectedAddons.fold(
      0,
      (sum, addon) => sum + addon.priceXof,
    );

    return basePrice + variationCost + addonCostPerUnit;
  }
}

class CartItemAddon {
  final String id;
  final String name;
  final int priceXof;
  final int quantity;

  const CartItemAddon({
    required this.id,
    required this.name,
    required this.priceXof,
    this.quantity = 1,
  });

  factory CartItemAddon.fromJson(Map<String, dynamic> json) {
    return CartItemAddon(
      id: json['id'] as String,
      name: json['name'] as String,
      priceXof: json['price_xof'] as int,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_xof': priceXof,
      'quantity': quantity,
    };
  }

  CartItemAddon copyWith({
    String? id,
    String? name,
    int? priceXof,
    int? quantity,
  }) {
    return CartItemAddon(
      id: id ?? this.id,
      name: name ?? this.name,
      priceXof: priceXof ?? this.priceXof,
      quantity: quantity ?? this.quantity,
    );
  }
}

// MenuItemVariation class to support cart variations
class MenuItemVariation {
  final String id;
  final String name;
  final int priceAdjustmentXof;
  final String? description;

  const MenuItemVariation({
    required this.id,
    required this.name,
    required this.priceAdjustmentXof,
    this.description,
  });

  factory MenuItemVariation.fromJson(Map<String, dynamic> json) {
    return MenuItemVariation(
      id: json['id'] as String,
      name: json['name'] as String,
      priceAdjustmentXof: json['price_adjustment_xof'] as int,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price_adjustment_xof': priceAdjustmentXof,
      'description': description,
    };
  }

  MenuItemVariation copyWith({
    String? id,
    String? name,
    int? priceAdjustmentXof,
    String? description,
  }) {
    return MenuItemVariation(
      id: id ?? this.id,
      name: name ?? this.name,
      priceAdjustmentXof: priceAdjustmentXof ?? this.priceAdjustmentXof,
      description: description ?? this.description,
    );
  }
}

// Helper class for cart operations
class CartHelper {
  // Add item to cart
  static Cart addItem(
    Cart cart,
    MenuItem menuItem, {
    int quantity = 1,
    List<MenuItemVariation>? variations,
    List<CartItemAddon>? addons,
    String? specialInstructions,
  }) {
    // Check if restaurant matches
    if (cart.restaurantId != null &&
        cart.restaurantId != menuItem.restaurantId) {
      throw Exception('Cannot add items from different restaurants');
    }

    final cartItem = CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      menuItem: menuItem,
      quantity: quantity,
      selectedVariations: variations ?? [],
      selectedAddons: addons ?? [],
      specialInstructions: specialInstructions,
      addedAt: DateTime.now(),
    );

    final updatedItems = [...cart.items, cartItem];

    return cart.copyWith(
      restaurantId: menuItem.restaurantId,
      items: updatedItems,
      subtotalXof: _calculateSubtotal(updatedItems),
      serviceFeeXof: _calculateServiceFee(updatedItems),
      totalXof: _calculateTotal(updatedItems, cart.deliveryFeeXof),
      updatedAt: DateTime.now(),
    );
  }

  // Remove item from cart
  static Cart removeItem(Cart cart, String cartItemId) {
    final updatedItems =
        cart.items.where((item) => item.id != cartItemId).toList();

    return cart.copyWith(
      restaurantId: updatedItems.isEmpty ? null : cart.restaurantId,
      items: updatedItems,
      subtotalXof: _calculateSubtotal(updatedItems),
      serviceFeeXof: _calculateServiceFee(updatedItems),
      totalXof: _calculateTotal(updatedItems, cart.deliveryFeeXof),
      updatedAt: DateTime.now(),
    );
  }

  // Update item quantity
  static Cart updateItemQuantity(
    Cart cart,
    String cartItemId,
    int newQuantity,
  ) {
    if (newQuantity <= 0) {
      return removeItem(cart, cartItemId);
    }

    final updatedItems = cart.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    return cart.copyWith(
      items: updatedItems,
      subtotalXof: _calculateSubtotal(updatedItems),
      serviceFeeXof: _calculateServiceFee(updatedItems),
      totalXof: _calculateTotal(updatedItems, cart.deliveryFeeXof),
      updatedAt: DateTime.now(),
    );
  }

  // Clear cart
  static Cart clearCart(Cart cart) {
    return cart.copyWith(
      restaurantId: null,
      items: [],
      subtotalXof: 0,
      serviceFeeXof: 0,
      totalXof: 0,
      updatedAt: DateTime.now(),
    );
  }

  // Private helper methods
  static int _calculateSubtotal(List<CartItem> items) {
    return items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  static int _calculateServiceFee(List<CartItem> items) {
    final subtotal = _calculateSubtotal(items);
    return (subtotal * 0.10).round(); // 10% commission
  }

  static int _calculateTotal(List<CartItem> items, int deliveryFee) {
    final subtotal = _calculateSubtotal(items);
    final serviceFee = _calculateServiceFee(items);
    return subtotal + deliveryFee + serviceFee;
  }
}
