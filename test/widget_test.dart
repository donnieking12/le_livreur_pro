// test/widget_test.dart - Fixed version for Le Livreur Pro
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_livreur_pro/main.dart';

void main() {
  testWidgets('Le Livreur Pro app loads correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LeLivreurProApp());

    // Verify the app loads with the correct title
    expect(find.text('Le Livreur Pro'), findsAtLeastNWidgets(1));

    // Verify basic app structure
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });

  testWidgets('App structure is correct', (WidgetTester tester) async {
    await tester.pumpWidget(const LeLivreurProApp());

    // Test basic structure
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);

    // Verify we have the main app title
    expect(find.text('Le Livreur Pro'), findsAtLeastNWidgets(1));
  });
}
