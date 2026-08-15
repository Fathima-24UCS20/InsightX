import 'audience_filter.dart';

enum CampaignObjective {
  brandAwareness('brand_awareness', 'Increase Brand Awareness'),
  productLaunch('product_launch', 'New Product Launch'),
  seasonalSale('seasonal_sale', 'Seasonal Sale'),
  reEngagement('re_engagement', 'Re-engagement / Win-back'),
  leadNurture('lead_nurture', 'Lead Nurture');

  final String key;
  final String label;
  const CampaignObjective(this.key, this.label);

  static CampaignObjective fromKey(String key) {
    return CampaignObjective.values.firstWhere(
      (o) => o.key == key,
      orElse: () => CampaignObjective.brandAwareness,
    );
  }
}
enum CampaignGoal {
  increaseSales('increase_sales', 'Increase Sales'),
  websiteTraffic('website_traffic', 'Increase Website Traffic'),
  customerRetention('customer_retention', 'Customer Retention'),
  festivalPromotion('festival_promotion', 'Festival Promotion'),
  productLaunch('product_launch', 'Product Launch');

  final String key;
  final String label;

  const CampaignGoal(this.key, this.label);

  static CampaignGoal fromKey(String key) {
    return CampaignGoal.values.firstWhere(
      (g) => g.key == key,
      orElse: () => CampaignGoal.increaseSales,
    );
  }
}

enum CampaignStatus { draft, active, completed }

enum CampaignChannel {
  facebook('facebook', 'Facebook'),
  instagram('instagram', 'Instagram'),
  linkedin('linkedin', 'LinkedIn'),
  twitter('twitter', 'Twitter'),
  email('email', 'Email');

  final String key;
  final String label;
  const CampaignChannel(this.key, this.label);
}

/// The multi-asset output of one generation call. Maps directly to the
/// tabs in the UI: Overview, Social Media Posts, Email Copy, Ad Copy,
/// Hashtags.
class GeneratedCampaignContent {
  final String headline;
  final String summary;
  final String keyMessage;
  final String callToAction;
  final List<String> socialMediaPosts;
  final String emailSubject;
  final String emailBody;
  final String adCopy;
  final List<String> hashtags;
  final DateTime generatedAt;

  const GeneratedCampaignContent({
    required this.headline,
    required this.summary,
    required this.keyMessage,
    required this.callToAction,
    required this.socialMediaPosts,
    required this.emailSubject,
    required this.emailBody,
    required this.adCopy,
    required this.hashtags,
    required this.generatedAt,
  });

  /// Reads the first present key from [keys] out of [json]. Some backends
  /// name these fields differently (e.g. `description` vs `summary`,
  /// `cta` vs `call_to_action`) — this is a temporary hedge until we
  /// confirm the actual response shape from /campaigns/generate.
  static String? _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  static List<String> _firstList(Map<String, dynamic> json, List<String> keys) {
    for (final k in keys) {
      final v = json[k];
      if (v is List && v.isNotEmpty) return List<String>.from(v);
    }
    return const [];
  }

  /// Your backend sends social posts as four separate per-platform keys
  /// (facebook_post, instagram_caption, linkedin_post, twitter_post)
  /// rather than a single social_media_posts list. This reassembles
  /// them into the list the UI expects, labeled by platform so it's
  /// still clear which post is which.
  static List<String> _socialPostsFromPerPlatformKeys(Map<String, dynamic> json) {
    const platformKeys = {
      'facebook_post': 'Facebook',
      'instagram_caption': 'Instagram',
      'linkedin_post': 'LinkedIn',
      'twitter_post': 'Twitter',
    };
    final posts = <String>[];
    platformKeys.forEach((key, platform) {
      final v = json[key];
      if (v is String && v.trim().isNotEmpty) {
        posts.add('$platform: $v');
      }
    });
    return posts;
  }

  factory GeneratedCampaignContent.fromJson(Map<String, dynamic> json) {
    // Prefer a generic list if the backend ever sends one; otherwise
    // fall back to combining the per-platform keys we actually get today.
    final genericPosts = _firstList(json, ['social_media_posts', 'posts', 'social_posts']);
    final socialPosts =
        genericPosts.isNotEmpty ? genericPosts : _socialPostsFromPerPlatformKeys(json);

    return GeneratedCampaignContent(
      headline: _firstString(
  json,
  ['headline', 'title'],
) ?? '',
      summary: _firstString(json, ['summary', 'description', 'overview']) ?? '',
      keyMessage: _firstString(json, ['key_message', 'message', 'core_message']) ?? '',
      callToAction: _firstString(json, ['call_to_action', 'cta']) ?? '',
      socialMediaPosts: socialPosts,
      emailSubject: json['email_subject'] as String? ?? '',
      emailBody: json['email_body'] as String? ?? '',
      adCopy: json['ad_copy'] as String? ?? '',
      hashtags: _firstList(json, ['hashtags', 'tags']),
      generatedAt:
          DateTime.tryParse(json['generated_at'] as String? ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'headline': headline,
        'summary': summary,
        'key_message': keyMessage,
        'call_to_action': callToAction,
        'social_media_posts': socialMediaPosts,
        'email_subject': emailSubject,
        'email_body': emailBody,
        'ad_copy': adCopy,
        'hashtags': hashtags,
        'generated_at': generatedAt.toIso8601String(),
      };
}

/// One row in the `campaigns` table.
class Campaign {
  final int? id; // null until saved
  final String name;
  final CampaignObjective objective;
final CampaignGoal goal;

final String? productId;
final String productLabel;
final AudienceFilter audience;
final List<CampaignChannel> channels;
final String tone;
final String? additionalInfo;
final String? postTime;

final double? budget;
final double? discount;
final DateTime? startDate;
final DateTime? endDate;

final GeneratedCampaignContent? generated;
  final CampaignStatus status;
  final double? revenue; // null until attribution exists (phase 2)
  final double? changePct; // null until attribution exists (phase 2)
  final DateTime createdAt;

  const Campaign({
  this.id,
  required this.name,
  required this.objective,
  required this.goal,
  this.productId,
  required this.productLabel,
  required this.audience,
  required this.channels,
  required this.tone,
  this.additionalInfo,
  this.postTime,
  this.budget,
  this.discount,
  this.startDate,
  this.endDate,
  this.generated,
  this.status = CampaignStatus.draft,
  this.revenue,
  this.changePct,
  required this.createdAt,
});

  factory Campaign.fromJson(Map<String, dynamic> json) {
  return Campaign(
    id: json['campaign_id'] as int?,
    name: json['campaign_name'] as String? ?? '',
    objective: CampaignObjective.fromKey(
      json['objective'] as String? ?? '',
    ),
    goal: CampaignGoal.fromKey(
      json['goal'] as String? ?? '',
    ),
    productId: json['product_id']?.toString(),
    productLabel: json['product_label'] as String? ?? '',
    audience: AudienceFilter.fromJson(
      json['target_segment'] as Map<String, dynamic>? ?? {},
    ),
    channels: List<String>.from(json['channels'] ?? [])
    .map(
      (k) => CampaignChannel.values.firstWhere(
        (c) => c.key == k,
        orElse: () => CampaignChannel.email,
      ),
    )
    .toList(),
    tone: json['tone'] as String? ?? 'Professional',
    additionalInfo: json['additional_info'] as String?,
    postTime: json['post_time'] as String?,
    budget: (json['budget'] as num?)?.toDouble(),
    discount: (json['discount'] as num?)?.toDouble(),
    startDate: json['start_date'] != null
        ? DateTime.tryParse(json['start_date'])
        : null,
    endDate: json['end_date'] != null
        ? DateTime.tryParse(json['end_date'])
        : null,
    generated: json['generated_copy'] != null
    ? GeneratedCampaignContent.fromJson(
        json['generated_copy'] as Map<String, dynamic>,
      )
    : null,
    status: CampaignStatus.values.firstWhere(
      (s) => s.name == (json['status'] as String? ?? 'draft'),
      orElse: () => CampaignStatus.draft,
    ),
    revenue: (json['revenue'] as num?)?.toDouble(),
    changePct: (json['change_pct'] as num?)?.toDouble(),
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
  );
}
  /// Full payload for POST /campaigns — this is the piece that makes
  /// CampaignListCard / AIRecommendationCard stop showing demo data,
  /// so every generated field needs to actually be here.
  Map<String, dynamic> toJson() {
  return {
    if (id != null) 'campaign_id': id,
    'campaign_name': name,
    'objective': objective.key,
    'goal': goal.key,
    'product_id': productId,
    'product_label': productLabel,
    'target_segment': audience.toJson(),
    'channels': channels.map((c) => c.key).toList(),
    'tone': tone,
    'additional_info': additionalInfo,
    'post_time': postTime,
    'budget': budget,
    'discount': discount,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'generated_copy': generated?.toJson(),
    'status': status.name,
    'revenue': revenue,
    'change_pct': changePct,
    'created_at': createdAt.toIso8601String(),
  };
}
}