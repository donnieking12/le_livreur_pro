import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/config/app_config.dart';

Future<void> main() async {
  print('🚀 Testing Supabase connection for Le Livreur Pro...');
  print('Using environment configuration...');

  // Display the configuration being used
  print('Supabase URL: ${AppConfig.supabaseUrl}');
  print('Supabase Anon Key: ${AppConfig.supabaseAnonKey}');

  // Check if configuration is valid
  if (!AppConfig.isValidSupabaseConfig) {
    print('⚠️  Warning: Supabase configuration is not valid');
    print(
        'Please check your .env file and ensure SUPABASE_URL and SUPABASE_ANON_KEY are correctly set');
    return;
  }

  try {
    // Initialize Supabase with environment configuration
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );

    final supabase = Supabase.instance.client;
    print('✅ Supabase client initialized successfully');

    // Test basic connection by counting users
    try {
      final response =
          await supabase.from('users').select().count(CountOption.exact);

      print('✅ Database connection successful!');
      print('📊 Found ${response.count} users in database');

      // Test fetching sample data
      final users = await supabase
          .from('users')
          .select('id, full_name, user_type')
          .limit(5);

      print('👥 Sample users:');
      for (final user in users) {
        print('   - ${user['full_name']} (${user['user_type']})');
      }

      // Test table structure
      print('\n🏗️  Testing table structure...');

      final restaurants =
          await supabase.from('restaurants').select().count(CountOption.exact);
      print('   🏢 Restaurants table: ${restaurants.count} records');

      final orders = await supabase
          .from('delivery_orders')
          .select()
          .count(CountOption.exact);
      print('   📦 Orders table: ${orders.count} records');

      final payments =
          await supabase.from('payments').select().count(CountOption.exact);
      print('   💳 Payments table: ${payments.count} records');

      print('\n🎉 Le Livreur Pro Supabase setup is complete and working!');
      print('\n📋 Next steps:');
      print('   1. ✅ Database schema executed successfully');
      print('   2. ✅ Connection verified');
      print('   3. 🔄 Ready for Flutter app integration');
      print('   4. 🗺️  Next: Set up Google Maps API');
    } catch (e) {
      print('❌ Database query failed: $e');
      print(
          '💡 Make sure you have run the database schema in Supabase SQL Editor');
      print(
          '💡 If you have not executed the schema yet, please follow the instructions in SUPABASE_SCHEMA_EXECUTION_GUIDE.md');
      return;
    }

    print('🎉 Supabase setup is complete and working!');
    print('\n🚀 Your Le Livreur Pro backend is ready for production!');
  } catch (e) {
    print('❌ Connection failed: $e');
    print('💡 Check your credentials and internet connection');
    print('💡 Make sure your .env file is properly configured');
  }
}
