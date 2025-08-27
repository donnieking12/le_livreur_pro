class User {
  // Core Identifiers
  final String id;
  final String phone;
  final String fullName;
  final UserType userType;

  // Authentication & Status
  final String? email;
  final String? profileImageUrl;
  final String preferredLanguage; // French default for Côte d'Ivoire
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLoginAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Location Tracking (All Users)
  final double? currentLatitude;
  final double? currentLongitude;

  // Courier-Specific Fields
  final bool isOnline;
  final double rating;
  final int totalDeliveries;
  final String? vehicleType; // 'bike', 'car', 'truck'
  final String? driverLicenseUrl; // Supabase storage path
  final String? nationalIdUrl; // For identity verification

  // Partner-Specific Fields
  final String? restaurantId; // Relational reference to partner_restaurants
  final String? businessAddress;
  final String? businessRegistrationUrl; // Legal documents

  // Technical
  final String? fcmToken; // Firebase Cloud Messaging

  const User({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.userType,
    this.email,
    this.profileImageUrl,
    this.preferredLanguage = 'fr',
    this.isActive = true,
    this.isVerified = false,
    this.lastLoginAt,
    this.createdAt,
    this.updatedAt,
    this.currentLatitude,
    this.currentLongitude,
    this.isOnline = false,
    this.rating = 0.0,
    this.totalDeliveries = 0,
    this.vehicleType,
    this.driverLicenseUrl,
    this.nationalIdUrl,
    this.restaurantId,
    this.businessAddress,
    this.businessRegistrationUrl,
    this.fcmToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phone: json['phone'] as String,
      fullName: json['full_name'] as String,
      userType: UserType.values.firstWhere(
        (e) => e.name == json['user_type'],
        orElse: () => UserType.customer,
      ),
      email: json['email'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      preferredLanguage: json['preferred_language'] as String? ?? 'fr',
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      currentLatitude: json['current_latitude'] as double?,
      currentLongitude: json['current_longitude'] as double?,
      isOnline: json['is_online'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      vehicleType: json['vehicle_type'] as String?,
      driverLicenseUrl: json['driver_license_url'] as String?,
      nationalIdUrl: json['national_id_url'] as String?,
      restaurantId: json['restaurant_id'] as String?,
      businessAddress: json['business_address'] as String?,
      businessRegistrationUrl: json['business_registration_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'user_type': userType.name,
      'email': email,
      'profile_image_url': profileImageUrl,
      'preferred_language': preferredLanguage,
      'is_active': isActive,
      'is_verified': isVerified,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'is_online': isOnline,
      'rating': rating,
      'total_deliveries': totalDeliveries,
      'vehicle_type': vehicleType,
      'driver_license_url': driverLicenseUrl,
      'national_id_url': nationalIdUrl,
      'restaurant_id': restaurantId,
      'business_address': businessAddress,
      'business_registration_url': businessRegistrationUrl,
      'fcm_token': fcmToken,
    };
  }

  User copyWith({
    String? id,
    String? phone,
    String? fullName,
    UserType? userType,
    String? email,
    String? profileImageUrl,
    String? preferredLanguage,
    bool? isActive,
    bool? isVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentLatitude,
    double? currentLongitude,
    bool? isOnline,
    double? rating,
    int? totalDeliveries,
    String? vehicleType,
    String? driverLicenseUrl,
    String? nationalIdUrl,
    String? restaurantId,
    String? businessAddress,
    String? businessRegistrationUrl,
    String? fcmToken,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      isOnline: isOnline ?? this.isOnline,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      vehicleType: vehicleType ?? this.vehicleType,
      driverLicenseUrl: driverLicenseUrl ?? this.driverLicenseUrl,
      nationalIdUrl: nationalIdUrl ?? this.nationalIdUrl,
      restaurantId: restaurantId ?? this.restaurantId,
      businessAddress: businessAddress ?? this.businessAddress,
      businessRegistrationUrl:
          businessRegistrationUrl ?? this.businessRegistrationUrl,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}

enum UserType {
  customer,
  courier,
  partner,
  admin,
}

extension UserTypeExtension on UserType {
  String get displayName {
    switch (this) {
      case UserType.customer:
        return 'Client';
      case UserType.courier:
        return 'Coursier';
      case UserType.partner:
        return 'Partenaire';
      case UserType.admin:
        return 'Administrateur';
    }
  }

  // Business Logic Helpers
  bool get canMakeOrders => this == UserType.customer;
  bool get canAcceptDeliveries => this == UserType.courier;
  bool get canCreateMenus => this == UserType.partner;
  bool get requiresVehicle => this == UserType.courier;
  bool get requiresBusinessRegistration => this == UserType.partner;
}
