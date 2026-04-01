/// Government scheme model
class SchemeModel {
  final String id;
  final String schemeName;
  final String? ministry;
  final String? schemeType;
  final String? description;
  final List<String>? benefits;
  final List<String>? eligibility;
  final String? applicationLink;
  final bool isActive;

  SchemeModel({
    required this.id,
    required this.schemeName,
    this.ministry,
    this.schemeType,
    this.description,
    this.benefits,
    this.eligibility,
    this.applicationLink,
    this.isActive = true,
  });

  factory SchemeModel.fromJson(Map<String, dynamic> json) => SchemeModel(
        id: json['_id'] ?? '',
        schemeName: json['schemeName'] ?? json['title'] ?? '',
        ministry: json['ministry'],
        schemeType: json['schemeType'],
        description: json['description'],
        benefits: (json['benefits'] as List?)?.map((e) => e.toString()).toList(),
        eligibility: (json['eligibility'] as List?)?.map((e) => e.toString()).toList(),
        applicationLink: json['applicationLink'],
        isActive: json['isActive'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'schemeName': schemeName,
        'ministry': ministry,
        'schemeType': schemeType,
        'description': description,
        'benefits': benefits,
        'eligibility': eligibility,
        'applicationLink': applicationLink,
      };
}
