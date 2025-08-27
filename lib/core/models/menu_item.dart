class MenuItem {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final int priceXof;
  final String? categoryId;
  final String? categoryName;
  final bool isAvailable;
  final bool isPopular;
  final bool isSpicy;
  final bool isVegetarian;
  final bool isVegan;
  final bool isHalal;
  final bool hasUnlimitedStock;
  final int stockQuantity;
  final int minimumOrderQuantity;
  final String? ingredients;
  final String? allergens;
  final int? calories;
  final int? preparationTimeMinutes;
  final List<Map<String, dynamic>> variations;
  final List<Map<String, dynamic>> addons;
  final String? imageUrl;
  final List<String> galleryUrls;
  final double rating;
  final int totalOrders;
  final int totalReviews;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItem({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.priceXof,
    this.categoryId,
    this.categoryName,
    this.isAvailable = true,
    this.isPopular = false,
    this.isSpicy = false,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isHalal = false,
    this.hasUnlimitedStock = true,
    this.stockQuantity = 0,
    this.minimumOrderQuantity = 0,
    this.ingredients,
    this.allergens,
    this.calories,
    this.preparationTimeMinutes,
    this.variations = const [],
    this.addons = const [],
    this.imageUrl,
    this.galleryUrls = const [],
    this.rating = 0.0,
    this.totalOrders = 0,
    this.totalReviews = 0,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      priceXof: json['price_xof'] as int,
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isPopular: json['is_popular'] as bool? ?? false,
      isSpicy: json['is_spicy'] as bool? ?? false,
      isVegetarian: json['is_vegetarian'] as bool? ?? false,
      isVegan: json['is_vegan'] as bool? ?? false,
      isHalal: json['is_halal'] as bool? ?? false,
      hasUnlimitedStock: json['has_unlimited_stock'] as bool? ?? true,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      minimumOrderQuantity: json['minimum_order_quantity'] as int? ?? 0,
      ingredients: json['ingredients'] as String?,
      allergens: json['allergens'] as String?,
      calories: json['calories'] as int?,
      preparationTimeMinutes: json['preparation_time_minutes'] as int?,
      variations: (json['variations'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [],
      addons:
          (json['addons'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
              [],
      imageUrl: json['image_url'] as String?,
      galleryUrls:
          (json['gallery_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price_xof': priceXof,
      'category_id': categoryId,
      'category_name': categoryName,
      'is_available': isAvailable,
      'is_popular': isPopular,
      'is_spicy': isSpicy,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_halal': isHalal,
      'has_unlimited_stock': hasUnlimitedStock,
      'stock_quantity': stockQuantity,
      'minimum_order_quantity': minimumOrderQuantity,
      'ingredients': ingredients,
      'allergens': allergens,
      'calories': calories,
      'preparation_time_minutes': preparationTimeMinutes,
      'variations': variations,
      'addons': addons,
      'image_url': imageUrl,
      'gallery_urls': galleryUrls,
      'rating': rating,
      'total_orders': totalOrders,
      'total_reviews': totalReviews,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    int? priceXof,
    String? categoryId,
    String? categoryName,
    bool? isAvailable,
    bool? isPopular,
    bool? isSpicy,
    bool? isVegetarian,
    bool? isVegan,
    bool? isHalal,
    bool? hasUnlimitedStock,
    int? stockQuantity,
    int? minimumOrderQuantity,
    String? ingredients,
    String? allergens,
    int? calories,
    int? preparationTimeMinutes,
    List<Map<String, dynamic>>? variations,
    List<Map<String, dynamic>>? addons,
    String? imageUrl,
    List<String>? galleryUrls,
    double? rating,
    int? totalOrders,
    int? totalReviews,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      priceXof: priceXof ?? this.priceXof,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      isAvailable: isAvailable ?? this.isAvailable,
      isPopular: isPopular ?? this.isPopular,
      isSpicy: isSpicy ?? this.isSpicy,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isHalal: isHalal ?? this.isHalal,
      hasUnlimitedStock: hasUnlimitedStock ?? this.hasUnlimitedStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      calories: calories ?? this.calories,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      variations: variations ?? this.variations,
      addons: addons ?? this.addons,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      totalReviews: totalReviews ?? this.totalReviews,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
