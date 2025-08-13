import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/models/room.dart';

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TenantCard({super.key, required this.tenant, required this.room, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tenant.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 6),
                  Text('Room: ${room.name}\nJoined: ${dateFormat.format(tenant.joinDate)}'),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
                IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
