import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:le_livreur_pro/features/profile/presentation/screens/profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('Profile Screen Tests', () {
    testWidgets('Profile screen displays correctly', (WidgetTester tester) async {
      // Create test app with proper providers
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: EasyLocalization(
              supportedLocales: const [Locale('en'), Locale('fr')],
              path: 'assets/translations',
              fallbackLocale: const Locale('en'),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pump();

      // Verify that the profile screen renders
      expect(find.byType(ProfileScreen), findsOneWidget);
      
      // Verify the app bar is present
      expect(find.byType(AppBar), findsOneWidget);
      
      // Wait for any async operations
      await tester.pumpAndSettle();
    });

    testWidgets('Profile options are displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: EasyLocalization(
              supportedLocales: const [Locale('en'), Locale('fr')],
              path: 'assets/translations',
              fallbackLocale: const Locale('en'),
              child: const ProfileScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify profile options are present
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.payment), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });
  });
}
