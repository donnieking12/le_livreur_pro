import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/models/menu_item.dart';
import 'package:le_livreur_pro/core/models/menu_category.dart';

class MenuService {
  static final _supabase = Supabase.instance.client;

  // ==================== MENU CATEGORIES ====================

  /// Get all menu categories for a restaurant
  static Future<List<MenuCategory>> getMenuCategories(
      String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_categories')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('display_order');

      return (response as List)
          .map((json) => MenuCategory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load menu categories: $e');
    }
  }

  /// Create a new menu category
  static Future<MenuCategory> createMenuCategory(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('menu_categories')
          .insert({
            'restaurant_id': restaurantId,
            ...data,
          })
          .select()
          .single();

      return MenuCategory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create menu category: $e');
    }
  }

  /// Update a menu category
  static Future<MenuCategory> updateMenuCategory(
    String categoryId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('menu_categories')
          .update(data)
          .eq('id', categoryId)
          .select()
          .single();

      return MenuCategory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update menu category: $e');
    }
  }

  /// Delete a menu category
  static Future<void> deleteMenuCategory(String categoryId) async {
    try {
      await _supabase.from('menu_categories').delete().eq('id', categoryId);
    } catch (e) {
      throw Exception('Failed to delete menu category: $e');
    }
  }

  // ==================== MENU ITEMS ====================

  /// Get all menu items for a restaurant
  static Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .order('display_order');

      return (response as List).map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load menu items: $e');
    }
  }

  /// Get menu items by category
  static Future<List<MenuItem>> getMenuItemsByCategory(
    String restaurantId,
    String categoryId,
  ) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('category_id', categoryId)
          .order('display_order');

      return (response as List).map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load menu items by category: $e');
    }
  }

  /// Get available menu items for a restaurant
  static Future<List<MenuItem>> getAvailableMenuItems(
      String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .order('display_order');

      return (response as List).map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load available menu items: $e');
    }
  }

  /// Get a single menu item by ID
  static Future<MenuItem?> getMenuItemById(String itemId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('id', itemId)
          .maybeSingle();

      return response != null ? MenuItem.fromJson(response) : null;
    } catch (e) {
      throw Exception('Failed to load menu item: $e');
    }
  }

  /// Create a new menu item
  static Future<MenuItem> createMenuItem(
    String restaurantId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .insert({
            'restaurant_id': restaurantId,
            ...data,
          })
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create menu item: $e');
    }
  }

  /// Update a menu item
  static Future<MenuItem> updateMenuItem(
    String itemId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .update(data)
          .eq('id', itemId)
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update menu item: $e');
    }
  }

  /// Delete a menu item
  static Future<void> deleteMenuItem(String itemId) async {
    try {
      await _supabase.from('menu_items').delete().eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to delete menu item: $e');
    }
  }

  /// Update menu item availability
  static Future<void> updateMenuItemAvailability(
    String itemId,
    bool isAvailable,
  ) async {
    try {
      await _supabase
          .from('menu_items')
          .update({'is_available': isAvailable}).eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to update menu item availability: $e');
    }
  }

  /// Update menu item stock quantity
  static Future<void> updateMenuItemStock(
    String itemId,
    int stockQuantity,
  ) async {
    try {
      await _supabase
          .from('menu_items')
          .update({'stock_quantity': stockQuantity}).eq('id', itemId);
    } catch (e) {
      throw Exception('Failed to update menu item stock: $e');
    }
  }

  /// Get popular menu items for a restaurant
  static Future<List<MenuItem>> getPopularMenuItems(
    String restaurantId, {
    int limit = 10,
  }) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .order('total_orders', ascending: false)
          .limit(limit);

      return (response as List).map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load popular menu items: $e');
    }
  }

  /// Search menu items
  static Future<List<MenuItem>> searchMenuItems(
    String restaurantId,
    String query,
  ) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .or('name.ilike.%$query%,description.ilike.%$query%,ingredients.ilike.%$query%')
          .order('display_order');

      return (response as List).map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search menu items: $e');
    }
  }

  /// Reorder menu items
  static Future<void> reorderMenuItems(
    List<Map<String, dynamic>> itemOrders,
  ) async {
    try {
      for (final itemOrder in itemOrders) {
        await _supabase
            .from('menu_items')
            .update({'display_order': itemOrder['displayOrder']}).eq(
                'id', itemOrder['id']);
      }
    } catch (e) {
      throw Exception('Failed to reorder menu items: $e');
    }
  }

  /// Reorder menu categories
  static Future<void> reorderMenuCategories(
    List<Map<String, dynamic>> categoryOrders,
  ) async {
    try {
      for (final categoryOrder in categoryOrders) {
        await _supabase
            .from('menu_categories')
            .update({'display_order': categoryOrder['displayOrder']}).eq(
                'id', categoryOrder['id']);
      }
    } catch (e) {
      throw Exception('Failed to reorder menu categories: $e');
    }
  }

  /// Duplicate a menu item
  static Future<MenuItem> duplicateMenuItem(String itemId) async {
    try {
      // Get the original item
      final original = await getMenuItemById(itemId);
      if (original == null) {
        throw Exception('Menu item not found');
      }

      // Create a copy with modified name
      final duplicateData = original.toJson();
      duplicateData.remove('id');
      duplicateData.remove('created_at');
      duplicateData.remove('updated_at');
      duplicateData['name'] = '${original.name} (Copie)';

      final response = await _supabase
          .from('menu_items')
          .insert(duplicateData)
          .select()
          .single();

      return MenuItem.fromJson(response);
    } catch (e) {
      throw Exception('Failed to duplicate menu item: $e');
    }
  }

  /// Get menu statistics for a restaurant
  static Future<Map<String, dynamic>> getMenuStatistics(
      String restaurantId) async {
    try {
      final totalItems = await _supabase
          .from('menu_items')
          .select('id')
          .eq('restaurant_id', restaurantId)
          .count(CountOption.exact);

      final availableItems = await _supabase
          .from('menu_items')
          .select('id')
          .eq('restaurant_id', restaurantId)
          .eq('is_available', true)
          .count(CountOption.exact);

      final popularItems = await _supabase
          .from('menu_items')
          .select('id')
          .eq('restaurant_id', restaurantId)
          .eq('is_popular', true)
          .count(CountOption.exact);

      final categories = await _supabase
          .from('menu_categories')
          .select('id')
          .eq('restaurant_id', restaurantId)
          .count(CountOption.exact);

      return {
        'totalItems': totalItems.count,
        'availableItems': availableItems.count,
        'popularItems': popularItems.count,
        'totalCategories': categories.count,
      };
    } catch (e) {
      throw Exception('Failed to get menu statistics: $e');
    }
  }
}
