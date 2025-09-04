import 'package:flutter_test/flutter_test.dart';
import 'package:le_livreur_pro/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('should have correct Supabase configuration', () {
      // Verify Supabase URL is set correctly
      expect(AppConfig.supabaseUrl, 'https://fnygxppfogfpwycbbhsv.supabase.co');

      // Verify Supabase Anon Key is set correctly
      expect(AppConfig.supabaseAnonKey,
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZueWd4cHBmb2dmcHd5Y2JiaHN2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ0OTkxNDIsImV4cCI6MjA3MDA3NTE0Mn0.MMu4mvYF7lR7ST6uHwf8A_EeujhwXUQ3-SxLNnFTV9o');

      // Verify configuration is valid
      expect(AppConfig.isValidSupabaseConfig, true);
    });

    test('should have correct app configuration', () {
      expect(AppConfig.appName, 'Le Livreur Pro');
      expect(AppConfig.appVersion, '1.0.0+1');
      expect(AppConfig.defaultCurrency, 'XOF');
      expect(AppConfig.defaultLanguage, 'fr');
    });
  });
}
