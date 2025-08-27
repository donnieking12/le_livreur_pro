import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'package:le_livreur_pro/core/config/app_config.dart';
import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/services/supabase_service.dart';

// Provider for current user profile
final currentUserProfileProvider = FutureProvider<User?>((ref) async {
  return await AuthService.getCurrentUserProfile();
});

// Provider for auth state notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier();
});

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

  Future<void> signInWithPhone(String phone) async {
    try {
      await AuthService.signInWithPhone(phone);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUpWithPhone({
    required String phone,
    required String fullName,
    required UserType userType,
  }) async {
    try {
      await AuthService.signUpWithPhone(
        phone: phone,
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

  /// Send OTP to phone number for sign in
  static Future<void> signInWithPhone(String phone) async {
    try {
      // Validate phone number format for Côte d'Ivoire
      final normalizedPhone = _normalizePhoneNumber(phone);

      await _client.auth.signInWithOtp(
        phone: normalizedPhone,
        shouldCreateUser: false, // Only sign in existing users
      );
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  /// Send OTP to phone number for sign up
  static Future<void> signUpWithPhone({
    required String phone,
    required String fullName,
    required UserType userType,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Validate phone number format
      final normalizedPhone = _normalizePhoneNumber(phone);

      final userData = {
        'full_name': fullName,
        'user_type': userType.name,
        'phone': normalizedPhone,
        'preferred_language': 'fr', // Default to French for Côte d'Ivoire
        ...?additionalData,
      };

      await _client.auth.signInWithOtp(
        phone: normalizedPhone,
        shouldCreateUser: true,
        data: userData,
      );
    } catch (e) {
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

    return await SupabaseService.getUserProfile(authUser.id);
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
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
      final userData = authUser.userMetadata;

      await SupabaseService.createUserProfile(
        userId: authUser.id,
        phone: userData?['phone'] ?? '',
        fullName: userData?['full_name'] ?? '',
        userType: UserType.values.byName(
          userData?['user_type'] ?? 'customer',
        ),
      );
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
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
    if (error is supabase.AuthException) {
      switch (error.message.toLowerCase()) {
        case 'invalid phone number':
          return Exception('Numéro de téléphone invalide');
        case 'user not found':
          return Exception('Utilisateur non trouvé');
        case 'invalid otp':
        case 'token expired':
          return Exception('Code de vérification invalide ou expiré');
        case 'too many requests':
          return Exception('Trop de tentatives. Veuillez réessayer plus tard');
        case 'signup disabled':
          return Exception('Les inscriptions sont temporairement désactivées');
        default:
          return Exception('Erreur d\'authentification: ${error.message}');
      }
    }

    return Exception('Erreur d\'authentification inattendue');
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

/// Provider for current user profile stream
final currentUserProvider = FutureProvider<User?>((ref) async {
  return await AuthService.getCurrentUserProfile();
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
