// lib/core/models/delivery_order.dart - CORRECTED VERSION - Replace entire file
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery_order.freezed.dart';
part 'delivery_order.g.dart';

@freezed
class DeliveryOrder with _$DeliveryOrder {
  const DeliveryOrder._(); // Required private constructor for getters

  const factory DeliveryOrder({
    required String id,
    required String orderNumber,
    required String customerId,
    String? courierId,
    String? partnerId, // For restaurant/business orders

    // Package details
    required String packageDescription,
    @Default(0) int packageValueXof, // Value in CFA Franc
    @Default(false) bool fragile,
    @Default(false) bool requiresSignature,

    // Status tracking
    required DeliveryStatus status,
    required PaymentStatus paymentStatus,
    @Default(1) int priorityLevel, // 1=normal, 2=urgent, 3=express

    // Location information (using separate lat/lng for Supabase compatibility)
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
    String? pickupAddress,
    String? deliveryAddress,

    // Zone-based pricing in CFA Franc (XOF)
    @Default(500)
    int basePriceXof, // Covers deliveries within base zone (4.5km)
    @Default(4.5) double baseZoneRadiusKm, // Base zone coverage
    @Default(0)
    int additionalDistancePriceXof, // Only for distance beyond base zone
    @Default(0) int urgencyPriceXof, // Priority surcharge
    @Default(0) int fragilePriceXof, // Fragile handling surcharge
    required int totalPriceXof,
    @Default('XOF') String currency,

    // Timing
    DateTime? estimatedPickupTime,
    DateTime? estimatedDeliveryTime,
    DateTime? actualPickupTime,
    DateTime? actualDeliveryTime,

    // Recipient details
    required String recipientName,
    required String recipientPhone,
    String? recipientEmail,
    String? specialInstructions,

    // Payment method (Côte d'Ivoire specific)
    required PaymentMethod paymentMethod,

    // Tracking
    @Default([]) List<OrderStatusUpdate> statusHistory,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _DeliveryOrder;

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) =>
      _$DeliveryOrderFromJson(json);

  // Helper method to calculate distance in km using Haversine formula
  double get distanceKm {
    const double earthRadius = 6371; // Earth's radius in km

    double lat1Rad = pickupLatitude * (pi / 180);
    double lon1Rad = pickupLongitude * (pi / 180);
    double lat2Rad = deliveryLatitude * (pi / 180);
    double lon2Rad = deliveryLongitude * (pi / 180);

    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // Check if delivery is within base zone
  bool get isWithinBaseZone => distanceKm <= baseZoneRadiusKm;

  // Calculate additional distance beyond base zone
  double get additionalDistanceKm =>
      distanceKm > baseZoneRadiusKm ? distanceKm - baseZoneRadiusKm : 0.0;
}

@freezed
class OrderStatusUpdate with _$OrderStatusUpdate {
  const factory OrderStatusUpdate({
    required DeliveryStatus status,
    required DateTime timestamp,
    String? note,
    double? latitude,
    double? longitude,
  }) = _OrderStatusUpdate;

  factory OrderStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$OrderStatusUpdateFromJson(json);
}

enum DeliveryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('assigned')
  assigned,
  @JsonValue('courier_en_route')
  courierEnRoute,
  @JsonValue('picked_up')
  pickedUp,
  @JsonValue('in_transit')
  inTransit,
  @JsonValue('arrived_destination')
  arrivedDestination,
  @JsonValue('delivered')
  delivered,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('disputed')
  disputed,
}

enum PaymentStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  @JsonValue('orange_money')
  orangeMoney,
  @JsonValue('mtn_money')
  mtnMoney,
  @JsonValue('moov_money')
  moovMoney,
  @JsonValue('wave')
  wave,
  @JsonValue('cash_on_delivery')
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
        return 'MTN Mobile Money';
      case PaymentMethod.moovMoney:
        return 'Moov Money';
      case PaymentMethod.wave:
        return 'Wave';
      case PaymentMethod.cashOnDelivery:
        return 'Paiement à la livraison';
    }
  }

  bool get requiresMobileNumber => [
        PaymentMethod.orangeMoney,
        PaymentMethod.mtnMoney,
        PaymentMethod.moovMoney,
        PaymentMethod.wave,
      ].contains(this);
}
