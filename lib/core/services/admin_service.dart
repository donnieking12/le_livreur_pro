import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/models/admin_dashboard_data.dart';
import 'package:le_livreur_pro/core/models/admin_analytics_data.dart';
import 'package:le_livreur_pro/core/models/admin_settings.dart';
import 'package:le_livreur_pro/core/models/user.dart' as app_user;
import 'package:le_livreur_pro/core/models/delivery_order.dart';

class AdminService {
  static final _supabase = Supabase.instance.client;

  // ==================== DASHBOARD OPERATIONS ====================

  /// Get admin dashboard data
  static Future<AdminDashboardData> getDashboardData() async {
    try {
      // For demo purposes, return mock data
      // In production, this would aggregate data from multiple tables
      return _getMockDashboardData();
    } catch (e) {
      throw Exception('Failed to load dashboard data: $e');
    }
  }

  /// Get system health status
  static Future<Map<String, dynamic>> getSystemHealth() async {
    try {
      // TODO: Implement real system health checks
      return {
        'status': 'healthy',
        'uptime': '99.8%',
        'responseTime': '120ms',
        'errorRate': '0.1%',
        'lastCheck': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get system health: $e');
    }
  }

  /// Get recent system activities
  static Future<List<RecentActivity>> getRecentActivities(
      {int limit = 10}) async {
    try {
      // TODO: Implement real activity logging query
      return _getMockRecentActivities();
    } catch (e) {
      throw Exception('Failed to load recent activities: $e');
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Get all users with pagination and filtering
  static Future<List<app_user.User>> getUsers({
    int page = 1,
    int limit = 20,
    String? userType,
    String? status,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase.from('users').select();

      // Apply filters
      if (userType != null && userType.isNotEmpty) {
        query = query.eq('user_type', userType);
      }

      if (status != null && status.isNotEmpty) {
        if (status == 'active') {
          query = query.eq('is_active', true);
        } else if (status == 'inactive') {
          query = query.eq('is_active', false);
        }
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'full_name.ilike.%$searchQuery%,phone.ilike.%$searchQuery%,email.ilike.%$searchQuery%');
      }

      // Apply pagination
      final offset = (page - 1) * limit;
      final response = await query
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_user.User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  /// Get user statistics
  static Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      // TODO: Implement real user statistics query
      return {
        'totalUsers': 1234,
        'activeUsers': 987,
        'newUsersToday': 45,
        'usersByType': {
          'customer': 890,
          'courier': 234,
          'partner': 110,
        },
        'growthRate': 12.5,
      };
    } catch (e) {
      throw Exception('Failed to load user statistics: $e');
    }
  }

  /// Update user status (activate/deactivate)
  static Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await _supabase.from('users').update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  /// Delete user (soft delete)
  static Future<void> deleteUser(String userId) async {
    try {
      await _supabase.from('users').update({
        'is_active': false,
        'deleted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Reset user password
  static Future<void> resetUserPassword(String userId) async {
    try {
      // TODO: Implement password reset logic
      // This would typically send a password reset email or SMS
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
    } catch (e) {
      throw Exception('Failed to reset user password: $e');
    }
  }

  // ==================== ORDER MANAGEMENT ====================

  /// Get all orders with filtering and pagination
  static Future<List<DeliveryOrder>> getAllOrders({int limit = 50}) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => DeliveryOrder.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all orders: $e');
    }
  }

  /// Get users by type
  static Future<List<app_user.User>> getUsersByType(String userType) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('user_type', userType)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_user.User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load users by type: $e');
    }
  }

  /// Get all users
  static Future<List<app_user.User>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => app_user.User.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load all users: $e');
    }
  }

  /// Get orders by status
  static Future<List<DeliveryOrder>> getOrdersByStatus(String status) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryOrder.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders by status: $e');
    }
  }

  /// Cancel order
  static Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _supabase.from('delivery_orders').update({
        'status': 'cancelled',
        'cancellation_reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  /// Toggle user status
  static Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _supabase.from('users').update({
        'is_active': isActive,
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  /// Update setting
  static Future<void> updateSetting(String key, dynamic value) async {
    try {
      // TODO: Implement real settings update
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Get all orders with filtering and pagination
  static Future<List<DeliveryOrder>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('delivery_orders').select();

      // Apply filters
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'id.ilike.%$searchQuery%,pickup_address.ilike.%$searchQuery%,delivery_address.ilike.%$searchQuery%');
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      // Apply pagination
      final offset = (page - 1) * limit;
      final response = await query
          .range(offset, offset + limit - 1)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DeliveryOrder.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load orders: $e');
    }
  }

  /// Get order statistics
  static Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      // TODO: Implement real order statistics query
      return {
        'totalOrders': 5678,
        'completedOrders': 4567,
        'cancelledOrders': 234,
        'pendingOrders': 345,
        'inProgressOrders': 532,
        'completionRate': 89.5,
        'averageOrderValue': 2500,
        'todayOrders': 78,
      };
    } catch (e) {
      throw Exception('Failed to load order statistics: $e');
    }
  }

  /// Update order status
  static Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase.from('delivery_orders').update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  /// Assign courier to order
  static Future<void> assignCourierToOrder(
      String orderId, String courierId) async {
    try {
      await _supabase.from('delivery_orders').update({
        'courier_id': courierId,
        'status': 'assigned',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', orderId);
    } catch (e) {
      throw Exception('Failed to assign courier to order: $e');
    }
  }

  // ==================== ANALYTICS ====================

  /// Get comprehensive admin analytics
  static Future<AdminAnalyticsData> getAnalytics(
      [String period = '30d', String? region]) async {
    try {
      // For demo purposes, return mock data
      // In production, this would aggregate complex analytics data
      return _getMockAnalyticsData(period);
    } catch (e) {
      throw Exception('Failed to load analytics: $e');
    }
  }

  /// Export analytics data as CSV
  static Future<String> exportAnalytics({
    String period = '30d',
    String format = 'csv',
  }) async {
    try {
      final analytics = await getAnalytics(period);

      // Create CSV content
      final csvLines = <String>[];
      csvLines.add('Date,Revenue,Orders,Users');

      // Add sample data (in production, would process real analytics)
      for (var data in analytics.revenueAnalytics.dailyRevenue) {
        csvLines.add('${data.date},${data.amount},10,5'); // Mock data
      }

      return csvLines.join('\n');
    } catch (e) {
      throw Exception('Failed to export analytics: $e');
    }
  }

  // ==================== SETTINGS MANAGEMENT ====================

  /// Get admin settings
  static Future<AdminSettings> getSettings() async {
    try {
      // TODO: Implement real settings retrieval from database
      return _getMockSettings();
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  /// Update admin settings
  static Future<AdminSettings> updateSettings(AdminSettings settings) async {
    try {
      // TODO: Implement real settings update in database
      await Future.delayed(const Duration(seconds: 1)); // Mock delay
      return settings;
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }

  /// Update general settings
  static Future<void> updateGeneralSettings(GeneralSettings settings) async {
    try {
      // TODO: Implement database update
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to update general settings: $e');
    }
  }

  /// Update payment settings
  static Future<void> updatePaymentSettings(PaymentSettings settings) async {
    try {
      // TODO: Implement database update
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to update payment settings: $e');
    }
  }

  /// Update security settings
  static Future<void> updateSecuritySettings(SecuritySettings settings) async {
    try {
      // TODO: Implement database update
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      throw Exception('Failed to update security settings: $e');
    }
  }

  // ==================== SYSTEM OPERATIONS ====================

  /// Enable maintenance mode
  static Future<void> enableMaintenanceMode(String message) async {
    try {
      // TODO: Implement maintenance mode activation
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to enable maintenance mode: $e');
    }
  }

  /// Disable maintenance mode
  static Future<void> disableMaintenanceMode() async {
    try {
      // TODO: Implement maintenance mode deactivation
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to disable maintenance mode: $e');
    }
  }

  /// Backup system data
  static Future<String> backupSystemData() async {
    try {
      // TODO: Implement real backup functionality
      await Future.delayed(const Duration(seconds: 3)); // Mock backup time
      return 'backup_${DateTime.now().millisecondsSinceEpoch}.zip';
    } catch (e) {
      throw Exception('Failed to backup system data: $e');
    }
  }

  /// Clear system cache
  static Future<void> clearSystemCache() async {
    try {
      // TODO: Implement cache clearing
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      throw Exception('Failed to clear system cache: $e');
    }
  }

  // ==================== MOCK DATA METHODS ====================
  // These would be replaced with real database queries in production

  static AdminDashboardData _getMockDashboardData() {
    return AdminDashboardData(
      totalUsers: 1234,
      totalOrders: 5678,
      totalRevenue: 2500000,
      activeUsers: 987,
      totalRestaurants: 156,
      activeCouriers: 89,
      userGrowthRate: 12.5,
      orderGrowthRate: 18.3,
      revenueGrowthRate: 15.7,
      systemUptime: '99.8',
      systemPerformance: 'Excellent',
      systemAlerts: [
        SystemAlert(
          id: '1',
          type: 'warning',
          message: 'Server load is approaching 80%',
          severity: 'medium',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        SystemAlert(
          id: '2',
          type: 'info',
          message: 'Scheduled maintenance in 2 days',
          severity: 'low',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
      recentActivities: _getMockRecentActivities(),
      userTypeDistribution: {
        'customer': 890,
        'courier': 234,
        'partner': 110,
      },
      orderStatusDistribution: {
        'pending': 123,
        'confirmed': 234,
        'in_progress': 345,
        'delivered': 4567,
        'cancelled': 409,
      },
      keyMetrics: [
        DashboardMetric(
          name: 'Active Users',
          value: '987',
          changePercentage: 12.5,
          changeDirection: 'up',
        ),
        DashboardMetric(
          name: 'Revenue Today',
          value: '45,000',
          unit: 'XOF',
          changePercentage: 8.3,
          changeDirection: 'up',
        ),
        DashboardMetric(
          name: 'Orders Today',
          value: '78',
          changePercentage: -2.1,
          changeDirection: 'down',
        ),
        DashboardMetric(
          name: 'System Health',
          value: '99.8%',
          changePercentage: 0.1,
          changeDirection: 'up',
        ),
      ],
    );
  }

  static List<RecentActivity> _getMockRecentActivities() {
    return [
      RecentActivity(
        id: '1',
        type: 'user_registered',
        description: 'New user registered',
        userName: 'Jean Kouassi',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      RecentActivity(
        id: '2',
        type: 'order_completed',
        description: 'Order #ORD-001234 completed',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      RecentActivity(
        id: '3',
        type: 'restaurant_joined',
        description: 'New restaurant "Chez Mama" joined the platform',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      RecentActivity(
        id: '4',
        type: 'payment_processed',
        description: 'Payment of 15,000 XOF processed via Orange Money',
        timestamp: DateTime.now().subtract(const Duration(minutes: 35)),
      ),
      RecentActivity(
        id: '5',
        type: 'courier_approved',
        description: 'Courier application approved for Kouadio Michel',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  static AdminAnalyticsData _getMockAnalyticsData(String period) {
    return AdminAnalyticsData(
      platformMetrics: PlatformMetrics(
        totalTransactions: 15678,
        totalGmv: 25000000.0,
        totalCommissions: 2500000,
        averageTransactionValue: 1594.5,
        commissionRate: 10.0,
        activeRestaurants: 156,
        activeCouriers: 89,
        activeCustomers: 890,
        platformGrowthRate: 15.7,
      ),
      revenueAnalytics: RevenueAnalytics(
        dailyRevenue: _generateMockRevenueData(period),
        monthlyRevenue: _generateMockRevenueData('12m'),
        revenueByPaymentMethod: {
          'Orange Money': 8500000.0,
          'MTN Money': 6200000.0,
          'Wave': 4300000.0,
          'Cash': 6000000.0,
        },
        revenueByRegion: {
          'Abidjan': 15000000.0,
          'Bouaké': 4500000.0,
          'San-Pédro': 3200000.0,
          'Yamoussoukro': 2300000.0,
        },
        totalRevenue: 25000000.0,
        revenueGrowth: 15.7,
        averageDailyRevenue: 833333.3,
        topRestaurants: [
          TopPerformingRestaurant(
              id: '1', name: 'Chez Mama', revenue: 450000.0, orderCount: 234),
          TopPerformingRestaurant(
              id: '2', name: 'Le Palmier', revenue: 380000.0, orderCount: 189),
          TopPerformingRestaurant(
              id: '3',
              name: 'Maquis Central',
              revenue: 320000.0,
              orderCount: 156),
        ],
      ),
      userAnalytics: UserAnalytics(
        totalUsers: 1234,
        newUsers: 156,
        userRetentionRate: 78.5,
        userAcquisitionCost: 2500.0,
        usersByType: {'customer': 890, 'courier': 234, 'partner': 110},
        usersByRegion: {
          'Abidjan': 890,
          'Bouaké': 156,
          'San-Pédro': 98,
          'Yamoussoukro': 90
        },
        userGrowthData: _generateMockUserGrowthData(period),
        averageUserLifetimeValue: 125000.0,
      ),
      orderAnalytics: OrderAnalytics(
        totalOrders: 5678,
        completedOrders: 4567,
        cancelledOrders: 409,
        completionRate: 89.5,
        averageOrderValue: 2500.0,
        averageDeliveryTime: 28.5,
        ordersByStatus: {
          'pending': 123,
          'confirmed': 234,
          'in_progress': 345,
          'delivered': 4567,
          'cancelled': 409,
        },
        ordersByRegion: {
          'Abidjan': 3567,
          'Bouaké': 1234,
          'San-Pédro': 567,
          'Yamoussoukro': 310,
        },
        orderVolumeData: _generateMockOrderVolumeData(period),
        orderGrowthRate: 18.3,
      ),
      performanceMetrics: PerformanceMetrics(
        systemUptime: 99.8,
        averageResponseTime: 120.5,
        errorRate: 0.1,
        totalApiCalls: 156789,
        serverLoad: 65.2,
        databasePerformance: 95.5,
        endpointPerformance: {
          '/api/orders': 95.2,
          '/api/users': 98.1,
          '/api/payments': 92.7,
          '/api/tracking': 96.8,
        },
        performanceHistory: _generateMockPerformanceData(period),
      ),
      geographicData: GeographicData(
        regionMetrics: {
          'Abidjan': RegionMetrics(
            regionName: 'Abidjan',
            userCount: 890,
            orderCount: 3567,
            revenue: 15000000.0,
            averageDeliveryTime: 25.5,
          ),
          'Bouaké': RegionMetrics(
            regionName: 'Bouaké',
            userCount: 156,
            orderCount: 1234,
            revenue: 4500000.0,
            averageDeliveryTime: 32.0,
          ),
        },
        deliveryHotspots: [
          HotspotData(
              name: 'Plateau',
              latitude: 5.3192,
              longitude: -4.0167,
              orderCount: 567,
              radius: 2.5),
          HotspotData(
              name: 'Cocody',
              latitude: 5.3475,
              longitude: -3.9869,
              orderCount: 434,
              radius: 3.0),
          HotspotData(
              name: 'Marcory',
              latitude: 5.2906,
              longitude: -4.0042,
              orderCount: 289,
              radius: 2.0),
        ],
        regionRevenue: {
          'Abidjan': 15000000.0,
          'Bouaké': 4500000.0,
          'San-Pédro': 3200000.0,
          'Yamoussoukro': 2300000.0,
        },
        regionOrderCount: {
          'Abidjan': 3567,
          'Bouaké': 1234,
          'San-Pédro': 567,
          'Yamoussoukro': 310,
        },
      ),
      trends: [
        TrendDataPoint(
            category: 'revenue',
            metric: 'total',
            period: period,
            value: 25000000.0,
            change: 15.7),
        TrendDataPoint(
            category: 'orders',
            metric: 'completed',
            period: period,
            value: 4567.0,
            change: 18.3),
        TrendDataPoint(
            category: 'users',
            metric: 'active',
            period: period,
            value: 987.0,
            change: 12.5),
      ],
      customMetrics: {
        'customer_satisfaction': 4.6,
        'courier_efficiency': 88.5,
        'restaurant_performance': 92.3,
        'system_reliability': 99.8,
      },
    );
  }

  static AdminSettings _getMockSettings() {
    return AdminSettings(
      generalSettings: GeneralSettings(
        platformName: 'Le Livreur Pro',
        platformDescription: 'Service de livraison rapide en Côte d\'Ivoire',
        platformLogo: 'https://example.com/logo.png',
        defaultLanguage: 'fr',
        supportedLanguages: ['fr', 'en'],
        defaultCurrency: 'XOF',
        timezone: 'Africa/Abidjan',
        supportEmail: 'support@lelivreurpro.ci',
        supportPhone: '+225 01 02 03 04 05',
        socialLinks: {
          'facebook': 'https://facebook.com/lelivreurpro',
          'twitter': 'https://twitter.com/lelivreurpro',
          'instagram': 'https://instagram.com/lelivreurpro',
        },
        maintenanceMode: false,
        maintenanceMessage:
            'Le service est temporairement indisponible pour maintenance.',
      ),
      paymentSettings: PaymentSettings(
        commissionSettings: CommissionSettings(
          defaultCommissionRate: 10.0,
          categoryCommissionRates: {
            'restaurant': 10.0,
            'grocery': 8.0,
            'pharmacy': 12.0,
          },
          minimumCommission: 100.0,
          maximumCommission: 5000.0,
          tieredCommission: false,
          commissionTiers: [],
        ),
        paymentMethods: [
          PaymentMethodConfig(
            name: 'orange_money',
            displayName: 'Orange Money',
            enabled: true,
            config: {'api_key': 'xxx', 'merchant_id': 'xxx'},
            supportedCountries: ['CI'],
            transactionFee: 1.5,
            requiresVerification: true,
          ),
          PaymentMethodConfig(
            name: 'mtn_money',
            displayName: 'MTN Money',
            enabled: true,
            config: {'api_key': 'xxx', 'merchant_id': 'xxx'},
            supportedCountries: ['CI'],
            transactionFee: 1.5,
            requiresVerification: true,
          ),
        ],
        autoWithdrawal: false,
        withdrawalThreshold: 50000,
        paymentProviderConfig: {},
        paymentLogging: true,
        fraudDetection: true,
      ),
      securitySettings: SecuritySettings(
        authSettings: AuthSettings(
          authProvider: 'supabase',
          providerConfig: {},
          allowAnonymous: false,
          requirePhoneVerification: true,
          requireEmailVerification: false,
          otpLength: 6,
          otpExpiration: 300,
        ),
        twoFactorAuth: false,
        sessionTimeout: 3600,
        maxLoginAttempts: 5,
        passwordMinLength: 8,
        requireSpecialChars: true,
        ipWhitelisting: false,
        allowedIpRanges: [],
        auditLogging: true,
        dataRetentionDays: 365,
      ),
      maintenanceSettings: MaintenanceSettings(
        scheduledMaintenance: false,
        nextMaintenanceDate: null,
        maintenanceDuration: 60,
        maintenanceNotice: 'Maintenance programmée ce weekend.',
        backupEnabled: true,
        backupFrequency: 'daily',
        backupRetentionDays: 30,
        autoUpdates: false,
        maintenanceWindows: [],
      ),
      notificationSettings: NotificationSettings(
        emailNotifications: true,
        smsNotifications: true,
        pushNotifications: true,
        notificationTypes: {
          'order_updates': true,
          'payment_confirmations': true,
          'system_alerts': true,
          'marketing': false,
        },
        emailProvider: 'sendgrid',
        smsProvider: 'twilio',
        providerConfig: {},
        adminNotificationEmails: ['admin@lelivreurpro.ci'],
      ),
      featureSettings: FeatureSettings(
        realTimeTracking: true,
        chatSupport: true,
        loyaltyProgram: false,
        referralProgram: true,
        scheduledDeliveries: true,
        multiplePaymentMethods: true,
        courierRatings: true,
        restaurantReviews: true,
        experimentalFeatures: {
          'ai_route_optimization': false,
          'voice_orders': false,
          'drone_delivery': false,
        },
      ),
      customSettings: {
        'theme_color': '#FF6B35',
        'max_delivery_distance': 25.0,
        'default_delivery_fee': 1000,
      },
    );
  }

  // Helper methods for generating mock data
  static List<RevenueDataPoint> _generateMockRevenueData(String period) {
    final List<RevenueDataPoint> data = [];
    final now = DateTime.now();

    final int days = period == '7d'
        ? 7
        : period == '30d'
            ? 30
            : 90;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final revenue = 750000.0 + (i % 7) * 50000.0; // Mock pattern

      data.add(RevenueDataPoint(
        date: '${date.day}/${date.month}',
        amount: revenue,
      ));
    }

    return data;
  }

  static List<UserGrowthDataPoint> _generateMockUserGrowthData(String period) {
    final List<UserGrowthDataPoint> data = [];
    final now = DateTime.now();

    final int days = period == '7d'
        ? 7
        : period == '30d'
            ? 30
            : 90;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final count = 5 + (i % 10); // Mock pattern

      data.add(UserGrowthDataPoint(
        date: '${date.day}/${date.month}',
        count: count,
        userType: 'customer',
      ));
    }

    return data;
  }

  static List<OrderVolumeDataPoint> _generateMockOrderVolumeData(
      String period) {
    final List<OrderVolumeDataPoint> data = [];
    final now = DateTime.now();

    final int days = period == '7d'
        ? 7
        : period == '30d'
            ? 30
            : 90;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final volume = 15 + (i % 12); // Mock pattern

      data.add(OrderVolumeDataPoint(
        date: '${date.day}/${date.month}',
        volume: volume,
        status: 'completed',
      ));
    }

    return data;
  }

  static List<PerformanceDataPoint> _generateMockPerformanceData(
      String period) {
    final List<PerformanceDataPoint> data = [];
    final now = DateTime.now();

    final int days = period == '7d'
        ? 7
        : period == '30d'
            ? 30
            : 90;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      data.add(PerformanceDataPoint(
        timestamp: date.toIso8601String(),
        responseTime: 100.0 + (i % 5) * 10.0,
        uptime: 99.0 + (i % 3) * 0.3,
        errorRate: 0.1 + (i % 4) * 0.05,
      ));
    }

    return data;
  }
}
