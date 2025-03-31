import 'package:flutter/material.dart';

class TenantsPage extends StatefulWidget {
  @override
  TenantsPageState createState() => TenantsPageState();
}

class TenantsPageState extends State<TenantsPage> {
  Map<String, dynamic>? latestBill;

  @override
  void initState() {
    super.initState();
    // _fetchLatestBill();
  }

  Future<void> _fetchLatestBill() async {
    try {
      await Future.delayed(Duration(seconds: 2));

      // Mock Data (Replace with actual DB fetch)
      Map<String, dynamic> bill = {
        "room_charges": 5000.00,
        "electric_charges": 1200.50,
        "additional_charges": 300.00,
        "additional_description": "Internet and water charges",
        "total_amount": 6500.50,
        "created_at": DateTime.now(),
      };

      setState(() {
        latestBill = bill;
      });
    } catch (e) {
      print("Error fetching bill: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Billing Statement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
           
      ),
    );
  }
}
