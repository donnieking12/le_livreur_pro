import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/models/payment_models.dart';

class PaymentService {
  static final _supabase = Supabase.instance.client;

  // Payment providers for Côte d'Ivoire
  static const List<String> _supportedProviders = [
    'orange_money',
    'mtn_momo',
    'moov_money',
    'wave',
    'visa',
    'mastercard',
    'cash_on_delivery',
  ];

  // Payment statuses
  static const String _statusPending = 'pending';
  static const String _statusProcessing = 'processing';
  static const String _statusCompleted = 'completed';
  static const String _statusFailed = 'failed';
  static const String _statusRefunded = 'refunded';

  /// Get supported payment providers
  static List<String> get supportedProviders => _supportedProviders;

  /// Initialize payment service
  static Future<void> initialize() async {
    // TODO: Initialize payment provider SDKs
    if (kDebugMode) {
      debugPrint('Payment service initialized');
    }
  }

  // ==================== PAYMENT METHODS ====================

  /// Get available payment methods for user
  static Future<List<Map<String, dynamic>>> getAvailablePaymentMethods({
    required String userId,
    required double amount,
    required String currency,
  }) async {
    final methods = <Map<String, dynamic>>[];

    // Mobile Money (Orange Money, MTN MoMo, Moov Money, Wave)
    methods.addAll([
      {
        'id': 'orange_money',
        'name': 'Orange Money',
        'type': 'mobile_money',
        'icon': 'assets/icons/orange_money.png',
        'description': 'Payer avec Orange Money',
        'isAvailable': true,
        'processingFee': 0.0,
        'processingTime': 'instant',
      },
      {
        'id': 'mtn_momo',
        'name': 'MTN MoMo',
        'type': 'mobile_money',
        'icon': 'assets/icons/mtn_momo.png',
        'description': 'Payer avec MTN Mobile Money',
        'isAvailable': true,
        'processingFee': 0.0,
        'processingTime': 'instant',
      },
      {
        'id': 'moov_money',
        'name': 'Moov Money',
        'type': 'mobile_money',
        'icon': 'assets/icons/moov_money.png',
        'description': 'Payer avec Moov Money',
        'isAvailable': true,
        'processingFee': 0.0,
        'processingTime': 'instant',
      },
      {
        'id': 'wave',
        'name': 'Wave',
        'type': 'mobile_money',
        'icon': 'assets/icons/wave.png',
        'description': 'Payer avec Wave',
        'isAvailable': true,
        'processingFee': 0.0,
        'processingTime': 'instant',
      },
    ]);

    // Card payments
    methods.addAll([
      {
        'id': 'visa',
        'name': 'Visa',
        'type': 'card',
        'icon': 'assets/icons/visa.png',
        'description': 'Payer avec votre carte Visa',
        'isAvailable': true,
        'processingFee': amount * 0.025, // 2.5%
        'processingTime': '2-3 business days',
      },
      {
        'id': 'mastercard',
        'name': 'Mastercard',
        'type': 'card',
        'icon': 'assets/icons/mastercard.png',
        'description': 'Payer avec votre carte Mastercard',
        'isAvailable': true,
        'processingFee': amount * 0.025, // 2.5%
        'processingTime': '2-3 business days',
      },
    ]);

    // Cash on delivery
    methods.add({
      'id': 'cash_on_delivery',
      'name': 'Paiement à la livraison',
      'type': 'cash',
      'icon': 'assets/icons/cash.png',
      'description': 'Payer en espèces à la livraison',
      'isAvailable': true,
      'processingFee': 0.0,
      'processingTime': 'upon_delivery',
    });

    return methods;
  }

  // ==================== PAYMENT PROCESSING ====================

  /// Process payment
  static Future<PaymentResult> processPayment({
    required String paymentMethodId,
    required String orderId,
    required double amount,
    required String currency,
    required String userId,
    Map<String, dynamic>? customerDetails,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      // Generate payment reference
      final paymentRef = _generatePaymentReference();

      // Create payment record
      await _createPaymentRecord(
        paymentRef: paymentRef,
        orderId: orderId,
        userId: userId,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethodId,
        status: _statusProcessing,
      );

      // Process payment based on method
      PaymentResult result;
      final details = paymentDetails ?? {};
      final customerPhoneNumber = customerDetails?['phone'] ?? '';

      switch (paymentMethodId) {
        case 'orange_money':
        case 'orangeMoney':
          result = await _processOrangeMoneyPayment(
            amount: amount,
            phoneNumber: details['phone_number'] ?? customerPhoneNumber,
            paymentRef: paymentRef,
          );
          break;

        case 'mtn_money':
        case 'mtnMoney':
          result = await _processMTNMoMoPayment(
            amount: amount,
            phoneNumber: details['phone_number'] ?? customerPhoneNumber,
            paymentRef: paymentRef,
          );
          break;

        case 'moov_money':
        case 'moovMoney':
          result = await _processMoovMoneyPayment(
            amount: amount,
            phoneNumber: details['phone_number'] ?? customerPhoneNumber,
            paymentRef: paymentRef,
          );
          break;

        case 'wave':
          result = await _processWavePayment(
            amount: amount,
            phoneNumber: details['phone_number'] ?? customerPhoneNumber,
            paymentRef: paymentRef,
          );
          break;

        case 'visa':
        case 'mastercard':
          result = await _processCardPayment(
            amount: amount,
            cardDetails: details,
            paymentRef: paymentRef,
          );
          break;

        case 'cash_on_delivery':
        case 'cashOnDelivery':
          result = await _processCashOnDelivery(
            amount: amount,
            paymentRef: paymentRef,
          );
          break;

        default:
          throw Exception('Unsupported payment method: $paymentMethodId');
      }

      // Update payment record with result
      await _updatePaymentRecord(
        paymentRef: paymentRef,
        status: result.isSuccess ? _statusCompleted : _statusFailed,
        transactionId: result.transactionId,
        errorMessage: result.errorMessage,
      );

      return result;
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        paymentRef: '',
        transactionId: '',
        errorMessage: e.toString(),
        amount: amount,
        currency: currency,
      );
    }
  }

  // ==================== MOBILE MONEY PAYMENTS ====================

  /// Process Orange Money payment
  static Future<PaymentResult> _processOrangeMoneyPayment({
    required double amount,
    required String phoneNumber,
    required String paymentRef,
  }) async {
    try {
      // TODO: Integrate with Orange Money API
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 3));

      // Simulate success (90% success rate)
      final isSuccess = DateTime.now().millisecond % 10 != 0;

      if (isSuccess) {
        return PaymentResult(
          isSuccess: true,
          paymentRef: paymentRef,
          transactionId: 'OM_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: '',
          amount: amount,
          currency: 'XOF',
        );
      } else {
        return PaymentResult(
          isSuccess: false,
          paymentRef: paymentRef,
          transactionId: 'OM_FAILED_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: 'Paiement Orange Money échoué',
          amount: amount,
          currency: 'XOF',
        );
      }
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        paymentRef: paymentRef,
        transactionId: 'OM_ERROR_${DateTime.now().millisecondsSinceEpoch}',
        errorMessage: 'Erreur Orange Money: $e',
        amount: amount,
        currency: 'XOF',
      );
    }
  }

  /// Process MTN MoMo payment
  static Future<PaymentResult> _processMTNMoMoPayment({
    required double amount,
    required String phoneNumber,
    required String paymentRef,
  }) async {
    try {
      // TODO: Integrate with MTN MoMo API
      await Future.delayed(const Duration(seconds: 2));

      final isSuccess =
          DateTime.now().millisecond % 8 != 0; // 87.5% success rate

      if (isSuccess) {
        return PaymentResult(
          isSuccess: true,
          paymentRef: paymentRef,
          transactionId: 'MTN_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: '',
          amount: amount,
          currency: 'XOF',
        );
      } else {
        return PaymentResult(
          isSuccess: false,
          paymentRef: paymentRef,
          transactionId: 'MTN_FAILED_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: 'Paiement MTN MoMo échoué',
          amount: amount,
          currency: 'XOF',
        );
      }
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        paymentRef: paymentRef,
        transactionId: 'MTN_ERROR_${DateTime.now().millisecondsSinceEpoch}',
        errorMessage: 'Erreur MTN MoMo: $e',
        amount: amount,
        currency: 'XOF',
      );
    }
  }

  /// Process Moov Money payment
  static Future<PaymentResult> _processMoovMoneyPayment({
    required double amount,
    required String phoneNumber,
    required String paymentRef,
  }) async {
    try {
      // TODO: Integrate with Moov Money API
      await Future.delayed(const Duration(milliseconds: 2500));

      final isSuccess =
          DateTime.now().millisecond % 12 != 0; // 91.7% success rate

      if (isSuccess) {
        return PaymentResult(
          isSuccess: true,
          paymentRef: paymentRef,
          transactionId: 'MOOV_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: '',
          amount: amount,
          currency: 'XOF',
        );
      } else {
        return PaymentResult(
          isSuccess: false,
          paymentRef: paymentRef,
          transactionId: 'MOOV_FAILED_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: 'Paiement Moov Money échoué',
          amount: amount,
          currency: 'XOF',
        );
      }
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        paymentRef: paymentRef,
        transactionId: 'MOOV_ERROR_${DateTime.now().millisecondsSinceEpoch}',
        errorMessage: 'Erreur Moov Money: $e',
        amount: amount,
        currency: 'XOF',
      );
    }
  }

  /// Process Wave payment
  static Future<PaymentResult> _processWavePayment({
    required double amount,
    required String phoneNumber,
    required String paymentRef,
  }) async {
    try {
      // TODO: Integrate with Wave API
      await Future.delayed(const Duration(seconds: 2));

      final isSuccess =
          DateTime.now().millisecond % 10 != 0; // 90% success rate

      if (isSuccess) {
        return PaymentResult(
          isSuccess: true,
          paymentRef: paymentRef,
          transactionId: 'WAVE_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: '',
          amount: amount,
          currency: 'XOF',
        );
      } else {
        return PaymentResult(
          isSuccess: false,
          paymentRef: paymentRef,
          transactionId: 'WAVE_FAILED_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: 'Paiement Wave échoué',
          amount: amount,
          currency: 'XOF',
        );
      }
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        paymentRef: paymentRef,
        transactionId: 'WAVE_ERROR_${DateTime.now().millisecondsSinceEpoch}',
        errorMessage: 'Erreur Wave: $e',
        amount: amount,
        currency: 'XOF',
      );
    }
  }

  // ==================== CARD PAYMENTS ====================

  /// Process card payment
  static Future<PaymentResult> _processCardPayment({
    required double amount,
    required Map<String, dynamic> cardDetails,
    required String paymentRef,
  }) async {
    try {
      // TODO: Integrate with payment gateway (Stripe, PayPal, etc.)
      await Future.delayed(const Duration(seconds: 4));

      // Validate card details
      if (!_validateCardDetails(cardDetails)) {
        return PaymentResult(
          isSuccess: false,
          paymentRef: paymentRef,
          transactionId:
              'CARD_INVALID_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: 'Détails de carte invalides',
          amount: amount,
          currency: 'XOF',
        );
      }

      final isSuccess =
          DateTime.now().millisecond % 15 != 0; // 93.3% success rate

      if (isSuccess) {
        return PaymentResult(
          isSuccess: true,
          paymentRef: paymentRef,
          transactionId: 'CARD_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: '',
          amount: amount,
          currency: 'XOF',
        );
      } else {
        return PaymentResult(
          isSuccess: false,
          paymentRef: paymentRef,
          transactionId: 'CARD_FAILED_${DateTime.now().millisecondsSinceEpoch}',
          errorMessage: 'Paiement par carte échoué',
          amount: amount,
          currency: 'XOF',
        );
      }
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        paymentRef: paymentRef,
        transactionId: 'CARD_ERROR_${DateTime.now().millisecondsSinceEpoch}',
        errorMessage: 'Erreur de paiement par carte: $e',
        amount: amount,
        currency: 'XOF',
      );
    }
  }

  /// Validate card details
  static bool _validateCardDetails(Map<String, dynamic> cardDetails) {
    final cardNumber = cardDetails['card_number'] as String?;
    final expiryMonth = cardDetails['expiry_month'] as int?;
    final expiryYear = cardDetails['expiry_year'] as int?;
    final cvv = cardDetails['cvv'] as String?;

    if (cardNumber == null ||
        cardNumber.length < 13 ||
        cardNumber.length > 19) {
      return false;
    }

    if (expiryMonth == null || expiryMonth < 1 || expiryMonth > 12) {
      return false;
    }

    if (expiryYear == null || expiryYear < DateTime.now().year) {
      return false;
    }

    if (cvv == null || cvv.length < 3 || cvv.length > 4) {
      return false;
    }

    return true;
  }

  // ==================== CASH ON DELIVERY ====================

  /// Process cash on delivery
  static Future<PaymentResult> _processCashOnDelivery({
    required double amount,
    required String paymentRef,
  }) async {
    // Cash on delivery is always successful
    return PaymentResult(
      isSuccess: true,
      paymentRef: paymentRef,
      transactionId: 'COD_${DateTime.now().millisecondsSinceEpoch}',
      errorMessage: '',
      amount: amount,
      currency: 'XOF',
    );
  }

  // ==================== PAYMENT RECORDS ====================

  /// Create payment record in database
  static Future<void> _createPaymentRecord({
    required String paymentRef,
    required String orderId,
    required String userId,
    required double amount,
    required String currency,
    required String paymentMethod,
    required String status,
  }) async {
    try {
      await _supabase.from('payment_transactions').insert({
        'payment_ref': paymentRef,
        'order_id': orderId,
        'user_id': userId,
        'provider': paymentMethod,
        'type': 'payment',
        'status': status,
        'amount': amount,
        'currency': currency,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (kDebugMode) {
        debugPrint('Payment record created: $paymentRef');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to create payment record: $e');
      }
      // Don't throw here to avoid breaking payment flow for logging issues
    }
  }

  /// Update payment record
  static Future<void> _updatePaymentRecord({
    required String paymentRef,
    required String status,
    String? transactionId,
    String? errorMessage,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (transactionId != null) {
        updateData['external_transaction_id'] = transactionId;
      }

      if (errorMessage != null) {
        updateData['failure_reason'] = errorMessage;
      }

      if (status == _statusCompleted) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('payment_transactions')
          .update(updateData)
          .eq('payment_ref', paymentRef);

      if (kDebugMode) {
        debugPrint('Payment record updated: $paymentRef - $status');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to update payment record: $e');
      }
    }
  }

  // ==================== REFUNDS ====================

  /// Process refund
  static Future<RefundResult> processRefund({
    required String paymentRef,
    required double amount,
    required String reason,
  }) async {
    try {
      // TODO: Implement refund logic with payment providers
      await Future.delayed(const Duration(seconds: 2));

      final isSuccess = DateTime.now().millisecond % 5 != 0; // 80% success rate

      if (isSuccess) {
        return RefundResult(
          isSuccess: true,
          refundId: 'REF_${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          reason: reason,
          processedAt: DateTime.now(),
        );
      } else {
        return RefundResult(
          isSuccess: false,
          refundId: 'REF_FAILED_${DateTime.now().millisecondsSinceEpoch}',
          amount: amount,
          reason: reason,
          processedAt: null,
          errorMessage: 'Remboursement échoué',
        );
      }
    } catch (e) {
      return RefundResult(
        isSuccess: false,
        refundId: 'REF_ERROR_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        reason: reason,
        processedAt: null,
        errorMessage: 'Erreur de remboursement: $e',
      );
    }
  }

  // ==================== UTILITIES ====================

  /// Generate unique payment reference
  static String _generatePaymentReference() {
    const uuid = Uuid();
    return 'PAY_${uuid.v4().substring(0, 8).toUpperCase()}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Get payment status
  static Future<String> getPaymentStatus(String paymentRef) async {
    try {
      final response = await _supabase
          .from('payment_transactions')
          .select('status')
          .eq('payment_ref', paymentRef)
          .maybeSingle();

      return response?['status'] as String? ?? _statusFailed;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get payment status: $e');
      }
      return _statusFailed;
    }
  }

  /// Get payment history for user
  static Future<List<PaymentTransaction>> getPaymentHistory(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('payment_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => PaymentTransaction.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get payment history: $e');
      }
      return [];
    }
  }

  /// Get payment transactions for order
  static Future<List<PaymentTransaction>> getOrderPayments(
      String orderId) async {
    try {
      final response = await _supabase
          .from('payment_transactions')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentTransaction.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get order payments: $e');
      }
      return [];
    }
  }

  /// Get payment summary for user
  static Future<PaymentSummary?> getPaymentSummary(String userId) async {
    try {
      // This would typically be a more complex query or stored procedure
      final transactions = await getPaymentHistory(userId, limit: 1000);

      if (transactions.isEmpty) return null;

      final totalPaid = transactions
          .where((t) => t.isSuccess && t.type == PaymentTransactionType.payment)
          .fold(0.0, (sum, t) => sum + t.amount);

      final totalRefunded = transactions
          .where((t) => t.isSuccess && t.type == PaymentTransactionType.refund)
          .fold(0.0, (sum, t) => sum + t.amount);

      final successfulTransactions =
          transactions.where((t) => t.isSuccess).length;

      final failedTransactions = transactions.where((t) => t.hasFailed).length;

      final paymentsByProvider = <PaymentProvider, double>{};
      for (final transaction in transactions) {
        if (transaction.isSuccess &&
            transaction.type == PaymentTransactionType.payment) {
          paymentsByProvider[transaction.provider] =
              (paymentsByProvider[transaction.provider] ?? 0.0) +
                  transaction.amount;
        }
      }

      return PaymentSummary(
        userId: userId,
        totalPaid: totalPaid,
        totalRefunded: totalRefunded,
        totalTransactions: transactions.length,
        successfulTransactions: successfulTransactions,
        failedTransactions: failedTransactions,
        paymentsByProvider: paymentsByProvider,
        lastPaymentDate: transactions.first.createdAt,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to get payment summary: $e');
      }
      return null;
    }
  }

  /// Get payment method details
  static Map<String, dynamic>? getPaymentMethodDetails(String methodId) {
    final methods = [
      {
        'id': 'orange_money',
        'name': 'Orange Money',
        'description': 'Service de paiement mobile d\'Orange',
        'logo': 'assets/icons/orange_money.png',
        'supported_currencies': ['XOF'],
        'min_amount': 100,
        'max_amount': 500000,
      },
      {
        'id': 'mtn_momo',
        'name': 'MTN MoMo',
        'description': 'Service de paiement mobile de MTN',
        'logo': 'assets/icons/mtn_momo.png',
        'supported_currencies': ['XOF'],
        'min_amount': 100,
        'max_amount': 500000,
      },
      {
        'id': 'moov_money',
        'name': 'Moov Money',
        'description': 'Service de paiement mobile de Moov',
        'logo': 'assets/icons/moov_money.png',
        'supported_currencies': ['XOF'],
        'min_amount': 100,
        'max_amount': 500000,
      },
      {
        'id': 'wave',
        'name': 'Wave',
        'description': 'Service de paiement mobile Wave',
        'logo': 'assets/icons/wave.png',
        'supported_currencies': ['XOF'],
        'min_amount': 100,
        'max_amount': 500000,
      },
      {
        'id': 'visa',
        'name': 'Visa',
        'description': 'Cartes de crédit et de débit Visa',
        'logo': 'assets/icons/visa.png',
        'supported_currencies': ['XOF', 'USD', 'EUR'],
        'min_amount': 100,
        'max_amount': 1000000,
      },
      {
        'id': 'mastercard',
        'name': 'Mastercard',
        'description': 'Cartes de crédit et de débit Mastercard',
        'logo': 'assets/icons/mastercard.png',
        'supported_currencies': ['XOF', 'USD', 'EUR'],
        'min_amount': 100,
        'max_amount': 1000000,
      },
      {
        'id': 'cash_on_delivery',
        'name': 'Paiement à la livraison',
        'description': 'Paiement en espèces à la livraison',
        'logo': 'assets/icons/cash.png',
        'supported_currencies': ['XOF'],
        'min_amount': 100,
        'max_amount': 100000,
      },
    ];

    try {
      return methods.firstWhere((method) => method['id'] == methodId);
    } catch (e) {
      return null;
    }
  }
}

// ==================== DATA MODELS ====================

/// Payment result model
class PaymentResult {
  final bool isSuccess;
  final String paymentRef;
  final String transactionId;
  final String errorMessage;
  final double amount;
  final String currency;

  PaymentResult({
    required this.isSuccess,
    required this.paymentRef,
    required this.transactionId,
    required this.errorMessage,
    required this.amount,
    required this.currency,
  });
}

/// Refund result model
class RefundResult {
  final bool isSuccess;
  final String refundId;
  final double amount;
  final String reason;
  final DateTime? processedAt;
  final String? errorMessage;

  RefundResult({
    required this.isSuccess,
    required this.refundId,
    required this.amount,
    required this.reason,
    this.processedAt,
    this.errorMessage,
  });
}
