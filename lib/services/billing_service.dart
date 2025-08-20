import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:m18_residences_admin/models/additional_charges.dart';
import 'package:m18_residences_admin/models/billing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BillingService {
  static final String baseUrl = '${dotenv.env['API_URL']}/bills';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<List<Bill>> fetchBills() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: await _getAuthHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Bill.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load bills: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching bills: $e');
      rethrow;
    }
  }

  Future<Bill> createBill({
    required int tenantId,
    required int readingId,
    required int roomCharges,
    required int electricCharges,
    List<AdditionalCharge>? additionalCharges,
  }) async {
    try {
      final body = {
        'tenant_id': tenantId,
        'reading_id': readingId,
        'room_charges': roomCharges,
        'electric_charges': electricCharges,
        'additional_charges': additionalCharges?.map((e) => e.toJson()).toList(),
      };

      final response = await http.post(Uri.parse(baseUrl), headers: await _getAuthHeaders(), body: json.encode(body));

      if (response.statusCode == 201) {
        print('Bill created successfully: ${response.body}');
        return Bill.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create bill: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating bill: $e');
      rethrow;
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
    try {
      if (receiptFile != null) {
        final url = Uri.parse('$baseUrl/$id/upload');
        var request = http.MultipartRequest('PUT', url);

        request.headers.addAll(await _getAuthHeaders());

        request.fields['tenant_id'] = tenantId.toString();
        request.fields['reading_id'] = readingId.toString();
        request.fields['room_charges'] = roomCharges.toString();
        request.fields['electric_charges'] = electricCharges.toString();
        request.fields['additional_charges'] = json.encode(additionalCharges?.map((e) => e.toJson()).toList() ?? []);
        request.fields['receipt_url'] = receiptUrl ?? '';

        final ext = receiptFile.extension?.toLowerCase();
        final mediaType = (ext == 'jpg' || ext == 'jpeg') ? MediaType('image', 'jpeg') : MediaType('image', 'png');

        // Add file bytes if available (web)
        if (receiptFile.bytes != null) {
          var multipartFile = http.MultipartFile.fromBytes('receipt_file', receiptFile.bytes!, filename: receiptFile.name, contentType: mediaType);
          request.files.add(multipartFile);
        } else if (receiptFile.path != null) {
          // Add file from path (mobile/desktop)
          var file = File(receiptFile.path!);
          var multipartFile = await http.MultipartFile.fromPath('receipt_file', file.path, contentType: mediaType);
          request.files.add(multipartFile);
        } else {
          throw Exception('No file bytes or path available for receiptFile');
        }

        final response = await request.send();
        final respStr = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          return Bill.fromJson(json.decode(respStr));
        } else {
          throw Exception('Failed to update bill with file: ${response.statusCode} $respStr');
        }
      } else {
        // No file provided, send JSON
        final url = Uri.parse('$baseUrl/$id');
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json', ...await _getAuthHeaders()},
          body: json.encode({
            'tenant_id': tenantId,
            'reading_id': readingId,
            'room_charges': roomCharges,
            'electric_charges': electricCharges,
            'additional_charges': additionalCharges?.map((e) => e.toJson()).toList(),
            'receipt_url': receiptUrl,
          }),
        );

        if (response.statusCode == 200) {
          return Bill.fromJson(json.decode(response.body));
        } else {
          throw Exception('Failed to update bill without file');
        }
      }
    } catch (e) {
      print('Error updating bill: $e');
      rethrow;
    }
  }

  Future<void> deleteBill(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _getAuthHeaders());
      if (response.statusCode != 204) {
        throw Exception('Failed to delete bill: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting bill: $e');
      rethrow;
    }
  }
}
