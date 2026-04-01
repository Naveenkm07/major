/// Loan model matching the Loan Mongoose schema
class LoanModel {
  final String id;
  final String? loanType;
  final String? bankName;
  final String? title;
  final Map<String, dynamic>? interestRate;
  final bool subsidyAvailable;
  final List<String>? features;
  final String? description;

  LoanModel({
    required this.id,
    this.loanType,
    this.bankName,
    this.title,
    this.interestRate,
    this.subsidyAvailable = false,
    this.features,
    this.description,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['_id'] ?? '',
        loanType: json['loanType'],
        bankName: json['bankName'],
        title: json['title'] ?? json['loanType'],
        interestRate: json['interestRate'],
        subsidyAvailable: json['subsidyAvailable'] ?? false,
        features: (json['features'] as List?)?.map((e) => e.toString()).toList(),
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'loanType': loanType,
        'bankName': bankName,
        'title': title,
        'interestRate': interestRate,
        'subsidyAvailable': subsidyAvailable,
        'features': features,
      };
}
