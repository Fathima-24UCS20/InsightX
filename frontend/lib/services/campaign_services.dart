import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import '../models/product.dart';
import '../models/campaign.dart';

/// NOTE ON ENDPOINTS
/// ------------------
/// I don't have your actual backend routes in this session, so the
/// endpoint paths below are assumptions based on the shape we designed
/// (POST /campaigns/generate, POST /campaigns). Swap `baseUrl` and the
/// paths in each method to match your real API — everything else
/// (models, widgets, page) stays the same regardless of the transport.
class CampaignService {
  final String baseUrl;
  final http.Client _client;

  CampaignService({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  /// Backs the "Product / Service" dropdown — real rows from your
  /// `products` table instead of free text.
  Future<List<Product>> fetchProducts() async {
  try {
    final res = await _client
        .get(Uri.parse('$baseUrl/products'))
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    final list = jsonDecode(res.body) as List;

    return list
    .map((e) => Product.fromJson(
          e as Map<String, dynamic>,
        ))
    .toList();

  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}

  /// Backs the "City" dropdown in the audience filter builder — real
  /// distinct cities from your `customers` table.
  Future<List<String>> fetchCustomerCities() async {
  try {
    final res = await _client
        .get(Uri.parse('$baseUrl/customers/cities'))
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    return List<String>.from(
      jsonDecode(res.body) as List,
    );
  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}

  /// Backs the "Purchased category" dropdown — distinct categories from
  /// `products`/`order_items`.
  Future<List<String>> fetchProductCategories() async {
  try {
    final res = await _client
        .get(Uri.parse('$baseUrl/products/categories'))
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    return List<String>.from(
      jsonDecode(res.body) as List,
    );
  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}

  /// POST /campaigns/generate — sends the structured form (objective,
  /// real product, real audience conditions, tone, channels) and gets
  /// back multi-asset content for all five tabs in one call.
  Future<GeneratedCampaignContent> generateCampaign(Campaign draft) async {
  final requestBody = {
    'campaign_name': draft.name,
    'objective': draft.objective.key,
    'goal': draft.goal.key,
    'product_id': draft.productId,
    'product_label': draft.productLabel,
    'target_segment': draft.audience.toJson(),
    'audience_description': draft.audience.toDescription(),
    'tone': draft.tone,
    'channels': draft.channels.map((e) => e.key).toList(),
    'budget': draft.budget,
    'discount': draft.discount,
    'start_date': draft.startDate?.toIso8601String(),
    'end_date': draft.endDate?.toIso8601String(),
    'additional_info': draft.additionalInfo,
  };

  try {
    print('Campaign Request: ${jsonEncode(requestBody)}');

    final res = await _client
        .post(
          Uri.parse('$baseUrl/campaigns/generate'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        )
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    print('Campaign Response: ${res.body}');

    return GeneratedCampaignContent.fromJson(
    jsonDecode(res.body)
        as Map<String, dynamic>,
);
 } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout. Please try again.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to the server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}

  /// POST /campaigns — persists the full campaign, including the
  /// generated copy. This is what CampaignListCard/AIRecommendationCard
  /// on AI Insights need to read from instead of demo data.
  /// Save Campaign
  Future<Campaign> saveCampaign(Campaign campaign) async {
  try {
    final res = await _client
        .post(
          Uri.parse('$baseUrl/campaigns'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(campaign.toJson()),
        )
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    return Campaign.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}

  /// GET /campaigns — backs "View Saved Campaigns".
  Future<List<Campaign>> fetchSavedCampaigns() async {
  try {
    final res = await _client
        .get(Uri.parse('$baseUrl/campaigns'))
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    final list = jsonDecode(res.body) as List;

    return list
        .map(
          (e) => Campaign.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList();
  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}
//Delete campaigns
  Future<void> deleteCampaign(int id) async {
  try {
    final res = await _client
        .delete(
          Uri.parse('$baseUrl/campaigns/$id'),
        )
        .timeout(const Duration(seconds: 30));

    _checkOk(res);
  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}
//Update Campaign
Future<Campaign> updateCampaign(
  int id,
  Campaign campaign,
) async {
  try {
    final res = await _client
        .put(
          Uri.parse('$baseUrl/campaigns/$id'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(
            campaign.toJson(),
          ),
        )
        .timeout(const Duration(seconds: 30));

    _checkOk(res);

    return Campaign.fromJson(
      jsonDecode(res.body)
          as Map<String, dynamic>,
    );
  } on TimeoutException {
  throw CampaignServiceException(
    "Server timeout.",
  );
} on SocketException {
  throw CampaignServiceException(
    "Unable to connect to server.",
  );
} on FormatException {
  throw CampaignServiceException(
    "Invalid response received from server.",
  );
} catch (e) {
  throw CampaignServiceException(
    e.toString(),
  );
}
}

  void _checkOk(http.Response res) {

  if (res.statusCode >= 200 &&
      res.statusCode < 300) {
    return;
  }

  String message;

  try {
    final body = jsonDecode(res.body);

    message = body['detail'] ??
              body['message'] ??
              res.body;
  } catch (_) {
    message = res.body;
  }

  throw CampaignServiceException(
      'HTTP ${res.statusCode}: $message');
}

  void dispose() => _client.close();
}

class CampaignServiceException implements Exception {
  final String message;
  CampaignServiceException(this.message);
  @override
  String toString() => message;
}