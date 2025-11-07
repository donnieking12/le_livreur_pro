// lib/core/services/order_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/services/pricing_service.dart';

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
        deliveryFeeXof: pricingBreakdown['distancePrice'] ?? 0,
        serviceFeeXof: pricingBreakdown['priorityPrice'] ?? 0,
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

      // Track analytics (fixed implementation)
      debugPrint('📊 Order created: ${order.orderNumber} for $customerId');

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
        deliveryFeeXof: deliveryPriceXof,
        serviceFeeXof: 0,
        totalPriceXof: totalPriceXof,
        items: items,
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

      // Track analytics (fixed implementation)
      debugPrint('📊 Marketplace order created: ${order.orderNumber} for $customerId');

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
      // For development - return demo data
      return _getDemoUserOrders(userId);
      
      // TODO: Enable this for production
      /*
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
      */
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
      // For development - calculate from demo data
      final orders = _getDemoUserOrders(userId);
      
      final int totalOrders = orders.length;
      int activeOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      int totalSpentXof = 0;

      for (final order in orders) {
        totalSpentXof += order.totalPriceXof;

        if (order.status.isActive) {
          activeOrders++;
        } else if (order.status == DeliveryStatus.delivered) {
          completedOrders++;
        } else if (order.status == DeliveryStatus.cancelled) {
          cancelledOrders++;
        }
      }

      return OrderStats(
        totalOrders: totalOrders,
        activeOrders: activeOrders,
        completedOrders: completedOrders,
        cancelledOrders: cancelledOrders,
        totalSpentXof: totalSpentXof,
      );
      
      // TODO: Enable this for production
      /*
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
      */
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

  /// Demo data for development
  List<DeliveryOrder> _getDemoUserOrders(String userId) {
    final now = DateTime.now();
    return [
      DeliveryOrder(
        id: 'demo_order_1',
        orderNumber: 'CMD-2024-001',
        customerId: userId,
        orderType: OrderType.package,
        packageDescription: 'Documents importants',
        status: DeliveryStatus.inTransit,
        paymentStatus: PaymentStatus.completed,
        priorityLevel: 2,
        pickupLatitude: 5.3364,
        pickupLongitude: -4.0267,
        deliveryLatitude: 5.2893,
        deliveryLongitude: -3.9926,
        pickupAddress: 'Cocody, Angré 7ème Tranche, Villa 25',
        deliveryAddress: 'Plateau, Immeuble Alpha 2000, 5ème étage',
        deliveryFeeXof: 1250,
        serviceFeeXof: 200,
        totalPriceXof: 1950,
        recipientName: 'Adjoua Kouassi',
        recipientPhone: '+225 07 98 76 54 32',
        paymentMethod: PaymentMethod.orangeMoney,
        fragile: false,
        requiresSignature: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      DeliveryOrder(
        id: 'demo_order_2',
        orderNumber: 'CMD-2024-002',
        customerId: userId,
        orderType: OrderType.marketplace,
        restaurantId: 'demo_1',
        status: DeliveryStatus.delivered,
        paymentStatus: PaymentStatus.completed,
        priorityLevel: 1,
        pickupLatitude: 5.3599517,
        pickupLongitude: -3.9715851,
        deliveryLatitude: 5.3364,
        deliveryLongitude: -4.0267,
        pickupAddress: 'Chez Mama Adjoua, Cocody Angré',
        deliveryAddress: 'Cocody, Angré 7ème Tranche, Villa 25',
        deliveryFeeXof: 500,
        serviceFeeXof: 0,
        totalPriceXof: 6500,
        items: [
          OrderItem(
            id: 'item_1',
            menuItemId: 'menu_1_1',
            name: 'Attiéké Poisson',
            unitPriceXof: 2500,
            quantity: 1,
            totalPriceXof: 2500,
          ),
          OrderItem(
            id: 'item_2',
            menuItemId: 'menu_1_2',
            name: 'Kedjenou de Poulet',
            unitPriceXof: 3000,
            quantity: 1,
            totalPriceXof: 3000,
          ),
          OrderItem(
            id: 'item_3',
            menuItemId: 'menu_1_3',
            name: 'Alloco',
            unitPriceXof: 1500,
            quantity: 1,
            totalPriceXof: 1500,
          ),
        ],
        recipientName: 'Jean Kouassi',
        recipientPhone: '+225 07 12 34 56 78',
        paymentMethod: PaymentMethod.cashOnDelivery,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1, hours: -2)),
      ),
      DeliveryOrder(
        id: 'demo_order_3',
        orderNumber: 'CMD-2024-003',
        customerId: userId,
        orderType: OrderType.package,
        packageDescription: 'Vêtements',
        status: DeliveryStatus.cancelled,
        paymentStatus: PaymentStatus.refunded,
        priorityLevel: 1,
        pickupLatitude: 5.2918802,
        pickupLongitude: -4.0197926,
        deliveryLatitude: 5.3247036,
        deliveryLongitude: -4.0285659,
        pickupAddress: 'Treichville, Rue 12, près du marché',
        deliveryAddress: 'Plateau, Avenue Chardy',
        deliveryFeeXof: 500,
        serviceFeeXof: 0,
        totalPriceXof: 500,
        recipientName: 'Marie Traoré',
        recipientPhone: '+225 07 55 44 33 22',
        paymentMethod: PaymentMethod.mtnMoney,
        specialInstructions: 'Annulé par le client',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3, hours: -1)),
      ),
      DeliveryOrder(
        id: 'demo_order_4',
        orderNumber: 'CMD-2024-004',
        customerId: userId,
        orderType: OrderType.package,
        packageDescription: 'Médicaments',
        status: DeliveryStatus.pending,
        paymentStatus: PaymentStatus.pending,
        priorityLevel: 3,
        pickupLatitude: 5.3247036,
        pickupLongitude: -4.0285659,
        deliveryLatitude: 5.3364,
        deliveryLongitude: -4.0267,
        pickupAddress: 'Pharmacie du Plateau, Avenue Chardy',
        deliveryAddress: 'Cocody, Angré 7ème Tranche, Villa 25',
        deliveryFeeXof: 500,
        serviceFeeXof: 400,
        totalPriceXof: 1900,
        recipientName: 'Jean Kouassi',
        recipientPhone: '+225 07 12 34 56 78',
        paymentMethod: PaymentMethod.wave,
        fragile: true,
        requiresSignature: true,
        specialInstructions: 'Livraison express - médicaments urgents',
        createdAt: now.subtract(const Duration(minutes: 15)),
        updatedAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];
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
