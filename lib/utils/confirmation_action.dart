import 'package:flutter/material.dart';

Future<bool> showConfirmationAction({
  required BuildContext context,
  required ScaffoldMessengerState messenger,
  required String confirmTitle,
  required String confirmContent,
  required Future<void> Function() onConfirmed,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text(confirmTitle),
          content: Text(confirmContent),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Confirm', style: TextStyle(color: Colors.red))),
          ],
        ),
  );

  if (confirmed != true) return false;

  try {
    await onConfirmed();
    return true;
  } catch (e) {
    return false;
  }
}
