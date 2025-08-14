import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static late SupabaseClient _supabaseClient;

  // Event names
  static const String _eventAppOpen = 'app_open';
  static const String _eventScreenView = 'screen_view';
  static const String _eventUserAction = 'user_action';
  static const String _eventOrderCreated = 'order_created';
  static const String _eventOrderCompleted = 'order_completed';
  static const String _eventPaymentInitiated = 'payment_initiated';
  static const String _eventPaymentCompleted = 'payment_completed';
  static const String _eventCourierAssigned = 'courier_assigned';
  static const String _eventDeliveryStarted = 'delivery_started';
  static const String _eventDeliveryCompleted = 'delivery_completed';
  static const String _eventUserRegistration = 'user_registration';
  static const String _eventUserLogin = 'user_login';
  static const String _eventUserLogout = 'user_logout';
  static const String _eventError = 'app_error';
  static const String _eventPerformance = 'performance_metric';

  /// Initialize analytics service
  static Future<void> initialize() async {
    try {
      // Initialize Supabase client
      _supabaseClient = Supabase.instance.client;

      if (kDebugMode) {
        print('Analytics service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing analytics: $e');
      }
    }
  }

  // ==================== SCREEN TRACKING ====================

  /// Track screen view
  static Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Supabase Analytics
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventScreenView,
        'event_type': 'screen_view',
        'screen_name': screenName,
        'screen_class': screenClass,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking screen view: $e');
    }
  }

  /// Save screen view to database
  static Future<void> _saveScreenView(
    String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      // TODO: Save to Supabase analytics table
      print('Screen view saved: $screenName');
    } catch (e) {
      print('Error saving screen view: $e');
    }
  }

  // ==================== USER ACTIONS ====================

  /// Track user action
  static Future<void> trackUserAction({
    required String action,
    required String screen,
    String? element,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Supabase Analytics
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventUserAction,
        'event_type': 'user_action',
        'action': action,
        'screen': screen,
        'element': element,
        'parameters': parameters,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking user action: $e');
    }
  }

  /// Save user action to database
  static Future<void> _saveUserAction(
    String action,
    String screen,
    String? element,
    Map<String, dynamic>? parameters,
  ) async {
    try {
      // TODO: Save to Supabase user_actions table
      print('User action saved: $action on $screen');
    } catch (e) {
      print('Error saving user action: $e');
    }
  }

  // ==================== ORDER ANALYTICS ====================

  /// Track order creation
  static Future<void> trackOrderCreated({
    required String orderId,
    required String userId,
    required double amount,
    required String pickupLocation,
    required String deliveryLocation,
    String? paymentMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventOrderCreated,
        'event_type': 'order_event',
        'order_id': orderId,
        'user_id': userId,
        'amount': amount,
        'pickup_location': pickupLocation,
        'delivery_location': deliveryLocation,
        'payment_method': paymentMethod,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking order creation: $e');
    }
  }

  /// Track order completion
  static Future<void> trackOrderCompleted({
    required String orderId,
    required String userId,
    required double amount,
    required Duration deliveryTime,
    String? courierId,
    String? courierName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventOrderCompleted,
        'event_type': 'order_event',
        'order_id': orderId,
        'user_id': userId,
        'amount': amount,
        'delivery_time_minutes': deliveryTime.inMinutes,
        'courier_id': courierId,
        'courier_name': courierName,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking order completion: $e');
    }
  }

  /// Save order event to database
  static Future<void> _saveOrderEvent(
    String eventType,
    String orderId,
    String userId,
    double amount,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Save to Supabase order_events table
      print('Order event saved: $eventType for order $orderId');
    } catch (e) {
      print('Error saving order event: $e');
    }
  }

  // ==================== PAYMENT ANALYTICS ====================

  /// Track payment initiation
  static Future<void> trackPaymentInitiated({
    required String orderId,
    required String userId,
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventPaymentInitiated,
        'event_type': 'payment_event',
        'order_id': orderId,
        'user_id': userId,
        'amount': amount,
        'payment_method': paymentMethod,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking payment initiation: $e');
    }
  }

  /// Track payment completion
  static Future<void> trackPaymentCompleted({
    required String orderId,
    required String userId,
    required double amount,
    required String paymentMethod,
    required bool isSuccess,
    String? transactionId,
    String? errorMessage,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventPaymentCompleted,
        'event_type': 'payment_event',
        'order_id': orderId,
        'user_id': userId,
        'amount': amount,
        'payment_method': paymentMethod,
        'is_success': isSuccess,
        'transaction_id': transactionId,
        'error_message': errorMessage,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking payment completion: $e');
    }
  }

  /// Save payment event to database
  static Future<void> _savePaymentEvent(
    String eventType,
    String orderId,
    String userId,
    double amount,
    String paymentMethod,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Save to Supabase payment_events table
      print('Payment event saved: $eventType for order $orderId');
    } catch (e) {
      print('Error saving payment event: $e');
    }
  }

  // ==================== DELIVERY ANALYTICS ====================

  /// Track courier assignment
  static Future<void> trackCourierAssigned({
    required String orderId,
    required String courierId,
    required String courierName,
    required String pickupLocation,
    required String deliveryLocation,
    double? estimatedDistance,
    Duration? estimatedTime,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventCourierAssigned,
        'event_type': 'delivery_event',
        'order_id': orderId,
        'courier_id': courierId,
        'courier_name': courierName,
        'pickup_location': pickupLocation,
        'delivery_location': deliveryLocation,
        'estimated_distance_km': estimatedDistance,
        'estimated_time_minutes': estimatedTime?.inMinutes,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking courier assignment: $e');
    }
  }

  /// Track delivery start
  static Future<void> trackDeliveryStarted({
    required String orderId,
    required String courierId,
    required String courierName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventDeliveryStarted,
        'event_type': 'delivery_event',
        'order_id': orderId,
        'courier_id': courierId,
        'courier_name': courierName,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking delivery start: $e');
    }
  }

  /// Track delivery completion
  static Future<void> trackDeliveryCompleted({
    required String orderId,
    required String courierId,
    required String courierName,
    required Duration actualDeliveryTime,
    double? actualDistance,
    String? customerRating,
    String? customerFeedback,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventDeliveryCompleted,
        'event_type': 'delivery_event',
        'order_id': orderId,
        'courier_id': courierId,
        'courier_name': courierName,
        'actual_delivery_time_minutes': actualDeliveryTime.inMinutes,
        'actual_distance_km': actualDistance,
        'customer_rating': customerRating,
        'customer_feedback': customerFeedback,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking delivery completion: $e');
    }
  }

  /// Save delivery event to database
  static Future<void> _saveDeliveryEvent(
    String eventType,
    String orderId,
    String courierId,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Save to Supabase delivery_events table
      print('Delivery event saved: $eventType for order $orderId');
    } catch (e) {
      print('Error saving delivery event: $e');
    }
  }

  // ==================== USER ANALYTICS ====================

  /// Track user registration
  static Future<void> trackUserRegistration({
    required String userId,
    required String userType,
    String? phone,
    String? fullName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventUserRegistration,
        'event_type': 'user_event',
        'user_id': userId,
        'user_type': userType,
        'phone': phone,
        'full_name': fullName,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking user registration: $e');
    }
  }

  /// Track user login
  static Future<void> trackUserLogin({
    required String userId,
    required String userType,
    String? loginMethod,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventUserLogin,
        'event_type': 'user_event',
        'user_id': userId,
        'user_type': userType,
        'login_method': loginMethod,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking user login: $e');
    }
  }

  /// Track user logout
  static Future<void> trackUserLogout({
    required String userId,
    required String userType,
    Duration? sessionDuration,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventUserLogout,
        'event_type': 'user_event',
        'user_id': userId,
        'user_type': userType,
        'session_duration_minutes': sessionDuration?.inMinutes,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking user logout: $e');
    }
  }

  /// Save user event to database
  static Future<void> _saveUserEvent(
    String eventType,
    String userId,
    String userType,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Save to Supabase user_events table
      print('User event saved: $eventType for user $userId');
    } catch (e) {
      print('Error saving user event: $e');
    }
  }

  // ==================== ERROR TRACKING ====================

  /// Track app error
  static Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? screen,
    String? userId,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventError,
        'event_type': 'error_event',
        'error_type': errorType,
        'error_message': errorMessage,
        'screen': screen,
        'user_id': userId,
        'stack_trace': stackTrace?.toString(),
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking error: $e');
    }
  }

  /// Save error event to database
  static Future<void> _saveErrorEvent(
    String errorType,
    String errorMessage,
    String? screen,
    String? userId,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Save to Supabase error_logs table
      print('Error event saved: $errorType - $errorMessage');
    } catch (e) {
      print('Error saving error event: $e');
    }
  }

  // ==================== PERFORMANCE TRACKING ====================

  /// Track performance metric
  static Future<void> trackPerformance({
    required String metricName,
    required dynamic value,
    String? unit,
    String? screen,
    String? userId,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final supabase = _supabaseClient;
      await supabase.from('analytics_events').insert({
        'event_name': _eventPerformance,
        'event_type': 'performance_metric',
        'metric_name': metricName,
        'value': value,
        'unit': unit,
        'screen': screen,
        'user_id': userId,
        'additional_data': additionalData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error tracking performance: $e');
    }
  }

  /// Save performance metric to database
  static Future<void> _savePerformanceMetric(
    String metricName,
    dynamic value,
    String? unit,
    String? screen,
    String? userId,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      // TODO: Save to Supabase performance_metrics table
      print('Performance metric saved: $metricName = $value $unit');
    } catch (e) {
      print('Error saving performance metric: $e');
    }
  }

  // ==================== BUSINESS INTELLIGENCE ====================

  /// Get order analytics
  static Future<Map<String, dynamic>> getOrderAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
    String? userType,
  }) async {
    try {
      // TODO: Query Supabase for order analytics
      return {
        'total_orders': 0,
        'total_revenue': 0.0,
        'average_order_value': 0.0,
        'orders_by_status': {},
        'orders_by_location': {},
        'orders_by_payment_method': {},
      };
    } catch (e) {
      print('Error getting order analytics: $e');
      return {};
    }
  }

  /// Get user analytics
  static Future<Map<String, dynamic>> getUserAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? userType,
  }) async {
    try {
      // TODO: Query Supabase for user analytics
      return {
        'total_users': 0,
        'new_users': 0,
        'active_users': 0,
        'users_by_type': {},
        'user_retention_rate': 0.0,
        'average_session_duration': 0.0,
      };
    } catch (e) {
      print('Error getting user analytics: $e');
      return {};
    }
  }

  /// Get delivery analytics
  static Future<Map<String, dynamic>> getDeliveryAnalytics({
    required DateTime startDate,
    required DateTime endDate,
    String? courierId,
  }) async {
    try {
      // TODO: Query Supabase for delivery analytics
      return {
        'total_deliveries': 0,
        'completed_deliveries': 0,
        'average_delivery_time': 0.0,
        'deliveries_by_courier': {},
        'deliveries_by_location': {},
        'customer_satisfaction_rate': 0.0,
      };
    } catch (e) {
      print('Error getting delivery analytics: $e');
      return {};
    }
  }

  // ==================== UTILITIES ====================

  /// Set user ID for analytics
  static Future<void> setUserId(String userId) async {
    try {
      // Store user ID in local storage or Supabase user metadata
      print('User ID set for analytics: $userId');
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }

  /// Set user properties for analytics
  static Future<void> setUserProperties(Map<String, String> properties) async {
    try {
      // Store user properties in local storage or Supabase user metadata
      print('User properties set for analytics: $properties');
    } catch (e) {
      print('Error setting user properties: $e');
    }
  }

  /// Reset analytics data
  static Future<void> resetAnalytics() async {
    try {
      // Clear local analytics data
      print('Analytics data reset');
    } catch (e) {
      print('Error resetting analytics: $e');
    }
  }

  /// Dispose service
  static void dispose() {
    // Cleanup resources
  }
}
