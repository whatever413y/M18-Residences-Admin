import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/login_page.dart';
import 'theme.dart';

Future<void> main() async {
  await dotenv.load();
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
