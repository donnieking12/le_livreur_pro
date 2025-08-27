class Address {
  final String id;
  final String userId; // Links to User
  final String label; // e.g., "Maison", "Bureau", "Chez maman"
  final String fullAddress;
  final double latitude;
  final double longitude;

  // Detailed address components
  final String? streetNumber;
  final String? streetName;
  final String? neighborhood; // Quartier (important for Abidjan/San-Pedro)
  final String? commune; // Commune (administrative division in Côte d'Ivoire)
  final String? city;
  final String? postalCode;

  // Landmark-based addressing (crucial for Côte d'Ivoire)
  final String? nearbyLandmark; // e.g., "Près de la pharmacie Nouvelle", "Derrière l'école primaire"
  final String? additionalInstructions; // Detailed directions in French
  // Address type and usage
  final AddressType type;
  final bool isDefault; // Default address for this type
  final bool isActive;

  // Contact information for this address
  final String? contactName; // Person to contact at this address
  final String? contactPhone; // Phone number for this specific location
  // Technical metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.streetNumber,
    this.streetName,
    this.neighborhood,
    this.commune,
    this.city,
    this.postalCode,
    this.nearbyLandmark,
    this.additionalInstructions,
    required this.type,
    this.isDefault = false,
    this.isActive = true,
    this.contactName,
    this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      label: json['label'] as String,
      fullAddress: json['full_address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      streetNumber: json['street_number'] as String?,
      streetName: json['street_name'] as String?,
      neighborhood: json['neighborhood'] as String?,
      commune: json['commune'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      nearbyLandmark: json['nearby_landmark'] as String?,
      additionalInstructions: json['additional_instructions'] as String?,
      type: AddressType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AddressType.other,
      ),
      isDefault: json['is_default'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'label': label,
      'full_address': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'street_number': streetNumber,
      'street_name': streetName,
      'neighborhood': neighborhood,
      'commune': commune,
      'city': city,
      'postal_code': postalCode,
      'nearby_landmark': nearbyLandmark,
      'additional_instructions': additionalInstructions,
      'type': type.name,
      'is_default': isDefault,
      'is_active': isActive,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Address copyWith({
    String? id,
    String? userId,
    String? label,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? streetNumber,
    String? streetName,
    String? neighborhood,
    String? commune,
    String? city,
    String? postalCode,
    String? nearbyLandmark,
    String? additionalInstructions,
    AddressType? type,
    bool? isDefault,
    bool? isActive,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Address(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      label: label ?? this.label,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      streetNumber: streetNumber ?? this.streetNumber,
      streetName: streetName ?? this.streetName,
      neighborhood: neighborhood ?? this.neighborhood,
      commune: commune ?? this.commune,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      nearbyLandmark: nearbyLandmark ?? this.nearbyLandmark,
      additionalInstructions:
          additionalInstructions ?? this.additionalInstructions,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum AddressType {
  home,
  work,
  other,
}

extension AddressTypeExtension on AddressType {
  String get displayNameFr {
    switch (this) {
      case AddressType.home:
        return 'Domicile';
      case AddressType.work:
        return 'Travail';
      case AddressType.other:
        return 'Autre';
    }
  }

  String get displayNameEn {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }

  String get iconName {
    switch (this) {
      case AddressType.home:
        return 'home';
      case AddressType.work:
        return 'work';
      case AddressType.other:
        return 'location_on';
    }
  }
}

// Common neighborhoods in San-Pedro for quick selection
class SanPedroNeighborhoods {
  static const List<String> neighborhoods = [
    'Balmer',
    'Bardot',
    'Bérdouané',
    'Brasserie',
    'Cité Air France',
    'Cité PALMCI',
    'Cité SACO',
    'Grand Béréby',
    'Libreville',
    'Lycée',
    'Marché Central',
    'Nouveau Port',
    'Phare',
    'Pont Charles',
    'Port Autonome',
    'Séwéké',
    'Tabou Carrefour',
    'Wharf',
  ];

  static const Map<String, List<String>> landmarks = {
    'Marché Central': [
      'Marché Central de San-Pedro',
      'Gare routière principale',
      'Mosquée centrale',
    ],
    'Port Autonome': [
      'Port Autonome de San-Pedro',
      'Direction du Port',
      'Terminal à conteneurs',
    ],
    'Lycée': [
      'Lycée Municipal de San-Pedro',
      'Complexe scolaire moderne',
      'Terrain de sport municipal',
    ],
  };
}
