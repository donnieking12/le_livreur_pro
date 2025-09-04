class AdminSettings {
  final GeneralSettings generalSettings;
  final PaymentSettings paymentSettings;
  final SecuritySettings securitySettings;
  final MaintenanceSettings maintenanceSettings;
  final NotificationSettings notificationSettings;
  final FeatureSettings featureSettings;
  final Map<String, dynamic> customSettings;

  AdminSettings({
    required this.generalSettings,
    required this.paymentSettings,
    required this.securitySettings,
    required this.maintenanceSettings,
    required this.notificationSettings,
    required this.featureSettings,
    required this.customSettings,
  });

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
      generalSettings: GeneralSettings.fromJson(json['general_settings']),
      paymentSettings: PaymentSettings.fromJson(json['payment_settings']),
      securitySettings: SecuritySettings.fromJson(json['security_settings']),
      maintenanceSettings:
          MaintenanceSettings.fromJson(json['maintenance_settings']),
      notificationSettings:
          NotificationSettings.fromJson(json['notification_settings']),
      featureSettings: FeatureSettings.fromJson(json['feature_settings']),
      customSettings: Map<String, dynamic>.from(json['custom_settings']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general_settings': generalSettings.toJson(),
      'payment_settings': paymentSettings.toJson(),
      'security_settings': securitySettings.toJson(),
      'maintenance_settings': maintenanceSettings.toJson(),
      'notification_settings': notificationSettings.toJson(),
      'feature_settings': featureSettings.toJson(),
      'custom_settings': customSettings,
    };
  }

  AdminSettings copyWith({
    GeneralSettings? generalSettings,
    PaymentSettings? paymentSettings,
    SecuritySettings? securitySettings,
    MaintenanceSettings? maintenanceSettings,
    NotificationSettings? notificationSettings,
    FeatureSettings? featureSettings,
    Map<String, dynamic>? customSettings,
  }) {
    return AdminSettings(
      generalSettings: generalSettings ?? this.generalSettings,
      paymentSettings: paymentSettings ?? this.paymentSettings,
      securitySettings: securitySettings ?? this.securitySettings,
      maintenanceSettings: maintenanceSettings ?? this.maintenanceSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      featureSettings: featureSettings ?? this.featureSettings,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  // Getters to access nested properties
  bool get maintenanceMode => generalSettings.maintenanceMode;
  bool get allowRegistrations => true; // Default value, adjust as needed
  bool get autoAssignOrders => featureSettings.scheduledDeliveries;
  double get baseCommissionRate =>
      paymentSettings.commissionSettings.defaultCommissionRate;
  int get baseDeliveryPrice => customSettings['default_delivery_fee'] ?? 1000;
  double get baseZoneRadius => customSettings['max_delivery_distance'] ?? 5.0;
  bool get enablePushNotifications => notificationSettings.pushNotifications;
  bool get enableEmailNotifications => notificationSettings.emailNotifications;
  bool get enableSmsNotifications => notificationSettings.smsNotifications;
}

class GeneralSettings {
  final String platformName;
  final String platformDescription;
  final String platformLogo;
  final String defaultLanguage;
  final List<String> supportedLanguages;
  final String defaultCurrency;
  final String timezone;
  final String supportEmail;
  final String supportPhone;
  final Map<String, String> socialLinks;
  final bool maintenanceMode;
  final String maintenanceMessage;

  GeneralSettings({
    required this.platformName,
    required this.platformDescription,
    required this.platformLogo,
    required this.defaultLanguage,
    required this.supportedLanguages,
    required this.defaultCurrency,
    required this.timezone,
    required this.supportEmail,
    required this.supportPhone,
    required this.socialLinks,
    required this.maintenanceMode,
    required this.maintenanceMessage,
  });

  factory GeneralSettings.fromJson(Map<String, dynamic> json) {
    return GeneralSettings(
      platformName: json['platform_name'] as String,
      platformDescription: json['platform_description'] as String,
      platformLogo: json['platform_logo'] as String,
      defaultLanguage: json['default_language'] as String,
      supportedLanguages: List<String>.from(json['supported_languages']),
      defaultCurrency: json['default_currency'] as String,
      timezone: json['timezone'] as String,
      supportEmail: json['support_email'] as String,
      supportPhone: json['support_phone'] as String,
      socialLinks: Map<String, String>.from(json['social_links']),
      maintenanceMode: json['maintenance_mode'] as bool,
      maintenanceMessage: json['maintenance_message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform_name': platformName,
      'platform_description': platformDescription,
      'platform_logo': platformLogo,
      'default_language': defaultLanguage,
      'supported_languages': supportedLanguages,
      'default_currency': defaultCurrency,
      'timezone': timezone,
      'support_email': supportEmail,
      'support_phone': supportPhone,
      'social_links': socialLinks,
      'maintenance_mode': maintenanceMode,
      'maintenance_message': maintenanceMessage,
    };
  }
}

class PaymentSettings {
  final CommissionSettings commissionSettings;
  final List<PaymentMethodConfig> paymentMethods;
  final bool autoWithdrawal;
  final int withdrawalThreshold;
  final Map<String, dynamic> paymentProviderConfig;
  final bool paymentLogging;
  final bool fraudDetection;

  PaymentSettings({
    required this.commissionSettings,
    required this.paymentMethods,
    required this.autoWithdrawal,
    required this.withdrawalThreshold,
    required this.paymentProviderConfig,
    required this.paymentLogging,
    required this.fraudDetection,
  });

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
      commissionSettings:
          CommissionSettings.fromJson(json['commission_settings']),
      paymentMethods: (json['payment_methods'] as List)
          .map((item) => PaymentMethodConfig.fromJson(item))
          .toList(),
      autoWithdrawal: json['auto_withdrawal'] as bool,
      withdrawalThreshold: json['withdrawal_threshold'] as int,
      paymentProviderConfig:
          Map<String, dynamic>.from(json['payment_provider_config']),
      paymentLogging: json['payment_logging'] as bool,
      fraudDetection: json['fraud_detection'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'commission_settings': commissionSettings.toJson(),
      'payment_methods':
          paymentMethods.map((method) => method.toJson()).toList(),
      'auto_withdrawal': autoWithdrawal,
      'withdrawal_threshold': withdrawalThreshold,
      'payment_provider_config': paymentProviderConfig,
      'payment_logging': paymentLogging,
      'fraud_detection': fraudDetection,
    };
  }
}

class SecuritySettings {
  final AuthSettings authSettings;
  final bool twoFactorAuth;
  final int sessionTimeout;
  final int maxLoginAttempts;
  final int passwordMinLength;
  final bool requireSpecialChars;
  final bool ipWhitelisting;
  final List<String> allowedIpRanges;
  final bool auditLogging;
  final int dataRetentionDays;

  SecuritySettings({
    required this.authSettings,
    required this.twoFactorAuth,
    required this.sessionTimeout,
    required this.maxLoginAttempts,
    required this.passwordMinLength,
    required this.requireSpecialChars,
    required this.ipWhitelisting,
    required this.allowedIpRanges,
    required this.auditLogging,
    required this.dataRetentionDays,
  });

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      authSettings: AuthSettings.fromJson(json['auth_settings']),
      twoFactorAuth: json['two_factor_auth'] as bool,
      sessionTimeout: json['session_timeout'] as int,
      maxLoginAttempts: json['max_login_attempts'] as int,
      passwordMinLength: json['password_min_length'] as int,
      requireSpecialChars: json['require_special_chars'] as bool,
      ipWhitelisting: json['ip_whitelisting'] as bool,
      allowedIpRanges: List<String>.from(json['allowed_ip_ranges']),
      auditLogging: json['audit_logging'] as bool,
      dataRetentionDays: json['data_retention_days'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_settings': authSettings.toJson(),
      'two_factor_auth': twoFactorAuth,
      'session_timeout': sessionTimeout,
      'max_login_attempts': maxLoginAttempts,
      'password_min_length': passwordMinLength,
      'require_special_chars': requireSpecialChars,
      'ip_whitelisting': ipWhitelisting,
      'allowed_ip_ranges': allowedIpRanges,
      'audit_logging': auditLogging,
      'data_retention_days': dataRetentionDays,
    };
  }
}

class MaintenanceSettings {
  final bool scheduledMaintenance;
  final DateTime? nextMaintenanceDate;
  final int maintenanceDuration;
  final String maintenanceNotice;
  final bool backupEnabled;
  final String backupFrequency;
  final int backupRetentionDays;
  final bool autoUpdates;
  final List<MaintenanceWindow> maintenanceWindows;

  MaintenanceSettings({
    required this.scheduledMaintenance,
    this.nextMaintenanceDate,
    required this.maintenanceDuration,
    required this.maintenanceNotice,
    required this.backupEnabled,
    required this.backupFrequency,
    required this.backupRetentionDays,
    required this.autoUpdates,
    required this.maintenanceWindows,
  });

  factory MaintenanceSettings.fromJson(Map<String, dynamic> json) {
    return MaintenanceSettings(
      scheduledMaintenance: json['scheduled_maintenance'] as bool,
      nextMaintenanceDate: json['next_maintenance_date'] != null
          ? DateTime.parse(json['next_maintenance_date'] as String)
          : null,
      maintenanceDuration: json['maintenance_duration'] as int,
      maintenanceNotice: json['maintenance_notice'] as String,
      backupEnabled: json['backup_enabled'] as bool,
      backupFrequency: json['backup_frequency'] as String,
      backupRetentionDays: json['backup_retention_days'] as int,
      autoUpdates: json['auto_updates'] as bool,
      maintenanceWindows: (json['maintenance_windows'] as List)
          .map((item) => MaintenanceWindow.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduled_maintenance': scheduledMaintenance,
      'next_maintenance_date': nextMaintenanceDate?.toIso8601String(),
      'maintenance_duration': maintenanceDuration,
      'maintenance_notice': maintenanceNotice,
      'backup_enabled': backupEnabled,
      'backup_frequency': backupFrequency,
      'backup_retention_days': backupRetentionDays,
      'auto_updates': autoUpdates,
      'maintenance_windows':
          maintenanceWindows.map((window) => window.toJson()).toList(),
    };
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final Map<String, bool> notificationTypes;
  final String emailProvider;
  final String smsProvider;
  final Map<String, String> providerConfig;
  final List<String> adminNotificationEmails;

  NotificationSettings({
    required this.emailNotifications,
    required this.smsNotifications,
    required this.pushNotifications,
    required this.notificationTypes,
    required this.emailProvider,
    required this.smsProvider,
    required this.providerConfig,
    required this.adminNotificationEmails,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      emailNotifications: json['email_notifications'] as bool,
      smsNotifications: json['sms_notifications'] as bool,
      pushNotifications: json['push_notifications'] as bool,
      notificationTypes: Map<String, bool>.from(json['notification_types']),
      emailProvider: json['email_provider'] as String,
      smsProvider: json['sms_provider'] as String,
      providerConfig: Map<String, String>.from(json['provider_config']),
      adminNotificationEmails:
          List<String>.from(json['admin_notification_emails']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      'push_notifications': pushNotifications,
      'notification_types': notificationTypes,
      'email_provider': emailProvider,
      'sms_provider': smsProvider,
      'provider_config': providerConfig,
      'admin_notification_emails': adminNotificationEmails,
    };
  }
}

class FeatureSettings {
  final bool realTimeTracking;
  final bool chatSupport;
  final bool loyaltyProgram;
  final bool referralProgram;
  final bool scheduledDeliveries;
  final bool multiplePaymentMethods;
  final bool courierRatings;
  final bool restaurantReviews;
  final Map<String, bool> experimentalFeatures;

  FeatureSettings({
    required this.realTimeTracking,
    required this.chatSupport,
    required this.loyaltyProgram,
    required this.referralProgram,
    required this.scheduledDeliveries,
    required this.multiplePaymentMethods,
    required this.courierRatings,
    required this.restaurantReviews,
    required this.experimentalFeatures,
  });

  factory FeatureSettings.fromJson(Map<String, dynamic> json) {
    return FeatureSettings(
      realTimeTracking: json['real_time_tracking'] as bool,
      chatSupport: json['chat_support'] as bool,
      loyaltyProgram: json['loyalty_program'] as bool,
      referralProgram: json['referral_program'] as bool,
      scheduledDeliveries: json['scheduled_deliveries'] as bool,
      multiplePaymentMethods: json['multiple_payment_methods'] as bool,
      courierRatings: json['courier_ratings'] as bool,
      restaurantReviews: json['restaurant_reviews'] as bool,
      experimentalFeatures:
          Map<String, bool>.from(json['experimental_features']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'real_time_tracking': realTimeTracking,
      'chat_support': chatSupport,
      'loyalty_program': loyaltyProgram,
      'referral_program': referralProgram,
      'scheduled_deliveries': scheduledDeliveries,
      'multiple_payment_methods': multiplePaymentMethods,
      'courier_ratings': courierRatings,
      'restaurant_reviews': restaurantReviews,
      'experimental_features': experimentalFeatures,
    };
  }
}

class CommissionSettings {
  final double defaultCommissionRate;
  final Map<String, double> categoryCommissionRates;
  final double minimumCommission;
  final double maximumCommission;
  final bool tieredCommission;
  final List<CommissionTier> commissionTiers;

  CommissionSettings({
    required this.defaultCommissionRate,
    required this.categoryCommissionRates,
    required this.minimumCommission,
    required this.maximumCommission,
    required this.tieredCommission,
    required this.commissionTiers,
  });

  factory CommissionSettings.fromJson(Map<String, dynamic> json) {
    return CommissionSettings(
      defaultCommissionRate:
          (json['default_commission_rate'] as num).toDouble(),
      categoryCommissionRates:
          Map<String, double>.from(json['category_commission_rates']),
      minimumCommission: (json['minimum_commission'] as num).toDouble(),
      maximumCommission: (json['maximum_commission'] as num).toDouble(),
      tieredCommission: json['tiered_commission'] as bool,
      commissionTiers: (json['commission_tiers'] as List)
          .map((item) => CommissionTier.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default_commission_rate': defaultCommissionRate,
      'category_commission_rates': categoryCommissionRates,
      'minimum_commission': minimumCommission,
      'maximum_commission': maximumCommission,
      'tiered_commission': tieredCommission,
      'commission_tiers': commissionTiers.map((tier) => tier.toJson()).toList(),
    };
  }
}

class PaymentMethodConfig {
  final String name;
  final String displayName;
  final bool enabled;
  final Map<String, dynamic> config;
  final List<String> supportedCountries;
  final double transactionFee;
  final bool requiresVerification;

  PaymentMethodConfig({
    required this.name,
    required this.displayName,
    required this.enabled,
    required this.config,
    required this.supportedCountries,
    required this.transactionFee,
    required this.requiresVerification,
  });

  factory PaymentMethodConfig.fromJson(Map<String, dynamic> json) {
    return PaymentMethodConfig(
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      enabled: json['enabled'] as bool,
      config: Map<String, dynamic>.from(json['config']),
      supportedCountries: List<String>.from(json['supported_countries']),
      transactionFee: (json['transaction_fee'] as num).toDouble(),
      requiresVerification: json['requires_verification'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display_name': displayName,
      'enabled': enabled,
      'config': config,
      'supported_countries': supportedCountries,
      'transaction_fee': transactionFee,
      'requires_verification': requiresVerification,
    };
  }
}

class AuthSettings {
  final String authProvider;
  final Map<String, dynamic> providerConfig;
  final bool allowAnonymous;
  final bool requirePhoneVerification;
  final bool requireEmailVerification;
  final int otpLength;
  final int otpExpiration;

  AuthSettings({
    required this.authProvider,
    required this.providerConfig,
    required this.allowAnonymous,
    required this.requirePhoneVerification,
    required this.requireEmailVerification,
    required this.otpLength,
    required this.otpExpiration,
  });

  factory AuthSettings.fromJson(Map<String, dynamic> json) {
    return AuthSettings(
      authProvider: json['auth_provider'] as String,
      providerConfig: Map<String, dynamic>.from(json['provider_config']),
      allowAnonymous: json['allow_anonymous'] as bool,
      requirePhoneVerification: json['require_phone_verification'] as bool,
      requireEmailVerification: json['require_email_verification'] as bool,
      otpLength: json['otp_length'] as int,
      otpExpiration: json['otp_expiration'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_provider': authProvider,
      'provider_config': providerConfig,
      'allow_anonymous': allowAnonymous,
      'require_phone_verification': requirePhoneVerification,
      'require_email_verification': requireEmailVerification,
      'otp_length': otpLength,
      'otp_expiration': otpExpiration,
    };
  }
}

class MaintenanceWindow {
  final String name;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final bool enabled;

  MaintenanceWindow({
    required this.name,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.enabled,
  });

  factory MaintenanceWindow.fromJson(Map<String, dynamic> json) {
    return MaintenanceWindow(
      name: json['name'] as String,
      dayOfWeek: json['day_of_week'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      enabled: json['enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'enabled': enabled,
    };
  }
}

class CommissionTier {
  final String name;
  final double minimumAmount;
  final double maximumAmount;
  final double commissionRate;

  CommissionTier({
    required this.name,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.commissionRate,
  });

  factory CommissionTier.fromJson(Map<String, dynamic> json) {
    return CommissionTier(
      name: json['name'] as String,
      minimumAmount: (json['minimum_amount'] as num).toDouble(),
      maximumAmount: (json['maximum_amount'] as num).toDouble(),
      commissionRate: (json['commission_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'minimum_amount': minimumAmount,
      'maximum_amount': maximumAmount,
      'commission_rate': commissionRate,
    };
  }
}
