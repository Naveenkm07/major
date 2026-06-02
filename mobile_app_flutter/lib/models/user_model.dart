class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? avatar;
  final LocationModel? location;
  final FarmDetailsModel? farmDetails;
  final UserStatsModel? stats;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.avatar,
    this.location,
    this.farmDetails,
    this.stats,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend sends location as flat fields (district, state, village) OR nested location object
    LocationModel? location;
    if (json['location'] != null) {
      location = LocationModel.fromJson(json['location']);
    } else if (json['district'] != null || json['state'] != null || json['village'] != null) {
      // Flat fields from backend
      location = LocationModel(
        district: json['district'],
        state: json['state'],
        village: json['village'],
      );
    }

    // Backend sends crops as cropTypes, farmSize as farmSize
    FarmDetailsModel? farmDetails;
    if (json['farmDetails'] != null) {
      farmDetails = FarmDetailsModel.fromJson(json['farmDetails']);
    } else if (json['cropTypes'] != null || json['farmSize'] != null || json['soilType'] != null || json['irrigationType'] != null) {
      farmDetails = FarmDetailsModel.fromJson(json);
    }

    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      role: json['role'] ?? 'farmer',
      avatar: json['avatar'],
      location: location,
      farmDetails: farmDetails,
      stats: json['stats'] != null ? UserStatsModel.fromJson(json['stats']) : null,
    );
  }
}

class UserStatsModel {
  final int diseaseScans;
  final int communityPosts;
  final int marketAlerts;
  final int schemesApplied;

  UserStatsModel({
    required this.diseaseScans,
    required this.communityPosts,
    required this.marketAlerts,
    required this.schemesApplied,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      diseaseScans: json['diseaseScans'] ?? 0,
      communityPosts: json['communityPosts'] ?? 0,
      marketAlerts: json['marketAlerts'] ?? 0,
      schemesApplied: json['schemesApplied'] ?? 0,
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
      landArea: json['farmSize']?.toDouble() ?? json['landArea']?.toDouble(),
      soilType: json['soilType'],
      irrigationType: json['irrigationType'],
      crops: json['cropTypes'] != null 
          ? List<String>.from(json['cropTypes']) 
          : (json['crops'] != null ? List<String>.from(json['crops']) : null),
    );
  }
}
