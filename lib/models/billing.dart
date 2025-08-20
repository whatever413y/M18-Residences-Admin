import 'package:file_picker/file_picker.dart';
import 'package:m18_residences_admin/models/additional_charges.dart';

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
    final billJson = json['bill'] ?? {};

    return Bill(
      id: billJson['id'],
      readingId: billJson['reading_id'],
      tenantId: billJson['tenant_id'],
      roomCharges: billJson['room_charges'],
      electricCharges: billJson['electric_charges'],
      totalAmount: billJson['total_amount'],
      createdAt: DateTime.parse(billJson['created_at']),
      paid: billJson['paid'],
      receiptUrl: billJson['receipt_url'],
      additionalCharges:
          json['additional_charges'] != null ? (json['additional_charges'] as List).map((e) => AdditionalCharge.fromJson(e)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reading_id': readingId,
      'tenant_id': tenantId,
      'room_charges': roomCharges,
      'electric_charges': electricCharges,
      'additional_charges': additionalCharges?.map((e) => e.toJson()).toList(),
      'receipt_url': receiptUrl,
    };
  }
}
