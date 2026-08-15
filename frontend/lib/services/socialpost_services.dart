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
          const Duration(seconds: 60),
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

  void dispose() {
    _client.close();
  }
}