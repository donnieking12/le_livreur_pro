class AdminAnalyticsData {
  final PlatformMetrics platformMetrics;
  final RevenueAnalytics revenueAnalytics;
  final UserAnalytics userAnalytics;
  final OrderAnalytics orderAnalytics;
  final PerformanceMetrics performanceMetrics;
  final GeographicData geographicData;
  final List<TrendDataPoint> trends;
  final Map<String, dynamic> customMetrics;

  AdminAnalyticsData({
    required this.platformMetrics,
    required this.revenueAnalytics,
    required this.userAnalytics,
    required this.orderAnalytics,
    required this.performanceMetrics,
    required this.geographicData,
    required this.trends,
    required this.customMetrics,
  });

  // Computed getters for backward compatibility
  double get totalRevenue => revenueAnalytics.totalRevenue;
  int get totalOrders => orderAnalytics.totalOrders;
  int get activeUsers => userAnalytics.totalUsers;
  double get revenueGrowth => revenueAnalytics.revenueGrowth;
  double get ordersGrowth => orderAnalytics.orderGrowthRate;
  double get userGrowth => platformMetrics.platformGrowthRate;
  double get revenuePerOrder =>
      totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
  int get totalCustomers => userAnalytics.usersByType['customer'] ?? 0;

  // Additional computed getters for analytics screen
  double get successRate => orderAnalytics.completionRate;
  double get successRateChange => orderAnalytics.orderGrowthRate;
  double get averageCommission => platformMetrics.commissionRate;
  int get totalCouriers => userAnalytics.usersByType['courier'] ?? 0;
  int get totalPartners => userAnalytics.usersByType['partner'] ?? 0;
  double get averageDeliveryTime => orderAnalytics.averageDeliveryTime;
  double get cancellationRate =>
      (orderAnalytics.cancelledOrders.toDouble() / orderAnalytics.totalOrders) *
      100;
  double get averageRating =>
      customMetrics['customer_satisfaction']?.toDouble() ?? 4.5;
  double get systemUptime => performanceMetrics.systemUptime;
  double get responseTime => performanceMetrics.averageResponseTime;
  List<Map<String, dynamic>> get topCities =>
      geographicData.regionMetrics.entries
          .map((e) => {
                'name': e.key,
                'orderCount': e.value.orderCount,
                'percentage': ((e.value.orderCount.toDouble() /
                            orderAnalytics.totalOrders) *
                        100)
                    .toStringAsFixed(1)
              })
          .toList();

  factory AdminAnalyticsData.fromJson(Map<String, dynamic> json) {
    return AdminAnalyticsData(
      platformMetrics: PlatformMetrics.fromJson(json['platform_metrics']),
      revenueAnalytics: RevenueAnalytics.fromJson(json['revenue_analytics']),
      userAnalytics: UserAnalytics.fromJson(json['user_analytics']),
      orderAnalytics: OrderAnalytics.fromJson(json['order_analytics']),
      performanceMetrics:
          PerformanceMetrics.fromJson(json['performance_metrics']),
      geographicData: GeographicData.fromJson(json['geographic_data']),
      trends: (json['trends'] as List)
          .map((item) => TrendDataPoint.fromJson(item))
          .toList(),
      customMetrics: Map<String, dynamic>.from(json['custom_metrics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform_metrics': platformMetrics.toJson(),
      'revenue_analytics': revenueAnalytics.toJson(),
      'user_analytics': userAnalytics.toJson(),
      'order_analytics': orderAnalytics.toJson(),
      'performance_metrics': performanceMetrics.toJson(),
      'geographic_data': geographicData.toJson(),
      'trends': trends.map((trend) => trend.toJson()).toList(),
      'custom_metrics': customMetrics,
    };
  }
}

class PlatformMetrics {
  final int totalTransactions;
  final double totalGmv; // Gross Merchandise Value
  final int totalCommissions;
  final double averageTransactionValue;
  final double commissionRate;
  final int activeRestaurants;
  final int activeCouriers;
  final int activeCustomers;
  final double platformGrowthRate;

  PlatformMetrics({
    required this.totalTransactions,
    required this.totalGmv,
    required this.totalCommissions,
    required this.averageTransactionValue,
    required this.commissionRate,
    required this.activeRestaurants,
    required this.activeCouriers,
    required this.activeCustomers,
    required this.platformGrowthRate,
  });

  factory PlatformMetrics.fromJson(Map<String, dynamic> json) {
    return PlatformMetrics(
      totalTransactions: json['total_transactions'] as int,
      totalGmv: (json['total_gmv'] as num).toDouble(),
      totalCommissions: json['total_commissions'] as int,
      averageTransactionValue:
          (json['average_transaction_value'] as num).toDouble(),
      commissionRate: (json['commission_rate'] as num).toDouble(),
      activeRestaurants: json['active_restaurants'] as int,
      activeCouriers: json['active_couriers'] as int,
      activeCustomers: json['active_customers'] as int,
      platformGrowthRate: (json['platform_growth_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_transactions': totalTransactions,
      'total_gmv': totalGmv,
      'total_commissions': totalCommissions,
      'average_transaction_value': averageTransactionValue,
      'commission_rate': commissionRate,
      'active_restaurants': activeRestaurants,
      'active_couriers': activeCouriers,
      'active_customers': activeCustomers,
      'platform_growth_rate': platformGrowthRate,
    };
  }
}

class RevenueAnalytics {
  final List<RevenueDataPoint> dailyRevenue;
  final List<RevenueDataPoint> monthlyRevenue;
  final Map<String, double> revenueByPaymentMethod;
  final Map<String, double> revenueByRegion;
  final double totalRevenue;
  final double revenueGrowth;
  final double averageDailyRevenue;
  final List<TopPerformingRestaurant> topRestaurants;

  RevenueAnalytics({
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.revenueByPaymentMethod,
    required this.revenueByRegion,
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.averageDailyRevenue,
    required this.topRestaurants,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      dailyRevenue: (json['daily_revenue'] as List)
          .map((item) => RevenueDataPoint.fromJson(item))
          .toList(),
      monthlyRevenue: (json['monthly_revenue'] as List)
          .map((item) => RevenueDataPoint.fromJson(item))
          .toList(),
      revenueByPaymentMethod:
          Map<String, double>.from(json['revenue_by_payment_method']),
      revenueByRegion: Map<String, double>.from(json['revenue_by_region']),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      revenueGrowth: (json['revenue_growth'] as num).toDouble(),
      averageDailyRevenue: (json['average_daily_revenue'] as num).toDouble(),
      topRestaurants: (json['top_restaurants'] as List)
          .map((item) => TopPerformingRestaurant.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_revenue': dailyRevenue.map((item) => item.toJson()).toList(),
      'monthly_revenue': monthlyRevenue.map((item) => item.toJson()).toList(),
      'revenue_by_payment_method': revenueByPaymentMethod,
      'revenue_by_region': revenueByRegion,
      'total_revenue': totalRevenue,
      'revenue_growth': revenueGrowth,
      'average_daily_revenue': averageDailyRevenue,
      'top_restaurants': topRestaurants.map((item) => item.toJson()).toList(),
    };
  }
}

class UserAnalytics {
  final int totalUsers;
  final int newUsers;
  final double userRetentionRate;
  final double userAcquisitionCost;
  final Map<String, int> usersByType;
  final Map<String, int> usersByRegion;
  final List<UserGrowthDataPoint> userGrowthData;
  final double averageUserLifetimeValue;

  UserAnalytics({
    required this.totalUsers,
    required this.newUsers,
    required this.userRetentionRate,
    required this.userAcquisitionCost,
    required this.usersByType,
    required this.usersByRegion,
    required this.userGrowthData,
    required this.averageUserLifetimeValue,
  });

  factory UserAnalytics.fromJson(Map<String, dynamic> json) {
    return UserAnalytics(
      totalUsers: json['total_users'] as int,
      newUsers: json['new_users'] as int,
      userRetentionRate: (json['user_retention_rate'] as num).toDouble(),
      userAcquisitionCost: (json['user_acquisition_cost'] as num).toDouble(),
      usersByType: Map<String, int>.from(json['users_by_type']),
      usersByRegion: Map<String, int>.from(json['users_by_region']),
      userGrowthData: (json['user_growth_data'] as List)
          .map((item) => UserGrowthDataPoint.fromJson(item))
          .toList(),
      averageUserLifetimeValue:
          (json['average_user_lifetime_value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'new_users': newUsers,
      'user_retention_rate': userRetentionRate,
      'user_acquisition_cost': userAcquisitionCost,
      'users_by_type': usersByType,
      'users_by_region': usersByRegion,
      'user_growth_data': userGrowthData.map((item) => item.toJson()).toList(),
      'average_user_lifetime_value': averageUserLifetimeValue,
    };
  }
}

class OrderAnalytics {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double completionRate;
  final double averageOrderValue;
  final double averageDeliveryTime;
  final Map<String, int> ordersByStatus;
  final Map<String, int> ordersByRegion;
  final List<OrderVolumeDataPoint> orderVolumeData;
  final double orderGrowthRate;

  OrderAnalytics({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.completionRate,
    required this.averageOrderValue,
    required this.averageDeliveryTime,
    required this.ordersByStatus,
    required this.ordersByRegion,
    required this.orderVolumeData,
    required this.orderGrowthRate,
  });

  factory OrderAnalytics.fromJson(Map<String, dynamic> json) {
    return OrderAnalytics(
      totalOrders: json['total_orders'] as int,
      completedOrders: json['completed_orders'] as int,
      cancelledOrders: json['cancelled_orders'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      averageDeliveryTime: (json['average_delivery_time'] as num).toDouble(),
      ordersByStatus: Map<String, int>.from(json['orders_by_status']),
      ordersByRegion: Map<String, int>.from(json['orders_by_region']),
      orderVolumeData: (json['order_volume_data'] as List)
          .map((item) => OrderVolumeDataPoint.fromJson(item))
          .toList(),
      orderGrowthRate: (json['order_growth_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_orders': totalOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'completion_rate': completionRate,
      'average_order_value': averageOrderValue,
      'average_delivery_time': averageDeliveryTime,
      'orders_by_status': ordersByStatus,
      'orders_by_region': ordersByRegion,
      'order_volume_data':
          orderVolumeData.map((item) => item.toJson()).toList(),
      'order_growth_rate': orderGrowthRate,
    };
  }
}

class PerformanceMetrics {
  final double systemUptime;
  final double averageResponseTime;
  final double errorRate;
  final int totalApiCalls;
  final double serverLoad;
  final double databasePerformance;
  final Map<String, double> endpointPerformance;
  final List<PerformanceDataPoint> performanceHistory;

  PerformanceMetrics({
    required this.systemUptime,
    required this.averageResponseTime,
    required this.errorRate,
    required this.totalApiCalls,
    required this.serverLoad,
    required this.databasePerformance,
    required this.endpointPerformance,
    required this.performanceHistory,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      systemUptime: (json['system_uptime'] as num).toDouble(),
      averageResponseTime: (json['average_response_time'] as num).toDouble(),
      errorRate: (json['error_rate'] as num).toDouble(),
      totalApiCalls: json['total_api_calls'] as int,
      serverLoad: (json['server_load'] as num).toDouble(),
      databasePerformance: (json['database_performance'] as num).toDouble(),
      endpointPerformance:
          Map<String, double>.from(json['endpoint_performance']),
      performanceHistory: (json['performance_history'] as List)
          .map((item) => PerformanceDataPoint.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'system_uptime': systemUptime,
      'average_response_time': averageResponseTime,
      'error_rate': errorRate,
      'total_api_calls': totalApiCalls,
      'server_load': serverLoad,
      'database_performance': databasePerformance,
      'endpoint_performance': endpointPerformance,
      'performance_history':
          performanceHistory.map((item) => item.toJson()).toList(),
    };
  }
}

class GeographicData {
  final Map<String, RegionMetrics> regionMetrics;
  final List<HotspotData> deliveryHotspots;
  final Map<String, double> regionRevenue;
  final Map<String, int> regionOrderCount;

  GeographicData({
    required this.regionMetrics,
    required this.deliveryHotspots,
    required this.regionRevenue,
    required this.regionOrderCount,
  });

  factory GeographicData.fromJson(Map<String, dynamic> json) {
    return GeographicData(
      regionMetrics: (json['region_metrics'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, RegionMetrics.fromJson(value))),
      deliveryHotspots: (json['delivery_hotspots'] as List)
          .map((item) => HotspotData.fromJson(item))
          .toList(),
      regionRevenue: Map<String, double>.from(json['region_revenue']),
      regionOrderCount: Map<String, int>.from(json['region_order_count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region_metrics':
          regionMetrics.map((key, value) => MapEntry(key, value.toJson())),
      'delivery_hotspots':
          deliveryHotspots.map((item) => item.toJson()).toList(),
      'region_revenue': regionRevenue,
      'region_order_count': regionOrderCount,
    };
  }
}

class RevenueDataPoint {
  final String date;
  final double amount;

  RevenueDataPoint({required this.date, required this.amount});

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'date': date, 'amount': amount};
}

class TopPerformingRestaurant {
  final String id;
  final String name;
  final double revenue;
  final int orderCount;

  TopPerformingRestaurant({
    required this.id,
    required this.name,
    required this.revenue,
    required this.orderCount,
  });

  factory TopPerformingRestaurant.fromJson(Map<String, dynamic> json) {
    return TopPerformingRestaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      orderCount: json['order_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'revenue': revenue,
      'order_count': orderCount
    };
  }
}

class UserGrowthDataPoint {
  final String date;
  final int count;
  final String userType;

  UserGrowthDataPoint({
    required this.date,
    required this.count,
    required this.userType,
  });

  factory UserGrowthDataPoint.fromJson(Map<String, dynamic> json) {
    return UserGrowthDataPoint(
      date: json['date'] as String,
      count: json['count'] as int,
      userType: json['user_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'count': count, 'user_type': userType};
  }
}

class OrderVolumeDataPoint {
  final String date;
  final int volume;
  final String status;

  OrderVolumeDataPoint({
    required this.date,
    required this.volume,
    required this.status,
  });

  factory OrderVolumeDataPoint.fromJson(Map<String, dynamic> json) {
    return OrderVolumeDataPoint(
      date: json['date'] as String,
      volume: json['volume'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'volume': volume, 'status': status};
  }
}

class PerformanceDataPoint {
  final String timestamp;
  final double responseTime;
  final double uptime;
  final double errorRate;

  PerformanceDataPoint({
    required this.timestamp,
    required this.responseTime,
    required this.uptime,
    required this.errorRate,
  });

  factory PerformanceDataPoint.fromJson(Map<String, dynamic> json) {
    return PerformanceDataPoint(
      timestamp: json['timestamp'] as String,
      responseTime: (json['response_time'] as num).toDouble(),
      uptime: (json['uptime'] as num).toDouble(),
      errorRate: (json['error_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'response_time': responseTime,
      'uptime': uptime,
      'error_rate': errorRate,
    };
  }
}

class RegionMetrics {
  final String regionName;
  final int userCount;
  final int orderCount;
  final double revenue;
  final double averageDeliveryTime;

  RegionMetrics({
    required this.regionName,
    required this.userCount,
    required this.orderCount,
    required this.revenue,
    required this.averageDeliveryTime,
  });

  factory RegionMetrics.fromJson(Map<String, dynamic> json) {
    return RegionMetrics(
      regionName: json['region_name'] as String,
      userCount: json['user_count'] as int,
      orderCount: json['order_count'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      averageDeliveryTime: (json['average_delivery_time'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'region_name': regionName,
      'user_count': userCount,
      'order_count': orderCount,
      'revenue': revenue,
      'average_delivery_time': averageDeliveryTime,
    };
  }
}

class HotspotData {
  final String name;
  final double latitude;
  final double longitude;
  final int orderCount;
  final double radius;

  HotspotData({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.orderCount,
    required this.radius,
  });

  factory HotspotData.fromJson(Map<String, dynamic> json) {
    return HotspotData(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      orderCount: json['order_count'] as int,
      radius: (json['radius'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'order_count': orderCount,
      'radius': radius,
    };
  }
}

class TrendDataPoint {
  final String category;
  final String metric;
  final String period;
  final double value;
  final double change;

  TrendDataPoint({
    required this.category,
    required this.metric,
    required this.period,
    required this.value,
    required this.change,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      category: json['category'] as String,
      metric: json['metric'] as String,
      period: json['period'] as String,
      value: (json['value'] as num).toDouble(),
      change: (json['change'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'metric': metric,
      'period': period,
      'value': value,
      'change': change,
    };
  }
}
