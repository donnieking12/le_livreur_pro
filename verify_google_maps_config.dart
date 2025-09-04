import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() async {
  print('=== Le Livreur Pro - Google Maps Configuration Verification ===\n');

  // Initialize the configuration
  await AppConfig.init();

  // Check if .env file exists
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('✅ .env file exists');
  } else {
    print('❌ .env file not found');
    print('   Please create a .env file with your configuration');
    return;
  }

  // Display Google Maps configuration
  print('\n--- Google Maps Configuration ---');
  print('GOOGLE_MAPS_API_KEY: ${AppConfig.googleMapsApiKey}');

  // Check if configuration is valid
  print('\n--- Validation Results ---');
  if (AppConfig.isValidGoogleMapsConfig) {
    print('✅ Google Maps configuration is VALID');
    print('   The API key is properly configured and ready to use');
  } else {
    print('❌ Google Maps configuration is INVALID');
    if (AppConfig.googleMapsApiKey == 'your-google-maps-api-key') {
      print('   - GOOGLE_MAPS_API_KEY is still using a placeholder value');
      print('   - Please update it with your actual Google Maps API key');
    } else if (AppConfig.googleMapsApiKey.isEmpty) {
      print('   - GOOGLE_MAPS_API_KEY is empty');
      print('   - Please provide a valid Google Maps API key');
    }
  }

  print('\n--- Next Steps ---');
  if (AppConfig.isValidGoogleMapsConfig) {
    print('✅ Your Google Maps API key is properly configured!');
    print('   You can now run the application and use map features');
  } else {
    print('1. Get your Google Maps API key from Google Cloud Console');
    print('2. Update the GOOGLE_MAPS_API_KEY value in your .env file');
    print('3. Re-run this verification script to confirm');
  }
}
