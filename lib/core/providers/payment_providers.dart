import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_livreur_pro/core/models/payment_models.dart';
import 'package:le_livreur_pro/core/services/payment_service.dart';

// Payment Methods Provider
final paymentMethodsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, PaymentMethodsRequest>(
        (ref, request) async {
  return await PaymentService.getAvailablePaymentMethods(
    userId: request.userId,
    amount: request.amount,
    currency: request.currency,
  );
});

// Payment History Provider
final paymentHistoryProvider =
    FutureProvider.family<List<PaymentTransaction>, String>(
        (ref, userId) async {
  return await PaymentService.getPaymentHistory(userId);
});

// Payment Summary Provider
final paymentSummaryProvider =
    FutureProvider.family<PaymentSummary?, String>((ref, userId) async {
  return await PaymentService.getPaymentSummary(userId);
});

// Order Payments Provider
final orderPaymentsProvider =
    FutureProvider.family<List<PaymentTransaction>, String>(
        (ref, orderId) async {
  return await PaymentService.getOrderPayments(orderId);
});

// Payment Status Provider
final paymentStatusProvider =
    FutureProvider.family<String, String>((ref, paymentRef) async {
  return await PaymentService.getPaymentStatus(paymentRef);
});

// Payment Processing State Provider
final paymentProcessingProvider =
    StateNotifierProvider<PaymentProcessingNotifier, PaymentProcessingState>(
        (ref) {
  return PaymentProcessingNotifier();
});

// Payment Method Configurations Provider
final paymentMethodConfigurationsProvider =
    Provider<List<PaymentMethodConfiguration>>((ref) {
  return PaymentMethodConfiguration.defaultMethods;
});

// Selected Payment Method Provider
final selectedPaymentMethodProvider =
    StateProvider<PaymentMethodConfiguration?>((ref) => null);

// Current Payment Transaction Provider
final currentPaymentTransactionProvider =
    StateProvider<PaymentTransaction?>((ref) => null);

// Classes for Provider Parameters
class PaymentMethodsRequest {
  final String userId;
  final double amount;
  final String currency;

  const PaymentMethodsRequest({
    required this.userId,
    required this.amount,
    required this.currency,
  });
}

// Payment Processing State Management
class PaymentProcessingState {
  final bool isProcessing;
  final String? currentPaymentRef;
  final String? errorMessage;
  final PaymentResult? result;

  const PaymentProcessingState({
    this.isProcessing = false,
    this.currentPaymentRef,
    this.errorMessage,
    this.result,
  });

  PaymentProcessingState copyWith({
    bool? isProcessing,
    String? currentPaymentRef,
    String? errorMessage,
    PaymentResult? result,
  }) {
    return PaymentProcessingState(
      isProcessing: isProcessing ?? this.isProcessing,
      currentPaymentRef: currentPaymentRef ?? this.currentPaymentRef,
      errorMessage: errorMessage ?? this.errorMessage,
      result: result ?? this.result,
    );
  }
}

class PaymentProcessingNotifier extends StateNotifier<PaymentProcessingState> {
  PaymentProcessingNotifier() : super(const PaymentProcessingState());

  Future<void> processPayment({
    required String paymentMethodId,
    required String orderId,
    required double amount,
    required String currency,
    required String userId,
    Map<String, dynamic>? customerDetails,
    Map<String, dynamic>? paymentDetails,
  }) async {
    state = state.copyWith(
      isProcessing: true,
      errorMessage: null,
      result: null,
    );

    try {
      final result = await PaymentService.processPayment(
        paymentMethodId: paymentMethodId,
        orderId: orderId,
        amount: amount,
        currency: currency,
        userId: userId,
        customerDetails: customerDetails,
        paymentDetails: paymentDetails,
      );

      state = state.copyWith(
        isProcessing: false,
        currentPaymentRef: result.paymentRef,
        result: result,
        errorMessage: result.isSuccess ? null : result.errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> processRefund({
    required String paymentRef,
    required double amount,
    required String reason,
  }) async {
    state = state.copyWith(
      isProcessing: true,
      errorMessage: null,
    );

    try {
      final result = await PaymentService.processRefund(
        paymentRef: paymentRef,
        amount: amount,
        reason: reason,
      );

      state = state.copyWith(
        isProcessing: false,
        errorMessage: result.isSuccess ? null : result.errorMessage,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
    }
  }

  void clearState() {
    state = const PaymentProcessingState();
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Utility Providers
final enabledPaymentMethodsProvider =
    Provider<List<PaymentMethodConfiguration>>((ref) {
  final configurations = ref.watch(paymentMethodConfigurationsProvider);
  return configurations.where((config) => config.isEnabled).toList();
});

final mobileMoneyMethodsProvider =
    Provider<List<PaymentMethodConfiguration>>((ref) {
  final configurations = ref.watch(enabledPaymentMethodsProvider);
  return configurations.where((config) => config.requiresPhoneNumber).toList();
});

final cardPaymentMethodsProvider =
    Provider<List<PaymentMethodConfiguration>>((ref) {
  final configurations = ref.watch(enabledPaymentMethodsProvider);
  return configurations.where((config) => config.requiresCardDetails).toList();
});

final instantPaymentMethodsProvider =
    Provider<List<PaymentMethodConfiguration>>((ref) {
  final configurations = ref.watch(enabledPaymentMethodsProvider);
  return configurations.where((config) => config.isInstant).toList();
});

// Provider for checking if a payment method is available for an amount
final paymentMethodAvailabilityProvider =
    Provider.family<bool, PaymentMethodAvailabilityRequest>((ref, request) {
  final config = request.configuration;
  return config.isEnabled &&
      request.amount >= config.minimumAmount &&
      request.amount <= config.maximumAmount &&
      config.supportedCurrencies.contains(request.currency);
});

class PaymentMethodAvailabilityRequest {
  final PaymentMethodConfiguration configuration;
  final double amount;
  final String currency;

  const PaymentMethodAvailabilityRequest({
    required this.configuration,
    required this.amount,
    required this.currency,
  });
}

// Provider for calculating total cost including fees
final paymentTotalCostProvider =
    Provider.family<double, PaymentCostRequest>((ref, request) {
  final config = request.configuration;
  final fee = config.processingFee <= 1.0
      ? request.amount * config.processingFee // Percentage fee
      : config.processingFee; // Fixed fee
  return request.amount + fee;
});

class PaymentCostRequest {
  final PaymentMethodConfiguration configuration;
  final double amount;

  const PaymentCostRequest({
    required this.configuration,
    required this.amount,
  });
}
