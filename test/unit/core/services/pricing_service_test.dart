// test/unit/core/services/pricing_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:le_livreur_pro/core/services/pricing_service.dart';
import 'package:le_livreur_pro/core/models/pricing_models.dart';

void main() {
  group('PricingService', () {
    group('Distance Calculation', () {
      test('should calculate distance between two points correctly', () {
        // Test distance between Abidjan and Bouaké (approximately 282km actual)
        final distance = PricingService.calculateDistance(
          lat1: 5.3600, // Abidjan
          lon1: -4.0083,
          lat2: 7.6900, // Bouaké
          lon2: -5.0300,
        );

        expect(distance, closeTo(282, 50)); // Corrected expected distance
      });

      test('should return 0 for same coordinates', () {
        final distance = PricingService.calculateDistance(
          lat1: 5.3600,
          lon1: -4.0083,
          lat2: 5.3600,
          lon2: -4.0083,
        );

        expect(distance, closeTo(0, 0.1));
      });
    });

    group('Basic Pricing Calculation', () {
      test('should calculate basic delivery price within zone', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 3.0, // Within base zone
          cityCode: 'abidjan',
          priorityLevel: 1,
          fragile: false,
        );

        expect(price, equals(500)); // Base price only
      });

      test('should add distance price beyond base zone', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 7.0, // 2km beyond 5km base zone for Abidjan
          cityCode: 'abidjan',
          priorityLevel: 1,
          fragile: false,
        );

        expect(price, equals(700)); // 500 base + 200 (2km × 100 XOF/km)
      });

      test('should apply urgent delivery surcharge', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 3.0,
          cityCode: 'abidjan',
          priorityLevel: 2, // Urgent
          fragile: false,
        );

        expect(price, equals(700)); // 500 base + 200 urgent
      });

      test('should apply express delivery surcharge', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 3.0,
          cityCode: 'abidjan',
          priorityLevel: 3, // Express
          fragile: false,
        );

        expect(price, equals(900)); // 500 base + 400 express
      });

      test('should apply fragile item surcharge', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 3.0,
          cityCode: 'abidjan',
          priorityLevel: 1,
          fragile: true,
        );

        expect(price, equals(700)); // 500 base + 200 fragile
      });

      test('should combine all surcharges correctly', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 7.0, // 2km beyond base zone
          cityCode: 'abidjan',
          priorityLevel: 3, // Express
          fragile: true,
        );

        expect(
            price,
            equals(
                1300)); // 500 base + 200 distance + 400 express + 200 fragile
      });
    });

    group('City-specific Pricing', () {
      test('should use correct base zone for different cities', () {
        final abidjanPrice = PricingService.calculateDeliveryPrice(
          distanceKm: 4.0,
          cityCode: 'abidjan', // 5km base zone
          priorityLevel: 1,
          fragile: false,
        );

        final bouakePrice = PricingService.calculateDeliveryPrice(
          distanceKm: 4.0,
          cityCode: 'bouake', // 3km base zone
          priorityLevel: 1,
          fragile: false,
        );

        expect(abidjanPrice, equals(500)); // Within base zone
        expect(
            bouakePrice, equals(600)); // 500 base + 100 (1km beyond 3km base)
      });

      test('should use default zone for unknown cities', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 5.0,
          cityCode: 'unknown_city',
          priorityLevel: 1,
          fragile: false,
        );

        expect(price,
            equals(550)); // 500 base + 50 (0.5km beyond 4.5km default base)
      });
    });

    group('Pricing Breakdown', () {
      test('should provide detailed pricing breakdown', () {
        final breakdown = PricingService.getPricingBreakdown(
          distanceKm: 7.0,
          cityCode: 'abidjan',
          priorityLevel: 2,
          fragile: true,
        );

        expect(breakdown['basePrice'], equals(500));
        expect(breakdown['distancePrice'], equals(200));
        expect(breakdown['priorityPrice'], equals(200)); // Urgent = 200 XOF
        expect(breakdown['fragilePrice'], equals(200));
        expect(breakdown['totalPrice'], equals(1100)); // 500 + 200 + 200 + 200 = 1100
        expect(breakdown['currency'], equals('XOF'));
        expect(breakdown['withinBaseZone'], isFalse);
        expect(breakdown['totalDistance'], equals(7.0));
        expect(breakdown['additionalDistance'], equals(2.0));
      });

      test('should provide correct descriptions', () {
        final breakdown = PricingService.getPricingBreakdown(
          distanceKm: 3.0,
          cityCode: 'abidjan',
          priorityLevel: 1,
          fragile: false,
        );

        expect(breakdown['basePriceDescription'], contains('Prix de base'));
        expect(breakdown['distancePriceDescription'],
            contains('Aucun frais de distance'));
        expect(
            breakdown['priorityPriceDescription'], equals('Livraison normale'));
        expect(breakdown['fragilePriceDescription'],
            equals('Aucun frais de fragilité'));
      });
    });

    group('Order Number Generation', () {
      test('should generate valid order number format', () {
        final orderNumber = PricingService.generateOrderNumber(cityCode: 'ABJ');

        expect(orderNumber, matches(r'^ABJ-\d{4}-\d{3}-\d{6}$'));
      });

      test('should use default prefix for null city code', () {
        final orderNumber = PricingService.generateOrderNumber();

        expect(orderNumber, matches(r'^CI-\d{4}-\d{3}-\d{6}$'));
      });

      test('should generate unique order numbers', () async {
        final orderNumber1 =
            PricingService.generateOrderNumber(cityCode: 'ABJ');
        
        // Add small delay to ensure different timestamps
        await Future.delayed(Duration(milliseconds: 1));
        
        final orderNumber2 =
            PricingService.generateOrderNumber(cityCode: 'ABJ');

        expect(orderNumber1, isNot(equals(orderNumber2)));
      });
    });

    group('Delivery Time Estimation', () {
      test('should estimate delivery time correctly', () {
        final duration = PricingService.estimateDeliveryTime(
          distanceKm: 10.0,
          priorityLevel: 1,
          isTrafficHour: false,
        );

        expect(
            duration.inMinutes, equals(80)); // 30 base + 50 (10km × 5 min/km)
      });

      test('should adjust for traffic hours', () {
        final normalTime = PricingService.estimateDeliveryTime(
          distanceKm: 10.0,
          priorityLevel: 1,
          isTrafficHour: false,
        );

        final trafficTime = PricingService.estimateDeliveryTime(
          distanceKm: 10.0,
          priorityLevel: 1,
          isTrafficHour: true,
        );

        expect(trafficTime.inMinutes,
            equals((normalTime.inMinutes * 1.5).round()));
      });

      test('should adjust for express priority', () {
        final normalTime = PricingService.estimateDeliveryTime(
          distanceKm: 10.0,
          priorityLevel: 1,
          isTrafficHour: false,
        );

        final expressTime = PricingService.estimateDeliveryTime(
          distanceKm: 10.0,
          priorityLevel: 3, // Express
          isTrafficHour: false,
        );

        expect(expressTime.inMinutes,
            equals((normalTime.inMinutes * 0.7).round()));
      });
    });

    group('Edge Cases', () {
      test('should handle zero distance', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 0.0,
          priorityLevel: 1,
          fragile: false,
        );

        expect(price, equals(500)); // Base price only
      });

      test('should handle negative distance gracefully', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: -5.0,
          priorityLevel: 1,
          fragile: false,
        );

        expect(price, equals(500)); // Should treat as 0 distance
      });

      test('should handle invalid priority level', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 5.0,
          priorityLevel: 10, // Invalid
          fragile: false,
        );

        expect(price, equals(550)); // Should treat as normal priority
      });

      test('should handle very large distances', () {
        final price = PricingService.calculateDeliveryPrice(
          distanceKm: 1000.0,
          priorityLevel: 1,
          fragile: false,
        );

        expect(price, greaterThan(90000)); // Should be significantly high
      });
    });
  });

  group('PricingModifier', () {
    test('should create urgent modifier correctly', () {
      final modifier = PricingModifier.urgent();

      expect(modifier.name, equals('Livraison urgente'));
      expect(modifier.type, equals(CommissionType.fixed));
      expect(modifier.value, equals(200.0));
      expect(modifier.isActive, isTrue);
      expect(modifier.applicableConditions, contains('priority_level_2'));
    });

    test('should create express modifier correctly', () {
      final modifier = PricingModifier.express();

      expect(modifier.name, equals('Livraison express'));
      expect(modifier.type, equals(CommissionType.fixed));
      expect(modifier.value, equals(400.0));
      expect(modifier.isActive, isTrue);
      expect(modifier.applicableConditions, contains('priority_level_3'));
    });

    test('should create fragile modifier correctly', () {
      final modifier = PricingModifier.fragile();

      expect(modifier.name, equals('Manipulation fragile'));
      expect(modifier.type, equals(CommissionType.fixed));
      expect(modifier.value, equals(200.0));
      expect(modifier.isActive, isTrue);
      expect(modifier.applicableConditions, contains('fragile'));
    });

    test('should serialize and deserialize correctly', () {
      final modifier = PricingModifier.urgent();
      final json = modifier.toJson();
      final deserialized = PricingModifier.fromJson(json);

      expect(deserialized.id, equals(modifier.id));
      expect(deserialized.name, equals(modifier.name));
      expect(deserialized.value, equals(modifier.value));
      expect(deserialized.type, equals(modifier.type));
      expect(deserialized.isActive, equals(modifier.isActive));
    });
  });

  group('CommissionStructure', () {
    test('should calculate percentage commission correctly', () {
      final commission = CommissionStructure.defaultStructure;
      final result = commission.calculateCommission(1000.0);

      expect(result, equals(100.0)); // 10% of 1000
    });

    test('should apply minimum commission limit', () {
      final commission = CommissionStructure.defaultStructure;
      final result = commission.calculateCommission(100.0);

      expect(result, equals(50.0)); // Minimum commission is 50 XOF
    });

    test('should apply maximum commission limit', () {
      final commission = CommissionStructure.defaultStructure;
      final result = commission.calculateCommission(50000.0);

      expect(result, equals(1000.0)); // Maximum commission is 1000 XOF
    });

    test('should use category-specific rates', () {
      final commission = CommissionStructure.defaultStructure;

      final packageCommission =
          commission.calculateCommission(1000.0, 'package');
      final foodCommission = commission.calculateCommission(1000.0, 'food');
      final pharmacyCommission =
          commission.calculateCommission(1000.0, 'pharmacy');
      final groceryCommission =
          commission.calculateCommission(1000.0, 'grocery');

      expect(packageCommission, equals(100.0)); // 10% for package
      expect(foodCommission, equals(150.0)); // 15% for food
      expect(pharmacyCommission, equals(120.0)); // 12% for pharmacy
      expect(groceryCommission, equals(80.0)); // 8% for grocery
    });

    test('should calculate net amount correctly', () {
      final commission = CommissionStructure.defaultStructure;
      final netAmount = commission.getNetAmount(1000.0);

      expect(netAmount, equals(900.0)); // 1000 - 100 commission
    });

    test('should serialize and deserialize correctly', () {
      final commission = CommissionStructure.defaultStructure;
      final json = commission.toJson();
      final deserialized = CommissionStructure.fromJson(json);

      expect(deserialized.id, equals(commission.id));
      expect(deserialized.name, equals(commission.name));
      expect(deserialized.rate, equals(commission.rate));
      expect(deserialized.minimumCommissionXof,
          equals(commission.minimumCommissionXof));
      expect(deserialized.maximumCommissionXof,
          equals(commission.maximumCommissionXof));
      expect(deserialized.isActive, equals(commission.isActive));
    });
  });

  group('PricingZone', () {
    test('should provide default zones for Côte d\'Ivoire', () {
      final zones = PricingZone.defaultZones;

      expect(zones, isNotEmpty);
      expect(zones.length, greaterThanOrEqualTo(4));

      // Check if major cities are included
      final cityNames = zones.map((z) => z.name.toLowerCase()).toList();
      expect(cityNames.any((name) => name.contains('abidjan')), isTrue);
      expect(cityNames.any((name) => name.contains('bouaké')), isTrue);
      expect(cityNames.any((name) => name.contains('yamoussoukro')), isTrue);
    });

    test('should have valid coordinates for zones', () {
      final zones = PricingZone.defaultZones;

      for (final zone in zones) {
        expect(zone.centerLatitude, inInclusiveRange(-90.0, 90.0));
        expect(zone.centerLongitude, inInclusiveRange(-180.0, 180.0));
        expect(zone.radiusKm, greaterThan(0.0));
        expect(zone.basePriceXof, greaterThan(0));
        expect(zone.pricePerKmXof, greaterThan(0));
        expect(zone.isActive, isTrue);
      }
    });

    test('should serialize and deserialize correctly', () {
      final zone = PricingZone.defaultZones.first;
      final json = zone.toJson();
      final deserialized = PricingZone.fromJson(json);

      expect(deserialized.id, equals(zone.id));
      expect(deserialized.name, equals(zone.name));
      expect(deserialized.cityCode, equals(zone.cityCode));
      expect(deserialized.centerLatitude, equals(zone.centerLatitude));
      expect(deserialized.centerLongitude, equals(zone.centerLongitude));
      expect(deserialized.radiusKm, equals(zone.radiusKm));
    });
  });
}
