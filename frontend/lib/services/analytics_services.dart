import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/dashboard_stats.dart';
import '../models/insight_model.dart';

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

  static Future<List<TopProduct>> fetchTopProducts({int limit = 5}) async {
    final uri = Uri.parse("$baseUrl/analytics/top-products?limit=$limit");
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to load top products (status ${response.statusCode})");
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['products'] as List<dynamic>? ?? [];
    return list.map((e) => TopProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<CustomerDistribution> fetchCustomerDistribution({int topN = 5}) async {
    final uri = Uri.parse("$baseUrl/analytics/customer-distribution?top_n=$topN");
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception("Failed to load customer distribution (status ${response.statusCode})");
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return CustomerDistribution.fromJson(body);
  }
}