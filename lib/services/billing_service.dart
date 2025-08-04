import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rental_management_system_flutter/models/billing.dart';

class BillingService {
  static final String baseUrl = '${dotenv.env['API_URL']}/bills';

  Future<List<Bill>> fetchBills() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Bill.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bills');
    }
  }

  Future<Bill> createBill({
    required int tenantId,
    required int readingId,
    required int roomCharges,
    required int electricCharges,
    int? additionalCharges,
    String? additionalDescription,
  }) async {
    final Map<String, dynamic> body = {
      'tenantId': tenantId,
      'readingId': readingId,
      'roomCharges': roomCharges,
      'electricCharges': electricCharges,
      'additionalCharges': additionalCharges,
      'additionalDescription': additionalDescription,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      return Bill.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create bill');
    }
  }

  Future<Bill> updateBill({
    required int id,
    required int tenantId,
    required int readingId,
    required int roomCharges,
    required int electricCharges,
    int? additionalCharges,
    String? additionalDescription,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'tenantId': tenantId,
        'readingId': readingId,
        'roomCharges': roomCharges,
        'electricCharges': electricCharges,
        'additionalCharges': additionalCharges,
        'additionalDescription': additionalDescription,
      }),
    );

    if (response.statusCode == 200) {
      return Bill.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update bill');
    }
  }

  Future<void> deleteBill(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete bill');
    }
  }
}
