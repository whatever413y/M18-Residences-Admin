import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/additional_charrges.dart';
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
                if (bill.receiptUrl != null && bill.receiptUrl!.isNotEmpty) _buildReceipt(context),
                _spacer(),
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

  Widget _buildReceipt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          if (bill.receiptUrl != null) {
            showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    child: InteractiveViewer(
                      child: Image.network(
                        bill.receiptUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load image'));
                        },
                      ),
                    ),
                  ),
            );
          }
        },
        child: Text(Uri.parse(bill.receiptUrl!).pathSegments.last, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
      ),
    );
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
      buildChargesDetails(detailRows, bill.additionalCharges!);
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

  void buildChargesDetails(List<Widget> detailRows, List<AdditionalCharge> charges) {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱', decimalDigits: 0);
    final additionalCharges = charges.where((c) => c.amount >= 0).toList();
    final discounts = charges.where((c) => c.amount < 0).toList();

    if (additionalCharges.isNotEmpty) {
      detailRows.add(const SizedBox(height: 12));
      detailRows.add(const Text('Additional Charges', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
      detailRows.add(const SizedBox(height: 8));

      for (final charge in additionalCharges) {
        detailRows.add(_buildChargeRow(charge.description, currencyFormat.format(charge.amount)));
      }
    }

    if (discounts.isNotEmpty) {
      detailRows.add(const SizedBox(height: 16));
      detailRows.add(const Text('Discounts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)));
      detailRows.add(const SizedBox(height: 8));

      for (final charge in discounts) {
        detailRows.add(_buildChargeRow(charge.description, currencyFormat.format(charge.amount.abs())));
      }
    }
  }

  Widget _buildChargeRow(String description, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(description.isNotEmpty ? description : '-', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))),
          Text(amount),
        ],
      ),
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
