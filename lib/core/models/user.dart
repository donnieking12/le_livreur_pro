import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    // Core Identifiers
    required String id,
    required String phone,
    required String fullName,
    required UserType userType,

    // Authentication & Status
    String? email,
    String? profileImageUrl,
    @Default('fr') String preferredLanguage, // French default for Côte d'Ivoire
    @Default(true) bool isActive,
    @Default(false) bool isVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,

    // Location Tracking (All Users)
    double? currentLatitude,
    double? currentLongitude,

    // Courier-Specific Fields
    @Default(false) bool isOnline,
    @Default(0.0) double rating,
    @Default(0) int totalDeliveries,
    String? vehicleType, // 'bike', 'car', 'truck'
    String? driverLicenseUrl, // Supabase storage path
    String? nationalIdUrl, // For identity verification

    // Partner-Specific Fields
    String? restaurantId, // Relational reference to partner_restaurants
    String? businessAddress,
    String? businessRegistrationUrl, // Legal documents

    // Technical
    String? fcmToken, // Firebase Cloud Messaging
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

enum UserType {
  @JsonValue('customer')
  customer,
  @JsonValue('courier')
  courier,
  @JsonValue('partner')
  partner,
  @JsonValue('admin')
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
