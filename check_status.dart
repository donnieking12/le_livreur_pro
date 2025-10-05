import 'dart:io';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() async {
  print('=== Le Livreur Pro Project Status Check ===\n');

  // Check if .env file exists
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('✅ .env file exists');
    
    // Initialize the configuration
    try {
      await AppConfig.init();
      print('✅ Configuration loaded successfully');
      
      // Display key configuration values
      print('\n--- Configuration Values ---');
      print('SUPABASE_URL: ${AppConfig.supabaseUrl}');
      print('SUPABASE_ANON_KEY: ${AppConfig.supabaseAnonKey.substring(0, 10)}...');
      print('GOOGLE_MAPS_API_KEY: ${AppConfig.googleMapsApiKey}');
      
      // Check if configuration is valid
      print('\n--- Validation Results ---');
      if (AppConfig.isValidSupabaseConfig) {
        print('✅ Supabase configuration is VALID');
      } else {
        print('❌ Supabase configuration is INVALID');
      }
      
      if (AppConfig.isValidGoogleMapsConfig) {
        print('✅ Google Maps configuration is VALID');
      } else {
        print('⚠️  Google Maps configuration is using placeholder value');
      }
      
    } catch (e) {
      print('❌ Failed to load configuration: $e');
    }
  } else {
    print('❌ .env file not found');
    print('   Please create a .env file with your configuration');
  }

  // Check Flutter dependencies
  print('\n--- Flutter Dependencies ---');
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
    print('✅ pubspec.yaml file exists');
  } else {
    print('❌ pubspec.yaml file not found');
  }

  // Check asset directories
  print('\n--- Asset Directories ---');
  final assetDirs = ['assets/images', 'assets/images/delivery', 
                     'assets/images/payment', 'assets/icons', 'assets/lottie'];
  for (final dir in assetDirs) {
    final dirFile = Directory(dir);
    if (dirFile.existsSync()) {
      print('✅ $dir exists');
    } else {
      print('❌ $dir not found');
    }
  }

  print('\n=== Project Status Check Complete ===');
}