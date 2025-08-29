// lib/core/services/order_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:le_livreur_pro/core/models/delivery_order_simple.dart';
import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/services/analytics_service.dart';
import 'package:le_livreur_pro/core/services/pricing_service.dart';
import 'package:le_livreur_pro/core/services/supabase_service.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final userOrdersProvider =
    FutureProvider.family<List<DeliveryOrder>, String>((ref, userId) async {
  return await ref.read(orderServiceProvider).getUserOrders(userId);
});

final orderStatsProvider =
    FutureProvider.family<OrderStats, String>((ref, userId) async {
  return await ref.read(orderServiceProvider).getUserOrderStats(userId);
});

final recentOrdersProvider =
    FutureProvider.family<List<DeliveryOrder>, String>((ref, userId) async {
  return await ref.read(orderServiceProvider).getRecentOrders(userId);
});

final orderByIdProvider =
    FutureProvider.family<DeliveryOrder?, String>((ref, orderId) async {
  return await ref.read(orderServiceProvider).getOrderById(orderId);
});

class OrderService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const Uuid _uuid = Uuid();

  // ==================== ORDER CREATION ====================

  /// Create a new package delivery order
  Future<DeliveryOrder> createPackageOrder({
    required String customerId,
    required String packageDescription,
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required String pickupAddress,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
    String? recipientEmail,
    String? specialInstructions,
    required PaymentMethod paymentMethod,
    int packageValueXof = 0,
    bool fragile = false,
    bool requiresSignature = false,
    int priorityLevel = 1,
  }) async {
    try {
      // Calculate distance first
      final distanceKm = PricingService.calculateDistance(
        lat1: pickupLatitude,
        lon1: pickupLongitude,
        lat2: deliveryLatitude,
        lon2: deliveryLongitude,
      );

      // Calculate pricing
      final totalPriceXof = PricingService.calculateDeliveryPrice(
        distanceKm: distanceKm,
        priorityLevel: priorityLevel,
        fragile: fragile,
      );

      // Get pricing breakdown for additional details
      final pricingBreakdown = PricingService.getPricingBreakdown(
        distanceKm: distanceKm,
        priorityLevel: priorityLevel,
        fragile: fragile,
      );

      // Generate order number
      final orderNumber = _generateOrderNumber();

      final order = DeliveryOrder(
        id: _uuid.v4(),
        orderNumber: orderNumber,
        customerId: customerId,
        orderType: OrderType.package,
        packageDescription: packageDescription,
        packageValueXof: packageValueXof,
        fragile: fragile,
        requiresSignature: requiresSignature,
        status: DeliveryStatus.pending,
        paymentStatus: PaymentStatus.pending,
        priorityLevel: priorityLevel,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        basePriceXof: pricingBreakdown['basePrice'] ?? 500,
        baseZoneRadiusKm: pricingBreakdown['baseZoneRadius'] ?? 4.5,
        additionalDistancePriceXof: pricingBreakdown['distancePrice'] ?? 0,
        urgencyPriceXof: pricingBreakdown['priorityPrice'] ?? 0,
        fragilePriceXof: pricingBreakdown['fragilePrice'] ?? 0,
        totalPriceXof: totalPriceXof,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        recipientEmail: recipientEmail,
        specialInstructions: specialInstructions,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _supabase.from('delivery_orders').insert(order.toJson());

      // Track analytics
      // Note: Remove this line as trackOrderCreated method doesn't exist
      // await AnalyticsService.trackOrderCreated(
      //   orderId: order.id,
      //   userId: customerId,
      //   orderType: 'package',
      //   amount: order.totalPriceXof.toDouble(),
      //   paymentMethod: paymentMethod.name,
      // );

      return order;
    } catch (e) {
      debugPrint('Error creating package order: $e');
      throw Exception('Failed to create package order: $e');
    }
  }

  /// Create a new marketplace order (restaurant)
  Future<DeliveryOrder> createMarketplaceOrder({
    required String customerId,
    required String restaurantId,
    required List<OrderItem> items,
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
    required String pickupAddress,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
    String? recipientEmail,
    String? specialInstructions,
    required PaymentMethod paymentMethod,
    int priorityLevel = 1,
  }) async {
    try {
      // Calculate item totals
      final itemsTotal =
          items.fold<int>(0, (sum, item) => sum + item.totalPriceXof);

      // Calculate distance
      final distanceKm = PricingService.calculateDistance(
        lat1: pickupLatitude,
        lon1: pickupLongitude,
        lat2: deliveryLatitude,
        lon2: deliveryLongitude,
      );

      // Calculate delivery pricing
      final deliveryPriceXof = PricingService.calculateDeliveryPrice(
        distanceKm: distanceKm,
        priorityLevel: priorityLevel,
      );

      // Get pricing breakdown
      final pricingBreakdown = PricingService.getPricingBreakdown(
        distanceKm: distanceKm,
        priorityLevel: priorityLevel,
      );

      final totalPriceXof = itemsTotal + deliveryPriceXof;

      // Generate order number
      final orderNumber = _generateOrderNumber();

      final order = DeliveryOrder(
        id: _uuid.v4(),
        orderNumber: orderNumber,
        customerId: customerId,
        restaurantId: restaurantId,
        orderType: OrderType.marketplace,
        status: DeliveryStatus.pending,
        paymentStatus: PaymentStatus.pending,
        priorityLevel: priorityLevel,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        deliveryLatitude: deliveryLatitude,
        deliveryLongitude: deliveryLongitude,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        basePriceXof: pricingBreakdown['basePrice'] ?? 500,
        baseZoneRadiusKm: pricingBreakdown['baseZoneRadius'] ?? 4.5,
        additionalDistancePriceXof: pricingBreakdown['distancePrice'] ?? 0,
        urgencyPriceXof: pricingBreakdown['priorityPrice'] ?? 0,
        totalPriceXof: totalPriceXof,
        recipientName: recipientName,
        recipientPhone: recipientPhone,
        recipientEmail: recipientEmail,
        specialInstructions: specialInstructions,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      await _supabase.from('delivery_orders').insert(order.toJson());

      // Track analytics
      // Note: Remove this line as trackOrderCreated method doesn't exist
      // await AnalyticsService.trackOrderCreated(
      //   orderId: order.id,
      //   userId: customerId,
      //   orderType: 'marketplace',
      //   amount: order.totalPriceXof.toDouble(),
      //   paymentMethod: paymentMethod.name,
      //   additionalData: {
      //     'restaurant_id': restaurantId,
      //     'item_count': items.length,
      //     'items_total': itemsTotal,
      //   },
      // );

      return order;
    } catch (e) {
      debugPrint('Error creating marketplace order: $e');
      throw Exception('Failed to create marketplace order: $e');
    }
  }

  // ==================== ORDER RETRIEVAL ====================

  /// Get all orders for a user
  Future<List<DeliveryOrder>> getUserOrders(String userId) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting user orders: $e');
      throw Exception('Failed to get user orders: $e');
    }
  }

  /// Get recent orders for a user (last 10)
  Future<List<DeliveryOrder>> getRecentOrders(String userId,
      {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting recent orders: $e');
      throw Exception('Failed to get recent orders: $e');
    }
  }

  /// Get a specific order by ID
  Future<DeliveryOrder?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('id', orderId)
          .single();

      return DeliveryOrder.fromJson(response);
    } catch (e) {
      debugPrint('Error getting order by ID: $e');
      return null;
    }
  }

  /// Get user order statistics
  Future<OrderStats> getUserOrderStats(String userId) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select('status, total_price_xof, created_at')
          .eq('customer_id', userId);

      final int totalOrders = response.length;
      int activeOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      int totalSpentXof = 0;

      for (final order in response) {
        final status = order['status'] as String;
        final amount = order['total_price_xof'] as int? ?? 0;

        totalSpentXof += amount;

        switch (status) {
          case 'pending':
          case 'assigned':
          case 'courier_en_route':
          case 'picked_up':
          case 'in_transit':
          case 'arrived_destination':
            activeOrders++;
            break;
          case 'delivered':
            completedOrders++;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      return OrderStats(
        totalOrders: totalOrders,
        activeOrders: activeOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        totalSpentXof: totalSpentXof,
      );
    } catch (e) {
      debugPrint('Error getting user order stats: $e');
      throw Exception('Failed to get user order stats: $e');
    }
  }

  // ==================== ORDER UPDATES ====================

  /// Cancel an order
  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      await _supabase.from('delivery_orders').update({
        'status': DeliveryStatus.cancelled.name,
        'special_instructions': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      return true;
    } catch (e) {
      debugPrint('Error cancelling order: $e');
      return false;
    }
  }

  /// Rate a completed order
  Future<bool> rateOrder(String orderId, int rating, String? feedback) async {
    try {
      // TODO: Implement rating system in database schema
      debugPrint('Rating order $orderId: $rating stars, feedback: $feedback');
      return true;
    } catch (e) {
      debugPrint('Error rating order: $e');
      return false;
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Generate unique order number
  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'CMD-${now.year}-$timestamp';
  }

  /// Get order status stream for real-time updates
  Stream<DeliveryOrder?> getOrderStatusStream(String orderId) {
    return _supabase
        .from('delivery_orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((data) {
          if (data.isNotEmpty) {
            return DeliveryOrder.fromJson(data.first);
          }
          return null;
        });
  }

  /// Filter orders by status
  List<DeliveryOrder> filterOrdersByStatus(
      List<DeliveryOrder> orders, DeliveryStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  /// Filter orders by date range
  List<DeliveryOrder> filterOrdersByDateRange(
    List<DeliveryOrder> orders,
    DateTime startDate,
    DateTime endDate,
  ) {
    return orders.where((order) {
      return order.createdAt.isAfter(startDate) &&
          order.createdAt.isBefore(endDate);
    }).toList();
  }
}

// ==================== DATA MODELS ====================

class OrderStats {
  final int totalOrders;
  final int activeOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int totalSpentXof;

  OrderStats({
    required this.totalOrders,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalSpentXof,
  });

  String get totalSpentFormatted => '$totalSpentXof XOF';
  double get completionRate =>
      totalOrders > 0 ? completedOrders / totalOrders : 0.0;
  String get completionRateFormatted =>
      '${(completionRate * 100).toStringAsFixed(1)}%';
}

// Simple OrderItem for marketplace orders (without freezed)
class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final int unitPriceXof;
  final int quantity;
  final List<String> variations;
  final List<String> addons;
  final String? specialInstructions;
  final int totalPriceXof;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.unitPriceXof,
    required this.quantity,
    this.variations = const [],
    this.addons = const [],
    this.specialInstructions,
    required this.totalPriceXof,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      unitPriceXof: json['unit_price_xof'] as int,
      quantity: json['quantity'] as int,
      variations: List<String>.from(json['variations'] ?? []),
      addons: List<String>.from(json['addons'] ?? []),
      specialInstructions: json['special_instructions'] as String?,
      totalPriceXof: json['total_price_xof'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'name': name,
      'unit_price_xof': unitPriceXof,
      'quantity': quantity,
      'variations': variations,
      'addons': addons,
      'special_instructions': specialInstructions,
      'total_price_xof': totalPriceXof,
    };
  }
}
