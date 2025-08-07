import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rental_management_system_flutter/bloc_providers.dart';
import 'features/login/login_page.dart';
import 'theme.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(debugShowCheckedModeBanner: false, title: 'Rental Management System', theme: AppTheme.lightTheme, home: LoginPage()),
    );
  }
}
