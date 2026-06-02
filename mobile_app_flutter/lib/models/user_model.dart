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
  final List<String> savedSchemes;
  final List<String> savedEquipment;

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
    this.savedSchemes = const [],
    this.savedEquipment = const [],
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

    List<String> extractIds(dynamic list) {
      if (list == null || list is! List) return [];
      return list.map((e) {
        if (e is Map) return e['_id']?.toString() ?? e['id']?.toString() ?? '';
        return e.toString();
      }).where((e) => e.isNotEmpty).toList();
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
      savedSchemes: extractIds(json['savedSchemes']),
      savedEquipment: extractIds(json['savedEquipment']),
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

class CropEntryModel {
  final String name;
  final DateTime? sowingDate;

  CropEntryModel({required this.name, this.sowingDate});

  factory CropEntryModel.fromJson(dynamic json) {
    if (json is String) {
      return CropEntryModel(name: json);
    }
    return CropEntryModel(
      name: json['name'] ?? '',
      sowingDate: json['sowingDate'] != null ? DateTime.parse(json['sowingDate']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'sowingDate': sowingDate?.toIso8601String(),
  };
}

class FarmDetailsModel {
  final double? landArea;
  final String? soilType;
  final String? irrigationType;
  final List<CropEntryModel>? crops;

  FarmDetailsModel({this.landArea, this.soilType, this.irrigationType, this.crops});

  factory FarmDetailsModel.fromJson(Map<String, dynamic> json) {
    var rawCrops = json['cropTypes'] ?? json['crops'];
    List<CropEntryModel>? cropList;
    if (rawCrops != null && rawCrops is List) {
      cropList = rawCrops.map((e) => CropEntryModel.fromJson(e)).toList();
    }

    return FarmDetailsModel(
      landArea: json['farmSize']?.toDouble() ?? json['landArea']?.toDouble(),
      soilType: json['soilType'],
      irrigationType: json['irrigationType'],
      crops: cropList,
    );
  }
}
