import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/lead.dart';

class LeadService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<List<Lead>> fetchLeads() async {
    final response = await http.get(Uri.parse("$baseUrl/analytics/leads"));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => Lead.fromJson(e)).toList();
    }

    throw Exception("Failed to load leads");
  }
}
