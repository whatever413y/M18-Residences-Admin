import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:rental_management_system_flutter/models/additional_charrges.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BillingService {
  static final String baseUrl = '${String.fromEnvironment('API_URL')}/bills';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<List<Bill>> fetchBills() async {
    final response = await http.get(Uri.parse(baseUrl), headers: await _getAuthHeaders());
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
    List<AdditionalCharge>? additionalCharges,
    String? additionalDescription,
  }) async {
    final Map<String, dynamic> body = {
      'tenantId': tenantId,
      'readingId': readingId,
      'roomCharges': roomCharges,
      'electricCharges': electricCharges,
      'additionalCharges': additionalCharges?.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(Uri.parse(baseUrl), headers: await _getAuthHeaders(), body: json.encode(body));

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
    String? receiptUrl,
    List<AdditionalCharge>? additionalCharges,
    PlatformFile? receiptFile,
  }) async {
    final url = Uri.parse('$baseUrl/$id');

    if (receiptFile != null) {
      var request = http.MultipartRequest('PUT', url);

      request.headers.addAll(await _getAuthHeaders());

      request.fields['tenantId'] = tenantId.toString();
      request.fields['readingId'] = readingId.toString();
      request.fields['roomCharges'] = roomCharges.toString();
      request.fields['electricCharges'] = electricCharges.toString();
      request.fields['additionalCharges'] = json.encode(additionalCharges?.map((e) => e.toJson()).toList() ?? []);
      request.fields['receiptUrl'] = receiptUrl ?? '';

      // Add file bytes if available (web)
      if (receiptFile.bytes != null) {
        var multipartFile = http.MultipartFile.fromBytes(
          'receiptFile',
          receiptFile.bytes!,
          filename: receiptFile.name,
          contentType: MediaType('image', 'png'),
        );
        request.files.add(multipartFile);
      } else if (receiptFile.path != null) {
        // Add file from path (mobile/desktop)
        var file = File(receiptFile.path!);
        var multipartFile = await http.MultipartFile.fromPath('receiptFile', file.path, contentType: MediaType('image', 'png'));
        request.files.add(multipartFile);
      } else {
        throw Exception('No file bytes or path available for receiptFile');
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        return Bill.fromJson(json.decode(respStr));
      } else {
        throw Exception('Failed to update bill with file');
      }
    } else {
      // No file provided, send JSON
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', ...await _getAuthHeaders()},
        body: json.encode({
          'tenantId': tenantId,
          'readingId': readingId,
          'roomCharges': roomCharges,
          'electricCharges': electricCharges,
          'additionalCharges': additionalCharges?.map((e) => e.toJson()).toList(),
          'receiptUrl': receiptUrl,
        }),
      );

      if (response.statusCode == 200) {
        return Bill.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update bill without file');
      }
    }
  }

  Future<void> deleteBill(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _getAuthHeaders());
    if (response.statusCode != 204) {
      throw Exception('Failed to delete bill');
    }
  }
}
