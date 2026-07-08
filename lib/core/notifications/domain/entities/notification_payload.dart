import 'dart:convert';

class NotificationPayload {
  final String title;
  final String body;
  final String type;
  final String screenRoute;
  final Map<String, dynamic> metadata;

  const NotificationPayload({
    required this.title,
    required this.body,
    required this.type,
    required this.screenRoute,
    required this.metadata,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> data) {
    Map<String, dynamic> parsedMetadata = {};
    final raw = data['metadata'];
    if (raw is String && raw.isNotEmpty) {
      try {
        parsedMetadata = json.decode(raw) as Map<String, dynamic>;
      } catch (_) {}
    } else if (raw is Map<String, dynamic>) {
      parsedMetadata = raw;
    }

    return NotificationPayload(
      title: data['title']?.toString() ?? '',
      body: data['body']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      screenRoute: data['screenRoute']?.toString() ?? '',
      metadata: parsedMetadata,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'body': body,
        'type': type,
        'screenRoute': screenRoute,
        'metadata': json.encode(metadata),
      };
}
