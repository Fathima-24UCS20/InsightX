import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lead_summary.dart';
import '../models/lead.dart';
import '../models/lead_suggestions.dart';
import '../models/lead_chart.dart';
import '../models/recent_lead.dart';

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

  Future<LeadSummary> fetchSummary() async {
    final response = await http.get(
      Uri.parse("$baseUrl/analytics/leads/summary"),
    );

    if (response.statusCode == 200) {
      return LeadSummary.fromJson(jsonDecode(response.body));
    }

    throw Exception("Failed to load summary");
  }

  Future<List<LeadSuggestion>> fetchSuggestions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/analytics/leads/suggestions"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((item) => LeadSuggestion.fromJson(item)).toList();
    }

    throw Exception("Failed to load suggestions");
  }

  Future<LeadChart> fetchLeadChart() async {
    final response = await http.get(
      Uri.parse("$baseUrl/analytics/leads/chart"),
    );

    if (response.statusCode == 200) {
      return LeadChart.fromJson(jsonDecode(response.body));
    }

    throw Exception("Failed to load chart");
  }

  Future<List<RecentLead>> fetchRecentLeads() async {
    final response = await http.get(
      Uri.parse("$baseUrl/analytics/leads/recent"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => RecentLead.fromJson(e)).toList();
    }

    throw Exception("Failed to load recent leads");
  }
}
