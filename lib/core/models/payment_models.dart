enum PaymentProvider {
  orangeMoney,
  mtnMoney,
  moovMoney,
  wave,
  visa,
  mastercard,
  cash,
}

enum PaymentTransactionType {
  payment,
  refund,
  adjustment,
  commission,
  withdrawal,
}

enum PaymentTransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
  disputed,
}

class PaymentTransaction {
  final String id;
  final String paymentRef;
  final String orderId;
  final String userId;
  final PaymentProvider provider;
  final PaymentTransactionType type;
  final PaymentTransactionStatus status;
  final double amount;
  final String currency;
  final String? externalTransactionId;
  final String? providerTransactionRef;
  final Map<String, dynamic>? customerDetails;
  final Map<String, dynamic>? providerDetails;
  final String? failureReason;
  final double? processingFee;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const PaymentTransaction({
    required this.id,
    required this.paymentRef,
    required this.orderId,
    required this.userId,
    required this.provider,
    required this.type,
    required this.status,
    required this.amount,
    required this.currency,
    this.externalTransactionId,
    this.providerTransactionRef,
    this.customerDetails,
    this.providerDetails,
    this.failureReason,
    this.processingFee,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    return PaymentTransaction(
      id: json['id'] as String,
      paymentRef: json['payment_ref'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => PaymentProvider.cash,
      ),
      type: PaymentTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PaymentTransactionType.payment,
      ),
      status: PaymentTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentTransactionStatus.pending,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      externalTransactionId: json['external_transaction_id'] as String?,
      providerTransactionRef: json['provider_transaction_ref'] as String?,
      customerDetails: json['customer_details'] as Map<String, dynamic>?,
      providerDetails: json['provider_details'] as Map<String, dynamic>?,
      failureReason: json['failure_reason'] as String?,
      processingFee: (json['processing_fee'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_ref': paymentRef,
      'order_id': orderId,
      'user_id': userId,
      'provider': provider.name,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'external_transaction_id': externalTransactionId,
      'provider_transaction_ref': providerTransactionRef,
      'customer_details': customerDetails,
      'provider_details': providerDetails,
      'failure_reason': failureReason,
      'processing_fee': processingFee,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  PaymentTransaction copyWith({
    String? id,
    String? paymentRef,
    String? orderId,
    String? userId,
    PaymentProvider? provider,
    PaymentTransactionType? type,
    PaymentTransactionStatus? status,
    double? amount,
    String? currency,
    String? externalTransactionId,
    String? providerTransactionRef,
    Map<String, dynamic>? customerDetails,
    Map<String, dynamic>? providerDetails,
    String? failureReason,
    double? processingFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      paymentRef: paymentRef ?? this.paymentRef,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      provider: provider ?? this.provider,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      externalTransactionId:
          externalTransactionId ?? this.externalTransactionId,
      providerTransactionRef:
          providerTransactionRef ?? this.providerTransactionRef,
      customerDetails: customerDetails ?? this.customerDetails,
      providerDetails: providerDetails ?? this.providerDetails,
      failureReason: failureReason ?? this.failureReason,
      processingFee: processingFee ?? this.processingFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  bool get isSuccess => status == PaymentTransactionStatus.completed;
  bool get isPending =>
      status == PaymentTransactionStatus.pending ||
      status == PaymentTransactionStatus.processing;
  bool get hasFailed =>
      status == PaymentTransactionStatus.failed ||
      status == PaymentTransactionStatus.cancelled;
}

class PaymentMethodConfiguration {
  final PaymentProvider provider;
  final String name;
  final String displayName;
  final String description;
  final String iconPath;
  final bool isEnabled;
  final double minimumAmount;
  final double maximumAmount;
  final double processingFee;
  final List<String> supportedCurrencies;
  final Map<String, dynamic> providerConfig;
  final bool requiresPhoneNumber;
  final bool requiresCardDetails;
  final bool isInstant;

  const PaymentMethodConfiguration({
    required this.provider,
    required this.name,
    required this.displayName,
    required this.description,
    required this.iconPath,
    required this.isEnabled,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.processingFee,
    required this.supportedCurrencies,
    required this.providerConfig,
    required this.requiresPhoneNumber,
    required this.requiresCardDetails,
    required this.isInstant,
  });

  factory PaymentMethodConfiguration.fromJson(Map<String, dynamic> json) {
    return PaymentMethodConfiguration(
      provider: PaymentProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => PaymentProvider.cash,
      ),
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      description: json['description'] as String,
      iconPath: json['icon_path'] as String,
      isEnabled: json['is_enabled'] as bool,
      minimumAmount: (json['minimum_amount'] as num).toDouble(),
      maximumAmount: (json['maximum_amount'] as num).toDouble(),
      processingFee: (json['processing_fee'] as num).toDouble(),
      supportedCurrencies: List<String>.from(json['supported_currencies']),
      providerConfig: Map<String, dynamic>.from(json['provider_config']),
      requiresPhoneNumber: json['requires_phone_number'] as bool,
      requiresCardDetails: json['requires_card_details'] as bool,
      isInstant: json['is_instant'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider': provider.name,
      'name': name,
      'display_name': displayName,
      'description': description,
      'icon_path': iconPath,
      'is_enabled': isEnabled,
      'minimum_amount': minimumAmount,
      'maximum_amount': maximumAmount,
      'processing_fee': processingFee,
      'supported_currencies': supportedCurrencies,
      'provider_config': providerConfig,
      'requires_phone_number': requiresPhoneNumber,
      'requires_card_details': requiresCardDetails,
      'is_instant': isInstant,
    };
  }

  // Static configurations for Côte d'Ivoire payment methods
  static List<PaymentMethodConfiguration> get defaultMethods => [
        const PaymentMethodConfiguration(
          provider: PaymentProvider.orangeMoney,
          name: 'orange_money',
          displayName: 'Orange Money',
          description: 'Paiement via Orange Money',
          iconPath: 'assets/icons/orange_money.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 500000.0,
          processingFee: 0.0,
          supportedCurrencies: ['XOF'],
          providerConfig: {},
          requiresPhoneNumber: true,
          requiresCardDetails: false,
          isInstant: true,
        ),
        const PaymentMethodConfiguration(
          provider: PaymentProvider.mtnMoney,
          name: 'mtn_money',
          displayName: 'MTN Money',
          description: 'Paiement via MTN Mobile Money',
          iconPath: 'assets/icons/mtn_money.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 500000.0,
          processingFee: 0.0,
          supportedCurrencies: ['XOF'],
          providerConfig: {},
          requiresPhoneNumber: true,
          requiresCardDetails: false,
          isInstant: true,
        ),
        const PaymentMethodConfiguration(
          provider: PaymentProvider.moovMoney,
          name: 'moov_money',
          displayName: 'Moov Money',
          description: 'Paiement via Moov Money',
          iconPath: 'assets/icons/moov_money.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 500000.0,
          processingFee: 0.0,
          supportedCurrencies: ['XOF'],
          providerConfig: {},
          requiresPhoneNumber: true,
          requiresCardDetails: false,
          isInstant: true,
        ),
        const PaymentMethodConfiguration(
          provider: PaymentProvider.wave,
          name: 'wave',
          displayName: 'Wave',
          description: 'Paiement via Wave',
          iconPath: 'assets/icons/wave.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 500000.0,
          processingFee: 0.0,
          supportedCurrencies: ['XOF'],
          providerConfig: {},
          requiresPhoneNumber: true,
          requiresCardDetails: false,
          isInstant: true,
        ),
        const PaymentMethodConfiguration(
          provider: PaymentProvider.visa,
          name: 'visa',
          displayName: 'Visa',
          description: 'Cartes Visa',
          iconPath: 'assets/icons/visa.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 1000000.0,
          processingFee: 0.025, // 2.5%
          supportedCurrencies: ['XOF', 'USD', 'EUR'],
          providerConfig: {},
          requiresPhoneNumber: false,
          requiresCardDetails: true,
          isInstant: false,
        ),
        const PaymentMethodConfiguration(
          provider: PaymentProvider.mastercard,
          name: 'mastercard',
          displayName: 'Mastercard',
          description: 'Cartes Mastercard',
          iconPath: 'assets/icons/mastercard.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 1000000.0,
          processingFee: 0.025, // 2.5%
          supportedCurrencies: ['XOF', 'USD', 'EUR'],
          providerConfig: {},
          requiresPhoneNumber: false,
          requiresCardDetails: true,
          isInstant: false,
        ),
        const PaymentMethodConfiguration(
          provider: PaymentProvider.cash,
          name: 'cash_on_delivery',
          displayName: 'Paiement à la livraison',
          description: 'Paiement en espèces lors de la livraison',
          iconPath: 'assets/icons/cash.png',
          isEnabled: true,
          minimumAmount: 100.0,
          maximumAmount: 100000.0,
          processingFee: 0.0,
          supportedCurrencies: ['XOF'],
          providerConfig: {},
          requiresPhoneNumber: false,
          requiresCardDetails: false,
          isInstant: true,
        ),
      ];
}

class PaymentSummary {
  final String userId;
  final double totalPaid;
  final double totalRefunded;
  final int totalTransactions;
  final int successfulTransactions;
  final int failedTransactions;
  final Map<PaymentProvider, double> paymentsByProvider;
  final DateTime lastPaymentDate;

  const PaymentSummary({
    required this.userId,
    required this.totalPaid,
    required this.totalRefunded,
    required this.totalTransactions,
    required this.successfulTransactions,
    required this.failedTransactions,
    required this.paymentsByProvider,
    required this.lastPaymentDate,
  });

  double get successRate =>
      totalTransactions > 0 ? successfulTransactions / totalTransactions : 0.0;
  double get netAmount => totalPaid - totalRefunded;

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      userId: json['user_id'] as String,
      totalPaid: (json['total_paid'] as num).toDouble(),
      totalRefunded: (json['total_refunded'] as num).toDouble(),
      totalTransactions: json['total_transactions'] as int,
      successfulTransactions: json['successful_transactions'] as int,
      failedTransactions: json['failed_transactions'] as int,
      paymentsByProvider: (json['payments_by_provider'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
                PaymentProvider.values.firstWhere((e) => e.name == key),
                (value as num).toDouble(),
              )),
      lastPaymentDate: DateTime.parse(json['last_payment_date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'total_paid': totalPaid,
      'total_refunded': totalRefunded,
      'total_transactions': totalTransactions,
      'successful_transactions': successfulTransactions,
      'failed_transactions': failedTransactions,
      'payments_by_provider':
          paymentsByProvider.map((key, value) => MapEntry(key.name, value)),
      'last_payment_date': lastPaymentDate.toIso8601String(),
    };
  }
}
