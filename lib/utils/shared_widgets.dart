import 'package:flutter/material.dart';

Widget buildActiveToggleFilter({
  required bool showActiveOnly,
  required ValueChanged<bool> onChanged,
  Color activeColor = Colors.white,
  TextStyle labelStyle = const TextStyle(color: Colors.white),
}) {
  return Row(children: [Text('Show Active Only', style: labelStyle), Switch(value: showActiveOnly, onChanged: onChanged, activeColor: activeColor)]);
}
