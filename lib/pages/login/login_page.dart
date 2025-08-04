import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/pages/login/widgets/login_card.dart';
import 'package:rental_management_system_flutter/theme.dart'; // your theme.dart
import '../home/home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _navigateToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      final username = _usernameController.text.trim();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HomePage(inputText: username)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primaryColor = theme.primaryColor;

    return Theme(
      data: theme,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withValues(alpha: 0.9),
                primaryColor.withValues(alpha: 0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: LoginCard(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  onSubmit: _navigateToNextPage,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
