class SocialPost {
  final int id;
  final int campaignId;
  final int dayNumber;
  final String platform;
  final String content;
  final String? imageUrl;
  final String status;
  final DateTime? scheduledAt;

  SocialPost({
    required this.id,
    required this.campaignId,
    required this.dayNumber,
    required this.platform,
    required this.content,
    this.imageUrl,
    required this.status,
    this.scheduledAt,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json['id'] as int,
      campaignId: json['campaign_id'] as int,
      dayNumber: json['day_number'] as int,
      platform: json['platform'] as String,
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'Draft',
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(
              json['scheduled_at'].toString(),
            )
          : null,
    );
  }
}