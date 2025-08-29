class AdminDashboardData {
  final int totalUsers;
  final int totalOrders;
  final int totalRevenue;
  final int activeUsers;
  final int totalRestaurants;
  final int activeCouriers;
  final double userGrowthRate;
  final double orderGrowthRate;
  final double revenueGrowthRate;
  final String systemUptime;
  final String systemPerformance;
  final List<SystemAlert> systemAlerts;
  final List<RecentActivity> recentActivities;
  final Map<String, int> userTypeDistribution;
  final Map<String, int> orderStatusDistribution;
  final List<DashboardMetric> keyMetrics;

  // Additional computed properties for dashboard screen
  String get appVersion => '1.0.0+1';
  int get newUsersToday => (activeUsers * 0.1).round(); // Mock calculation
  int get activeOrders => (totalOrders * 0.05).round(); // Mock calculation
  int get completedOrdersToday =>
      (totalOrders * 0.8).round(); // Mock calculation
  int get onlineCouriers => (activeCouriers * 0.7).round(); // Mock calculation
  int get totalCouriers => activeCouriers + 50; // Mock calculation
  int get activeRestaurants =>
      (totalRestaurants * 0.9).round(); // Mock calculation
  List<HealthCheck> get systemHealthChecks => [
        HealthCheck(name: 'Database', status: 'healthy', responseTime: '45ms'),
        HealthCheck(
            name: 'API Gateway', status: 'healthy', responseTime: '12ms'),
        HealthCheck(
            name: 'Payment Service', status: 'warning', responseTime: '150ms'),
      ];

  AdminDashboardData({
    required this.totalUsers,
    required this.totalOrders,
    required this.totalRevenue,
    required this.activeUsers,
    required this.totalRestaurants,
    required this.activeCouriers,
    required this.userGrowthRate,
    required this.orderGrowthRate,
    required this.revenueGrowthRate,
    required this.systemUptime,
    required this.systemPerformance,
    required this.systemAlerts,
    required this.recentActivities,
    required this.userTypeDistribution,
    required this.orderStatusDistribution,
    required this.keyMetrics,
  });

  factory AdminDashboardData.fromJson(Map<String, dynamic> json) {
    return AdminDashboardData(
      totalUsers: json['total_users'] as int,
      totalOrders: json['total_orders'] as int,
      totalRevenue: json['total_revenue'] as int,
      activeUsers: json['active_users'] as int,
      totalRestaurants: json['total_restaurants'] as int,
      activeCouriers: json['active_couriers'] as int,
      userGrowthRate: (json['user_growth_rate'] as num).toDouble(),
      orderGrowthRate: (json['order_growth_rate'] as num).toDouble(),
      revenueGrowthRate: (json['revenue_growth_rate'] as num).toDouble(),
      systemUptime: json['system_uptime'] as String,
      systemPerformance: json['system_performance'] as String,
      systemAlerts: (json['system_alerts'] as List)
          .map((item) => SystemAlert.fromJson(item))
          .toList(),
      recentActivities: (json['recent_activities'] as List)
          .map((item) => RecentActivity.fromJson(item))
          .toList(),
      userTypeDistribution:
          Map<String, int>.from(json['user_type_distribution']),
      orderStatusDistribution:
          Map<String, int>.from(json['order_status_distribution']),
      keyMetrics: (json['key_metrics'] as List)
          .map((item) => DashboardMetric.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'active_users': activeUsers,
      'total_restaurants': totalRestaurants,
      'active_couriers': activeCouriers,
      'user_growth_rate': userGrowthRate,
      'order_growth_rate': orderGrowthRate,
      'revenue_growth_rate': revenueGrowthRate,
      'system_uptime': systemUptime,
      'system_performance': systemPerformance,
      'system_alerts': systemAlerts.map((alert) => alert.toJson()).toList(),
      'recent_activities':
          recentActivities.map((activity) => activity.toJson()).toList(),
      'user_type_distribution': userTypeDistribution,
      'order_status_distribution': orderStatusDistribution,
      'key_metrics': keyMetrics.map((metric) => metric.toJson()).toList(),
    };
  }
}

class SystemAlert {
  final String id;
  final String type;
  final String message;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final DateTime timestamp;
  final bool isResolved;

  SystemAlert({
    required this.id,
    required this.type,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.isResolved = false,
  });

  factory SystemAlert.fromJson(Map<String, dynamic> json) {
    return SystemAlert(
      id: json['id'] as String,
      type: json['type'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isResolved: json['is_resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'message': message,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
      'is_resolved': isResolved,
    };
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String description;
  final String? userId;
  final String? userName;
  final String? entityId;
  final String? entityType;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    this.userId,
    this.userName,
    this.entityId,
    this.entityType,
    required this.timestamp,
    this.metadata,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
      entityId: json['entity_id'] as String?,
      entityType: json['entity_type'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'user_id': userId,
      'user_name': userName,
      'entity_id': entityId,
      'entity_type': entityType,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }
}

class DashboardMetric {
  final String name;
  final String value;
  final String? unit;
  final double? changePercentage;
  final String? changeDirection; // 'up', 'down', 'neutral'
  final String? icon;
  final String? color;

  DashboardMetric({
    required this.name,
    required this.value,
    this.unit,
    this.changePercentage,
    this.changeDirection,
    this.icon,
    this.color,
  });

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    return DashboardMetric(
      name: json['name'] as String,
      value: json['value'] as String,
      unit: json['unit'] as String?,
      changePercentage: (json['change_percentage'] as num?)?.toDouble(),
      changeDirection: json['change_direction'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'change_percentage': changePercentage,
      'change_direction': changeDirection,
      'icon': icon,
      'color': color,
    };
  }
}

// Additional classes for admin dashboard
class ActivityItem {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final String? userName;

  ActivityItem({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['user_id'] as String?,
      userName: json['user_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'user_id': userId,
      'user_name': userName,
    };
  }
}

class HealthCheck {
  final String name;
  final String status;
  final String responseTime;
  final String? errorMessage;

  HealthCheck({
    required this.name,
    required this.status,
    required this.responseTime,
    this.errorMessage,
  });

  bool get isHealthy => status == 'healthy';

  factory HealthCheck.fromJson(Map<String, dynamic> json) {
    return HealthCheck(
      name: json['name'] as String,
      status: json['status'] as String,
      responseTime: json['response_time'] as String,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'response_time': responseTime,
      'error_message': errorMessage,
    };
  }
}
