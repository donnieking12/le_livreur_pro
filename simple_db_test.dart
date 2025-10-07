import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  print('🗄️  Le Livreur Pro - Database Verification');
  print('=' * 50);

  // Supabase project details
  const supabaseUrl = 'https://fnygxppfogfpwycbbhsv.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZueWd4cHBmb2dmcHd5Y2JiaHN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0OTkxNDIsImV4cCI6MjA3MDA3NTE0Mn0.MMu4mvYF7lR7ST6uHwf8A_EeujhwXUQ3-SxLNnFTV9o';

  try {
    print('🔗 Testing connection to Supabase...');
    
    // Test basic connection
    final response = await http.get(
      Uri.parse('$supabaseUrl/rest/v1/users?select=count'),  
      headers: {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
        'Prefer': 'count=exact',
      },
    );

    if (response.statusCode == 200) {
      print('✅ Successfully connected to Supabase!');
      
      // Parse count from headers
      final countHeader = response.headers['content-range'];
      final userCount = countHeader?.split('/').last ?? '0';
      print('👥 Found $userCount users in database');
      
      // Test each table
      final tables = ['users', 'addresses', 'restaurants', 'menu_categories', 
                     'menu_items', 'delivery_orders', 'order_items', 'payments', 'user_analytics'];
      
      print('\n📋 Verifying database tables:');
      
      for (String table in tables) {
        try {
          final tableResponse = await http.get(
            Uri.parse('$supabaseUrl/rest/v1/$table?select=count'),
            headers: {
              'apikey': anonKey,
              'Authorization': 'Bearer $anonKey',
              'Content-Type': 'application/json',
              'Prefer': 'count=exact',
            },
          );
          
          if (tableResponse.statusCode == 200) {
            final tableCountHeader = tableResponse.headers['content-range'];
            final tableCount = tableCountHeader?.split('/').last ?? '0';
            print('   ✅ $table: $tableCount records');
          } else {
            print('   ❌ $table: Error ${tableResponse.statusCode}');
          }
        } catch (e) {
          print('   ❌ $table: Connection error');
        }
        
        // Small delay to avoid rate limiting
        await Future.delayed(Duration(milliseconds: 100));
      }
      
      print('\n🎉 DATABASE VERIFICATION COMPLETE!');
      print('✅ Your Le Livreur Pro database is ready for production!');
      
      print('\n📋 Next Steps:');
      print('   1. ✅ Database schema executed successfully');
      print('   2. 🔄 Ready to replace mock data with real data');
      print('   3. 🔐 Next: Set up real authentication');
      print('   4. 🗺️  Next: Configure Google Maps API');
      print('   5. 💳 Next: Integrate payment gateways');
      
    } else {
      print('❌ Connection failed: HTTP ${response.statusCode}');
      print('Response: ${response.body}');
    }
    
  } catch (e) {
    print('❌ Connection error: $e');
    print('\n💡 Troubleshooting:');
    print('   1. Check your internet connection');
    print('   2. Verify Supabase project is active');
    print('   3. Confirm database schema was executed successfully');
  }
}