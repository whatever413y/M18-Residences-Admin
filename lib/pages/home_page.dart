import 'package:flutter/material.dart';
import 'rooms_page.dart';
import 'tenants_page.dart';
import 'readings_page.dart';
import 'billings_page.dart';

class HomePage extends StatefulWidget {
  final String inputText;

  HomePage({required this.inputText});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _navigateToPage(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome Admin!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
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
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSquareButton("Rooms", Icons.receipt, RoomsPage()),
                SizedBox(height: 20),
                _buildSquareButton("Tenants", Icons.history, TenantsPage()),
                SizedBox(height: 20),
                _buildSquareButton("Electric Readings", Icons.receipt, ReadingsPage()),
                SizedBox(height: 20),
                _buildSquareButton("Billing", Icons.receipt, BillingsPage()),
                SizedBox(height: 20),
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
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
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
            SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
