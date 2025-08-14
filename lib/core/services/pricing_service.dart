// lib/core/services/pricing_service.dart - Complete corrected file
import 'dart:math'; // FIXED: Added missing import for sin, cos, sqrt functions

class PricingService {
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
    double effectiveBaseZone = baseZoneRadiusKm ??
        cityBaseZones[cityCode?.toLowerCase()] ??
        cityBaseZones['default']!;

    // Calculate price components
    int basePriceComponent = basePriceXof;

    // Only charge for distance beyond the base zone
    double additionalDistance =
        distanceKm > effectiveBaseZone ? distanceKm - effectiveBaseZone : 0.0;
    int distancePriceComponent =
        (additionalDistance * pricePerKmBeyondZone).round();

    // Priority surcharge
    int priorityPriceComponent = _calculatePrioritySurcharge(priorityLevel);

    // Fragile surcharge
    int fragilePriceComponent = fragile ? fragileSurcharge : 0;

    int totalPrice = basePriceComponent +
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
    double effectiveBaseZone = baseZoneRadiusKm ??
        cityBaseZones[cityCode?.toLowerCase()] ??
        cityBaseZones['default']!;

    double additionalDistance =
        distanceKm > effectiveBaseZone ? distanceKm - effectiveBaseZone : 0.0;

    int basePriceComponent = basePriceXof;
    int distancePriceComponent =
        (additionalDistance * pricePerKmBeyondZone).round();
    int priorityPriceComponent = _calculatePrioritySurcharge(priorityLevel);
    int fragilePriceComponent = fragile ? fragileSurcharge : 0;
    int totalPrice = basePriceComponent +
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

    String cityPrefix = cityCode?.toUpperCase() ?? 'CI';

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

    double lat1Rad = lat1 * (pi / 180);
    double lon1Rad = lon1 * (pi / 180);
    double lat2Rad = lat2 * (pi / 180);
    double lon2Rad = lon2 * (pi / 180);

    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  /// Estimate delivery time based on distance and priority
  static Duration estimateDeliveryTime({
    required double distanceKm,
    int priorityLevel = 1,
    bool isTrafficHour = false,
  }) {
    // Base time: 30 minutes + 5 minutes per km
    int baseMinutes = 30;
    int timePerKm = 5;

    // Traffic adjustment
    double trafficMultiplier = isTrafficHour ? 1.5 : 1.0;

    // Priority adjustment
    double priorityMultiplier =
        priorityLevel == 3 ? 0.7 : 1.0; // Express is faster

    int totalMinutes = ((baseMinutes + (distanceKm * timePerKm)) *
            trafficMultiplier *
            priorityMultiplier)
        .round();

    return Duration(minutes: totalMinutes);
  }
}
