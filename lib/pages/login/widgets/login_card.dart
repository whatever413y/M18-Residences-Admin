import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;
  final Color color;

  const LoginCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Admin Login',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: usernameController,
                labelText: 'Username',
                prefixIcon: Icon(Icons.person, color: color),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter Username'
                            : null,
              ),
              const SizedBox(height: 15),
              CustomTextFormField(
                controller: passwordController,
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock, color: color),
                obscureText: true,
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter Password'
                            : null,
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
