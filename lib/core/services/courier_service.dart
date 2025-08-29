// lib/core/services/courier_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

import 'package:le_livreur_pro/core/models/delivery_order_simple.dart';
import 'package:le_livreur_pro/core/models/user.dart' as app_user;
import 'package:le_livreur_pro/core/services/analytics_service.dart';
import 'package:le_livreur_pro/core/services/supabase_service.dart';

final courierServiceProvider = Provider<CourierService>((ref) {
  return CourierService();
});

final courierStatsProvider =
    FutureProvider.family<CourierStats, String>((ref, courierId) async {
  return await ref.read(courierServiceProvider).getCourierStats(courierId);
});

final availableOrdersProvider =
    FutureProvider<List<DeliveryOrder>>((ref) async {
  return await ref.read(courierServiceProvider).getAvailableOrders();
});

final courierOrdersProvider =
    FutureProvider.family<List<DeliveryOrder>, String>((ref, courierId) async {
  return await ref.read(courierServiceProvider).getCourierOrders(courierId);
});

final courierLocationProvider =
    StreamProvider.family<Position, String>((ref, courierId) {
  return ref.read(courierServiceProvider).trackCourierLocation(courierId);
});

class CourierService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // ==================== COURIER STATS & DASHBOARD ====================

  /// Get comprehensive courier statistics
  Future<CourierStats> getCourierStats(String courierId) async {
    try {
      // Get today's stats
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final todayResponse = await _supabase
          .from('delivery_orders')
          .select('total_price_xof, status, created_at')
          .eq('courier_id', courierId)
          .gte('created_at', startOfDay.toIso8601String());

      // Get overall stats
      final overallResponse = await _supabase
          .from('delivery_orders')
          .select('total_price_xof, status, created_at')
          .eq('courier_id', courierId)
          .eq('status', 'delivered');

      // Get courier rating
      final courierResponse = await _supabase
          .from('users')
          .select('rating, total_deliveries')
          .eq('id', courierId)
          .single();

      // Calculate today's stats
      int todayDeliveries = 0;
      int todayEarnings = 0;

      for (final order in todayResponse) {
        if (order['status'] == 'delivered') {
          todayDeliveries++;
          todayEarnings += (order['total_price_xof'] as int? ?? 0);
        }
      }

      // Calculate overall stats
      int totalEarnings = 0;
      for (final order in overallResponse) {
        totalEarnings += (order['total_price_xof'] as int? ?? 0);
      }

      return CourierStats(
        todayDeliveries: todayDeliveries,
        todayEarningsXof: todayEarnings,
        totalDeliveries: courierResponse['total_deliveries'] as int? ?? 0,
        totalEarningsXof: totalEarnings,
        rating: (courierResponse['rating'] as num?)?.toDouble() ?? 0.0,
        activeOrders: todayResponse
            .where((o) => [
                  'assigned',
                  'courier_en_route',
                  'picked_up',
                  'in_transit'
                ].contains(o['status']))
            .length,
      );
    } catch (e) {
      debugPrint('Error getting courier stats: $e');
      throw Exception('Failed to get courier stats: $e');
    }
  }

  /// Get available orders for courier to accept
  Future<List<DeliveryOrder>> getAvailableOrders() async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('status', 'pending')
          .isFilter('courier_id', null)
          .order('priority_level', ascending: false)
          .order('created_at', ascending: true)
          .limit(20);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting available orders: $e');
      throw Exception('Failed to get available orders: $e');
    }
  }

  /// Get courier's assigned orders
  Future<List<DeliveryOrder>> getCourierOrders(String courierId) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('courier_id', courierId)
          .inFilter('status', [
        'assigned',
        'courier_en_route',
        'picked_up',
        'in_transit',
        'arrived_destination'
      ]).order('created_at', ascending: false);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting courier orders: $e');
      throw Exception('Failed to get courier orders: $e');
    }
  }

  /// Get courier's recent delivery history
  Future<List<DeliveryOrder>> getCourierHistory(String courierId,
      {int limit = 10}) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('courier_id', courierId)
          .inFilter('status', ['delivered', 'cancelled'])
          .order('updated_at', ascending: false)
          .limit(limit);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting courier history: $e');
      throw Exception('Failed to get courier history: $e');
    }
  }

  // ==================== JOB MANAGEMENT ====================

  /// Accept a delivery order
  Future<bool> acceptOrder(String orderId, String courierId) async {
    try {
      // Check if order is still available
      final orderResponse = await _supabase
          .from('delivery_orders')
          .select('status, courier_id')
          .eq('id', orderId)
          .single();

      if (orderResponse['status'] != 'pending' ||
          orderResponse['courier_id'] != null) {
        throw Exception('Order is no longer available');
      }

      // Update order with courier
      await _supabase.from('delivery_orders').update({
        'courier_id': courierId,
        'status': 'assigned',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Track analytics
      // TODO: Implement AnalyticsService.trackCourierAssigned method
      // await AnalyticsService.trackCourierAssigned(
      //   orderId: orderId,
      //   courierId: courierId,
      //   courierName: 'Courier', // TODO: Get actual courier name
      //   pickupLocation: 'Pickup Location', // TODO: Get actual locations
      //   deliveryLocation: 'Delivery Location',
      // );

      return true;
    } catch (e) {
      debugPrint('Error accepting order: $e');
      throw Exception('Failed to accept order: $e');
    }
  }

  /// Update order status
  Future<bool> updateOrderStatus(
    String orderId,
    DeliveryStatus newStatus, {
    double? latitude,
    double? longitude,
    String? note,
  }) async {
    try {
      // Update order status
      await _supabase.from('delivery_orders').update({
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      // Add status update to history
      final statusUpdate = OrderStatusUpdate(
        status: newStatus,
        timestamp: DateTime.now(),
        note: note,
        latitude: latitude,
        longitude: longitude,
      );

      // Get current status history and append new update
      final orderResponse = await _supabase
          .from('delivery_orders')
          .select('status_history')
          .eq('id', orderId)
          .single();

      final currentHistory = List<Map<String, dynamic>>.from(
          orderResponse['status_history'] ?? []);
      currentHistory.add({
        'status': statusUpdate.status.name,
        'timestamp': statusUpdate.timestamp.toIso8601String(),
        'note': statusUpdate.note,
        'latitude': statusUpdate.latitude,
        'longitude': statusUpdate.longitude,
      });

      await _supabase.from('delivery_orders').update({
        'status_history': currentHistory,
      }).eq('id', orderId);

      return true;
    } catch (e) {
      debugPrint('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Start delivery (courier is en route to pickup)
  Future<bool> startDelivery(String orderId, String courierId) async {
    try {
      await updateOrderStatus(orderId, DeliveryStatus.courierEnRoute);

      // Track analytics
      // TODO: Implement AnalyticsService.trackDeliveryStarted method
      // await AnalyticsService.trackDeliveryStarted(
      //   orderId: orderId,
      //   courierId: courierId,
      //   courierName: 'Courier', // TODO: Get actual courier name
      // );

      return true;
    } catch (e) {
      debugPrint('Error starting delivery: $e');
      return false;
    }
  }

  /// Mark package as picked up
  Future<bool> markPickedUp(String orderId) async {
    try {
      await _supabase.from('delivery_orders').update({
        'status': DeliveryStatus.pickedUp.name,
        'actual_pickup_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      await updateOrderStatus(orderId, DeliveryStatus.pickedUp,
          note: 'Package picked up by courier');

      return true;
    } catch (e) {
      debugPrint('Error marking picked up: $e');
      return false;
    }
  }

  /// Mark as delivered
  Future<bool> markDelivered(String orderId, String courierId) async {
    try {
      await _supabase.from('delivery_orders').update({
        'status': DeliveryStatus.delivered.name,
        'actual_delivery_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);

      await updateOrderStatus(orderId, DeliveryStatus.delivered,
          note: 'Package delivered successfully');

      // Update courier stats
      await _updateCourierDeliveryCount(courierId);

      // Track analytics
      // TODO: Implement AnalyticsService.trackDeliveryCompleted method
      // await AnalyticsService.trackDeliveryCompleted(
      //   orderId: orderId,
      //   courierId: courierId,
      //   courierName: 'Courier', // TODO: Get actual courier name
      //   actualDeliveryTime:
      //       const Duration(minutes: 30), // TODO: Calculate actual time
      // );

      return true;
    } catch (e) {
      debugPrint('Error marking delivered: $e');
      return false;
    }
  }

  // ==================== COURIER STATUS MANAGEMENT ====================

  /// Update courier online/offline status
  Future<bool> updateCourierStatus(String courierId, bool isOnline) async {
    try {
      await _supabase.from('users').update({
        'is_online': isOnline,
        'last_login_at': isOnline ? DateTime.now().toIso8601String() : null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', courierId);

      return true;
    } catch (e) {
      debugPrint('Error updating courier status: $e');
      return false;
    }
  }

  /// Update courier location
  Future<bool> updateCourierLocation(
      String courierId, double latitude, double longitude) async {
    try {
      await _supabase.from('users').update({
        'current_latitude': latitude,
        'current_longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', courierId);

      return true;
    } catch (e) {
      debugPrint('Error updating courier location: $e');
      return false;
    }
  }

  // ==================== REAL-TIME TRACKING ====================

  /// Track courier location in real-time
  Stream<Position> trackCourierLocation(String courierId) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Update every 10 meters
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings)
        .map((position) {
      // Update location in database
      updateCourierLocation(courierId, position.latitude, position.longitude);
      return position;
    });
  }

  /// Get live order updates stream
  Stream<List<DeliveryOrder>> getOrderUpdatesStream(String courierId) {
    return _supabase
        .from('delivery_orders')
        .stream(primaryKey: ['id'])
        .eq('courier_id', courierId)
        .map((data) =>
            data.map((json) => DeliveryOrder.fromJson(json)).toList());
  }

  // ==================== PRIVATE HELPER METHODS ====================

  /// Update courier's total delivery count
  Future<void> _updateCourierDeliveryCount(String courierId) async {
    try {
      // Get current delivery count
      final response = await _supabase
          .from('users')
          .select('total_deliveries')
          .eq('id', courierId)
          .single();

      final currentCount = response['total_deliveries'] as int? ?? 0;

      await _supabase.from('users').update({
        'total_deliveries': currentCount + 1,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', courierId);
    } catch (e) {
      debugPrint('Error updating courier delivery count: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Calculate earnings for a period
  Future<Map<String, dynamic>> getCourierEarnings(
    String courierId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase
          .from('delivery_orders')
          .select('total_price_xof, created_at')
          .eq('courier_id', courierId)
          .eq('status', 'delivered');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;

      int totalEarnings = 0;
      final int totalDeliveries = response.length;

      for (final order in response) {
        totalEarnings += (order['total_price_xof'] as int? ?? 0);
      }

      return {
        'total_earnings_xof': totalEarnings,
        'total_deliveries': totalDeliveries,
        'average_per_delivery_xof':
            totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0,
        'period_start': startDate?.toIso8601String(),
        'period_end': endDate?.toIso8601String(),
      };
    } catch (e) {
      debugPrint('Error calculating courier earnings: $e');
      throw Exception('Failed to calculate courier earnings: $e');
    }
  }

  /// Get courier performance metrics
  Future<CourierPerformance> getCourierPerformance(String courierId) async {
    try {
      // Get delivery times and ratings
      final response = await _supabase
          .from('delivery_orders')
          .select('estimated_delivery_time, actual_delivery_time, created_at')
          .eq('courier_id', courierId)
          .eq('status', 'delivered')
          .limit(50);

      int onTimeDeliveries = 0;
      final int totalDeliveries = response.length;
      Duration totalDeliveryTime = Duration.zero;

      for (final order in response) {
        final estimated =
            DateTime.tryParse(order['estimated_delivery_time'] ?? '');
        final actual = DateTime.tryParse(order['actual_delivery_time'] ?? '');
        final created = DateTime.tryParse(order['created_at'] ?? '');

        if (estimated != null && actual != null) {
          if (actual.isBefore(estimated) ||
              actual.isAtSameMomentAs(estimated)) {
            onTimeDeliveries++;
          }

          if (created != null) {
            totalDeliveryTime += actual.difference(created);
          }
        }
      }

      final onTimeRate =
          totalDeliveries > 0 ? onTimeDeliveries / totalDeliveries : 0.0;
      final avgDeliveryMinutes = totalDeliveries > 0
          ? totalDeliveryTime.inMinutes.toDouble() / totalDeliveries
          : 0.0;

      // Get courier rating
      final courierResponse = await _supabase
          .from('users')
          .select('rating')
          .eq('id', courierId)
          .single();

      return CourierPerformance(
        onTimeDeliveryRate: onTimeRate,
        averageDeliveryMinutes: avgDeliveryMinutes,
        rating: (courierResponse['rating'] as num?)?.toDouble() ?? 0.0,
        totalCompletedDeliveries: totalDeliveries,
      );
    } catch (e) {
      debugPrint('Error getting courier performance: $e');
      throw Exception('Failed to get courier performance: $e');
    }
  }
}

// ==================== DATA MODELS ====================

class CourierStats {
  final int todayDeliveries;
  final int todayEarningsXof;
  final int totalDeliveries;
  final int totalEarningsXof;
  final double rating;
  final int activeOrders;

  CourierStats({
    required this.todayDeliveries,
    required this.todayEarningsXof,
    required this.totalDeliveries,
    required this.totalEarningsXof,
    required this.rating,
    required this.activeOrders,
  });

  String get todayEarningsFormatted => '$todayEarningsXof XOF';
  String get totalEarningsFormatted => '$totalEarningsXof XOF';
  String get ratingFormatted => rating.toStringAsFixed(1);
}

class CourierPerformance {
  final double onTimeDeliveryRate;
  final double averageDeliveryMinutes;
  final double rating;
  final int totalCompletedDeliveries;

  CourierPerformance({
    required this.onTimeDeliveryRate,
    required this.averageDeliveryMinutes,
    required this.rating,
    required this.totalCompletedDeliveries,
  });

  String get onTimePercentage =>
      '${(onTimeDeliveryRate * 100).toStringAsFixed(1)}%';
  String get averageDeliveryTime =>
      '${averageDeliveryMinutes.toStringAsFixed(0)} min';
}
