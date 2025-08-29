import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('🚀 Testing Supabase connection for Le Livreur Pro...');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://fnygxppfogfpwycbbhsv.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZueWd4cHBmb2dmcHd5Y2JiaHN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0OTkxNDIsImV4cCI6MjA3MDA3NTE0Mn0.MMu4mvYF7lR7ST6uHwf8A_EeujhwXUQ3-SxLNnFTV9o',
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
      return;
    }

    print('🎉 Supabase setup is complete and working!');
    print('\n🚀 Your Le Livreur Pro backend is ready for production!');
  } catch (e) {
    print('❌ Connection failed: $e');
    print('💡 Check your credentials and internet connection');
  }
}
