import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    return Text('Billing Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue.shade800));
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey.shade300, thickness: 1);
  }

  Widget _spacer() => const SizedBox(height: 12);

  Widget _buildDetails() {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);

    List<Widget> detailRows = [
      _buildDetailRow('Tenant', tenantName),
      _spacer(),
      _buildDetailRow('Room', roomName),
      _spacer(),
      _buildDetailRow('Consumption', '$consumption kWh'),
      _spacer(),
      _buildDetailRow('Electric Charges', currencyFormat.format(bill.electricCharges)),
      _spacer(),
      _buildDetailRow('Room Charges', currencyFormat.format(bill.roomCharges)),
    ];

    if (bill.additionalCharges != null && bill.additionalCharges!.isNotEmpty) {
      for (final charge in bill.additionalCharges!) {
        final label = charge.amount < 0 ? 'Discount' : 'Additional Charge';
        detailRows.add(_spacer());
        detailRows.add(_buildDetailRow(label, currencyFormat.format(charge.amount.abs())));
        if (charge.description.isNotEmpty) {
          detailRows.add(_spacer());
          detailRows.add(_buildDetailRow('Notes', charge.description));
        }
      }
    }

    detailRows.addAll([
      _spacer(),
      _buildDivider(),
      _spacer(),
      _buildDetailRow('Total Amount', currencyFormat.format(bill.totalAmount)),
      _spacer(),
      _buildDetailRow('Date', date),
    ]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: detailRows);
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w400))),
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
        child: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}
