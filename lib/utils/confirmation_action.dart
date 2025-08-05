import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

Future<bool> showConfirmationAction({
  required BuildContext context,
  required String confirmTitle,
  required String confirmContent,
  required Future<void> Function() onConfirmed,
  required ScaffoldMessengerState messenger,
  String loadingMessage = 'Processing...',
  String successMessage = 'Success',
  String failureMessage = 'Operation failed',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text(confirmTitle),
          content: Text(confirmContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
  );

  if (confirmed != true) return false;

  try {
    CustomSnackbar.showWithMessenger(
      messenger,
      loadingMessage,
      type: SnackBarType.loading,
    );

    await onConfirmed();

    CustomSnackbar.showWithMessenger(
      messenger,
      successMessage,
      type: SnackBarType.success,
    );

    return true;
  } catch (e) {
    CustomSnackbar.showWithMessenger(
      messenger,
      failureMessage,
      type: SnackBarType.error,
    );
    return false;
  } finally {
    CustomSnackbar.hideWithMessenger(messenger);
  }
}
