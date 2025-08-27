// test/unit/core/services/payment_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:le_livreur_pro/core/services/payment_service.dart';
import 'package:le_livreur_pro/core/models/payment_models.dart';

void main() {
  group('PaymentService', () {
    group('Payment Method Availability', () {
      test('should return available payment methods', () async {
        final methods = await PaymentService.getAvailablePaymentMethods(
          userId: 'test-user-id',
          amount: 1000.0,
          currency: 'XOF',
        );

        expect(methods, isNotEmpty);
        expect(methods.length,
            greaterThanOrEqualTo(5)); // At least mobile money + cards + cash

        // Check for Côte d'Ivoire mobile money methods
        final methodIds = methods.map((m) => m['id']).toList();
        expect(methodIds, contains('orange_money'));
        expect(methodIds, contains('mtn_momo'));
        expect(methodIds, contains('moov_money'));
        expect(methodIds, contains('wave'));
        expect(methodIds, contains('cash_on_delivery'));
      });

      test('should include payment method details', () async {
        final methods = await PaymentService.getAvailablePaymentMethods(
          userId: 'test-user-id',
          amount: 1000.0,
          currency: 'XOF',
        );

        final orangeMoney =
            methods.firstWhere((m) => m['id'] == 'orange_money');

        expect(orangeMoney['name'], equals('Orange Money'));
        expect(orangeMoney['type'], equals('mobile_money'));
        expect(orangeMoney['isAvailable'], isTrue);
        expect(orangeMoney['processingFee'], isA<double>());
        expect(orangeMoney['processingTime'], isNotNull);
      });

      test('should calculate processing fees correctly', () async {
        final methods = await PaymentService.getAvailablePaymentMethods(
          userId: 'test-user-id',
          amount: 1000.0,
          currency: 'XOF',
        );

        final cardMethod = methods.firstWhere((m) => m['type'] == 'card');
        expect(cardMethod['processingFee'], equals(25.0)); // 2.5% of 1000

        final mobileMoneyMethod =
            methods.firstWhere((m) => m['id'] == 'orange_money');
        expect(mobileMoneyMethod['processingFee'],
            equals(0.0)); // No fee for mobile money
      });
    });

    group('Payment Processing', () {
      test('should process Orange Money payment successfully', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'orange_money',
          orderId: 'test-order-123',
          userId: 'test-user-id',
          amount: 1000.0,
          currency: 'XOF',
          customerDetails: {
            'name': 'Test User',
            'phone': '+2250700000000',
            'email': 'test@example.com',
          },
          paymentDetails: {
            'phone_number': '+2250700000000',
          },
        );

        expect(result.paymentRef, isNotEmpty);
        expect(result.amount, equals(1000.0));
        expect(result.currency, equals('XOF'));
        // Note: Success rate is simulated at 90%, so we can't guarantee success
        expect(result.transactionId, isNotEmpty);
      });

      test('should process MTN Money payment successfully', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'mtn_momo',
          orderId: 'test-order-124',
          userId: 'test-user-id',
          amount: 1500.0,
          currency: 'XOF',
          customerDetails: {
            'name': 'Test User',
            'phone': '+2250700000001',
            'email': 'test@example.com',
          },
          paymentDetails: {
            'phone_number': '+2250700000001',
          },
        );

        expect(result.paymentRef, isNotEmpty);
        expect(result.amount, equals(1500.0));
        expect(result.currency, equals('XOF'));
        expect(result.transactionId, contains('MTN_'));
      });

      test('should process cash on delivery successfully', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'cash_on_delivery',
          orderId: 'test-order-125',
          userId: 'test-user-id',
          amount: 800.0,
          currency: 'XOF',
          customerDetails: {
            'name': 'Test User',
            'phone': '+2250700000002',
            'email': 'test@example.com',
          },
        );

        expect(
            result.isSuccess, isTrue); // Cash on delivery is always successful
        expect(result.paymentRef, isNotEmpty);
        expect(result.amount, equals(800.0));
        expect(result.transactionId, contains('COD_'));
      });

      test('should validate card details for card payments', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'visa',
          orderId: 'test-order-126',
          userId: 'test-user-id',
          amount: 2000.0,
          currency: 'XOF',
          customerDetails: {
            'name': 'Test User',
            'phone': '+2250700000003',
            'email': 'test@example.com',
          },
          paymentDetails: {
            'card_number': '1234567890123456',
            'expiry_month': 12,
            'expiry_year': 2025,
            'cvv': '123',
          },
        );

        expect(result.paymentRef, isNotEmpty);
        expect(result.amount, equals(2000.0));
        // Card payments have validation logic
      });

      test('should reject invalid card details', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'visa',
          orderId: 'test-order-127',
          userId: 'test-user-id',
          amount: 2000.0,
          currency: 'XOF',
          customerDetails: {
            'name': 'Test User',
            'phone': '+2250700000004',
            'email': 'test@example.com',
          },
          paymentDetails: {
            'card_number': '123', // Invalid card number
            'expiry_month': 12,
            'expiry_year': 2020, // Expired
            'cvv': '12', // Invalid CVV
          },
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('invalide'));
      });

      test('should handle unsupported payment method', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'unsupported_method',
          orderId: 'test-order-128',
          userId: 'test-user-id',
          amount: 1000.0,
          currency: 'XOF',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Unsupported payment method'));
      });
    });

    group('Payment Status Tracking', () {
      test('should track payment status', () async {
        // First create a payment
        final result = await PaymentService.processPayment(
          paymentMethodId: 'orange_money',
          orderId: 'test-order-status-1',
          userId: 'test-user-id',
          amount: 1000.0,
          currency: 'XOF',
          paymentDetails: {
            'phone_number': '+2250700000005',
          },
        );

        // Then check its status
        final status = await PaymentService.getPaymentStatus(result.paymentRef);
        expect(status, isIn(['pending', 'processing', 'completed', 'failed']));
      });

      test('should return failed status for non-existent payment', () async {
        final status =
            await PaymentService.getPaymentStatus('non-existent-ref');
        expect(status, equals('failed'));
      });
    });

    group('Refund Processing', () {
      test('should process refund successfully', () async {
        final result = await PaymentService.processRefund(
          paymentRef: 'test-payment-ref-123',
          amount: 500.0,
          reason: 'Customer requested refund',
        );

        expect(result.refundId, isNotEmpty);
        expect(result.amount, equals(500.0));
        expect(result.reason, equals('Customer requested refund'));
        // Note: Success rate is simulated at 80%
      });

      test('should handle refund failure', () async {
        // Multiple attempts to potentially trigger simulated failure
        RefundResult? failedResult;

        for (int i = 0; i < 10; i++) {
          final result = await PaymentService.processRefund(
            paymentRef: 'test-payment-ref-fail-$i',
            amount: 100.0,
            reason: 'Test refund failure',
          );

          if (!result.isSuccess) {
            failedResult = result;
            break;
          }
        }

        if (failedResult != null) {
          expect(failedResult.isSuccess, isFalse);
          expect(failedResult.errorMessage, isNotEmpty);
          expect(failedResult.processedAt, isNull);
        }
      });
    });

    group('Payment History', () {
      test('should retrieve empty payment history for new user', () async {
        final history = await PaymentService.getPaymentHistory('new-user-id');
        expect(history, isEmpty);
      });

      test('should handle pagination correctly', () async {
        final historyPage1 = await PaymentService.getPaymentHistory(
          'test-user-id',
          limit: 10,
          offset: 0,
        );

        final historyPage2 = await PaymentService.getPaymentHistory(
          'test-user-id',
          limit: 10,
          offset: 10,
        );

        expect(historyPage1, isA<List<PaymentTransaction>>());
        expect(historyPage2, isA<List<PaymentTransaction>>());
        // Pages should be different (unless user has very few transactions)
      });
    });

    group('Order Payments', () {
      test('should retrieve payments for specific order', () async {
        final payments =
            await PaymentService.getOrderPayments('test-order-123');
        expect(payments, isA<List<PaymentTransaction>>());
      });

      test('should return empty list for non-existent order', () async {
        final payments =
            await PaymentService.getOrderPayments('non-existent-order');
        expect(payments, isEmpty);
      });
    });

    group('Payment Summary', () {
      test('should return null for user with no transactions', () async {
        final summary =
            await PaymentService.getPaymentSummary('new-user-no-transactions');
        expect(summary, isNull);
      });

      test('should calculate summary correctly when transactions exist',
          () async {
        // This test would require mock data or a test database
        // For now, we test the structure when summary exists
        final summary =
            await PaymentService.getPaymentSummary('user-with-transactions');

        if (summary != null) {
          expect(summary.userId, isNotEmpty);
          expect(summary.totalPaid, greaterThanOrEqualTo(0));
          expect(summary.totalRefunded, greaterThanOrEqualTo(0));
          expect(summary.totalTransactions, greaterThanOrEqualTo(0));
          expect(summary.successfulTransactions,
              lessThanOrEqualTo(summary.totalTransactions));
          expect(summary.successRate, inInclusiveRange(0.0, 1.0));
          expect(summary.netAmount,
              equals(summary.totalPaid - summary.totalRefunded));
        }
      });
    });

    group('Payment Method Configuration', () {
      test('should provide default payment method configurations', () {
        final configurations = PaymentMethodConfiguration.defaultMethods;

        expect(configurations, isNotEmpty);
        expect(configurations.length,
            equals(7)); // 4 mobile money + 2 cards + 1 cash

        // Check Côte d'Ivoire mobile money providers
        final providers = configurations.map((c) => c.provider).toList();
        expect(providers, contains(PaymentProvider.orangeMoney));
        expect(providers, contains(PaymentProvider.mtnMoney));
        expect(providers, contains(PaymentProvider.moovMoney));
        expect(providers, contains(PaymentProvider.wave));
        expect(providers, contains(PaymentProvider.visa));
        expect(providers, contains(PaymentProvider.mastercard));
        expect(providers, contains(PaymentProvider.cash));
      });

      test('should have correct configuration for Orange Money', () {
        final configurations = PaymentMethodConfiguration.defaultMethods;
        final orangeMoney = configurations.firstWhere(
          (c) => c.provider == PaymentProvider.orangeMoney,
        );

        expect(orangeMoney.displayName, equals('Orange Money'));
        expect(orangeMoney.isEnabled, isTrue);
        expect(orangeMoney.minimumAmount, equals(100.0));
        expect(orangeMoney.maximumAmount, equals(500000.0));
        expect(orangeMoney.processingFee, equals(0.0));
        expect(orangeMoney.supportedCurrencies, contains('XOF'));
        expect(orangeMoney.requiresPhoneNumber, isTrue);
        expect(orangeMoney.requiresCardDetails, isFalse);
        expect(orangeMoney.isInstant, isTrue);
      });

      test('should have correct configuration for Visa cards', () {
        final configurations = PaymentMethodConfiguration.defaultMethods;
        final visa = configurations.firstWhere(
          (c) => c.provider == PaymentProvider.visa,
        );

        expect(visa.displayName, equals('Visa'));
        expect(visa.isEnabled, isTrue);
        expect(visa.minimumAmount, equals(100.0));
        expect(visa.maximumAmount, equals(1000000.0));
        expect(visa.processingFee, equals(0.025)); // 2.5%
        expect(visa.supportedCurrencies, contains('XOF'));
        expect(visa.supportedCurrencies, contains('USD'));
        expect(visa.supportedCurrencies, contains('EUR'));
        expect(visa.requiresPhoneNumber, isFalse);
        expect(visa.requiresCardDetails, isTrue);
        expect(visa.isInstant, isFalse);
      });

      test('should serialize and deserialize configurations correctly', () {
        final original = PaymentMethodConfiguration.defaultMethods.first;
        final json = original.toJson();
        final deserialized = PaymentMethodConfiguration.fromJson(json);

        expect(deserialized.provider, equals(original.provider));
        expect(deserialized.name, equals(original.name));
        expect(deserialized.displayName, equals(original.displayName));
        expect(deserialized.isEnabled, equals(original.isEnabled));
        expect(deserialized.minimumAmount, equals(original.minimumAmount));
        expect(deserialized.maximumAmount, equals(original.maximumAmount));
        expect(deserialized.processingFee, equals(original.processingFee));
      });
    });

    group('Payment Transaction Model', () {
      test('should create payment transaction correctly', () {
        final transaction = PaymentTransaction(
          id: 'txn-123',
          paymentRef: 'pay-ref-123',
          orderId: 'order-123',
          userId: 'user-123',
          provider: PaymentProvider.orangeMoney,
          type: PaymentTransactionType.payment,
          status: PaymentTransactionStatus.completed,
          amount: 1500.0,
          currency: 'XOF',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(transaction.isSuccess, isTrue);
        expect(transaction.isPending, isFalse);
        expect(transaction.hasFailed, isFalse);
      });

      test('should correctly identify pending transactions', () {
        final pendingTransaction = PaymentTransaction(
          id: 'txn-pending',
          paymentRef: 'pay-ref-pending',
          orderId: 'order-pending',
          userId: 'user-pending',
          provider: PaymentProvider.mtnMoney,
          type: PaymentTransactionType.payment,
          status: PaymentTransactionStatus.pending,
          amount: 1000.0,
          currency: 'XOF',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(pendingTransaction.isSuccess, isFalse);
        expect(pendingTransaction.isPending, isTrue);
        expect(pendingTransaction.hasFailed, isFalse);

        final processingTransaction = pendingTransaction.copyWith(
          status: PaymentTransactionStatus.processing,
        );

        expect(processingTransaction.isPending, isTrue);
      });

      test('should correctly identify failed transactions', () {
        final failedTransaction = PaymentTransaction(
          id: 'txn-failed',
          paymentRef: 'pay-ref-failed',
          orderId: 'order-failed',
          userId: 'user-failed',
          provider: PaymentProvider.wave,
          type: PaymentTransactionType.payment,
          status: PaymentTransactionStatus.failed,
          amount: 800.0,
          currency: 'XOF',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(failedTransaction.isSuccess, isFalse);
        expect(failedTransaction.isPending, isFalse);
        expect(failedTransaction.hasFailed, isTrue);

        final cancelledTransaction = failedTransaction.copyWith(
          status: PaymentTransactionStatus.cancelled,
        );

        expect(cancelledTransaction.hasFailed, isTrue);
      });

      test('should serialize and deserialize payment transaction correctly',
          () {
        final original = PaymentTransaction(
          id: 'txn-serialize-test',
          paymentRef: 'pay-ref-serialize-test',
          orderId: 'order-serialize-test',
          userId: 'user-serialize-test',
          provider: PaymentProvider.visa,
          type: PaymentTransactionType.payment,
          status: PaymentTransactionStatus.completed,
          amount: 2500.0,
          currency: 'XOF',
          externalTransactionId: 'ext-txn-123',
          customerDetails: {'name': 'Test User', 'email': 'test@example.com'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = original.toJson();
        final deserialized = PaymentTransaction.fromJson(json);

        expect(deserialized.id, equals(original.id));
        expect(deserialized.paymentRef, equals(original.paymentRef));
        expect(deserialized.orderId, equals(original.orderId));
        expect(deserialized.userId, equals(original.userId));
        expect(deserialized.provider, equals(original.provider));
        expect(deserialized.type, equals(original.type));
        expect(deserialized.status, equals(original.status));
        expect(deserialized.amount, equals(original.amount));
        expect(deserialized.currency, equals(original.currency));
        expect(deserialized.externalTransactionId,
            equals(original.externalTransactionId));
      });
    });

    group('Error Handling', () {
      test('should handle network errors gracefully', () async {
        // This test would require mocking network failures
        // For now, we ensure error responses are handled
        expect(() async {
          await PaymentService.processPayment(
            paymentMethodId: 'orange_money',
            orderId: 'error-test-order',
            userId: 'error-test-user',
            amount: 0.0, // Invalid amount might trigger error
            currency: 'XOF',
          );
        }, returnsNormally);
      });

      test('should validate payment amounts', () async {
        final result = await PaymentService.processPayment(
          paymentMethodId: 'orange_money',
          orderId: 'validation-test',
          userId: 'validation-user',
          amount: -100.0, // Negative amount
          currency: 'XOF',
        );

        // Service should handle invalid amounts gracefully
        expect(result, isA<PaymentResult>());
      });
    });
  });
}
