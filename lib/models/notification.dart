import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime sentDate;
  final String? sentBy;
  final List<String> readBy;
  final String status;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.sentDate,
    this.sentBy,
    required this.readBy,
    required this.status,
  });

  factory NotificationModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NotificationModel(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'all',
      sentDate: (data['sentDate'] as Timestamp).toDate(),
      sentBy: data['sentBy'],
      readBy: List<String>.from(data['readBy'] ?? []),
      status: data['status'] ?? 'sent',
    );
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    String? type,
    DateTime? sentDate,
    String? sentBy,
    List<String>? readBy,
    String? status,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      sentDate: sentDate ?? this.sentDate,
      sentBy: sentBy ?? this.sentBy,
      readBy: readBy ?? this.readBy,
      status: status ?? this.status,
    );
  }
}