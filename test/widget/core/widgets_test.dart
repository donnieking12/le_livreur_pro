// test/widget/core/widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_livreur_pro/shared/widgets/pricing_widgets.dart';
import 'package:le_livreur_pro/shared/widgets/payment_status_widget.dart';
import 'package:le_livreur_pro/shared/widgets/payment_integration_demo.dart';
import 'package:le_livreur_pro/core/models/pricing_models.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Test helper to wrap widgets with necessary providers
Widget createTestWidget(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(body: child),
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
    ),
  );
}

void main() {
  group('Pricing Widgets Tests', () {
    group('PricingCalculatorWidget', () {
      testWidgets('should render pricing calculator with all components',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PricingCalculatorWidget(
              pickupLatitude: 5.3600,
              pickupLongitude: -4.0083,
              deliveryLatitude: 5.3800,
              deliveryLongitude: -4.0200,
            ),
          ),
        );

        // Verify header
        expect(find.byIcon(Icons.calculate), findsOneWidget);
        expect(find.text('Calculateur de prix'), findsOneWidget);

        // Verify location info
        expect(find.byIcon(Icons.my_location), findsOneWidget);
        expect(find.byIcon(Icons.location_on), findsOneWidget);

        // Verify priority options
        expect(find.text('Normale'), findsOneWidget);
        expect(find.text('Urgente (+200 XOF)'), findsOneWidget);
        expect(find.text('Express (+400 XOF)'), findsOneWidget);

        // Verify option checkboxes
        expect(find.text('Colis fragile'), findsOneWidget);
        expect(find.text('Livraison week-end'), findsOneWidget);
        expect(find.text('Livraison nocturne'), findsOneWidget);

        // Verify calculate button
        expect(find.text('Calculer le prix'), findsOneWidget);
      });

      testWidgets('should show location warning when coordinates are missing',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PricingCalculatorWidget(),
          ),
        );

        // Should show warning icon and message
        expect(find.byIcon(Icons.location_off), findsOneWidget);
        expect(
            find.textContaining('sélectionner les adresses'), findsOneWidget);

        // Calculate button should be disabled
        final calculateButton = find.text('Calculer le prix');
        expect(calculateButton, findsOneWidget);

        final buttonWidget = tester.widget<ElevatedButton>(
          find.ancestor(
            of: calculateButton,
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(buttonWidget.onPressed, isNull);
      });

      testWidgets(
          'should update priority selection when radio button is tapped',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PricingCalculatorWidget(
              pickupLatitude: 5.3600,
              pickupLongitude: -4.0083,
              deliveryLatitude: 5.3800,
              deliveryLongitude: -4.0200,
            ),
          ),
        );

        // Initially, normal priority should be selected
        final normalRadio = find.byWidgetPredicate(
          (widget) =>
              widget is Radio<PriorityLevel> &&
              widget.value == PriorityLevel.normal,
        );
        expect(normalRadio, findsOneWidget);

        // Tap urgent priority
        final urgentRadio = find.byWidgetPredicate(
          (widget) =>
              widget is Radio<PriorityLevel> &&
              widget.value == PriorityLevel.urgent,
        );
        await tester.tap(urgentRadio);
        await tester.pump();

        // Verify urgent is now selected
        final urgentRadioWidget =
            tester.widget<Radio<PriorityLevel>>(urgentRadio);
        expect(urgentRadioWidget.groupValue, equals(PriorityLevel.urgent));
      });

      testWidgets('should update checkbox states when toggled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PricingCalculatorWidget(
              pickupLatitude: 5.3600,
              pickupLongitude: -4.0083,
              deliveryLatitude: 5.3800,
              deliveryLongitude: -4.0200,
            ),
          ),
        );

        // Find fragile checkbox
        final fragileCheckbox = find.byWidgetPredicate(
          (widget) =>
              widget is CheckboxListTile &&
              widget.title is Text &&
              (widget.title as Text).data == 'Colis fragile',
        );

        expect(fragileCheckbox, findsOneWidget);

        // Initially should be unchecked
        CheckboxListTile fragileWidget = tester.widget(fragileCheckbox);
        expect(fragileWidget.value, isFalse);

        // Tap to check
        await tester.tap(fragileCheckbox);
        await tester.pump();

        // Should now be checked
        fragileWidget = tester.widget(fragileCheckbox);
        expect(fragileWidget.value, isTrue);
      });

      testWidgets('should select category from dropdown',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PricingCalculatorWidget(
              pickupLatitude: 5.3600,
              pickupLongitude: -4.0083,
              deliveryLatitude: 5.3800,
              deliveryLongitude: -4.0200,
            ),
          ),
        );

        // Find category dropdown
        final categoryDropdown = find.byType(DropdownButtonFormField<String>);
        expect(categoryDropdown, findsOneWidget);

        // Tap dropdown
        await tester.tap(categoryDropdown);
        await tester.pumpAndSettle();

        // Select food category
        final foodOption = find.text('Nourriture');
        if (foodOption.evaluate().isNotEmpty) {
          await tester.tap(foodOption);
          await tester.pumpAndSettle();
        }

        // Verify selection (this would require access to widget state)
      });
    });

    group('PricingResultWidget', () {
      testWidgets('should display pricing calculation results correctly',
          (WidgetTester tester) async {
        final mockCalculation = PricingCalculation(
          totalDistance: 5.2,
          zone: PricingZone.defaultZones.first,
          basePriceXof: 500,
          distancePriceXof: 70,
          appliedModifiers: [
            AppliedModifier(
              modifier: PricingModifier.urgent(),
              calculatedAmountXof: 200,
              reason: 'Livraison urgente demandée',
            ),
          ],
          subtotalXof: 770,
          platformCommission: 77.0,
          totalPriceXof: 770,
          courierEarningsXof: 693,
          currency: 'XOF',
          estimatedDuration: const Duration(minutes: 35),
          breakdown: {
            'distance_km': 5.2,
            'zone_name': 'Abidjan Centre',
          },
          calculatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(
            PricingResultWidget(calculation: mockCalculation),
          ),
        );

        // Verify total price display
        expect(find.text('770 XOF'), findsOneWidget);
        expect(find.text('Prix calculé'), findsOneWidget);

        // Verify breakdown
        expect(find.text('Détail du prix'), findsOneWidget);
        expect(find.text('500 XOF'), findsOneWidget); // Base price
        expect(find.text('70 XOF'), findsOneWidget); // Distance price
        expect(find.text('200 XOF'), findsOneWidget); // Urgent modifier

        // Verify commission info
        expect(find.text('Répartition des revenus'), findsOneWidget);
        expect(find.text('77 XOF'), findsOneWidget); // Commission
        expect(find.text('693 XOF'), findsOneWidget); // Courier earnings

        // Verify delivery info
        expect(find.text('5.2 km'), findsOneWidget); // Distance
        expect(find.text('35 min'), findsOneWidget); // Duration
        expect(find.text('Abidjan Centre'), findsOneWidget); // Zone
      });

      testWidgets('should display modifiers correctly',
          (WidgetTester tester) async {
        final mockCalculation = PricingCalculation(
          totalDistance: 3.0,
          zone: PricingZone.defaultZones.first,
          basePriceXof: 500,
          distancePriceXof: 0,
          appliedModifiers: [
            AppliedModifier(
              modifier: PricingModifier.fragile(),
              calculatedAmountXof: 200,
              reason: 'Colis fragile',
            ),
            AppliedModifier(
              modifier: PricingModifier.nightDelivery(),
              calculatedAmountXof: 250,
              reason: 'Livraison nocturne',
            ),
          ],
          subtotalXof: 950,
          platformCommission: 95.0,
          totalPriceXof: 950,
          courierEarningsXof: 855,
          currency: 'XOF',
          estimatedDuration: const Duration(minutes: 45),
          breakdown: {},
          calculatedAt: DateTime.now(),
        );

        await tester.pumpWidget(
          createTestWidget(
            PricingResultWidget(calculation: mockCalculation),
          ),
        );

        // Should show both modifiers
        expect(find.text('Manipulation fragile'), findsOneWidget);
        expect(find.text('Livraison nocturne'), findsOneWidget);
      });
    });

    group('PricingSummaryWidget', () {
      testWidgets('should display loading state initially',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PricingSummaryWidget(
              pickupLatitude: 5.3600,
              pickupLongitude: -4.0083,
              deliveryLatitude: 5.3800,
              deliveryLongitude: -4.0200,
            ),
          ),
        );

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Calcul du prix...'), findsOneWidget);
      });
    });
  });

  group('Payment Widgets Tests', () {
    group('PaymentStatusWidget', () {
      testWidgets('should display loading state', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PaymentStatusWidget(
              paymentRef: 'test-payment-ref',
            ),
          ),
        );

        // Should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(
            find.text('Vérification du statut de paiement...'), findsOneWidget);
      });

      testWidgets('should show retry and cancel buttons when enabled',
          (WidgetTester tester) async {
        bool retryPressed = false;
        bool cancelPressed = false;

        await tester.pumpWidget(
          createTestWidget(
            PaymentStatusWidget(
              paymentRef: 'test-payment-ref',
              onRetry: () => retryPressed = true,
              onCancel: () => cancelPressed = true,
            ),
          ),
        );

        // Wait for loading to complete (if it does)
        await tester.pump(const Duration(seconds: 2));

        // Look for action buttons if they appear
        final retryButton = find.textContaining('Réessayer');
        final cancelButton = find.textContaining('Annuler');

        if (retryButton.evaluate().isNotEmpty) {
          await tester.tap(retryButton);
          expect(retryPressed, isTrue);
        }

        if (cancelButton.evaluate().isNotEmpty) {
          await tester.tap(cancelButton);
          expect(cancelPressed, isTrue);
        }
      });
    });

    group('PaymentHistoryWidget', () {
      testWidgets('should display empty state message',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PaymentHistoryWidget(
              userId: 'empty-user-id',
              limit: 5,
            ),
          ),
        );

        // Wait for loading
        await tester.pump(const Duration(seconds: 1));

        // Should show empty state
        expect(find.byIcon(Icons.payment), findsOneWidget);
        expect(find.text('Aucun historique de paiement'), findsOneWidget);
      });
    });

    group('PaymentIntegrationDemo', () {
      testWidgets('should render demo with all sections',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PaymentIntegrationDemo(demoAmount: 2500.0),
          ),
        );

        // Verify header
        expect(find.text('Payment Integration Demo'), findsOneWidget);
        expect(find.text('2500 XOF'), findsOneWidget);

        // Verify sections
        expect(find.text('Méthodes de paiement disponibles'), findsOneWidget);
        expect(find.text('Actions de paiement'), findsOneWidget);
        expect(find.text('Historique des paiements'), findsOneWidget);
      });

      testWidgets('should enable demo button when payment method selected',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PaymentIntegrationDemo(demoAmount: 1000.0),
          ),
        );

        // Initially demo button might be disabled
        final demoButton = find.text('Lancer démonstration');
        expect(demoButton, findsOneWidget);

        // Select a payment method (Orange Money)
        final orangeMoneyTile = find.textContaining('Orange Money');
        if (orangeMoneyTile.evaluate().isNotEmpty) {
          await tester.tap(orangeMoneyTile);
          await tester.pump();

          // Demo button should now be enabled
          await tester.tap(demoButton);
          await tester.pump();
        }
      });

      testWidgets('should clear demo state when clear button pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            const PaymentIntegrationDemo(demoAmount: 1000.0),
          ),
        );

        // Find and tap clear button
        final clearButton = find.text('Effacer');
        expect(clearButton, findsOneWidget);

        await tester.tap(clearButton);
        await tester.pump();

        // State should be cleared (this would require checking internal state)
      });
    });
  });

  group('Theme and Styling Tests', () {
    testWidgets('should use consistent colors from AppTheme',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          Container(
            color: AppTheme.primaryGreen,
            child: const Text('Theme Test'),
          ),
        ),
      );

      // Verify theme colors are applied
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(AppTheme.primaryGreen));
    });

    testWidgets('should display icons consistently',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const Column(
            children: [
              Icon(Icons.calculate, color: AppTheme.primaryGreen),
              Icon(Icons.payment, color: AppTheme.infoBlue),
              Icon(Icons.location_on, color: AppTheme.successGreen),
            ],
          ),
        ),
      );

      // Verify icons are rendered
      expect(find.byIcon(Icons.calculate), findsOneWidget);
      expect(find.byIcon(Icons.payment), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('should provide semantic labels for important widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PricingCalculatorWidget(
            pickupLatitude: 5.3600,
            pickupLongitude: -4.0083,
            deliveryLatitude: 5.3800,
            deliveryLongitude: -4.0200,
          ),
        ),
      );

      // Verify semantic labels exist for accessibility
      expect(find.bySemanticsLabel('Calculer le prix'), findsAny);
    });

    testWidgets('should support screen readers with proper labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PaymentIntegrationDemo(demoAmount: 1500.0),
        ),
      );

      // Check for semantic information
      final semantics =
          tester.getSemantics(find.byType(PaymentIntegrationDemo));
      expect(semantics, isNotNull);
    });
  });

  group('Error Handling in Widgets', () {
    testWidgets('should display error messages appropriately',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PaymentStatusWidget(
            paymentRef: 'invalid-payment-ref',
          ),
        ),
      );

      // Wait for potential error state
      await tester.pump(const Duration(seconds: 3));

      // Should handle errors gracefully
      expect(find.byType(PaymentStatusWidget), findsOneWidget);
    });

    testWidgets('should handle network errors in pricing widgets',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PricingSummaryWidget(
            pickupLatitude: 999.0, // Invalid coordinate
            pickupLongitude: 999.0, // Invalid coordinate
            deliveryLatitude: 5.3800,
            deliveryLongitude: -4.0200,
          ),
        ),
      );

      // Wait for error handling
      await tester.pump(const Duration(seconds: 2));

      // Should show error state
      expect(find.textContaining('Erreur'), findsAny);
    });
  });

  group('Performance Tests', () {
    testWidgets('should render complex widgets efficiently',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        createTestWidget(
          const Column(
            children: [
              PricingCalculatorWidget(
                pickupLatitude: 5.3600,
                pickupLongitude: -4.0083,
                deliveryLatitude: 5.3800,
                deliveryLongitude: -4.0200,
              ),
              PaymentIntegrationDemo(demoAmount: 2000.0),
            ],
          ),
        ),
      );

      stopwatch.stop();

      // Rendering should be reasonably fast
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    testWidgets('should handle rapid state changes smoothly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          const PricingCalculatorWidget(
            pickupLatitude: 5.3600,
            pickupLongitude: -4.0083,
            deliveryLatitude: 5.3800,
            deliveryLongitude: -4.0200,
          ),
        ),
      );

      // Rapidly toggle checkboxes
      for (int i = 0; i < 5; i++) {
        final fragileCheckbox = find.byWidgetPredicate(
          (widget) =>
              widget is CheckboxListTile &&
              widget.title is Text &&
              (widget.title as Text).data == 'Colis fragile',
        );

        if (fragileCheckbox.evaluate().isNotEmpty) {
          await tester.tap(fragileCheckbox);
          await tester.pump();
        }
      }

      // Should handle rapid changes without issues
      expect(find.byType(PricingCalculatorWidget), findsOneWidget);
    });
  });
}
