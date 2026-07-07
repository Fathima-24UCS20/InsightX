import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dashboard_stats.dart';

class AnalyticsService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<DashboardStats> fetchDashboardStats() async {
    final uri = Uri.parse("$baseUrl/analytics/dashboard");
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to load dashboard stats (status ${response.statusCode})");
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return DashboardStats.fromJson(body);
  }
}