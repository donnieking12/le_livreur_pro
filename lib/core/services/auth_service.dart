import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/services/supabase_service.dart';
import 'package:le_livreur_pro/core/services/demo_auth_service.dart';
import 'package:le_livreur_pro/core/utils/app_logger.dart';

// Provider for current user profile
final currentUserProfileProvider = Provider<AsyncValue<User?>>((ref) {
  return ref.watch(authNotifierProvider);
});

// Provider for auth state notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

// Alias for backward compatibility
final currentUserProvider = authNotifierProvider;

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final user = await AuthService.getCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Check if this is a demo account first
      if (DemoAuthService.isDemoEmail(email)) {
        AppLogger.info('Using demo authentication', tag: 'AuthNotifier');
        final demoUser = await DemoAuthService.signInDemo(
          email: email,
          password: password,
        );

        if (demoUser != null) {
          AppLogger.info('Demo login successful, updating state',
              tag: 'AuthNotifier');
          state = AsyncValue.data(demoUser);
          return;
        } else {
          throw Exception('Demo credentials invalides (utilisez: demo123)');
        }
      }

      // Normal Supabase authentication
      await AuthService.signInWithEmail(
        email: email,
        password: password,
      );
      final user = await AuthService.getCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      // For demo emails, don't try to sign up - redirect to sign in
      if (DemoAuthService.isDemoEmail(email)) {
        throw Exception(
            'Compte de démo existant. Utilisez "Se connecter" avec: $email / demo123');
      }

      await AuthService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
        userType: userType,
      );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      await AuthService.verifyOTP(phone: phone, token: token);
      final user = await AuthService.getCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> refreshProfile() async {
    try {
      state = const AsyncValue.loading();
      final user = await AuthService.getCurrentUserProfile();
      state = AsyncValue.data(user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class AuthService {
  static final supabase.SupabaseClient _client = SupabaseService.client;

  // ==================== PHONE AUTHENTICATION ====================

  /// Sign in with email and password
  static Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.info('Attempting signin with email: $email',
          tag: 'AuthService');

      // Normal Supabase authentication (demo logic handled in AuthNotifier)
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      AppLogger.info(
          'Signin response: User ID = ${response.user?.id}, Session = ${response.session != null}',
          tag: 'AuthService');

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }
    } catch (e) {
      AppLogger.error('Signin error', tag: 'AuthService', error: e);
      throw _handleAuthError(e);
    }
  }

  /// Sign up with email and password
  static Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final userData = {
        'full_name': fullName,
        'user_type': userType.name,
        'email': email,
        'preferred_language': 'fr', // Default to French for Côte d'Ivoire
        ...?additionalData,
      };

      AppLogger.info('Attempting signup with email: $email',
          tag: 'AuthService');

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );

      AppLogger.info(
          'Signup response: User ID = ${response.user?.id}, Session = ${response.session != null}',
          tag: 'AuthService');

      if (response.user != null) {
        // Create user profile regardless of email confirmation status
        await _createUserProfile(response.user!);
        AppLogger.info('User profile created successfully', tag: 'AuthService');
      } else {
        AppLogger.warning(
            'Signup successful but user is null (email confirmation may be required)',
            tag: 'AuthService');
        // Still throw success since this is expected behavior with email confirmation
      }
    } catch (e) {
      AppLogger.error('Signup error', tag: 'AuthService', error: e);
      throw _handleAuthError(e);
    }
  }

  /// Verify OTP code
  static Future<supabase.AuthResponse> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final normalizedPhone = _normalizePhoneNumber(phone);

      final response = await _client.auth.verifyOTP(
        phone: normalizedPhone,
        token: token,
        type: supabase.OtpType.sms,
      );

      // If verification successful and user is new, create profile
      if (response.user != null) {
        final existingProfile =
            await SupabaseService.getUserProfile(response.user!.id);
        if (existingProfile == null) {
          await _createUserProfile(response.user!);
        }
      }

      return response;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Resend OTP code
  static Future<void> resendOTP(String phone) async {
    try {
      final normalizedPhone = _normalizePhoneNumber(phone);

      await _client.auth.resend(
        phone: normalizedPhone,
        type: supabase.OtpType.sms,
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Get current user session
  static supabase.Session? getCurrentSession() {
    return _client.auth.currentSession;
  }

  /// Get current authenticated user
  static supabase.User? getCurrentAuthUser() {
    return _client.auth.currentUser;
  }

  /// Get current user profile
  static Future<User?> getCurrentUserProfile() async {
    final authUser = getCurrentAuthUser();
    if (authUser == null) return null;

    try {
      // Try to get from database first
      final profile = await SupabaseService.getUserProfile(authUser.id);
      if (profile != null) {
        return profile;
      }
    } catch (e) {
      AppLogger.warning('Could not fetch user profile from database',
          tag: 'AuthService', error: e);
    }

    // Fallback: Create user profile from auth metadata for development
    AppLogger.info('Creating fallback user profile from auth data',
        tag: 'AuthService');
    final userData = authUser.userMetadata ?? {};
    return User(
      id: authUser.id,
      phone: userData['phone'] ?? '',
      fullName: userData['full_name'] ?? authUser.email ?? 'Demo User',
      email: authUser.email,
      userType: UserType.values.byName(
        userData['user_type'] ?? 'customer',
      ),
      isActive: true,
      isVerified: authUser.emailConfirmedAt != null,
      preferredLanguage: userData['preferred_language'] ?? 'fr',
      createdAt: authUser.createdAt != null
          ? DateTime.parse(authUser.createdAt)
          : DateTime.now(),
      updatedAt: authUser.lastSignInAt != null
          ? DateTime.parse(authUser.lastSignInAt!)
          : DateTime.now(),
    );
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      // Sign out demo user if applicable
      DemoAuthService.signOutDemo();

      // Sign out from Supabase
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Refresh current session
  static Future<supabase.AuthResponse> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      return response;
    } catch (e) {
      throw Exception('Session refresh failed: $e');
    }
  }

  // ==================== USER PROFILE MANAGEMENT ====================

  /// Create user profile in database after successful auth
  static Future<void> _createUserProfile(supabase.User authUser) async {
    try {
      final userData = authUser.userMetadata ?? {};
      AppLogger.debug('Creating user profile with metadata: $userData',
          tag: 'AuthService');

      await SupabaseService.createUserProfile(
        userId: authUser.id,
        phone: userData['phone'] ?? '',
        fullName: userData['full_name'] ?? 'Utilisateur',
        userType: UserType.values.byName(
          userData['user_type'] ?? 'customer',
        ),
      );
      AppLogger.info('User profile created in database', tag: 'AuthService');
    } catch (e) {
      AppLogger.error('Failed to create user profile',
          tag: 'AuthService', error: e);
      // Don't throw here - profile creation failure shouldn't block auth
      // throw Exception('Failed to create user profile: $e');
    }
  }

  /// Update user profile
  static Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final authUser = getCurrentAuthUser();
      if (authUser == null) throw Exception('User not authenticated');

      // Update auth metadata if needed
      if (updates.containsKey('full_name') ||
          updates.containsKey('preferred_language')) {
        final metadataUpdates = <String, dynamic>{};
        if (updates.containsKey('full_name')) {
          metadataUpdates['full_name'] = updates['full_name'];
        }
        if (updates.containsKey('preferred_language')) {
          metadataUpdates['preferred_language'] = updates['preferred_language'];
        }

        await _client.auth.updateUser(
          supabase.UserAttributes(data: metadataUpdates),
        );
      }

      // Update profile in database
      return await SupabaseService.updateUserProfile(authUser.id, updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update phone number (requires re-verification)
  static Future<void> updatePhoneNumber(String newPhone) async {
    try {
      final normalizedPhone = _normalizePhoneNumber(newPhone);

      await _client.auth.updateUser(
        supabase.UserAttributes(phone: normalizedPhone),
      );
    } catch (e) {
      throw Exception('Failed to update phone number: $e');
    }
  }

  // ==================== AUTHENTICATION STATE ====================

  /// Listen to authentication state changes
  static Stream<supabase.AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  /// Check if user is authenticated
  static bool get isAuthenticated {
    return getCurrentSession() != null;
  }

  /// Check if current session is valid
  static bool get isSessionValid {
    final session = getCurrentSession();
    if (session == null) return false;

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      session.expiresAt! * 1000,
    );

    return DateTime.now().isBefore(expiresAt);
  }

  // ==================== HELPER METHODS ====================

  /// Normalize phone number to international format for Côte d'Ivoire
  static String _normalizePhoneNumber(String phone) {
    // Remove all non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');

    // Handle different input formats for Côte d'Ivoire
    if (digitsOnly.startsWith('225')) {
      // Already has country code
      return '+$digitsOnly';
    } else if (digitsOnly.startsWith('0')) {
      // Remove leading 0 and add country code
      return '+225${digitsOnly.substring(1)}';
    } else if (digitsOnly.length == 10) {
      // Assume it's a local number, add country code
      return '+225$digitsOnly';
    } else {
      throw Exception('Invalid phone number format for Côte d\'Ivoire');
    }
  }

  /// Validate phone number format
  static bool isValidPhoneNumber(String phone) {
    try {
      final normalized = _normalizePhoneNumber(phone);
      // Côte d'Ivoire phone numbers should be +225 followed by 10 digits
      return RegExp(r'^\+225\d{10}$').hasMatch(normalized);
    } catch (e) {
      return false;
    }
  }

  /// Handle authentication errors with localized messages
  static Exception _handleAuthError(dynamic error) {
    AppLogger.error('Auth error details', tag: 'AuthService', error: error);

    if (error is supabase.AuthException) {
      AppLogger.error('AuthException message: ${error.message}',
          tag: 'AuthService');
      switch (error.message.toLowerCase()) {
        case 'invalid phone number':
          return Exception('Numéro de téléphone invalide');
        case 'user not found':
          return Exception('Utilisateur non trouvé');
        case 'invalid login credentials':
        case 'email not confirmed':
          return Exception(
              'Email ou mot de passe incorrect, ou email non confirmé');
        case 'invalid otp':
        case 'token expired':
          return Exception('Code de vérification invalide ou expiré');
        case 'too many requests':
          return Exception('Trop de tentatives. Veuillez réessayer plus tard');
        case 'signup disabled':
          return Exception('Les inscriptions sont temporairement désactivées');
        case 'email address not confirmed':
          return Exception(
              'Veuillez confirmer votre email avant de vous connecter');
        case 'signups not allowed for otp':
          return Exception(
              'Inscriptions par OTP désactivées. Utilisez l\'email.');
        default:
          return Exception('Erreur d\'authentification: ${error.message}');
      }
    }

    return Exception('Erreur d\'authentification inattendue: $error');
  }
}

// ==================== RIVERPOD PROVIDERS ====================

/// Provider for authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for current user session
final currentSessionProvider = StateProvider<supabase.Session?>((ref) {
  return AuthService.getCurrentSession();
});

/// Provider for authentication state stream
final authStateProvider = StreamProvider<supabase.AuthState>((ref) {
  return AuthService.authStateChanges;
});

/// Provider for authentication status
final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(currentSessionProvider);
  return session != null;
});
