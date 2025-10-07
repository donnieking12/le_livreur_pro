// lib/core/services/pricing_service.dart - Comprehensive pricing service with commission system
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/models/pricing_models.dart';

class PricingService {
  static final _supabase = Supabase.instance.client;

  // Commission configuration
  static const double _platformCommissionRate = 0.10; // 10% platform commission

  // Zone-based pricing configuration for different cities in Côte d'Ivoire
  static const Map<String, double> cityBaseZones = {
    'abidjan': 5.0, // 5km base zone for Abidjan
    'bouake': 3.0, // 3km base zone for Bouaké
    'yamoussoukro': 4.0, // 4km base zone for Yamoussoukro
    'san_pedro': 4.5, // 4.5km base zone for San-Pédro
    'korhogo': 2.5, // 2.5km base zone for Korhogo
    'default': 4.5, // Default 4.5km base zone
  };

  // Base price configuration
  static const int basePriceXof = 500; // 500 XOF base price
  static const int pricePerKmBeyondZone =
      100; // 100 XOF per km beyond base zone
  static const int urgentSurcharge = 200; // 200 XOF for urgent delivery
  static const int expressSurcharge = 400; // 400 XOF for express delivery
  static const int fragileSurcharge = 200; // 200 XOF for fragile items

  /// Calculate total delivery price using zone-based pricing
  static int calculateDeliveryPrice({
    required double distanceKm,
    double? baseZoneRadiusKm,
    String? cityCode,
    int priorityLevel = 1, // 1=normal, 2=urgent, 3=express
    bool fragile = false,
  }) {
    // Determine base zone radius
    final double effectiveBaseZone = baseZoneRadiusKm ??
        cityBaseZones[cityCode?.toLowerCase()] ??
        cityBaseZones['default']!;

    // Calculate price components
    const int basePriceComponent = basePriceXof;

    // Only charge for distance beyond the base zone
    final double additionalDistance =
        distanceKm > effectiveBaseZone ? distanceKm - effectiveBaseZone : 0.0;
    final int distancePriceComponent =
        (additionalDistance * pricePerKmBeyondZone).round();

    // Priority surcharge
    final int priorityPriceComponent =
        _calculatePrioritySurcharge(priorityLevel);

    // Fragile surcharge
    final int fragilePriceComponent = fragile ? fragileSurcharge : 0;

    final int totalPrice = basePriceComponent +
        distancePriceComponent +
        priorityPriceComponent +
        fragilePriceComponent;

    return totalPrice;
  }

  /// Calculate priority surcharge based on priority level
  static int _calculatePrioritySurcharge(int priorityLevel) {
    switch (priorityLevel) {
      case 1:
        return 0; // Normal delivery - no surcharge
      case 2:
        return urgentSurcharge; // Urgent delivery
      case 3:
        return expressSurcharge; // Express delivery
      default:
        return 0;
    }
  }

  /// Get pricing breakdown for display to users
  static Map<String, dynamic> getPricingBreakdown({
    required double distanceKm,
    double? baseZoneRadiusKm,
    String? cityCode,
    int priorityLevel = 1,
    bool fragile = false,
  }) {
    final double effectiveBaseZone = baseZoneRadiusKm ??
        cityBaseZones[cityCode?.toLowerCase()] ??
        cityBaseZones['default']!;

    final double additionalDistance =
        distanceKm > effectiveBaseZone ? distanceKm - effectiveBaseZone : 0.0;

    const int basePriceComponent = basePriceXof;
    final int distancePriceComponent =
        (additionalDistance * pricePerKmBeyondZone).round();
    final int priorityPriceComponent =
        _calculatePrioritySurcharge(priorityLevel);
    final int fragilePriceComponent = fragile ? fragileSurcharge : 0;
    final int totalPrice = basePriceComponent +
        distancePriceComponent +
        priorityPriceComponent +
        fragilePriceComponent;

    return {
      'basePrice': basePriceComponent,
      'basePriceDescription':
          'Prix de base (couvre ${effectiveBaseZone.toStringAsFixed(1)} km)',
      'distancePrice': distancePriceComponent,
      'distancePriceDescription': additionalDistance > 0
          ? 'Distance supplémentaire (${additionalDistance.toStringAsFixed(1)} km × $pricePerKmBeyondZone XOF)'
          : 'Aucun frais de distance (dans la zone de base)',
      'priorityPrice': priorityPriceComponent,
      'priorityPriceDescription': _getPriorityDescription(priorityLevel),
      'fragilePrice': fragilePriceComponent,
      'fragilePriceDescription':
          fragile ? 'Manipulation fragile' : 'Aucun frais de fragilité',
      'totalPrice': totalPrice,
      'currency': 'XOF',
      'withinBaseZone': distanceKm <= effectiveBaseZone,
      'baseZoneRadius': effectiveBaseZone,
      'totalDistance': distanceKm,
      'additionalDistance': additionalDistance,
    };
  }

  /// Get priority level description in French
  static String _getPriorityDescription(int priorityLevel) {
    switch (priorityLevel) {
      case 1:
        return 'Livraison normale';
      case 2:
        return 'Livraison urgente (+$urgentSurcharge XOF)';
      case 3:
        return 'Livraison express (+$expressSurcharge XOF)';
      default:
        return 'Livraison normale';
    }
  }

  /// Generate order number with city prefix
  static String generateOrderNumber({String? cityCode}) {
    final now = DateTime.now();
    final year = now.year;
    final dayOfYear = now.difference(DateTime(year, 1, 1)).inDays + 1;
    final timestamp = now.millisecondsSinceEpoch;

    final String cityPrefix = cityCode?.toUpperCase() ?? 'CI';

    return '$cityPrefix-$year-${dayOfYear.toString().padLeft(3, '0')}-${timestamp.toString().substring(timestamp.toString().length - 6)}';
  }

  /// Calculate distance between two points using Haversine formula
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadius = 6371; // Earth's radius in km

    final double lat1Rad = lat1 * (pi / 180);
    final double lon1Rad = lon1 * (pi / 180);
    final double lat2Rad = lat2 * (pi / 180);
    final double lon2Rad = lon2 * (pi / 180);

    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Estimate delivery time based on distance and priority
  static Duration estimateDeliveryTime({
    required double distanceKm,
    int priorityLevel = 1,
    bool isTrafficHour = false,
  }) {
    // Base time: 30 minutes + 5 minutes per km
    const int baseMinutes = 30;
    const int timePerKm = 5;

    // Traffic adjustment
    final double trafficMultiplier = isTrafficHour ? 1.5 : 1.0;

    // Priority adjustment
    final double priorityMultiplier =
        priorityLevel == 3 ? 0.7 : 1.0; // Express is faster

    final int totalMinutes = ((baseMinutes + (distanceKm * timePerKm)) *
            trafficMultiplier *
            priorityMultiplier)
        .round();

    return Duration(minutes: totalMinutes);
  }

  // ==================== COMPREHENSIVE PRICING ENGINE ====================

  /// Get all pricing zones from database or fallback to default zones
  static Future<List<PricingZone>> getAllPricingZones() async {
    try {
      final response = await _supabase.from('pricing_zones').select('*');
      return (response as List)
          .map((json) => PricingZone.fromJson(json))
          .toList();
    } catch (e) {
      // Fallback to default zones if database is not available
      return PricingZone.defaultZones;
    }
  }

  /// Find the appropriate pricing zone for given coordinates
  static Future<PricingZone?> findPricingZoneForLocation(
    double latitude,
    double longitude,
  ) async {
    final zones = await getAllPricingZones();

    for (final zone in zones) {
      if (!zone.isActive) continue;

      final distance = calculateDistance(
        lat1: latitude,
        lon1: longitude,
        lat2: zone.centerLatitude,
        lon2: zone.centerLongitude,
      );

      if (distance <= zone.radiusKm) {
        return zone;
      }
    }

    return null; // No zone found
  }

  /// Get current commission structure
  static Future<CommissionStructure> getCommissionStructure() async {
    try {
      final response = await _supabase
          .from('commission_structures')
          .select('*')
          .eq('is_active', true)
          .order('effective_from', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return CommissionStructure.fromJson(response);
      }
    } catch (e) {
      // Fallback to default structure
    }

    return CommissionStructure.defaultStructure;
  }

  /// Comprehensive pricing calculation with commission
  static Future<PricingCalculation> calculatePricing({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
    PriorityLevel priorityLevel = PriorityLevel.normal,
    bool fragile = false,
    bool isWeekend = false,
    bool isNightDelivery = false,
    String? categoryCode,
  }) async {
    // Calculate total distance
    final distance = calculateDistance(
      lat1: pickupLatitude,
      lon1: pickupLongitude,
      lat2: deliveryLatitude,
      lon2: deliveryLongitude,
    );

    // Find pricing zone for pickup location
    final zone =
        await findPricingZoneForLocation(pickupLatitude, pickupLongitude) ??
            PricingZone.defaultZones.first;

    // Calculate base and distance pricing
    final basePriceXof = zone.basePriceXof;
    final additionalDistance = max(0.0, distance - zone.radiusKm);
    final distancePriceXof = (additionalDistance * zone.pricePerKmXof).round();

    // Apply modifiers
    final appliedModifiers = <AppliedModifier>[];
    int modifiersTotal = 0;

    // Priority level modifiers
    if (priorityLevel == PriorityLevel.urgent) {
      final modifier = PricingModifier.urgent();
      final amount = modifier.value.round();
      appliedModifiers.add(AppliedModifier(
        modifier: modifier,
        calculatedAmountXof: amount,
        reason: 'Livraison urgente demandée',
      ));
      modifiersTotal += amount;
    } else if (priorityLevel == PriorityLevel.express) {
      final modifier = PricingModifier.express();
      final amount = modifier.value.round();
      appliedModifiers.add(AppliedModifier(
        modifier: modifier,
        calculatedAmountXof: amount,
        reason: 'Livraison express demandée',
      ));
      modifiersTotal += amount;
    }

    // Fragile modifier
    if (fragile) {
      final modifier = PricingModifier.fragile();
      final amount = modifier.value.round();
      appliedModifiers.add(AppliedModifier(
        modifier: modifier,
        calculatedAmountXof: amount,
        reason: 'Colis fragile',
      ));
      modifiersTotal += amount;
    }

    // Weekend modifier
    if (isWeekend) {
      final modifier = PricingModifier.weekendDelivery();
      final subtotal = basePriceXof + distancePriceXof;
      final amount = (subtotal * modifier.value).round();
      appliedModifiers.add(AppliedModifier(
        modifier: modifier,
        calculatedAmountXof: amount,
        reason: 'Livraison week-end',
      ));
      modifiersTotal += amount;
    }

    // Night delivery modifier
    if (isNightDelivery) {
      final modifier = PricingModifier.nightDelivery();
      final subtotal = basePriceXof + distancePriceXof;
      final amount = (subtotal * modifier.value).round();
      appliedModifiers.add(AppliedModifier(
        modifier: modifier,
        calculatedAmountXof: amount,
        reason: 'Livraison nocturne',
      ));
      modifiersTotal += amount;
    }

    // Calculate subtotal
    final subtotalXof = basePriceXof + distancePriceXof + modifiersTotal;

    // Calculate commission
    final commissionStructure = await getCommissionStructure();
    final platformCommission = commissionStructure.calculateCommission(
      subtotalXof.toDouble(),
      categoryCode,
    );

    // Calculate final amounts
    final totalPriceXof = subtotalXof;
    final courierEarningsXof = (subtotalXof - platformCommission).round();

    // Estimate delivery time
    final estimatedDuration = estimateDeliveryTime(
      distanceKm: distance,
      priorityLevel: priorityLevel.index + 1,
      isTrafficHour: isNightDelivery,
    );

    // Create breakdown
    final breakdown = {
      'distance_km': distance,
      'zone_name': zone.name,
      'base_price': basePriceXof,
      'distance_price': distancePriceXof,
      'modifiers': appliedModifiers
          .map((m) => {
                'name': m.modifier.name,
                'amount': m.calculatedAmountXof,
                'reason': m.reason,
              })
          .toList(),
      'subtotal': subtotalXof,
      'platform_commission': platformCommission,
      'commission_rate': commissionStructure.rate,
      'courier_earnings': courierEarningsXof,
      'estimated_duration_minutes': estimatedDuration.inMinutes,
      'currency': 'XOF',
    };

    return PricingCalculation(
      totalDistance: distance,
      zone: zone,
      basePriceXof: basePriceXof,
      distancePriceXof: distancePriceXof,
      appliedModifiers: appliedModifiers,
      subtotalXof: subtotalXof,
      platformCommission: platformCommission,
      totalPriceXof: totalPriceXof,
      courierEarningsXof: courierEarningsXof,
      currency: 'XOF',
      estimatedDuration: estimatedDuration,
      breakdown: breakdown,
      calculatedAt: DateTime.now(),
    );
  }

  /// Find cheapest pricing option
  static Future<PricingCalculation?> findCheapestPricing({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    // Calculate normal priority pricing
    return await calculatePricing(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      priorityLevel: PriorityLevel.normal,
      fragile: false,
      isWeekend: false,
      isNightDelivery: false,
    );
  }

  /// Find fastest delivery option
  static Future<PricingCalculation?> findFastestDelivery({
    required double pickupLatitude,
    required double pickupLongitude,
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    // Calculate express priority pricing
    return await calculatePricing(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      priorityLevel: PriorityLevel.express,
      fragile: false,
      isWeekend: false,
      isNightDelivery: false,
    );
  }

  // ==================== ANALYTICS AND REPORTING ====================

  /// Get pricing analytics
  static Future<Map<String, dynamic>> getPricingAnalytics() async {
    try {
      // This would typically query the database for real analytics
      return {
        'total_orders_today': 45,
        'average_order_value': 1250.0,
        'total_commission_earned': 5625.0,
        'popular_zones': [
          {'zone': 'Abidjan Centre', 'orders': 28},
          {'zone': 'Bouaké Centre', 'orders': 12},
          {'zone': 'San-Pédro Centre', 'orders': 5},
        ],
        'commission_by_category': {
          'package': 3200.0,
          'food': 1800.0,
          'pharmacy': 625.0,
        },
        'peak_hours': [
          {'hour': '12:00-13:00', 'orders': 15},
          {'hour': '18:00-19:00', 'orders': 12},
          {'hour': '20:00-21:00', 'orders': 8},
        ],
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'total_orders_today': 0,
        'average_order_value': 0.0,
        'total_commission_earned': 0.0,
      };
    }
  }

  /// Get zone performance metrics
  static Future<Map<String, dynamic>> getZonePerformanceMetrics(
      String zoneId) async {
    try {
      // This would typically query the database for real metrics
      return {
        'zone_id': zoneId,
        'total_orders': 156,
        'successful_deliveries': 148,
        'success_rate': 0.949,
        'average_delivery_time_minutes': 32,
        'total_revenue': 78000.0,
        'total_commission': 7800.0,
        'popular_times': [
          '12:00-14:00',
          '18:00-20:00',
        ],
        'courier_count': 12,
        'average_rating': 4.6,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'zone_id': zoneId,
        'total_orders': 0,
      };
    }
  }

  /// Get commission earnings for a period
  static Future<Map<String, dynamic>> getCommissionEarnings(
      String period) async {
    try {
      // This would typically query the database for real earnings
      return {
        'period': period,
        'total_commission': 45600.0,
        'total_orders': 456,
        'average_commission_per_order': 100.0,
        'commission_by_day': [
          {'date': '2024-01-01', 'commission': 6500.0, 'orders': 65},
          {'date': '2024-01-02', 'commission': 7200.0, 'orders': 72},
          {'date': '2024-01-03', 'commission': 5800.0, 'orders': 58},
        ],
        'top_categories': [
          {'category': 'food', 'commission': 18240.0, 'percentage': 0.40},
          {'category': 'package', 'commission': 13680.0, 'percentage': 0.30},
          {'category': 'pharmacy', 'commission': 9120.0, 'percentage': 0.20},
          {'category': 'grocery', 'commission': 4560.0, 'percentage': 0.10},
        ],
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'period': period,
        'total_commission': 0.0,
      };
    }
  }
}
