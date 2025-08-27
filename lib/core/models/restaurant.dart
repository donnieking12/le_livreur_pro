class Restaurant {
  final String id;
  final String name;
  final String ownerId; // Links to User with UserType.partner
  final String description;
  final String businessAddress;
  final double latitude;
  final double longitude;

  // Business Information
  final String? businessPhone;
  final String? businessEmail;
  final String? businessRegistrationNumber;
  final String? businessLicenseUrl; // Supabase storage path
  // Operational Details
  final bool isActive;
  final bool isVerified;
  final bool acceptsOrders;
  final int preparationTimeMinutes;
  final int minimumOrderXof; // Minimum order in CFA Franc
  final int deliveryFeeXof; // Restaurant's delivery fee
  // Business Hours (JSON stored as string in DB)
  final Map<String, OperatingHours>? operatingHours;

  // Categories and Cuisine
  final List<String> cuisineTypes; // 'ivorian', 'french', 'fast_food', etc.
  final List<String> categories; // 'restaurant', 'grocery', 'pharmacy', etc.
  // Performance Metrics
  final double rating;
  final int totalOrders;
  final int totalReviews;

  // Visual Assets
  final String? logoUrl;
  final String? bannerUrl;
  final List<String> galleryUrls;

  // Platform Integration
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastOrderAt;

  const Restaurant({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.description,
    required this.businessAddress,
    required this.latitude,
    required this.longitude,
    this.businessPhone,
    this.businessEmail,
    this.businessRegistrationNumber,
    this.businessLicenseUrl,
    this.isActive = true,
    this.isVerified = false,
    this.acceptsOrders = true,
    this.preparationTimeMinutes = 30,
    this.minimumOrderXof = 5000,
    this.deliveryFeeXof = 0,
    this.operatingHours,
    this.cuisineTypes = const [],
    this.categories = const [],
    this.rating = 0.0,
    this.totalOrders = 0,
    this.totalReviews = 0,
    this.logoUrl,
    this.bannerUrl,
    this.galleryUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.lastOrderAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String,
      description: json['description'] as String,
      businessAddress: json['business_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      businessPhone: json['business_phone'] as String?,
      businessEmail: json['business_email'] as String?,
      businessRegistrationNumber:
          json['business_registration_number'] as String?,
      businessLicenseUrl: json['business_license_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isVerified: json['is_verified'] as bool? ?? false,
      acceptsOrders: json['accepts_orders'] as bool? ?? true,
      preparationTimeMinutes: json['preparation_time_minutes'] as int? ?? 30,
      minimumOrderXof: json['minimum_order_xof'] as int? ?? 5000,
      deliveryFeeXof: json['delivery_fee_xof'] as int? ?? 0,
      operatingHours: json['operating_hours'] != null
          ? (json['operating_hours'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key,
                OperatingHours.fromJson(value as Map<String, dynamic>),
              ),
            )
          : null,
      cuisineTypes:
          (json['cuisine_types'] as List<dynamic>?)?.cast<String>() ?? [],
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      logoUrl: json['logo_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      galleryUrls:
          (json['gallery_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastOrderAt: json['last_order_at'] != null
          ? DateTime.parse(json['last_order_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_id': ownerId,
      'description': description,
      'business_address': businessAddress,
      'latitude': latitude,
      'longitude': longitude,
      'business_phone': businessPhone,
      'business_email': businessEmail,
      'business_registration_number': businessRegistrationNumber,
      'business_license_url': businessLicenseUrl,
      'is_active': isActive,
      'is_verified': isVerified,
      'accepts_orders': acceptsOrders,
      'preparation_time_minutes': preparationTimeMinutes,
      'minimum_order_xof': minimumOrderXof,
      'delivery_fee_xof': deliveryFeeXof,
      'operating_hours': operatingHours?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'cuisine_types': cuisineTypes,
      'categories': categories,
      'rating': rating,
      'total_orders': totalOrders,
      'total_reviews': totalReviews,
      'logo_url': logoUrl,
      'banner_url': bannerUrl,
      'gallery_urls': galleryUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_order_at': lastOrderAt?.toIso8601String(),
    };
  }

  Restaurant copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? description,
    String? businessAddress,
    double? latitude,
    double? longitude,
    String? businessPhone,
    String? businessEmail,
    String? businessRegistrationNumber,
    String? businessLicenseUrl,
    bool? isActive,
    bool? isVerified,
    bool? acceptsOrders,
    int? preparationTimeMinutes,
    int? minimumOrderXof,
    int? deliveryFeeXof,
    Map<String, OperatingHours>? operatingHours,
    List<String>? cuisineTypes,
    List<String>? categories,
    double? rating,
    int? totalOrders,
    int? totalReviews,
    String? logoUrl,
    String? bannerUrl,
    List<String>? galleryUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastOrderAt,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      description: description ?? this.description,
      businessAddress: businessAddress ?? this.businessAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessRegistrationNumber:
          businessRegistrationNumber ?? this.businessRegistrationNumber,
      businessLicenseUrl: businessLicenseUrl ?? this.businessLicenseUrl,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      acceptsOrders: acceptsOrders ?? this.acceptsOrders,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      minimumOrderXof: minimumOrderXof ?? this.minimumOrderXof,
      deliveryFeeXof: deliveryFeeXof ?? this.deliveryFeeXof,
      operatingHours: operatingHours ?? this.operatingHours,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      totalReviews: totalReviews ?? this.totalReviews,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOrderAt: lastOrderAt ?? this.lastOrderAt,
    );
  }
}

class OperatingHours {
  final bool isOpen;
  final String? openTime; // Format: "08:00"
  final String? closeTime; // Format: "22:00"
  final bool isAllDay;

  OperatingHours({
    required this.isOpen,
    this.openTime,
    this.closeTime,
    this.isAllDay = false,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      isOpen: json['is_open'] as bool,
      openTime: json['open_time'] as String?,
      closeTime: json['close_time'] as String?,
      isAllDay: json['is_all_day'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_open': isOpen,
      'open_time': openTime,
      'close_time': closeTime,
      'is_all_day': isAllDay,
    };
  }

  OperatingHours copyWith({
    bool? isOpen,
    String? openTime,
    String? closeTime,
    bool? isAllDay,
  }) {
    return OperatingHours(
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isAllDay: isAllDay ?? this.isAllDay,
    );
  }
}

enum RestaurantCategory {
  restaurant,
  fastFood,
  grocery,
  pharmacy,
  bakery,
  butcher,
  electronics,
  clothing,
  other,
}

extension RestaurantCategoryExtension on RestaurantCategory {
  String get displayNameFr {
    switch (this) {
      case RestaurantCategory.restaurant:
        return 'Restaurant';
      case RestaurantCategory.fastFood:
        return 'Restauration Rapide';
      case RestaurantCategory.grocery:
        return 'Épicerie';
      case RestaurantCategory.pharmacy:
        return 'Pharmacie';
      case RestaurantCategory.bakery:
        return 'Boulangerie';
      case RestaurantCategory.butcher:
        return 'Boucherie';
      case RestaurantCategory.electronics:
        return 'Électronique';
      case RestaurantCategory.clothing:
        return 'Vêtements';
      case RestaurantCategory.other:
        return 'Autre';
    }
  }

  String get displayNameEn {
    switch (this) {
      case RestaurantCategory.restaurant:
        return 'Restaurant';
      case RestaurantCategory.fastFood:
        return 'Fast Food';
      case RestaurantCategory.grocery:
        return 'Grocery';
      case RestaurantCategory.pharmacy:
        return 'Pharmacy';
      case RestaurantCategory.bakery:
        return 'Bakery';
      case RestaurantCategory.butcher:
        return 'Butcher';
      case RestaurantCategory.electronics:
        return 'Electronics';
      case RestaurantCategory.clothing:
        return 'Clothing';
      case RestaurantCategory.other:
        return 'Other';
    }
  }
}
