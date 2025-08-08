import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_event.dart';
import 'package:rental_management_system_flutter/features/login/login_page.dart';

Widget buildErrorWidget({required BuildContext context, required String message, VoidCallback? onRetry}) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed:
              onRetry ??
              () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => LoginPage()), (route) => false);
              },
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    ),
  );
}
