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
      final response = await SupabaseService.client
          .from(_restaurantsTable)
          .select()
          .eq('is_active', true)
          .eq('is_verified', true)
          .order('name');

      return response.map((json) => Restaurant.fromJson(json)).toList();
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
        if (restaurant == null) return false;
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
          if (a == null || b == null) return 0;
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
      final response = await SupabaseService.client
          .from(_menuItemsTable)
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .order('display_order')
          .order('name');

      return response.map((json) => MenuItem.fromJson(json)).toList();
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
