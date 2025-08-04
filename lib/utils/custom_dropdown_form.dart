import 'package:flutter/material.dart';

class CustomDropdownForm<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?) onChanged;

  const CustomDropdownForm({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
