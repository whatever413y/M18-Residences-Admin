import 'package:flutter/material.dart';

enum SnackBarType { success, error, info, loading }

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    bool dismissPrevious = true,
  }) {
    final theme = Theme.of(context);

    final Map<SnackBarType, Color> colorMap = {
      SnackBarType.success: Colors.green.shade600,
      SnackBarType.error: Colors.red.shade600,
      SnackBarType.info: Colors.blue.shade600,
      SnackBarType.loading: Colors.grey.shade800,
    };

    final Map<SnackBarType, IconData> iconMap = {
      SnackBarType.success: Icons.check_circle_outline,
      SnackBarType.error: Icons.error_outline,
      SnackBarType.info: Icons.info_outline,
    };

    final Color contentColor =
        theme.snackBarTheme.contentTextStyle?.color ??
        theme.colorScheme.onPrimary;

    final Widget leading =
        type == SnackBarType.loading
            ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(contentColor),
              ),
            )
            : Icon(iconMap[type], color: contentColor);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorMap[type],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration:
          type == SnackBarType.loading ? const Duration(hours: 1) : duration,
      content: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style:
                  theme.snackBarTheme.contentTextStyle ??
                  TextStyle(color: contentColor),
            ),
          ),
        ],
      ),
    );

    final messenger = ScaffoldMessenger.of(context);
    if (dismissPrevious) messenger.hideCurrentSnackBar();
    messenger.showSnackBar(snackBar);
  }

  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}
