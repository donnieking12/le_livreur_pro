import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Centralized error handling for Le Livreur Pro
class ErrorHandler {
  static const String _defaultErrorMessage = 'Une erreur inattendue s\'est produite';

  /// Handle errors with proper logging and user feedback
  static void handleError({
    required dynamic error,
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
    BuildContext? buildContext,
  }) {
    // Log error for debugging
    _logError(error, stackTrace, context);

    // Show user-friendly message if requested
    if (showToUser && buildContext != null) {
      _showErrorToUser(buildContext, error);
    }
  }

  /// Log error with proper formatting
  static void _logError(dynamic error, StackTrace? stackTrace, String? context) {
    if (kDebugMode) {
      debugPrint('❌ ERROR ${context != null ? '[$context]' : ''}: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Show error message to user
  static void _showErrorToUser(BuildContext context, dynamic error) {
    final message = _getUserFriendlyMessage(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Convert technical errors to user-friendly messages
  static String _getUserFriendlyMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Problème de connexion internet. Veuillez vérifier votre connexion.';
    } else if (errorString.contains('timeout')) {
      return 'La requête a pris trop de temps. Veuillez réessayer.';
    } else if (errorString.contains('server') || errorString.contains('500')) {
      return 'Problème du serveur. Veuillez réessayer plus tard.';
    } else if (errorString.contains('authentication') || errorString.contains('unauthorized')) {
      return 'Problème d\'authentification. Veuillez vous reconnecter.';
    } else if (errorString.contains('permission') || errorString.contains('forbidden')) {
      return 'Vous n\'avez pas l\'autorisation pour cette action.';
    } else if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Ressource non trouvée.';
    } else {
      return _defaultErrorMessage;
    }
  }

  /// Validate email format
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Veuillez entrer votre adresse email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Format d\'email invalide';
    }
    
    return null;
  }

  /// Validate phone number format (Ivorian format)
  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    
    // Remove all non-digit characters
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check Ivorian phone number formats
    if (cleanPhone.length == 8) {
      // Local format: 07123456
      if (cleanPhone.startsWith('0')) {
        return null;
      }
    } else if (cleanPhone.length == 10) {
      // National format: 2250712345678
      if (cleanPhone.startsWith('225')) {
        return null;
      }
    } else if (cleanPhone.length == 13) {
      // International format: +2250712345678
      if (cleanPhone.startsWith('225')) {
        return null;
      }
    }
    
    return 'Format de numéro invalide. Utilisez le format ivoirien.';
  }

  /// Validate password strength
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    
    if (password.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Le champ $fieldName est requis';
    }
    return null;
  }

  /// Validate amount (positive number)
  static String? validateAmount(String? amount) {
    if (amount == null || amount.isEmpty) {
      return 'Veuillez entrer un montant';
    }
    
    final parsedAmount = double.tryParse(amount);
    if (parsedAmount == null || parsedAmount <= 0) {
      return 'Montant invalide';
    }
    
    return null;
  }
}