class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String? titleKn;
  final String? messageKn;
  final DateTime timestamp;
  final String type; // e.g., 'market', 'feature', 'weather', 'alert'
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.titleKn,
    this.messageKn,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? json['id'],
      title: json['title'],
      message: json['message'],
      titleKn: json['title_kn'],
      messageKn: json['message_kn'],
      timestamp: DateTime.parse(json['createdAt'] ?? json['timestamp']),
      type: json['type'],
      isRead: json['readStatus'] ?? json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'isRead': isRead,
    };
  }
}
