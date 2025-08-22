class Immobile {
  final int idImmobile;
  final String propertyType;
  final String zipCode;
  final String state;
  final String city;
  final String street;
  final String? number;
  final bool noNumber;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final double rent;
  final bool airConditioning;
  final bool garage;
  final bool pool;
  final bool furnished;
  final bool petFriendly;
  final bool nearbyMarket;
  final bool nearbyBus;
  final bool internet;
  final String description;
  final String? additionalRules;
  final String status;
  final String createdAt;
  final List<ImmobilePhoto> photosBlob;

  Immobile({
    required this.idImmobile,
    required this.propertyType,
    required this.zipCode,
    required this.state,
    required this.city,
    required this.street,
    this.number,
    required this.noNumber,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.rent,
    required this.airConditioning,
    required this.garage,
    required this.pool,
    required this.furnished,
    required this.petFriendly,
    required this.nearbyMarket,
    required this.nearbyBus,
    required this.internet,
    required this.description,
    this.additionalRules,
    required this.status,
    required this.createdAt,
    required this.photosBlob,
  });

  factory Immobile.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    return Immobile(
      idImmobile: parseInt(json['id_immobile']),
      propertyType: json['property_type'] as String,
      zipCode: json['zip_code'] as String,
      state: json['state'] as String,
      city: json['city'] as String,
      street: json['street'] as String,
      number: json['number'] as String?,
      noNumber: json['no_number'] as bool? ?? false,
      bedrooms: parseInt(json['bedrooms']),
      bathrooms: parseInt(json['bathrooms']),
      area: parseDouble(json['area']),
      rent: parseDouble(json['rent']),
      airConditioning: json['air_conditioning'] as bool? ?? false,
      garage: json['garage'] as bool? ?? false,
      pool: json['pool'] as bool? ?? false,
      furnished: json['furnished'] as bool? ?? false,
      petFriendly: json['pet_friendly'] as bool? ?? false,
      nearbyMarket: json['nearby_market'] as bool? ?? false,
      nearbyBus: json['nearby_bus'] as bool? ?? false,
      internet: json['internet'] as bool? ?? false,
      description: json['description'] as String,
      additionalRules: json['additional_rules'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      photosBlob: (json['photosBlob'] as List<dynamic>? ?? [])
          .map((e) => ImmobilePhoto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_immobile': idImmobile,
      'property_type': propertyType,
      'zip_code': zipCode,
      'state': state,
      'city': city,
      'street': street,
      'number': number,
      'no_number': noNumber,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'rent': rent,
      'air_conditioning': airConditioning,
      'garage': garage,
      'pool': pool,
      'furnished': furnished,
      'pet_friendly': petFriendly,
      'nearby_market': nearbyMarket,
      'nearby_bus': nearbyBus,
      'internet': internet,
      'description': description,
      'additional_rules': additionalRules,
      'status': status,
      'created_at': createdAt,
      'photosBlob': photosBlob.map((p) => p.toJson()).toList(),
    };
  }
}


class ImmobilePhoto {
  final int id;
  final int photoId; 
  String imageBase64;
  String contentType;
  final String uploadedAt;

  ImmobilePhoto({
    required this.id,
    required this.photoId,
    required this.imageBase64,
    required this.contentType,
    required this.uploadedAt,
  });

  factory ImmobilePhoto.fromJson(Map<String, dynamic> json) {
    return ImmobilePhoto(
      id: json['id'] as int,
      photoId: json['id'] as int,
      imageBase64: json['image_blob'] as String,
      contentType: json['content_type'] as String,
      uploadedAt: json['uploaded_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_blob': imageBase64,
      'content_type': contentType,
      'uploaded_at': uploadedAt,
    };
  }
}