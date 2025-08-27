class PartnerAnalytics {
  final int totalRevenue;
  final int totalOrders;
  final int uniqueCustomers;
  final int averageOrderValue;
  final double revenueChange;
  final double ordersChange;
  final double customersChange;
  final double aovChange;
  final List<RevenueDataPoint> revenueData;
  final List<OrdersDataPoint> ordersData;
  final List<TopProduct> topProducts;
  final int newCustomers;
  final int returningCustomers;
  final double repeatOrderRate;
  final double satisfactionRate;
  final int avgPreparationTime;
  final double acceptanceRate;
  final double averageRating;
  final int avgDeliveryTime;

  PartnerAnalytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.uniqueCustomers,
    required this.averageOrderValue,
    required this.revenueChange,
    required this.ordersChange,
    required this.customersChange,
    required this.aovChange,
    required this.revenueData,
    required this.ordersData,
    required this.topProducts,
    required this.newCustomers,
    required this.returningCustomers,
    required this.repeatOrderRate,
    required this.satisfactionRate,
    required this.avgPreparationTime,
    required this.acceptanceRate,
    required this.averageRating,
    required this.avgDeliveryTime,
  });

  factory PartnerAnalytics.fromJson(Map<String, dynamic> json) {
    return PartnerAnalytics(
      totalRevenue: json['total_revenue'] as int,
      totalOrders: json['total_orders'] as int,
      uniqueCustomers: json['unique_customers'] as int,
      averageOrderValue: json['average_order_value'] as int,
      revenueChange: (json['revenue_change'] as num).toDouble(),
      ordersChange: (json['orders_change'] as num).toDouble(),
      customersChange: (json['customers_change'] as num).toDouble(),
      aovChange: (json['aov_change'] as num).toDouble(),
      revenueData: (json['revenue_data'] as List)
          .map((item) => RevenueDataPoint.fromJson(item))
          .toList(),
      ordersData: (json['orders_data'] as List)
          .map((item) => OrdersDataPoint.fromJson(item))
          .toList(),
      topProducts: (json['top_products'] as List)
          .map((item) => TopProduct.fromJson(item))
          .toList(),
      newCustomers: json['new_customers'] as int,
      returningCustomers: json['returning_customers'] as int,
      repeatOrderRate: (json['repeat_order_rate'] as num).toDouble(),
      satisfactionRate: (json['satisfaction_rate'] as num).toDouble(),
      avgPreparationTime: json['avg_preparation_time'] as int,
      acceptanceRate: (json['acceptance_rate'] as num).toDouble(),
      averageRating: (json['average_rating'] as num).toDouble(),
      avgDeliveryTime: json['avg_delivery_time'] as int,
    );
  }
}

class RevenueDataPoint {
  final String date;
  final double amount;

  RevenueDataPoint({
    required this.date,
    required this.amount,
  });

  factory RevenueDataPoint.fromJson(Map<String, dynamic> json) {
    return RevenueDataPoint(
      date: json['date'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class OrdersDataPoint {
  final String date;
  final int count;

  OrdersDataPoint({
    required this.date,
    required this.count,
  });

  factory OrdersDataPoint.fromJson(Map<String, dynamic> json) {
    return OrdersDataPoint(
      date: json['date'] as String,
      count: json['count'] as int,
    );
  }
}

class TopProduct {
  final String id;
  final String name;
  final int quantity;
  final int revenue;
  final String? imageUrl;

  TopProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.revenue,
    this.imageUrl,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      revenue: json['revenue'] as int,
      imageUrl: json['image_url'] as String?,
    );
  }
}
