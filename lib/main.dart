import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rental Management System',
      theme: AppTheme.lightTheme,
      home: LoginPage(),
    );
  }
}
