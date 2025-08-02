import 'package:flutter/material.dart';

class CustomAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  const CustomAddButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon = Icons.add,
    this.backgroundColor = const Color(0xFF1565C0),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      icon: Icon(icon, color: foregroundColor),
      label: Text(label, style: TextStyle(color: foregroundColor)),
    );
  }
}
