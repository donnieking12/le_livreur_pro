import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

/// Test helper to setup test environment
class TestHelper {
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Load test environment variables
    if (File('.env.test').existsSync()) {
      await dotenv.load(fileName: '.env.test');
    }
    
    // Initialize EasyLocalization for tests
    await EasyLocalization.ensureInitialized();
  }
  
  /// Wrapper widget for testing widgets that require localization
  static Widget createTestableWidget(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('fr', 'CI'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('fr', 'CI'),
      child: MaterialApp(
        localizationsDelegates: EasyLocalization.of(context)?.localizationDelegates,
        supportedLocales: EasyLocalization.of(context)?.supportedLocales ?? [],
        home: child,
      ),
    );
  }
}