import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/models/analytics_data.dart';

class AnalyticsService {
  static final _supabase = Supabase.instance.client;

  /// Get analytics data for a partner
  static Future<PartnerAnalytics> getPartnerAnalytics(
    String partnerId,
    String period,
  ) async {
    try {
      // Calculate date range based on period
      final endDate = DateTime.now();
      DateTime startDate;

      switch (period) {
        case '7d':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case '30d':
          startDate = endDate.subtract(const Duration(days: 30));
          break;
        case '90d':
          startDate = endDate.subtract(const Duration(days: 90));
          break;
        case '1y':
          startDate = endDate.subtract(const Duration(days: 365));
          break;
        default:
          startDate = endDate.subtract(const Duration(days: 7));
      }

      // For demo purposes, return mock data
      // In production, this would query the database for real analytics
      return _getMockAnalytics(period);
    } catch (e) {
      throw Exception('Failed to load partner analytics: $e');
    }
  }

  /// Get revenue analytics for a partner
  static Future<List<RevenueDataPoint>> getRevenueAnalytics(
    String partnerId,
    String period,
  ) async {
    try {
      // TODO: Implement real revenue analytics query
      return _getMockRevenueData(period);
    } catch (e) {
      throw Exception('Failed to load revenue analytics: $e');
    }
  }

  /// Get order analytics for a partner
  static Future<List<OrdersDataPoint>> getOrderAnalytics(
    String partnerId,
    String period,
  ) async {
    try {
      // TODO: Implement real order analytics query
      return _getMockOrdersData(period);
    } catch (e) {
      throw Exception('Failed to load order analytics: $e');
    }
  }

  /// Get top products for a partner
  static Future<List<TopProduct>> getTopProducts(
    String partnerId,
    String period, {
    int limit = 10,
  }) async {
    try {
      // TODO: Implement real top products query
      return _getMockTopProducts();
    } catch (e) {
      throw Exception('Failed to load top products: $e');
    }
  }

  /// Get customer insights for a partner
  static Future<Map<String, dynamic>> getCustomerInsights(
    String partnerId,
    String period,
  ) async {
    try {
      // TODO: Implement real customer insights query
      return {
        'newCustomers': 25,
        'returningCustomers': 45,
        'repeatOrderRate': 65.5,
        'satisfactionRate': 88.2,
      };
    } catch (e) {
      throw Exception('Failed to load customer insights: $e');
    }
  }

  /// Get performance metrics for a partner
  static Future<Map<String, dynamic>> getPerformanceMetrics(
    String partnerId,
    String period,
  ) async {
    try {
      // TODO: Implement real performance metrics query
      return {
        'avgPreparationTime': 25,
        'acceptanceRate': 92.5,
        'averageRating': 4.7,
        'avgDeliveryTime': 35,
      };
    } catch (e) {
      throw Exception('Failed to load performance metrics: $e');
    }
  }

  // ==================== MOCK DATA METHODS ====================
  // These would be replaced with real database queries in production

  static PartnerAnalytics _getMockAnalytics(String period) {
    return PartnerAnalytics(
      totalRevenue: 125000,
      totalOrders: 89,
      uniqueCustomers: 67,
      averageOrderValue: 1404,
      revenueChange: 12.5,
      ordersChange: 8.3,
      customersChange: 15.7,
      aovChange: 4.2,
      revenueData: _getMockRevenueData(period),
      ordersData: _getMockOrdersData(period),
      topProducts: _getMockTopProducts(),
      newCustomers: 25,
      returningCustomers: 45,
      repeatOrderRate: 65.5,
      satisfactionRate: 88.2,
      avgPreparationTime: 25,
      acceptanceRate: 92.5,
      averageRating: 4.7,
      avgDeliveryTime: 35,
    );
  }

  static List<RevenueDataPoint> _getMockRevenueData(String period) {
    final now = DateTime.now();
    final List<RevenueDataPoint> data = [];

    int days;
    switch (period) {
      case '7d':
        days = 7;
        break;
      case '30d':
        days = 30;
        break;
      case '90d':
        days = 90;
        break;
      case '1y':
        days = 365;
        break;
      default:
        days = 7;
    }

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayOfWeek = date.weekday;

      // Generate mock revenue with weekend patterns
      double baseRevenue = 8000;
      if (dayOfWeek == 6 || dayOfWeek == 7) {
        baseRevenue *= 1.3; // Weekend boost
      }

      // Add some randomness
      final revenue = baseRevenue * (0.7 + (i % 5) * 0.1);

      data.add(RevenueDataPoint(
        date: _formatDate(date, period),
        amount: revenue,
      ));
    }

    return data;
  }

  static List<OrdersDataPoint> _getMockOrdersData(String period) {
    final now = DateTime.now();
    final List<OrdersDataPoint> data = [];

    int days;
    switch (period) {
      case '7d':
        days = 7;
        break;
      case '30d':
        days = 30;
        break;
      case '90d':
        days = 90;
        break;
      case '1y':
        days = 365;
        break;
      default:
        days = 7;
    }

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayOfWeek = date.weekday;

      // Generate mock orders with weekend patterns
      int baseOrders = 8;
      if (dayOfWeek == 6 || dayOfWeek == 7) {
        baseOrders = (baseOrders * 1.4).round(); // Weekend boost
      }

      // Add some randomness
      final orders = baseOrders + (i % 4);

      data.add(OrdersDataPoint(
        date: _formatDate(date, period),
        count: orders,
      ));
    }

    return data;
  }

  static List<TopProduct> _getMockTopProducts() {
    return [
      TopProduct(
        id: '1',
        name: 'Attiéké Poisson',
        quantity: 45,
        revenue: 67500,
        imageUrl: null,
      ),
      TopProduct(
        id: '2',
        name: 'Riz au Gras',
        quantity: 38,
        revenue: 57000,
        imageUrl: null,
      ),
      TopProduct(
        id: '3',
        name: 'Poulet Braisé',
        quantity: 32,
        revenue: 48000,
        imageUrl: null,
      ),
      TopProduct(
        id: '4',
        name: 'Alloco Sauce',
        quantity: 28,
        revenue: 35000,
        imageUrl: null,
      ),
      TopProduct(
        id: '5',
        name: 'Jus de Gingembre',
        quantity: 52,
        revenue: 26000,
        imageUrl: null,
      ),
    ];
  }

  static String _formatDate(DateTime date, String period) {
    switch (period) {
      case '7d':
        const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
        return weekdays[date.weekday - 1];
      case '30d':
        return '${date.day}/${date.month}';
      case '90d':
        return '${date.day}/${date.month}';
      case '1y':
        const months = [
          'Jan',
          'Fév',
          'Mar',
          'Avr',
          'Mai',
          'Jun',
          'Jul',
          'Aoû',
          'Sep',
          'Oct',
          'Nov',
          'Déc'
        ];
        return months[date.month - 1];
      default:
        return '${date.day}/${date.month}';
    }
  }

  /// Export analytics data as CSV
  static Future<String> exportAnalyticsAsCSV(
    String partnerId,
    String period,
  ) async {
    try {
      final analytics = await getPartnerAnalytics(partnerId, period);

      // Create CSV content
      final csvLines = <String>[];
      csvLines.add('Date,Revenus,Commandes');

      for (int i = 0; i < analytics.revenueData.length; i++) {
        final revenue = analytics.revenueData[i];
        final orders =
            i < analytics.ordersData.length ? analytics.ordersData[i].count : 0;
        csvLines.add('${revenue.date},${revenue.amount},$orders');
      }

      return csvLines.join('\n');
    } catch (e) {
      throw Exception('Failed to export analytics: $e');
    }
  }

  /// Get real-time dashboard data
  static Future<Map<String, dynamic>> getRealTimeDashboard(
      String partnerId) async {
    try {
      // TODO: Implement real-time dashboard query
      return {
        'todayRevenue': 8500,
        'todayOrders': 12,
        'activeOrders': 3,
        'avgResponseTime': 5,
        'restaurantStatus': 'open',
      };
    } catch (e) {
      throw Exception('Failed to load real-time dashboard: $e');
    }
  }

  /// Get comparison analytics (current vs previous period)
  static Future<Map<String, dynamic>> getComparisonAnalytics(
    String partnerId,
    String period,
  ) async {
    try {
      // TODO: Implement comparison analytics
      return {
        'currentPeriod': await getPartnerAnalytics(partnerId, period),
        'previousPeriod': _getMockAnalytics(period), // Mock previous period
        'improvements': {
          'revenue': 12.5,
          'orders': 8.3,
          'customers': 15.7,
          'rating': 0.2,
        },
      };
    } catch (e) {
      throw Exception('Failed to load comparison analytics: $e');
    }
  }
}
