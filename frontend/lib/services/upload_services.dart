import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

/// Result of an upload attempt: whether it succeeded, how many rows were
/// processed (parsed from the backend's JSON response), and an error message
/// on failure so the UI can show something more useful than "Failed".
class UploadResult {
  final bool success;
  final int? rows;
  final String? error;

  const UploadResult({required this.success, this.rows, this.error});
}

class UploadService {

  static const String baseUrl = "http://127.0.0.1:8000";

  /// Generic uploader used by all four dataset types.
  /// [endpoint] should be one of: customers, products, orders, order_items
  static Future<UploadResult> uploadFile(
      String endpoint, PlatformFile file) async {

    var uri = Uri.parse("$baseUrl/upload/$endpoint");

    try {
      var request = http.MultipartRequest("POST", uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          file.bytes!,
          filename: file.name,
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ignore: avoid_print
      print("Upload [$endpoint] response [${response.statusCode}]: ${response.body}");

      Map<String, dynamic>? body;
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        body = null;
      }

      if (response.statusCode == 200) {
        final rows = body?["rows"] as int?;
        return UploadResult(success: true, rows: rows);
      }

      // FastAPI's HTTPException puts the message in "detail".
      final errorMsg = body?["detail"]?.toString() ??
          "Upload failed (status ${response.statusCode})";
      return UploadResult(success: false, error: errorMsg);
    } catch (e) {
      // ignore: avoid_print
      print("Upload [$endpoint] failed with exception: $e");
      return UploadResult(success: false, error: e.toString());
    }
  }

  static Future<UploadResult> uploadCustomers(PlatformFile file) =>
      uploadFile("customers", file);

  static Future<UploadResult> uploadProducts(PlatformFile file) =>
      uploadFile("products", file);

  static Future<UploadResult> uploadOrders(PlatformFile file) =>
      uploadFile("orders", file);

  static Future<UploadResult> uploadOrderItems(PlatformFile file) =>
      uploadFile("order_items", file);
}