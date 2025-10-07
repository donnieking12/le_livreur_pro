import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math' as math;

import 'package:le_livreur_pro/core/models/menu_item.dart';
import 'package:le_livreur_pro/core/models/menu_category.dart';
import 'package:le_livreur_pro/core/models/cart.dart';
import 'package:le_livreur_pro/core/models/restaurant.dart';
import 'package:le_livreur_pro/core/services/supabase_service.dart';

class RestaurantService {
  static const String _restaurantsTable = 'restaurants';
  static const String _menuItemsTable = 'menu_items';
  static const String _categoriesTable = 'menu_categories';

  // ==================== RESTAURANT MANAGEMENT ====================

  /// Get all active restaurants
  static Future<List<Restaurant>> getAllRestaurants() async {
    try {
      // For development - return demo data
      return _getDemoRestaurants();
      
      // TODO: Enable this for production
      /*
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .select()
          .eq('is_active', true)
          .eq('is_verified', true)
          .order('name');

      return response.map((json) => Restaurant.fromJson(json)).toList();
      */
    } catch (e) {
      throw Exception('Failed to get restaurants: $e');
    }
  }

  /// Get restaurants by category
  static Future<List<Restaurant>> getRestaurantsByCategory(
      String category) async {
    try {
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .select()
          .contains('categories', [category])
          .eq('is_active', true)
          .eq('is_verified', true)
          .order('rating', ascending: false);

      return response.map((json) => Restaurant.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get restaurants by category: $e');
    }
  }

  /// Get restaurant by ID
  static Future<Restaurant?> getRestaurantById(String restaurantId) async {
    try {
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .select()
          .eq('id', restaurantId)
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Search restaurants by name or cuisine
  static Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%,cuisine_types.cs.["$query"]')
          .eq('is_active', true)
          .eq('is_verified', true)
          .order('rating', ascending: false);

      return response.map((json) => Restaurant.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  /// Get restaurants near location
  static Future<List<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Using PostGIS for geographic queries (if available) or simple distance calculation
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .select()
          .eq('is_active', true)
          .eq('is_verified', true);

      final restaurants =
          response.map((json) => Restaurant.fromJson(json)).toList();

      // Filter by distance (simple calculation)
      return restaurants.where((restaurant) {
        // Add null check
        final distance = _calculateDistance(
          latitude,
          longitude,
          restaurant.latitude,
          restaurant.longitude,
        );
        return distance <= radiusKm;
      }).toList()
        ..sort((a, b) {
          // Add null checks
          if (b == null) return 0;
          final distanceA =
              _calculateDistance(latitude, longitude, a.latitude, a.longitude);
          final distanceB =
              _calculateDistance(latitude, longitude, b.latitude, b.longitude);
          return distanceA.compareTo(distanceB);
        });
    } catch (e) {
      throw Exception('Failed to get nearby restaurants: $e');
    }
  }

  /// Create new restaurant (for partners)
  static Future<Restaurant> createRestaurant({
    required String ownerId,
    required String name,
    required String description,
    required String businessAddress,
    required double latitude,
    required double longitude,
    String? businessPhone,
    String? businessEmail,
    List<String>? cuisineTypes,
    List<String>? categories,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .insert({
            'owner_id': ownerId,
            'name': name,
            'description': description,
            'business_address': businessAddress,
            'latitude': latitude,
            'longitude': longitude,
            'business_phone': businessPhone,
            'business_email': businessEmail,
            'cuisine_types': cuisineTypes ?? [],
            'categories': categories ?? ['restaurant'],
            'is_active': true,
            'is_verified': false, // Requires admin verification
            'accepts_orders': false, // Enabled after verification
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create restaurant: $e');
    }
  }

  /// Update restaurant
  static Future<Restaurant> updateRestaurant(
    String restaurantId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .update(updates)
          .eq('id', restaurantId)
          .select()
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update restaurant: $e');
    }
  }

  // ==================== MENU MANAGEMENT ====================

  /// Get menu items for restaurant
  static Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      // For development - return demo data
      return _getDemoMenuItems(restaurantId);
      
      // TODO: Enable this for production
      /*
      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .order('display_order')
          .order('name');

      return response.map((json) => MenuItem.fromJson(json)).toList();
      */
    } catch (e) {
      throw Exception('Failed to get menu items: $e');
    }
  }

  /// Get menu items by category
  static Future<List<MenuItem>> getMenuItemsByCategory(
    String restaurantId,
    String categoryId,
  ) async {
    try {
      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('category_id', categoryId)
          .eq('is_available', true)
          .order('display_order')
          .order('name');

      return response.map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get menu items by category: $e');
    }
  }

  /// Get menu item by ID
  static Future<MenuItem?> getMenuItemById(String menuItemId) async {
    try {
      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .select()
          .eq('id', menuItemId)
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Search menu items
  static Future<List<MenuItem>> searchMenuItems(
    String restaurantId,
    String query,
  ) async {
    try {
      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .select()
          .eq('restaurant_id', restaurantId)
          .or('name.ilike.%$query%,description.ilike.%$query%,ingredients.ilike.%$query%')
          .eq('is_available', true)
          .order('name');

      return response.map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }

  /// Create menu item
  static Future<MenuItem> createMenuItem({
    required String restaurantId,
    required String name,
    required String description,
    required int priceXof,
    String? categoryId,
    String? categoryName,
    List<CartItemAddon>? addons,
    String? imageUrl,
    bool isPopular = false,
    bool isSpicy = false,
    bool isVegetarian = false,
  }) async {
    try {
      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .insert({
            'restaurant_id': restaurantId,
            'name': name,
            'description': description,
            'price_xof': priceXof,
            'category_id': categoryId,
            'category_name': categoryName,
            'addons': addons?.map((a) => a.toJson()).toList() ?? [],
            'image_url': imageUrl,
            'is_popular': isPopular,
            'is_spicy': isSpicy,
            'is_vegetarian': isVegetarian,
            'is_available': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  /// Update menu item
  static Future<MenuItem> updateMenuItem(
    String menuItemId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .update(updates)
          .eq('id', menuItemId)
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  /// Get menu categories for restaurant
  static Future<List<MenuCategory>> getMenuCategories(
      String restaurantId) async {
    try {
      final response = await SupabaseService.client
          .from(_categoriesTable)
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_active', true)
          .order('display_order');

      return response.map((json) => MenuCategory.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get menu categories: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Calculate distance between two points in kilometers
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in km

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Demo data for development - Côte d'Ivoire restaurants
  static List<Restaurant> _getDemoRestaurants() {
    final now = DateTime.now();
    return [
      Restaurant(
        id: 'demo_1',
        name: 'Chez Mama Adjoua',
        ownerId: 'demo_owner_1',
        description: 'Cuisine ivoirienne authentique - Attiéké, kedjenou, alloco',
        businessAddress: 'Cocody, Angré 7ème Tranche, Abidjan',
        latitude: 5.3599517,
        longitude: -3.9715851,
        businessPhone: '+225 07 12 34 56 78',
        isActive: true,
        isVerified: true,
        acceptsOrders: true,
        preparationTimeMinutes: 25,
        minimumOrderXof: 3000,
        deliveryFeeXof: 500,
        cuisineTypes: ['ivorian', 'traditional'],
        categories: ['restaurant'],
        rating: 4.7,
        totalOrders: 450,
        totalReviews: 89,
        createdAt: now.subtract(const Duration(days: 180)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Restaurant(
        id: 'demo_2',
        name: 'Pizza Palace',
        ownerId: 'demo_owner_2',
        description: 'Pizzas, burgers et plats italiens. Livraison rapide!',
        businessAddress: 'Plateau, Rue des Jardins, Abidjan',
        latitude: 5.3196879,
        longitude: -4.0248565,
        businessPhone: '+225 07 98 76 54 32',
        isActive: true,
        isVerified: true,
        acceptsOrders: true,
        preparationTimeMinutes: 20,
        minimumOrderXof: 4000,
        deliveryFeeXof: 0, // Free delivery
        cuisineTypes: ['italian', 'fast_food'],
        categories: ['restaurant'],
        rating: 4.3,
        totalOrders: 680,
        totalReviews: 124,
        createdAt: now.subtract(const Duration(days: 120)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      Restaurant(
        id: 'demo_3',
        name: 'Pharmacie du Plateau',
        ownerId: 'demo_owner_3',
        description: 'Médicaments, produits de santé et cosmétiques',
        businessAddress: 'Plateau, Avenue Chardy, Abidjan',
        latitude: 5.3247036,
        longitude: -4.0285659,
        businessPhone: '+225 07 55 44 33 22',
        isActive: true,
        isVerified: true,
        acceptsOrders: true,
        preparationTimeMinutes: 10,
        minimumOrderXof: 2000,
        deliveryFeeXof: 1000,
        cuisineTypes: [],
        categories: ['pharmacy'],
        rating: 4.8,
        totalOrders: 290,
        totalReviews: 67,
        createdAt: now.subtract(const Duration(days: 240)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      Restaurant(
        id: 'demo_4',
        name: 'Boulangerie des Palmes',
        ownerId: 'demo_owner_4',
        description: 'Pain frais, viennoiseries et pâtisseries artisanales',
        businessAddress: 'Deux-Plateaux, Cité des Arts, Abidjan',
        latitude: 5.3471744,
        longitude: -3.9816362,
        businessPhone: '+225 07 11 22 33 44',
        isActive: true,
        isVerified: true,
        acceptsOrders: true,
        preparationTimeMinutes: 15,
        minimumOrderXof: 1500,
        deliveryFeeXof: 500,
        cuisineTypes: ['french', 'bakery'],
        categories: ['bakery'],
        rating: 4.5,
        totalOrders: 520,
        totalReviews: 95,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      Restaurant(
        id: 'demo_5',
        name: 'Épicerie Moderne',
        ownerId: 'demo_owner_5',
        description: 'Produits alimentaires, épices et articles ménagers',
        businessAddress: 'Treichville, Rue 12, Abidjan',
        latitude: 5.2918802,
        longitude: -4.0197926,
        businessPhone: '+225 07 66 77 88 99',
        isActive: true,
        isVerified: true,
        acceptsOrders: true,
        preparationTimeMinutes: 20,
        minimumOrderXof: 3500,
        deliveryFeeXof: 750,
        cuisineTypes: [],
        categories: ['grocery'],
        rating: 4.2,
        totalOrders: 380,
        totalReviews: 78,
        createdAt: now.subtract(const Duration(days: 150)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      Restaurant(
        id: 'demo_6',
        name: 'Le Jardin Gourmand',
        ownerId: 'demo_owner_6',
        description: 'Restaurant gastronomique - Cuisine française et internationale',
        businessAddress: 'Cocody, Riviera Golf, Abidjan',
        latitude: 5.3767102,
        longitude: -3.9912474,
        businessPhone: '+225 07 44 55 66 77',
        isActive: true,
        isVerified: true,
        acceptsOrders: false, // Closed for now
        preparationTimeMinutes: 35,
        minimumOrderXof: 8000,
        deliveryFeeXof: 1500,
        cuisineTypes: ['french', 'international'],
        categories: ['restaurant'],
        rating: 4.9,
        totalOrders: 180,
        totalReviews: 42,
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  /// Demo menu items for development
  static List<MenuItem> _getDemoMenuItems(String restaurantId) {
    final now = DateTime.now();
    
    switch (restaurantId) {
      case 'demo_1': // Chez Mama Adjoua
        return [
          MenuItem(
            id: 'menu_1_1',
            restaurantId: restaurantId,
            name: 'Attiéké Poisson',
            description: 'Attiéké traditionnel avec poisson braisé et légumes',
            priceXof: 2500,
            categoryId: 'cat_1',
            categoryName: 'Plats Principaux',
            isPopular: true,
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
          MenuItem(
            id: 'menu_1_2',
            restaurantId: restaurantId,
            name: 'Kedjenou de Poulet',
            description: 'Poulet mijoté aux épices dans une canari',
            priceXof: 3000,
            categoryId: 'cat_1',
            categoryName: 'Plats Principaux',
            isSpicy: true,
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
          MenuItem(
            id: 'menu_1_3',
            restaurantId: restaurantId,
            name: 'Alloco',
            description: 'Bananes plantains frites avec sauce tomate pimentée',
            priceXof: 1500,
            categoryId: 'cat_2',
            categoryName: 'Entrées',
            isVegetarian: true,
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        
      case 'demo_2': // Pizza Palace
        return [
          MenuItem(
            id: 'menu_2_1',
            restaurantId: restaurantId,
            name: 'Pizza Margherita',
            description: 'Sauce tomate, mozzarella, basilic frais',
            priceXof: 4500,
            categoryId: 'cat_1',
            categoryName: 'Pizzas',
            isVegetarian: true,
            isPopular: true,
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
          MenuItem(
            id: 'menu_2_2',
            restaurantId: restaurantId,
            name: 'Burger Classic',
            description: 'Steak de bœuf, salade, tomate, cornichons, sauce burger',
            priceXof: 3500,
            categoryId: 'cat_2',
            categoryName: 'Burgers',
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
          MenuItem(
            id: 'menu_2_3',
            restaurantId: restaurantId,
            name: 'Pizza 4 Fromages',
            description: 'Mozzarella, gorgonzola, parmesan, chèvre',
            priceXof: 5500,
            categoryId: 'cat_1',
            categoryName: 'Pizzas',
            isVegetarian: true,
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        
      case 'demo_4': // Boulangerie des Palmes
        return [
          MenuItem(
            id: 'menu_4_1',
            restaurantId: restaurantId,
            name: 'Pain de Campagne',
            description: 'Pain artisanal à la farine de blé complet',
            priceXof: 800,
            categoryId: 'cat_1',
            categoryName: 'Pains',
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
          MenuItem(
            id: 'menu_4_2',
            restaurantId: restaurantId,
            name: 'Croissant',
            description: 'Croissant au beurre traditionnel',
            priceXof: 300,
            categoryId: 'cat_2',
            categoryName: 'Viennoiseries',
            isPopular: true,
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
          MenuItem(
            id: 'menu_4_3',
            restaurantId: restaurantId,
            name: 'Gâteau au Chocolat',
            description: 'Gâteau moelleux au chocolat noir',
            priceXof: 2000,
            categoryId: 'cat_3',
            categoryName: 'Pâtisseries',
            isAvailable: true,
            createdAt: now,
            updatedAt: now,
          ),
        ];
        
      default:
        return [];
    }
  }
}

// Riverpod providers for restaurant data
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService();
});

final allRestaurantsProvider = FutureProvider<List<Restaurant>>((ref) async {
  return RestaurantService.getAllRestaurants();
});

final restaurantByIdProvider =
    FutureProvider.family<Restaurant?, String>((ref, restaurantId) async {
  return RestaurantService.getRestaurantById(restaurantId);
});

final menuItemsProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, restaurantId) async {
  return RestaurantService.getMenuItems(restaurantId);
});

final menuCategoriesProvider =
    FutureProvider.family<List<MenuCategory>, String>(
        (ref, restaurantId) async {
  return RestaurantService.getMenuCategories(restaurantId);
});
