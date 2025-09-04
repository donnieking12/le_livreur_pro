import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart';

import 'package:le_livreur_pro/core/config/app_config.dart';
import 'package:le_livreur_pro/core/models/address.dart';
import 'package:le_livreur_pro/core/models/cart.dart';
import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/models/menu_item.dart';
import 'package:le_livreur_pro/core/models/restaurant.dart';
import 'package:le_livreur_pro/core/models/user.dart';

class SupabaseService {
  static late SupabaseClient _client;
  static late RealtimeChannel _realtimeChannel;

  // Table names
  static const String _usersTable = 'users';
  static const String _ordersTable = 'delivery_orders';
  static const String _couriersTable = 'couriers';
  static const String _paymentsTable = 'payments';
  static const String _notificationsTable = 'notifications';

  /// Initialize Supabase client
  static Future<void> initialize() async {
    // Validate configuration before initializing
    if (!AppConfig.isValidSupabaseConfig) {
      print('⚠️  Warning: Using demo Supabase configuration');
      print(
          '💡 To use real data, update your .env file with actual Supabase credentials');
      // Allow demo mode to continue for development
    }

    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _client = Supabase.instance.client;
    print('🚀 Supabase initialized: ${AppConfig.supabaseUrl}');
    _setupRealtime();
  }

  /// Get Supabase client instance
  static SupabaseClient get client => _client;

  /// Setup real-time subscriptions
  static void _setupRealtime() {
    _realtimeChannel = _client.channel('le_livreur_pro');

    // Subscribe to order updates using modern API
    _realtimeChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: _ordersTable,
          callback: (payload) {
            // Handle real-time order updates
            debugPrint(
                'Real-time order update received: ${payload.eventType.name}');
            // TODO: Implement proper payload handling when API is stable
          },
        )
        .subscribe();
  }

  /// Handle real-time order updates
  static void _handleOrderUpdate(Map<String, dynamic> payload) {
    // TODO: Implement real-time order update handling
    debugPrint('Real-time order update: $payload');
  }

  // ==================== AUTHENTICATION ====================

  /// Sign in with phone number
  static Future<AuthResponse> signInWithPhone({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: '$phone@lelivreurpro.ci', // Convert phone to email format
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign up new user
  static Future<AuthResponse> signUp({
    required String phone,
    required String password,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: '$phone@lelivreurpro.ci',
        password: password,
        data: {
          'full_name': fullName,
          'user_type': userType.name,
          'phone': phone,
        },
      );

      if (response.user != null) {
        // Create user profile in database
        await createUserProfile(
          userId: response.user!.id,
          phone: phone,
          fullName: fullName,
          userType: userType,
        );
      }

      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get current user
  static User? getCurrentUser() {
    final authUser = _client.auth.currentUser;
    if (authUser != null) {
      return User(
        id: authUser.id,
        phone: authUser.userMetadata?['phone'] ?? '',
        fullName: authUser.userMetadata?['full_name'] ?? '',
        userType: UserType.values.byName(
          authUser.userMetadata?['user_type'] ?? 'customer',
        ),
        createdAt: authUser.createdAt != null
            ? DateTime.parse(authUser.createdAt)
            : null,
        updatedAt: authUser.lastSignInAt != null
            ? DateTime.parse(authUser.lastSignInAt!)
            : null,
      );
    }
    return null;
  }

  // ==================== USER MANAGEMENT ====================

  /// Create user profile in database
  static Future<void> createUserProfile({
    required String userId,
    required String phone,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      await _client.from(_usersTable).insert({
        'id': userId,
        'phone': phone,
        'full_name': fullName,
        'user_type': userType.name,
        'is_active': true,
        'is_verified': false,
        'preferred_language': 'fr',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  /// Get user profile by ID
  static Future<User?> getUserProfile(String userId) async {
    try {
      final response =
          await _client.from(_usersTable).select().eq('id', userId).single();

      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(String userId) async {
    try {
      final response =
          await _client.from(_usersTable).select().eq('id', userId).single();

      return User.fromJson(response);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response =
          await _client.from(_usersTable).update(updates).eq('id', userId);

      return response != null;
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  /// Create new delivery order
  static Future<DeliveryOrder> createOrder({
    required String customerId,
    required String pickupAddress,
    required String deliveryAddress,
    required String description,
    required double amount,
    required String customerPhone,
    required String customerName,
  }) async {
    try {
      final response = await _client
          .from(_ordersTable)
          .insert({
            'customer_id': customerId,
            'pickup_address': pickupAddress,
            'delivery_address': deliveryAddress,
            'description': description,
            'amount': amount,
            'customer_phone': customerPhone,
            'customer_name': customerName,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return DeliveryOrder.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get orders for user
  static Future<List<DeliveryOrder>> getUserOrders(String userId) async {
    try {
      final response = await _client
          .from(_ordersTable)
          .select()
          .eq('customer_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get user orders: $e');
    }
  }

  /// Get available orders for couriers
  static Future<List<DeliveryOrder>> getAvailableOrders() async {
    try {
      final response = await _client
          .from(_ordersTable)
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response.map((json) => DeliveryOrder.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get available orders: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus({
    required String orderId,
    required String status,
    String? courierId,
    String? estimatedDeliveryTime,
  }) async {
    try {
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (courierId != null) {
        updates['courier_id'] = courierId;
      }

      if (estimatedDeliveryTime != null) {
        updates['estimated_delivery_time'] = estimatedDeliveryTime;
      }

      await _client.from(_ordersTable).update(updates).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // ==================== COURIER MANAGEMENT ====================

  /// Update courier status (online/offline)
  static Future<void> updateCourierStatus({
    required String courierId,
    required bool isOnline,
    String? currentLocation,
  }) async {
    try {
      final updates = {
        'is_online': isOnline,
        'last_online_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (currentLocation != null) {
        updates['current_location'] = currentLocation;
      }

      await _client.from(_couriersTable).update(updates).eq('id', courierId);
    } catch (e) {
      throw Exception('Failed to update courier status: $e');
    }
  }

  /// Get courier earnings
  static Future<Map<String, dynamic>> getCourierEarnings(
    String courierId,
  ) async {
    try {
      final response = await _client
          .from(_ordersTable)
          .select('amount, status, created_at')
          .eq('courier_id', courierId)
          .eq('status', 'delivered');

      double totalEarnings = 0;
      final int totalDeliveries = response.length;

      for (final order in response) {
        totalEarnings += (order['amount'] as num).toDouble();
      }

      return {
        'total_earnings': totalEarnings,
        'total_deliveries': totalDeliveries,
        'average_per_delivery':
            totalDeliveries > 0 ? totalEarnings / totalDeliveries : 0,
      };
    } catch (e) {
      throw Exception('Failed to get courier earnings: $e');
    }
  }

  // ==================== PAYMENT INTEGRATION ====================

  /// Create payment record
  static Future<void> createPayment({
    required String orderId,
    required String customerId,
    required double amount,
    required String paymentMethod,
    required String status,
  }) async {
    try {
      await _client.from(_paymentsTable).insert({
        'order_id': orderId,
        'customer_id': customerId,
        'amount': amount,
        'payment_method': paymentMethod,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Update payment status
  static Future<void> updatePaymentStatus({
    required String paymentId,
    required String status,
    String? transactionId,
  }) async {
    try {
      final updates = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (transactionId != null) {
        updates['transaction_id'] = transactionId;
      }

      await _client.from(_paymentsTable).update(updates).eq('id', paymentId);
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Create notification
  static Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _client.from(_notificationsTable).insert({
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'data': data,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Get user notifications
  static Future<List<Map<String, dynamic>>> getUserNotifications(
    String userId,
  ) async {
    try {
      final response = await _client
          .from(_notificationsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(50);

      return response;
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  /// Mark notification as read
  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client.from(_notificationsTable).update({
        'is_read': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // ==================== ANALYTICS ====================

  /// Track user action
  static Future<void> trackUserAction({
    required String userId,
    required String action,
    required String screen,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _client.from('user_analytics').insert({
        'user_id': userId,
        'action': action,
        'screen': screen,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Analytics failures shouldn't break the app
      debugPrint('Analytics tracking failed: $e');
    }
  }

  /// Get user analytics
  static Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    try {
      final response = await _client
          .from('user_analytics')
          .select()
          .eq('user_id', userId)
          .gte(
            'timestamp',
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          );

      // Process analytics data
      final actions = <String, int>{};
      final screens = <String, int>{};

      for (final record in response) {
        final action = record['action'] as String;
        final screen = record['screen'] as String;

        actions[action] = (actions[action] ?? 0) + 1;
        screens[screen] = (screens[screen] ?? 0) + 1;
      }

      return {
        'total_actions': response.length,
        'action_breakdown': actions,
        'screen_breakdown': screens,
        'period_days': 30,
      };
    } catch (e) {
      throw Exception('Failed to get user analytics: $e');
    }
  }

  // ==================== UTILITIES ====================

  /// Close real-time connections
  static void dispose() {
    _realtimeChannel.unsubscribe();
  }
}

// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
