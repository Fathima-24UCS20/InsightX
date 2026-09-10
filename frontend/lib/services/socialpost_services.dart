import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/social_post.dart';

class SocialPostService {
  final String baseUrl;
  final http.Client _client;

  SocialPostService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<SocialPost> generatePost({
    required int campaignId,
    required int dayNumber,
    required String platform,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/social-posts/',
    );

    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'campaign_id': campaignId,
            'day_number': dayNumber,
            'platform': platform,
          }),
        )
        .timeout(
          const Duration(seconds: 180),
        );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String message =
          'Failed to generate social post';

      try {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['detail'] != null) {
          message = data['detail'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data = jsonDecode(response.body);

    return SocialPost.fromJson(data);
  }

  /// Fetch already-generated posts from the backend.
  ///
  /// This is used by the Post Generator page to pick up posts created
  /// automatically by the campaign scheduler.
  Future<List<SocialPost>> fetchPosts({
    int? campaignId,
    int? dayNumber,
    String? platform,
  }) async {
    final queryParameters = <String, String>{};

    if (campaignId != null) {
      queryParameters['campaign_id'] = campaignId.toString();
    }

    if (dayNumber != null) {
      queryParameters['day_number'] = dayNumber.toString();
    }

    if (platform != null && platform.trim().isNotEmpty) {
      queryParameters['platform'] = platform;
    }

    final uri = Uri.parse(
      '$baseUrl/social-posts/',
    ).replace(
      queryParameters:
          queryParameters.isEmpty ? null : queryParameters,
    );

    final response = await _client
        .get(uri)
        .timeout(
          const Duration(seconds: 30),
        );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String message = 'Failed to fetch social posts';

      try {
        final data = jsonDecode(response.body);

        if (data is Map &&
            data['detail'] != null) {
          message = data['detail'].toString();
        }
      } catch (_) {}

      throw Exception(message);
    }

    final data = jsonDecode(response.body);

    if (data is! List) {
      throw Exception('Invalid social posts response.');
    }

    return data
        .map(
          (item) => SocialPost.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  void dispose() {
    _client.close();
  }
}