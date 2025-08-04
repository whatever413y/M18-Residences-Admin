import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/pages/billings_page.dart';
import 'package:rental_management_system_flutter/pages/home/widgets/square_button.dart';
import 'package:rental_management_system_flutter/pages/reading/readings_page.dart';
import 'package:rental_management_system_flutter/pages/room/rooms_page.dart';
import 'package:rental_management_system_flutter/pages/tenants/tenants_page.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';

class HomePage extends StatefulWidget {
  final String inputText;

  const HomePage({required this.inputText, super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final primaryColor = theme.primaryColor;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Welcome Admin!'),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SquareButton(
                      text: "Rooms",
                      icon: Icons.meeting_room,
                      onTap: () => _navigateToPage(RoomsPage()),
                      color: primaryColor,
                    ),
                    const SizedBox(height: 20),
                    SquareButton(
                      text: "Tenants",
                      icon: Icons.people,
                      onTap: () => _navigateToPage(TenantsPage()),
                      color: primaryColor,
                    ),
                    const SizedBox(height: 20),
                    SquareButton(
                      text: "Electric Readings",
                      icon: Icons.flash_on,
                      onTap: () => _navigateToPage(ReadingsPage()),
                      color: primaryColor,
                    ),
                    const SizedBox(height: 20),
                    SquareButton(
                      text: "Billing",
                      icon: Icons.receipt_long,
                      onTap: () => _navigateToPage(BillingsPage()),
                      color: primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
