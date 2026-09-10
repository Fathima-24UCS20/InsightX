import 'dart:async';
import 'dart:html' as html;
import 'dart:convert';

import 'package:http/http.dart' as http;


class NotificationService {
  final String baseUrl;
  final http.Client _client;

  Timer? _timer;
  final Set<int> _shownIds = {};

  NotificationService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<void> start({
    void Function(Map<String, dynamic> notification)? onNotification,
  }) async {
    await _requestBrowserPermission();

    // Check immediately, then keep checking while InsightX is open.
    await poll(onNotification: onNotification);

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => poll(onNotification: onNotification),
    );
  }

  Future<void> _requestBrowserPermission() async {
    try {
      if (!html.Notification.supported) return;

      if (html.Notification.permission == 'default') {
        await html.Notification.requestPermission();
      }
    } catch (_) {
      // Browser notifications are an enhancement; the backend notification
      // is still stored even when browser permission is unavailable.
    }
  }

  Future<void> poll({
    void Function(Map<String, dynamic> notification)? onNotification,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/notifications/unread'),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return;

      for (final item in decoded) {
        if (item is! Map) continue;

        final notification = Map<String, dynamic>.from(item);
        final id = int.tryParse(notification['id'].toString());

        if (id == null || _shownIds.contains(id)) {
          continue;
        }

        _shownIds.add(id);

        _showBrowserNotification(
          notification['title']?.toString() ?? 'InsightX',
          notification['message']?.toString() ?? '',
        );

        onNotification?.call(notification);

        await markAsRead(id);
      }
    } catch (_) {
      // Keep polling silently if the backend is temporarily unavailable.
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _client.patch(
        Uri.parse('$baseUrl/notifications/$id/read'),
      );
    } catch (_) {}
  }

  void _showBrowserNotification(String title, String message) {
    try {
      if (!html.Notification.supported) return;
      if (html.Notification.permission != 'granted') return;

      html.Notification(
        title,
        body: message,
      );
    } catch (_) {}
  }

  void dispose() {
    _timer?.cancel();
    _client.close();
  }
}
