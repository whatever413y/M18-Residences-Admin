import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';
import 'rooms_page.dart';
import 'tenants_page.dart';
import 'readings_page.dart';
import 'billings_page.dart';

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
    final Color blue = Colors.blue.shade800;

    return Scaffold(
      appBar: CustomAppBar(title: 'Welcome Admin!', backgroundColor: blue),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSquareButton("Rooms", Icons.meeting_room, RoomsPage()),
                const SizedBox(height: 20),
                _buildSquareButton("Tenants", Icons.people, TenantsPage()),
                const SizedBox(height: 20),
                _buildSquareButton(
                  "Electric Readings",
                  Icons.flash_on,
                  ReadingsPage(),
                ),
                const SizedBox(height: 20),
                _buildSquareButton(
                  "Billing",
                  Icons.receipt_long,
                  BillingsPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(String text, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => _navigateToPage(page),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.blue.shade800),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
