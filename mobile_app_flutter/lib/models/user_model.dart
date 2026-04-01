class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final LocationModel? location;
  final FarmDetailsModel? farmDetails;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.location,
    this.farmDetails,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'farmer',
      avatar: json['avatar'],
      location: json['location'] != null ? LocationModel.fromJson(json['location']) : null,
      farmDetails: json['farmDetails'] != null ? FarmDetailsModel.fromJson(json['farmDetails']) : null,
    );
  }
}

class LocationModel {
  final String? state;
  final String? district;
  final String? village;

  LocationModel({this.state, this.district, this.village});

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      state: json['state'],
      district: json['district'],
      village: json['village'],
    );
  }
}

class FarmDetailsModel {
  final double? landArea;
  final String? soilType;
  final String? irrigationType;
  final List<String>? crops;

  FarmDetailsModel({this.landArea, this.soilType, this.irrigationType, this.crops});

  factory FarmDetailsModel.fromJson(Map<String, dynamic> json) {
    return FarmDetailsModel(
      landArea: json['landArea']?.toDouble(),
      soilType: json['soilType'],
      irrigationType: json['irrigationType'],
      crops: json['crops'] != null ? List<String>.from(json['crops']) : null,
    );
  }
}
