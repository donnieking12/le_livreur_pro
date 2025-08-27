// lib/core/models/delivery_order.dart - Enhanced version with marketplace support
import 'dart:math';

import 'package:le_livreur_pro/core/models/cart.dart';

class DeliveryOrder {
  final String id;
  final String orderNumber;
  final String customerId;
  final String? courierId;
  final String? partnerId; // For restaurant/business orders
  final String? restaurantId; // For marketplace orders
  // Order Type
  final OrderType orderType; // 'package' or 'marketplace'
  // Package details (for package delivery)
  final String? packageDescription;
  final int packageValueXof; // Value in CFA Franc
  final bool fragile;
  final bool requiresSignature;

  // Marketplace details (for restaurant orders)
  final Cart? cart; // Shopping cart for marketplace orders
  final List<OrderItem> items; // Order items for marketplace
  // Status tracking
  final DeliveryStatus status;
  final PaymentStatus paymentStatus;
  final int priorityLevel; // 1=normal, 2=urgent, 3=express
  // Location information (using separate lat/lng for Supabase compatibility)
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String pickupAddress;
  final String deliveryAddress;
  final String? pickupInstructions;
  final String? deliveryInstructions;

  // Recipient information
  final String recipientName;
  final String recipientPhone;
  final String? recipientEmail;

  // Pricing and payment
  final int totalPriceXof;
  final int deliveryFeeXof;
  final int serviceFeeXof; // Platform commission
  final PaymentMethod paymentMethod;
  final String? paymentTransactionId;

  // Courier information
  final String? courierName;
  final String? courierPhone;
  final String? courierVehicleType;
  final String? courierVehiclePlate;

  // Timing
  final DateTime? requestedDeliveryTime;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualPickupTime;
  final DateTime? actualDeliveryTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Reviews and rating
  final double? customerRating;
  final String? customerReview;
  final double? courierRating;
  final String? courierReview;

  // Special requirements
  final bool requiresId;
  final String? specialInstructions;
  final List<String> photoUrls;
  final double baseZoneRadiusKm; // Base zone coverage

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
    this.cart,
    this.items = const [],
    required this.status,
    required this.paymentStatus,
    this.priorityLevel = 1,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.pickupInstructions,
    this.deliveryInstructions,
    required this.recipientName,
    required this.recipientPhone,
    this.recipientEmail,
    required this.totalPriceXof,
    this.deliveryFeeXof = 0,
    this.serviceFeeXof = 0,
    required this.paymentMethod,
    this.paymentTransactionId,
    this.courierName,
    this.courierPhone,
    this.courierVehicleType,
    this.courierVehiclePlate,
    this.requestedDeliveryTime,
    this.estimatedDeliveryTime,
    this.actualPickupTime,
    this.actualDeliveryTime,
    required this.createdAt,
    required this.updatedAt,
    this.customerRating,
    this.customerReview,
    this.courierRating,
    this.courierReview,
    this.requiresId = false,
    this.specialInstructions,
    this.photoUrls = const [],
    this.baseZoneRadiusKm = 4.5,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    return DeliveryOrder(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      courierId: json['courier_id'] as String?,
      partnerId: json['partner_id'] as String?,
      restaurantId: json['restaurant_id'] as String?,
      orderType: OrderType.values.firstWhere(
        (e) => e.toString().split('.').last == json['order_type'],
        orElse: () => OrderType.package,
      ),
      packageDescription: json['package_description'] as String?,
      packageValueXof: json['package_value_xof'] as int? ?? 0,
      fragile: json['fragile'] as bool? ?? false,
      requiresSignature: json['requires_signature'] as bool? ?? false,
      cart: json['cart'] != null
          ? Cart.fromJson(json['cart'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['payment_status'],
        orElse: () => PaymentStatus.pending,
      ),
      priorityLevel: json['priority_level'] as int? ?? 1,
      pickupLatitude: (json['pickup_latitude'] as num).toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num).toDouble(),
      deliveryLatitude: (json['delivery_latitude'] as num).toDouble(),
      deliveryLongitude: (json['delivery_longitude'] as num).toDouble(),
      pickupAddress: json['pickup_address'] as String,
      deliveryAddress: json['delivery_address'] as String,
      pickupInstructions: json['pickup_instructions'] as String?,
      deliveryInstructions: json['delivery_instructions'] as String?,
      recipientName: json['recipient_name'] as String,
      recipientPhone: json['recipient_phone'] as String,
      recipientEmail: json['recipient_email'] as String?,
      totalPriceXof: json['total_price_xof'] as int,
      deliveryFeeXof: json['delivery_fee_xof'] as int? ?? 0,
      serviceFeeXof: json['service_fee_xof'] as int? ?? 0,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['payment_method'],
        orElse: () => PaymentMethod.cashOnDelivery,
      ),
      paymentTransactionId: json['payment_transaction_id'] as String?,
      courierName: json['courier_name'] as String?,
      courierPhone: json['courier_phone'] as String?,
      courierVehicleType: json['courier_vehicle_type'] as String?,
      courierVehiclePlate: json['courier_vehicle_plate'] as String?,
      requestedDeliveryTime: json['requested_delivery_time'] != null
          ? DateTime.parse(json['requested_delivery_time'] as String)
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
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      customerRating: (json['customer_rating'] as num?)?.toDouble(),
      customerReview: json['customer_review'] as String?,
      courierRating: (json['courier_rating'] as num?)?.toDouble(),
      courierReview: json['courier_review'] as String?,
      requiresId: json['requires_id'] as bool? ?? false,
      specialInstructions: json['special_instructions'] as String?,
      photoUrls: (json['photo_urls'] as List<dynamic>? ?? [])
          .map((url) => url as String)
          .toList(),
      baseZoneRadiusKm:
          (json['base_zone_radius_km'] as num?)?.toDouble() ?? 4.5,
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
      'order_type': orderType.toString().split('.').last,
      'package_description': packageDescription,
      'package_value_xof': packageValueXof,
      'fragile': fragile,
      'requires_signature': requiresSignature,
      'cart': cart?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'status': status.toString().split('.').last,
      'payment_status': paymentStatus.toString().split('.').last,
      'priority_level': priorityLevel,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'pickup_address': pickupAddress,
      'delivery_address': deliveryAddress,
      'pickup_instructions': pickupInstructions,
      'delivery_instructions': deliveryInstructions,
      'recipient_name': recipientName,
      'recipient_phone': recipientPhone,
      'recipient_email': recipientEmail,
      'total_price_xof': totalPriceXof,
      'delivery_fee_xof': deliveryFeeXof,
      'service_fee_xof': serviceFeeXof,
      'payment_method': paymentMethod.toString().split('.').last,
      'payment_transaction_id': paymentTransactionId,
      'courier_name': courierName,
      'courier_phone': courierPhone,
      'courier_vehicle_type': courierVehicleType,
      'courier_vehicle_plate': courierVehiclePlate,
      'requested_delivery_time': requestedDeliveryTime?.toIso8601String(),
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'actual_pickup_time': actualPickupTime?.toIso8601String(),
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer_rating': customerRating,
      'customer_review': customerReview,
      'courier_rating': courierRating,
      'courier_review': courierReview,
      'requires_id': requiresId,
      'special_instructions': specialInstructions,
      'photo_urls': photoUrls,
      'base_zone_radius_km': baseZoneRadiusKm,
    };
  }

  // Calculate distance between pickup and delivery using Haversine formula
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
        (e) => e.toString().split('.').last == json['status'],
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
      'status': status.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

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

class OrderItem {
  final String id;
  final String menuItemId;
  final String name;
  final int unitPriceXof;
  final int quantity;
  final List<String> variations; // Selected variations
  final List<String> addons; // Selected addons
  final String? specialInstructions;
  final int totalPriceXof;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.unitPriceXof,
    required this.quantity,
    this.variations = const [],
    this.addons = const [],
    this.specialInstructions,
    required this.totalPriceXof,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      menuItemId: json['menu_item_id'] as String,
      name: json['name'] as String,
      unitPriceXof: json['unit_price_xof'] as int,
      quantity: json['quantity'] as int,
      variations: (json['variations'] as List<dynamic>? ?? [])
          .map((v) => v as String)
          .toList(),
      addons: (json['addons'] as List<dynamic>? ?? [])
          .map((a) => a as String)
          .toList(),
      specialInstructions: json['special_instructions'] as String?,
      totalPriceXof: json['total_price_xof'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'menu_item_id': menuItemId,
      'name': name,
      'unit_price_xof': unitPriceXof,
      'quantity': quantity,
      'variations': variations,
      'addons': addons,
      'special_instructions': specialInstructions,
      'total_price_xof': totalPriceXof,
    };
  }
}

enum OrderType {
  package,
  marketplace,
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.package:
        return 'Livraison de colis';
      case OrderType.marketplace:
        return 'Commande restaurant';
    }
  }

  String get displayNameEn {
    switch (this) {
      case OrderType.package:
        return 'Package Delivery';
      case OrderType.marketplace:
        return 'Restaurant Order';
    }
  }
}
