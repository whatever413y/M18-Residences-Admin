import 'package:file_picker/file_picker.dart';
import 'package:rental_management_system_flutter/models/additional_charrges.dart';

class Bill {
  final int? id;
  final int tenantId;
  final int readingId;
  final int roomCharges;
  final int electricCharges;
  final List<AdditionalCharge>? additionalCharges;
  final int? totalAmount;
  final DateTime? createdAt;
  final PlatformFile? receiptFile;
  final String? receiptUrl;
  final bool? paid;

  Bill({
    this.id,
    required this.tenantId,
    required this.readingId,
    required this.roomCharges,
    required this.electricCharges,
    this.paid,
    this.additionalCharges,
    this.totalAmount,
    this.createdAt,
    this.receiptFile,
    this.receiptUrl,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      readingId: json['readingId'],
      tenantId: json['tenantId'],
      roomCharges: json['roomCharges'],
      electricCharges: json['electricCharges'],
      additionalCharges:
          json['additionalCharges'] != null ? (json['additionalCharges'] as List).map((e) => AdditionalCharge.fromJson(e)).toList() : null,
      totalAmount: json['totalAmount'],
      createdAt: DateTime.parse(json['createdAt']),
      paid: json['paid'],
      receiptUrl: json['receiptUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'readingId': readingId,
      'tenantId': tenantId,
      'roomCharges': roomCharges,
      'electricCharges': electricCharges,
      'additionalCharges': additionalCharges?.map((e) => e.toJson()).toList(),
      'receiptUrl': receiptUrl,
    };
  }
}
