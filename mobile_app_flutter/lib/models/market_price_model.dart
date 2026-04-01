class MarketPriceModel {
  final String id;
  final String commodity;
  final String? variety;
  final String state;
  final String district;
  final String market;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;
  final String unit;
  final DateTime arrivalDate;

  MarketPriceModel({
    required this.id,
    required this.commodity,
    this.variety,
    required this.state,
    required this.district,
    required this.market,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
    required this.unit,
    required this.arrivalDate,
  });

  factory MarketPriceModel.fromJson(Map<String, dynamic> json) {
    return MarketPriceModel(
      id: json['_id'] ?? '',
      commodity: json['commodity'] ?? '',
      variety: json['variety'],
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      market: json['market'] ?? '',
      minPrice: (json['minPrice'] ?? 0).toDouble(),
      maxPrice: (json['maxPrice'] ?? 0).toDouble(),
      modalPrice: (json['modalPrice'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'Quintal',
      arrivalDate: DateTime.parse(json['arrivalDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
