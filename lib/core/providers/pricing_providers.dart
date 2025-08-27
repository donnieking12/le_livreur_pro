// lib/core/providers/pricing_providers.dart - Comprehensive pricing providers with Riverpod

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_livreur_pro/core/models/pricing_models.dart';
import 'package:le_livreur_pro/core/services/pricing_service.dart';

// ==================== CORE PRICING PROVIDERS ====================

/// Provider for all pricing zones
final pricingZonesProvider = FutureProvider<List<PricingZone>>((ref) async {
  return await PricingService.getAllPricingZones();
});

/// Provider for active pricing zones only
final activePricingZonesProvider = Provider<List<PricingZone>>((ref) {
  final zonesAsync = ref.watch(pricingZonesProvider);
  return zonesAsync.when(
    data: (zones) => zones.where((zone) => zone.isActive).toList(),
    loading: () => [],
    error: (_, __) => PricingZone.defaultZones,
  );
});

/// Provider for commission structure
final commissionStructureProvider =
    FutureProvider<CommissionStructure>((ref) async {
  return await PricingService.getCommissionStructure();
});

/// Provider for finding the best pricing zone for coordinates
final pricingZoneForLocationProvider =
    FutureProvider.family<PricingZone?, PricingLocationRequest>(
        (ref, request) async {
  return await PricingService.findPricingZoneForLocation(
    request.latitude,
    request.longitude,
  );
});

// ==================== PRICING CALCULATION PROVIDERS ====================

/// Provider for calculating delivery pricing
final pricingCalculationProvider =
    FutureProvider.family<PricingCalculation, PricingRequest>(
        (ref, request) async {
  return await PricingService.calculatePricing(
    pickupLatitude: request.pickupLatitude,
    pickupLongitude: request.pickupLongitude,
    deliveryLatitude: request.deliveryLatitude,
    deliveryLongitude: request.deliveryLongitude,
    priorityLevel: request.priorityLevel,
    fragile: request.fragile,
    isWeekend: request.isWeekend,
    isNightDelivery: request.isNightDelivery,
    categoryCode: request.categoryCode,
  );
});

/// Provider for pricing breakdown
final pricingBreakdownProvider =
    FutureProvider.family<Map<String, dynamic>, PricingRequest>(
        (ref, request) async {
  final calculation =
      await ref.read(pricingCalculationProvider(request).future);
  return calculation.breakdown;
});

/// Provider for commission calculation
final commissionCalculationProvider =
    FutureProvider.family<double, CommissionRequest>((ref, request) async {
  final commissionStructure =
      await ref.read(commissionStructureProvider.future);
  return commissionStructure.calculateCommission(
      request.amount, request.category);
});

// ==================== REAL-TIME PRICING STATE PROVIDERS ====================

/// State provider for current pricing request
final currentPricingRequestProvider =
    StateProvider<PricingRequest?>((ref) => null);

/// State provider for selected pricing zone
final selectedPricingZoneProvider = StateProvider<PricingZone?>((ref) => null);

/// State provider for pricing calculation state
final pricingCalculationStateProvider =
    StateNotifierProvider<PricingCalculationNotifier, PricingCalculationState>(
        (ref) {
  return PricingCalculationNotifier(ref);
});

// ==================== ZONE MANAGEMENT PROVIDERS ====================

/// Provider for zones in a specific city
final cityZonesProvider =
    Provider.family<List<PricingZone>, String>((ref, cityCode) {
  final zones = ref.watch(activePricingZonesProvider);
  return zones
      .where((zone) => zone.cityCode.toLowerCase() == cityCode.toLowerCase())
      .toList();
});

/// Provider for zones by type
final zonesByTypeProvider =
    Provider.family<List<PricingZone>, PricingZoneType>((ref, type) {
  final zones = ref.watch(activePricingZonesProvider);
  return zones.where((zone) => zone.type == type).toList();
});

/// Provider for checking if location is within any pricing zone
final locationInZoneProvider =
    FutureProvider.family<bool, PricingLocationRequest>((ref, request) async {
  final zone = await ref.read(pricingZoneForLocationProvider(request).future);
  return zone != null;
});

// ==================== UTILITY PROVIDERS ====================

/// Provider for distance calculation between two points
final distanceCalculationProvider =
    Provider.family<double, DistanceRequest>((ref, request) {
  return PricingService.calculateDistance(
    lat1: request.lat1,
    lon1: request.lon1,
    lat2: request.lat2,
    lon2: request.lon2,
  );
});

/// Provider for delivery time estimation
final deliveryTimeEstimationProvider =
    Provider.family<Duration, DeliveryTimeRequest>((ref, request) {
  return PricingService.estimateDeliveryTime(
    distanceKm: request.distanceKm,
    priorityLevel: request.priorityLevel,
    isTrafficHour: request.isTrafficHour,
  );
});

/// Provider for order number generation
final orderNumberProvider = Provider.family<String, String?>((ref, cityCode) {
  return PricingService.generateOrderNumber(cityCode: cityCode);
});

// ==================== PRICING ANALYTICS PROVIDERS ====================

/// Provider for pricing analytics
final pricingAnalyticsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  return await PricingService.getPricingAnalytics();
});

/// Provider for zone performance metrics
final zonePerformanceProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, zoneId) async {
  return await PricingService.getZonePerformanceMetrics(zoneId);
});

/// Provider for commission earnings summary
final commissionEarningsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, period) async {
  return await PricingService.getCommissionEarnings(period);
});

// ==================== DATA MODELS ====================

/// Request model for pricing calculations
class PricingRequest {
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;
  final PriorityLevel priorityLevel;
  final bool fragile;
  final bool isWeekend;
  final bool isNightDelivery;
  final String? categoryCode;

  const PricingRequest({
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    this.priorityLevel = PriorityLevel.normal,
    this.fragile = false,
    this.isWeekend = false,
    this.isNightDelivery = false,
    this.categoryCode,
  });

  PricingRequest copyWith({
    double? pickupLatitude,
    double? pickupLongitude,
    double? deliveryLatitude,
    double? deliveryLongitude,
    PriorityLevel? priorityLevel,
    bool? fragile,
    bool? isWeekend,
    bool? isNightDelivery,
    String? categoryCode,
  }) {
    return PricingRequest(
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      priorityLevel: priorityLevel ?? this.priorityLevel,
      fragile: fragile ?? this.fragile,
      isWeekend: isWeekend ?? this.isWeekend,
      isNightDelivery: isNightDelivery ?? this.isNightDelivery,
      categoryCode: categoryCode ?? this.categoryCode,
    );
  }
}

/// Request model for location-based operations
class PricingLocationRequest {
  final double latitude;
  final double longitude;

  const PricingLocationRequest({
    required this.latitude,
    required this.longitude,
  });
}

/// Request model for commission calculations
class CommissionRequest {
  final double amount;
  final String? category;

  const CommissionRequest({
    required this.amount,
    this.category,
  });
}

/// Request model for distance calculations
class DistanceRequest {
  final double lat1;
  final double lon1;
  final double lat2;
  final double lon2;

  const DistanceRequest({
    required this.lat1,
    required this.lon1,
    required this.lat2,
    required this.lon2,
  });
}

/// Request model for delivery time estimation
class DeliveryTimeRequest {
  final double distanceKm;
  final int priorityLevel;
  final bool isTrafficHour;

  const DeliveryTimeRequest({
    required this.distanceKm,
    this.priorityLevel = 1,
    this.isTrafficHour = false,
  });
}

// ==================== STATE MANAGEMENT ====================

/// State for pricing calculations
class PricingCalculationState {
  final bool isCalculating;
  final PricingCalculation? calculation;
  final String? errorMessage;
  final DateTime? lastUpdated;

  const PricingCalculationState({
    this.isCalculating = false,
    this.calculation,
    this.errorMessage,
    this.lastUpdated,
  });

  PricingCalculationState copyWith({
    bool? isCalculating,
    PricingCalculation? calculation,
    String? errorMessage,
    DateTime? lastUpdated,
  }) {
    return PricingCalculationState(
      isCalculating: isCalculating ?? this.isCalculating,
      calculation: calculation ?? this.calculation,
      errorMessage: errorMessage ?? this.errorMessage,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Notifier for pricing calculation state
class PricingCalculationNotifier
    extends StateNotifier<PricingCalculationState> {
  final Ref ref;

  PricingCalculationNotifier(this.ref) : super(const PricingCalculationState());

  /// Calculate pricing for a delivery request
  Future<void> calculatePricing(PricingRequest request) async {
    state = state.copyWith(
      isCalculating: true,
      errorMessage: null,
    );

    try {
      final calculation =
          await ref.read(pricingCalculationProvider(request).future);

      state = state.copyWith(
        isCalculating: false,
        calculation: calculation,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Update pricing request and recalculate
  Future<void> updateRequest(PricingRequest request) async {
    ref.read(currentPricingRequestProvider.notifier).state = request;
    await calculatePricing(request);
  }

  /// Clear current calculation
  void clearCalculation() {
    state = const PricingCalculationState();
    ref.read(currentPricingRequestProvider.notifier).state = null;
  }

  /// Get current pricing if available
  PricingCalculation? get currentPricing => state.calculation;

  /// Check if pricing is being calculated
  bool get isCalculating => state.isCalculating;

  /// Get last error message
  String? get errorMessage => state.errorMessage;
}

// ==================== FILTERED PROVIDERS ====================

/// Provider for zones within a specific radius of a location
final zonesInRadiusProvider =
    FutureProvider.family<List<PricingZone>, ZoneRadiusRequest>(
        (ref, request) async {
  final zones = ref.watch(activePricingZonesProvider);
  return zones.where((zone) {
    final distance = PricingService.calculateDistance(
      lat1: request.latitude,
      lon1: request.longitude,
      lat2: zone.centerLatitude,
      lon2: zone.centerLongitude,
    );
    return distance <= request.radiusKm;
  }).toList();
});

/// Provider for cheapest pricing option
final cheapestPricingProvider =
    FutureProvider.family<PricingCalculation?, PricingRequest>(
        (ref, request) async {
  try {
    return await PricingService.findCheapestPricing(
      pickupLatitude: request.pickupLatitude,
      pickupLongitude: request.pickupLongitude,
      deliveryLatitude: request.deliveryLatitude,
      deliveryLongitude: request.deliveryLongitude,
    );
  } catch (e) {
    return null;
  }
});

/// Provider for fastest delivery option
final fastestDeliveryProvider =
    FutureProvider.family<PricingCalculation?, PricingRequest>(
        (ref, request) async {
  try {
    return await PricingService.findFastestDelivery(
      pickupLatitude: request.pickupLatitude,
      pickupLongitude: request.pickupLongitude,
      deliveryLatitude: request.deliveryLatitude,
      deliveryLongitude: request.deliveryLongitude,
    );
  } catch (e) {
    return null;
  }
});

class ZoneRadiusRequest {
  final double latitude;
  final double longitude;
  final double radiusKm;

  const ZoneRadiusRequest({
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
  });
}
