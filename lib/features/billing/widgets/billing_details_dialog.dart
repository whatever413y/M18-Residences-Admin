import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

class BillingDetailsDialog extends StatelessWidget {
  final Bill bill;
  final String tenantName;
  final String roomName;
  final String consumption;
  final String date;

  const BillingDetailsDialog({
    super.key,
    required this.bill,
    required this.tenantName,
    required this.roomName,
    required this.consumption,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 12,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildDetails(),
                const SizedBox(height: 24),
                _buildCloseButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Billing Details',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.blue.shade800,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade300, thickness: 1);
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Tenant', tenantName),
        const SizedBox(height: 12),
        _buildDetailRow('Room', roomName),
        const SizedBox(height: 12),
        _buildDetailRow('Consumption', '$consumption kWh'),
        const SizedBox(height: 12),
        _buildDetailRow('Electric Charges', '₱${bill.electricCharges}'),
        const SizedBox(height: 12),
        _buildDetailRow('Room Charges', '₱${bill.roomCharges}'),
        if (bill.additionalCharges! > 0) ...[
          const SizedBox(height: 12),
          _buildDetailRow('Additional Charges', '₱${bill.additionalCharges}'),
        ],
        if ((bill.additionalDescription ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailRow('Notes', bill.additionalDescription!),
        ],
        const SizedBox(height: 12),
        _buildDivider(),
        const SizedBox(height: 12),
        _buildDetailRow('Total Amount', '₱${bill.totalAmount}'),
        const SizedBox(height: 12),
        _buildDetailRow('Date', date),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.blue.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () => Navigator.of(context).pop(),
        child: const Text(
          'Close',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}
