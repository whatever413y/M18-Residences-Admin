import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m18_residences_admin/bloc_providers.dart';
import 'features/login/login_page.dart';
import 'theme.dart';

Future<void> main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(debugShowCheckedModeBanner: false, title: 'M18 Residences Admin', theme: AppTheme.lightTheme, home: LoginPage()),
    );
  }
}
