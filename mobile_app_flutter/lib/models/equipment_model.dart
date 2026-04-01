class EquipmentModel {
  final String id;
  final String name;
  final String type;
  final String ownerName;
  final String? description;
  final double pricePerHour;
  final bool availability;
  final String? village;
  final String? district;
  final String contactPhone;
  final List<String> images;

  EquipmentModel({
    required this.id,
    required this.name,
    required this.type,
    required this.ownerName,
    this.description,
    required this.pricePerHour,
    required this.availability,
    this.village,
    this.district,
    required this.contactPhone,
    required this.images,
  });

  factory EquipmentModel.fromJson(Map<String, dynamic> json) {
    return EquipmentModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'Other',
      ownerName: json['ownerName'] ?? 'Farmer',
      description: json['description'],
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
      availability: json['availability'] ?? true,
      village: json['location']?['village'],
      district: json['location']?['district'],
      contactPhone: json['contactPhone'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
    );
  }
}
