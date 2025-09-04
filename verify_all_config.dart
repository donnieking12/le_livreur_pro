import 'dart:io';

void main() {
  print('========================================');
  print('Le Livreur Pro - Complete Configuration Check');
  print('========================================\n');

  // Check if .env file exists
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    print('   Please create a .env file with your configuration');
    return;
  }

  print('✅ .env file exists\n');

  // Read the .env file
  final lines = envFile.readAsLinesSync();

  Map<String, String> config = {};

  // Parse the .env file
  for (var line in lines) {
    line = line.trim();
    // Skip comments and empty lines
    if (line.startsWith('#') || line.isEmpty) {
      continue;
    }

    // Parse key=value pairs
    if (line.contains('=')) {
      final parts = line.split('=');
      final key = parts[0].trim();
      final value = parts.length > 1 ? parts[1].trim() : '';
      config[key] = value;
    }
  }

  // Display all configuration
  print('--- All Configuration Values ---');
  config.forEach((key, value) {
    // Mask sensitive values for display
    String displayValue = value;
    if (key.contains('KEY') || key.contains('SECRET')) {
      displayValue = value.length > 10
          ? '${value.substring(0, 6)}...${value.substring(value.length - 4)}'
          : '****';
    }
    print('$key: $displayValue');
  });

  // Validate specific configurations
  print('\n--- Validation Results ---');

  // Supabase validation
  bool isValidSupabase = validateSupabaseConfig(config);

  // Google Maps validation
  bool isValidGoogleMaps = validateGoogleMapsConfig(config);

  // Payment gateways validation
  bool isValidPayment = validatePaymentConfig(config);

  print('\n--- Summary ---');
  print('Supabase Configuration: ${isValidSupabase ? '✅ VALID' : '❌ INVALID'}');
  print(
      'Google Maps Configuration: ${isValidGoogleMaps ? '✅ VALID' : '⚠️  NEEDS ATTENTION'}');
  print(
      'Payment Configuration: ${isValidPayment ? '✅ VALID' : '⚠️  NEEDS ATTENTION'}');

  if (!isValidSupabase) {
    print(
        '\n🔧 Fix Supabase configuration by updating SUPABASE_URL and SUPABASE_ANON_KEY in .env');
  }

  if (!isValidGoogleMaps) {
    print(
        '\n🔧 Get a Google Maps API key from https://console.cloud.google.com/');
    print('   Then update GOOGLE_MAPS_API_KEY in .env');
  }

  if (!isValidPayment) {
    print('\n🔧 For production, update payment gateway keys in .env');
    print('   - WAVE_API_KEY');
    print('   - ORANGE_MONEY_API_KEY');
    print('   - MTN_MONEY_API_KEY');
  }

  print('\n🎉 Configuration check complete!');
}

bool validateSupabaseConfig(Map<String, String> config) {
  final url = config['SUPABASE_URL'] ?? '';
  final key = config['SUPABASE_ANON_KEY'] ?? '';

  bool isValid = true;

  if (url.isEmpty ||
      url.contains('demo.supabase.co') ||
      url.contains('your-project')) {
    print('❌ Supabase URL is INVALID');
    isValid = false;
  } else {
    print('✅ Supabase URL is VALID');
  }

  if (key.isEmpty || key == 'demo-key' || !key.startsWith('ey')) {
    print('❌ Supabase Anon Key is INVALID');
    isValid = false;
  } else {
    print('✅ Supabase Anon Key is VALID');
  }

  return isValid;
}

bool validateGoogleMapsConfig(Map<String, String> config) {
  final key = config['GOOGLE_MAPS_API_KEY'] ?? '';

  if (key.isEmpty || key.contains('your') || key.contains('YOUR')) {
    print('⚠️  Google Maps API Key needs to be configured');
    return false;
  } else {
    print('✅ Google Maps API Key is present');
    return true;
  }
}

bool validatePaymentConfig(Map<String, String> config) {
  final wave = config['WAVE_API_KEY'] ?? '';
  final orange = config['ORANGE_MONEY_API_KEY'] ?? '';
  final mtn = config['MTN_MONEY_API_KEY'] ?? '';

  bool allConfigured = true;

  if (wave.isEmpty || wave.contains('your') || wave.contains('YOUR')) {
    print('⚠️  Wave API Key needs to be configured for production');
    allConfigured = false;
  } else {
    print('✅ Wave API Key is present');
  }

  if (orange.isEmpty || orange.contains('your') || orange.contains('YOUR')) {
    print('⚠️  Orange Money API Key needs to be configured for production');
    allConfigured = false;
  } else {
    print('✅ Orange Money API Key is present');
  }

  if (mtn.isEmpty || mtn.contains('your') || mtn.contains('YOUR')) {
    print('⚠️  MTN Money API Key needs to be configured for production');
    allConfigured = false;
  } else {
    print('✅ MTN Money API Key is present');
  }

  return allConfigured;
}
