class Bill {
  final int id;
  final int tenantId;
  final int readingId;
  final int roomCharges;
  final int electricCharges;
  final int additionalCharges;
  final String? additionalDescription;
  final int totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.id,
    required this.tenantId,
    required this.readingId,
    required this.roomCharges,
    required this.electricCharges,
    required this.additionalCharges,
    this.additionalDescription,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      tenantId: json['tenantId'],
      readingId: json['readingId'],
      roomCharges: json['roomCharges'],
      electricCharges: json['electricCharges'],
      additionalCharges: json['additionalCharges'],
      additionalDescription: json['additionalDescription'],
      totalAmount: json['totalAmount'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenantId': tenantId,
      'readingId': readingId,
      'roomCharges': roomCharges,
      'electricCharges': electricCharges,
      'additionalCharges': additionalCharges,
      'additionalDescription': additionalDescription,
      'totalAmount': totalAmount,
    };
  }
}
