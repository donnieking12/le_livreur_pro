// lib/core/models/delivery_order_simple.dart - Simple version without freezed
import 'dart:math';

enum DeliveryStatus {
  pending,
  assigned,
  courierEnRoute,
  pickedUp,
  inTransit,
  arrivedDestination,
  delivered,
  cancelled,
  disputed,
}

enum PaymentStatus {
  pending,
  completed,
  failed,
  refunded,
}

enum PaymentMethod {
  orangeMoney,
  mtnMoney,
  moovMoney,
  wave,
  cashOnDelivery,
}

enum OrderType {
  package,
  marketplace,
}

class DeliveryOrder {
  final String id;
  final String orderNumber;
  final String customerId;
  final String? courierId;
  final String? partnerId;
  final String? restaurantId;
  final OrderType orderType;
  final String? packageDescription;
  final int packageValueXof;
  final bool fragile;
  final bool requiresSignature;
  final DeliveryStatus status;
  final PaymentStatus paymentStatus;
  final int priorityLevel;
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String? pickupAddress;
  final String? deliveryAddress;
  final int basePriceXof;
  final double baseZoneRadiusKm;
  final int additionalDistancePriceXof;
  final int urgencyPriceXof;
  final int fragilePriceXof;
  final int totalPriceXof;
  final String currency;
  final DateTime? estimatedPickupTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualPickupTime;
  final DateTime? actualDeliveryTime;
  final String recipientName;
  final String recipientPhone;
  final String? recipientEmail;
  final String? specialInstructions;
  final PaymentMethod paymentMethod;
  final List<OrderStatusUpdate> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryOrder({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.courierId,
    this.partnerId,
    this.restaurantId,
    required this.orderType,
    this.packageDescription,
    this.packageValueXof = 0,
    this.fragile = false,
    this.requiresSignature = false,
    required this.status,
    required this.paymentStatus,
    this.priorityLevel = 1,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.pickupAddress,
    this.deliveryAddress,
    this.basePriceXof = 500,
    this.baseZoneRadiusKm = 4.5,
    this.additionalDistancePriceXof = 0,
    this.urgencyPriceXof = 0,
    this.fragilePriceXof = 0,
    required this.totalPriceXof,
    this.currency = 'XOF',
    this.estimatedPickupTime,
    this.estimatedDeliveryTime,
    this.actualPickupTime,
    this.actualDeliveryTime,
    required this.recipientName,
    required this.recipientPhone,
    this.recipientEmail,
    this.specialInstructions,
    required this.paymentMethod,
    this.statusHistory = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to calculate distance in km using Haversine formula
  double get distanceKm {
    const double earthRadius = 6371; // Earth's radius in km

    final double lat1Rad = pickupLatitude * (pi / 180);
    final double lon1Rad = pickupLongitude * (pi / 180);
    final double lat2Rad = deliveryLatitude * (pi / 180);
    final double lon2Rad = deliveryLongitude * (pi / 180);

    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // Check if delivery is within base zone
  bool get isWithinBaseZone => distanceKm <= baseZoneRadiusKm;

  // Calculate additional distance beyond base zone
  double get additionalDistanceKm =>
      distanceKm > baseZoneRadiusKm ? distanceKm - baseZoneRadiusKm : 0.0;

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      courierId: json['courier_id'] as String?,
      partnerId: json['partner_id'] as String?,
      restaurantId: json['restaurant_id'] as String?,
      orderType: OrderType.values.firstWhere(
        (e) => e.name == json['order_type'],
        orElse: () => OrderType.package,
      ),
      packageDescription: json['package_description'] as String?,
      packageValueXof: json['package_value_xof'] as int? ?? 0,
      fragile: json['fragile'] as bool? ?? false,
      requiresSignature: json['requires_signature'] as bool? ?? false,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      priorityLevel: json['priority_level'] as int? ?? 1,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      deliveryLatitude: (json['delivery_latitude'] as num).toDouble(),
      deliveryLongitude: (json['delivery_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String?,
      deliveryAddress: json['delivery_address'] as String?,
      basePriceXof: json['base_price_xof'] as int? ?? 500,
      baseZoneRadiusKm:
          (json['base_zone_radius_km'] as num?)?.toDouble() ?? 4.5,
      additionalDistancePriceXof:
          json['additional_distance_price_xof'] as int? ?? 0,
      urgencyPriceXof: json['urgency_price_xof'] as int? ?? 0,
      fragilePriceXof: json['fragile_price_xof'] as int? ?? 0,
      totalPriceXof: json['total_price_xof'] as int,
      currency: json['currency'] as String? ?? 'XOF',
      estimatedPickupTime: json['estimated_pickup_time'] != null
          ? DateTime.parse(json['estimated_pickup_time'] as String)
          : null,
      estimatedDeliveryTime: json['estimated_delivery_time'] != null
          ? DateTime.parse(json['estimated_delivery_time'] as String)
          : null,
      actualPickupTime: json['actual_pickup_time'] != null
          ? DateTime.parse(json['actual_pickup_time'] as String)
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null
          ? DateTime.parse(json['actual_delivery_time'] as String)
          : null,
      recipientName: json['recipient_name'] as String,
      recipientPhone: json['recipient_phone'] as String,
      recipientEmail: json['recipient_email'] as String?,
      specialInstructions: json['special_instructions'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['payment_method'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      statusHistory: [], // TODO: Parse status history
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'courier_id': courierId,
      'partner_id': partnerId,
      'restaurant_id': restaurantId,
      'order_type': orderType.name,
      'package_description': packageDescription,
      'package_value_xof': packageValueXof,
      'fragile': fragile,
      'requires_signature': requiresSignature,
      'status': status.name,
      'payment_status': paymentStatus.name,
      'priority_level': priorityLevel,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'base_price_xof': basePriceXof,
      'base_zone_radius_km': baseZoneRadiusKm,
      'additional_distance_price_xof': additionalDistancePriceXof,
      'urgency_price_xof': urgencyPriceXof,
      'fragile_price_xof': fragilePriceXof,
      'total_price_xof': totalPriceXof,
      'currency': currency,
      'estimated_pickup_time': estimatedPickupTime?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'recipient_email': recipientEmail,
      'special_instructions': specialInstructions,
      'payment_method': paymentMethod.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class OrderStatusUpdate {
  final DeliveryStatus status;
  final DateTime timestamp;
  final String? note;
  final double? latitude;
  final double? longitude;

  const OrderStatusUpdate({
    required this.status,
    required this.timestamp,
    this.note,
    this.latitude,
    this.longitude,
  });

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) {
    return OrderStatusUpdate(
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// Helper extensions
extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.pending:
        return 'En attente';
      case DeliveryStatus.assigned:
        return 'Assigné';
      case DeliveryStatus.courierEnRoute:
        return 'Coursier en route';
      case DeliveryStatus.pickedUp:
        return 'Récupéré';
      case DeliveryStatus.inTransit:
        return 'En transit';
      case DeliveryStatus.arrivedDestination:
        return 'Arrivé à destination';
      case DeliveryStatus.delivered:
        return 'Livré';
      case DeliveryStatus.cancelled:
        return 'Annulé';
      case DeliveryStatus.disputed:
        return 'En litige';
    }
  }

  bool get isActive => [
        DeliveryStatus.pending,
        DeliveryStatus.assigned,
        DeliveryStatus.courierEnRoute,
        DeliveryStatus.pickedUp,
        DeliveryStatus.inTransit,
        DeliveryStatus.arrivedDestination,
      ].contains(this);
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.orangeMoney:
        return 'Orange Money';
      case PaymentMethod.mtnMoney:
        return 'MTN Money';
      case PaymentMethod.moovMoney:
        return 'Moov Money';
      case PaymentMethod.wave:
        return 'Wave';
      case PaymentMethod.cashOnDelivery:
        return 'Paiement à la livraison';
    }
  }

  bool get isDigital => [
        PaymentMethod.orangeMoney,
        PaymentMethod.mtnMoney,
        PaymentMethod.moovMoney,
        PaymentMethod.wave,
      ].contains(this);

  bool get requiresMobileNumber => [
        PaymentMethod.orangeMoney,
        PaymentMethod.mtnMoney,
        PaymentMethod.moovMoney,
        PaymentMethod.wave,
      ].contains(this);
}
