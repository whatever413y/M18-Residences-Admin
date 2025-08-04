import 'package:flutter/material.dart';
import '../../../models/reading.dart';
import 'package:intl/intl.dart';

class ReadingDetailsDialog extends StatelessWidget {
  final Reading reading;
  final String Function(int tenantId) getTenantName;
  final String Function(int roomId) getRoomName;
  final DateFormat dateFormat;

  const ReadingDetailsDialog({
    super.key,
    required this.reading,
    required this.getTenantName,
    required this.getRoomName,
    required this.dateFormat,
  });

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
      'Reading Details',
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
        _buildDetailRow('Tenant', getTenantName(reading.tenantId)),
        const SizedBox(height: 12),
        _buildDetailRow('Room', getRoomName(reading.roomId)),
        const SizedBox(height: 12),
        _buildDetailRow('Previous Reading', '${reading.prevReading} kWh'),
        const SizedBox(height: 12),
        _buildDetailRow('Current Reading', '${reading.currReading} kWh'),
        const SizedBox(height: 12),
        _buildDetailRow('Consumption', '${reading.consumption} kWh'),
        const SizedBox(height: 12),
        _buildDetailRow('Date', dateFormat.format(reading.createdAt)),
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
