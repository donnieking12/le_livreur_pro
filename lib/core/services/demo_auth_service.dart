import 'package:le_livreur_pro/core/models/user.dart';

/// Demo authentication service for development and testing
/// Bypasses Supabase authentication when needed
class DemoAuthService {
  static User? _currentDemoUser;
  
  /// Demo users for testing
  static final List<User> _demoUsers = [
    User(
      id: 'demo-customer-1',
      email: 'client@demo.com',
      fullName: 'Jean Kouassi',
      phone: '+22507123456',
      userType: UserType.customer,
      isActive: true,
      isVerified: true,
      preferredLanguage: 'fr',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'demo-courier-1',
      email: 'coursier@demo.com',
      fullName: 'Marie Traore',
      phone: '+22507654321',
      userType: UserType.courier,
      isActive: true,
      isVerified: true,
      preferredLanguage: 'fr',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now(),
    ),
    User(
      id: 'demo-partner-1',
      email: 'partenaire@demo.com',
      fullName: 'Restaurant Chez Mama',
      phone: '+22507987654',
      userType: UserType.partner,
      isActive: true,
      isVerified: true,
      preferredLanguage: 'fr',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
  ];
  
  /// Sign in with demo credentials
  static Future<User?> signInDemo({
    required String email,
    required String password,
  }) async {
    print('🧪 Demo auth: Attempting login with $email');
    
    // Very permissive demo authentication - accept common passwords
    if (password == 'demo123' || password == '123456' || password == 'password' || password == 'demo') {
      final user = _demoUsers.firstWhere(
        (user) => user.email == email,
        orElse: () => _createDemoUser(email),
      );
      
      _currentDemoUser = user;
      print('✅ Demo auth: Login successful for ${user.fullName}');
      return user;
    }
    
    print('❌ Demo auth: Invalid password for $email (try: demo123, 123456, demo, or password)');
    return null;
  }
  
  /// Create a new demo user
  static User _createDemoUser(String email) {
    print('👤 Creating new demo user for $email');
    
    return User(
      id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      fullName: 'Demo User',
      phone: '+22507000000',
      userType: UserType.customer,
      isActive: true,
      isVerified: true,
      preferredLanguage: 'fr',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Get current demo user
  static User? getCurrentDemoUser() {
    return _currentDemoUser;
  }
  
  /// Sign out demo user
  static void signOutDemo() {
    print('🔓 Demo auth: Signing out');
    _currentDemoUser = null;
  }
  
  /// Check if email is a demo account
  static bool isDemoEmail(String email) {
    return email.contains('demo.com') || 
           email.contains('test.com') ||
           _demoUsers.any((user) => user.email == email);
  }
}