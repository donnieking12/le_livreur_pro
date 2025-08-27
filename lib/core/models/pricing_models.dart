// lib/core/models/pricing_models.dart - Comprehensive pricing models for zone-based delivery pricing

enum PriorityLevel {
  normal,
  urgent,
  express,
}

enum CommissionType {
  percentage,
  fixed,
  tiered,
}

enum PricingZoneType {
  urban,
  suburban,
  rural,
}

/// Zone-based pricing model for different areas in Côte d'Ivoire
class PricingZone {
  final String id;
  final String name;
  final String cityCode;
  final PricingZoneType type;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusKm;
  final int basePriceXof;
  final int pricePerKmXof;
  final bool isActive;
  final List<PricingModifier> modifiers;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PricingZone({
    required this.id,
    required this.name,
    required this.cityCode,
    required this.type,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
    required this.basePriceXof,
    required this.pricePerKmXof,
    required this.isActive,
    required this.modifiers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PricingZone.fromJson(Map<String, dynamic> json) {
    return PricingZone(
      id: json['id'] as String,
      name: json['name'] as String,
      cityCode: json['city_code'] as String,
      type: PricingZoneType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PricingZoneType.urban,
      ),
      centerLatitude: (json['center_latitude'] as num).toDouble(),
      centerLongitude: (json['center_longitude'] as num).toDouble(),
      radiusKm: (json['radius_km'] as num).toDouble(),
      basePriceXof: json['base_price_xof'] as int,
      pricePerKmXof: json['price_per_km_xof'] as int,
      isActive: json['is_active'] as bool,
      modifiers: (json['modifiers'] as List?)
              ?.map((m) => PricingModifier.fromJson(m))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city_code': cityCode,
      'type': type.name,
      'center_latitude': centerLatitude,
      'center_longitude': centerLongitude,
      'radius_km': radiusKm,
      'base_price_xof': basePriceXof,
      'price_per_km_xof': pricePerKmXof,
      'is_active': isActive,
      'modifiers': modifiers.map((m) => m.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Static zones for Côte d'Ivoire major cities
  static List<PricingZone> get defaultZones => [
        PricingZone(
          id: 'abidjan-central',
          name: 'Abidjan Centre',
          cityCode: 'ABJ',
          type: PricingZoneType.urban,
          centerLatitude: 5.3600,
          centerLongitude: -4.0083,
          radiusKm: 5.0,
          basePriceXof: 500,
          pricePerKmXof: 100,
          isActive: true,
          modifiers: [
            PricingModifier.urgent(),
            PricingModifier.express(),
            PricingModifier.fragile(),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PricingZone(
          id: 'bouake-central',
          name: 'Bouaké Centre',
          cityCode: 'BKE',
          type: PricingZoneType.urban,
          centerLatitude: 7.6900,
          centerLongitude: -5.0300,
          radiusKm: 3.0,
          basePriceXof: 400,
          pricePerKmXof: 80,
          isActive: true,
          modifiers: [
            PricingModifier.urgent(),
            PricingModifier.express(),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PricingZone(
          id: 'yamoussoukro-central',
          name: 'Yamoussoukro Centre',
          cityCode: 'YAM',
          type: PricingZoneType.urban,
          centerLatitude: 6.8276,
          centerLongitude: -5.2893,
          radiusKm: 4.0,
          basePriceXof: 450,
          pricePerKmXof: 90,
          isActive: true,
          modifiers: [
            PricingModifier.urgent(),
            PricingModifier.express(),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        PricingZone(
          id: 'san-pedro-central',
          name: 'San-Pédro Centre',
          cityCode: 'SPD',
          type: PricingZoneType.urban,
          centerLatitude: 4.7467,
          centerLongitude: -6.6364,
          radiusKm: 4.5,
          basePriceXof: 500,
          pricePerKmXof: 100,
          isActive: true,
          modifiers: [
            PricingModifier.urgent(),
            PricingModifier.fragile(),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
}

/// Pricing modifiers for special conditions
class PricingModifier {
  final String id;
  final String name;
  final String description;
  final CommissionType type;
  final double value; // Percentage (0.0-1.0) or fixed amount
  final bool isActive;
  final List<String> applicableConditions;

  const PricingModifier({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.isActive,
    required this.applicableConditions,
  });

  factory PricingModifier.fromJson(Map<String, dynamic> json) {
    return PricingModifier(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: CommissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CommissionType.percentage,
      ),
      value: (json['value'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      applicableConditions: List<String>.from(json['applicable_conditions']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'is_active': isActive,
      'applicable_conditions': applicableConditions,
    };
  }

  // Factory methods for common modifiers
  static PricingModifier urgent() => const PricingModifier(
        id: 'urgent-delivery',
        name: 'Livraison urgente',
        description: 'Supplément pour livraison urgente (2h)',
        type: CommissionType.fixed,
        value: 200.0,
        isActive: true,
        applicableConditions: ['priority_level_2'],
      );

  static PricingModifier express() => const PricingModifier(
        id: 'express-delivery',
        name: 'Livraison express',
        description: 'Supplément pour livraison express (1h)',
        type: CommissionType.fixed,
        value: 400.0,
        isActive: true,
        applicableConditions: ['priority_level_3'],
      );

  static PricingModifier fragile() => const PricingModifier(
        id: 'fragile-handling',
        name: 'Manipulation fragile',
        description: 'Supplément pour colis fragile',
        type: CommissionType.fixed,
        value: 200.0,
        isActive: true,
        applicableConditions: ['fragile'],
      );

  static PricingModifier nightDelivery() => const PricingModifier(
        id: 'night-delivery',
        name: 'Livraison nocturne',
        description: 'Supplément pour livraison de nuit (20h-6h)',
        type: CommissionType.percentage,
        value: 0.5, // 50% surcharge
        isActive: true,
        applicableConditions: ['night_hours'],
      );

  static PricingModifier weekendDelivery() => const PricingModifier(
        id: 'weekend-delivery',
        name: 'Livraison week-end',
        description: 'Supplément pour livraison week-end',
        type: CommissionType.percentage,
        value: 0.25, // 25% surcharge
        isActive: true,
        applicableConditions: ['weekend'],
      );
}

/// Commission structure for platform earnings
class CommissionStructure {
  final String id;
  final String name;
  final CommissionType type;
  final double rate; // Platform commission rate (0.10 = 10%)
  final double minimumCommissionXof;
  final double maximumCommissionXof;
  final List<CommissionTier> tiers;
  final Map<String, double> categoryRates;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;

  const CommissionStructure({
    required this.id,
    required this.name,
    required this.type,
    required this.rate,
    required this.minimumCommissionXof,
    required this.maximumCommissionXof,
    required this.tiers,
    required this.categoryRates,
    required this.isActive,
    required this.effectiveFrom,
    this.effectiveUntil,
  });

  factory CommissionStructure.fromJson(Map<String, dynamic> json) {
    return CommissionStructure(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CommissionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CommissionType.percentage,
      ),
      rate: (json['rate'] as num).toDouble(),
      minimumCommissionXof: (json['minimum_commission_xof'] as num).toDouble(),
      maximumCommissionXof: (json['maximum_commission_xof'] as num).toDouble(),
      tiers: (json['tiers'] as List?)
              ?.map((t) => CommissionTier.fromJson(t))
              .toList() ??
          [],
      categoryRates: Map<String, double>.from(json['category_rates'] ?? {}),
      isActive: json['is_active'] as bool,
      effectiveFrom: DateTime.parse(json['effective_from'] as String),
      effectiveUntil: json['effective_until'] != null
          ? DateTime.parse(json['effective_until'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'rate': rate,
      'minimum_commission_xof': minimumCommissionXof,
      'maximum_commission_xof': maximumCommissionXof,
      'tiers': tiers.map((t) => t.toJson()).toList(),
      'category_rates': categoryRates,
      'is_active': isActive,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_until': effectiveUntil?.toIso8601String(),
    };
  }

  // Default commission structure for Côte d'Ivoire
  static CommissionStructure get defaultStructure => CommissionStructure(
        id: 'ci-default-commission',
        name: 'Commission Standard Côte d\'Ivoire',
        type: CommissionType.percentage,
        rate: 0.10, // 10% platform commission
        minimumCommissionXof: 50.0,
        maximumCommissionXof: 1000.0,
        tiers: [],
        categoryRates: {
          'package': 0.10, // 10% for package delivery
          'food': 0.15, // 15% for food delivery
          'pharmacy': 0.12, // 12% for pharmacy delivery
          'grocery': 0.08, // 8% for grocery delivery
        },
        isActive: true,
        effectiveFrom: DateTime.now(),
      );

  /// Calculate commission for a given amount and category
  double calculateCommission(double amount, [String? category]) {
    final double effectiveRate =
        category != null ? (categoryRates[category] ?? rate) : rate;

    double commission = amount * effectiveRate;

    // Apply min/max limits
    if (commission < minimumCommissionXof) {
      commission = minimumCommissionXof;
    } else if (commission > maximumCommissionXof) {
      commission = maximumCommissionXof;
    }

    return commission;
  }

  /// Get net amount after commission deduction
  double getNetAmount(double amount, [String? category]) {
    return amount - calculateCommission(amount, category);
  }
}

/// Tiered commission structure
class CommissionTier {
  final String id;
  final String name;
  final double minimumAmountXof;
  final double maximumAmountXof;
  final double rate;
  final bool isActive;

  const CommissionTier({
    required this.id,
    required this.name,
    required this.minimumAmountXof,
    required this.maximumAmountXof,
    required this.rate,
    required this.isActive,
  });

  factory CommissionTier.fromJson(Map<String, dynamic> json) {
    return CommissionTier(
      id: json['id'] as String,
      name: json['name'] as String,
      minimumAmountXof: (json['minimum_amount_xof'] as num).toDouble(),
      maximumAmountXof: (json['maximum_amount_xof'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      isActive: json['is_active'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minimum_amount_xof': minimumAmountXof,
      'maximum_amount_xof': maximumAmountXof,
      'rate': rate,
      'is_active': isActive,
    };
  }
}

/// Comprehensive pricing calculation result
class PricingCalculation {
  final double totalDistance;
  final PricingZone zone;
  final int basePriceXof;
  final int distancePriceXof;
  final List<AppliedModifier> appliedModifiers;
  final int subtotalXof;
  final double platformCommission;
  final int totalPriceXof;
  final int courierEarningsXof;
  final String currency;
  final Duration estimatedDuration;
  final Map<String, dynamic> breakdown;
  final DateTime calculatedAt;

  const PricingCalculation({
    required this.totalDistance,
    required this.zone,
    required this.basePriceXof,
    required this.distancePriceXof,
    required this.appliedModifiers,
    required this.subtotalXof,
    required this.platformCommission,
    required this.totalPriceXof,
    required this.courierEarningsXof,
    required this.currency,
    required this.estimatedDuration,
    required this.breakdown,
    required this.calculatedAt,
  });

  factory PricingCalculation.fromJson(Map<String, dynamic> json) {
    return PricingCalculation(
      totalDistance: (json['total_distance'] as num).toDouble(),
      zone: PricingZone.fromJson(json['zone']),
      basePriceXof: json['base_price_xof'] as int,
      distancePriceXof: json['distance_price_xof'] as int,
      appliedModifiers: (json['applied_modifiers'] as List)
          .map((m) => AppliedModifier.fromJson(m))
          .toList(),
      subtotalXof: json['subtotal_xof'] as int,
      platformCommission: (json['platform_commission'] as num).toDouble(),
      totalPriceXof: json['total_price_xof'] as int,
      courierEarningsXof: json['courier_earnings_xof'] as int,
      currency: json['currency'] as String,
      estimatedDuration:
          Duration(seconds: json['estimated_duration_seconds'] as int),
      breakdown: Map<String, dynamic>.from(json['breakdown']),
      calculatedAt: DateTime.parse(json['calculated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_distance': totalDistance,
      'zone': zone.toJson(),
      'base_price_xof': basePriceXof,
      'distance_price_xof': distancePriceXof,
      'applied_modifiers': appliedModifiers.map((m) => m.toJson()).toList(),
      'subtotal_xof': subtotalXof,
      'platform_commission': platformCommission,
      'total_price_xof': totalPriceXof,
      'courier_earnings_xof': courierEarningsXof,
      'currency': currency,
      'estimated_duration_seconds': estimatedDuration.inSeconds,
      'breakdown': breakdown,
      'calculated_at': calculatedAt.toIso8601String(),
    };
  }
}

/// Applied modifier with calculated amount
class AppliedModifier {
  final PricingModifier modifier;
  final int calculatedAmountXof;
  final String reason;

  const AppliedModifier({
    required this.modifier,
    required this.calculatedAmountXof,
    required this.reason,
  });

  factory AppliedModifier.fromJson(Map<String, dynamic> json) {
    return AppliedModifier(
      modifier: PricingModifier.fromJson(json['modifier']),
      calculatedAmountXof: json['calculated_amount_xof'] as int,
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modifier': modifier.toJson(),
      'calculated_amount_xof': calculatedAmountXof,
      'reason': reason,
    };
  }
}
