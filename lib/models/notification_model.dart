import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum NotificationType { transaction, system, promo, trip }

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;
  
  // Optional extra payload depending on type
  final double? amount;
  final bool? isCredit;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.amount,
    this.isCredit,
  });

  factory NotificationModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    final rawType = (data['type'] as String?)?.toLowerCase();
    final rawTimestamp =
        data['timestamp'] ?? data['sentAt'] ?? data['createdAt'];
    DateTime timestamp;
    if (rawTimestamp is Timestamp) {
      timestamp = rawTimestamp.toDate();
    } else if (rawTimestamp is DateTime) {
      timestamp = rawTimestamp;
    } else {
      timestamp = DateTime.now();
    }

    return NotificationModel(
      id: id,
      title: data['title'] as String? ?? 'Notification',
      message: data['message'] as String? ?? '',
      timestamp: timestamp,
      isRead: data['isRead'] as bool? ?? false,
      type: _typeFromString(rawType),
      amount: (data['amount'] as num?)?.toDouble(),
      isCredit: data['isCredit'] as bool?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': _typeToString(type),
      if (amount != null) 'amount': amount,
      if (isCredit != null) 'isCredit': isCredit,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
    double? amount,
    bool? isCredit,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      isCredit: isCredit ?? this.isCredit,
    );
  }
}

NotificationType _typeFromString(String? value) {
  switch (value) {
    case 'transaction':
      return NotificationType.transaction;
    case 'promo':
      return NotificationType.promo;
    case 'trip':
      return NotificationType.trip;
    case 'system':
    default:
      return NotificationType.system;
  }
}

String _typeToString(NotificationType type) {
  switch (type) {
    case NotificationType.transaction:
      return 'transaction';
    case NotificationType.system:
      return 'system';
    case NotificationType.promo:
      return 'promo';
    case NotificationType.trip:
      return 'trip';
  }
}

final List<NotificationModel> sampleNotifications = [
  NotificationModel(
    id: '1',
    title: 'Wallet Top-up Successful',
    message: 'Your transport wallet has been successfully credited.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    type: NotificationType.transaction,
    amount: 50.00,
    isCredit: true,
  ),
  NotificationModel(
    id: '2',
    title: 'System Maintenance',
    message: 'Campus Wallet systems will be down for maintenance tonight from 2 AM to 4 AM.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    type: NotificationType.system,
  ),
  NotificationModel(
    id: '3',
    title: 'Weekend Promo!',
    message: 'Enjoy 20% off all intra-campus trips this weekend. Apply promo code WKND20.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    type: NotificationType.promo,
  ),
  NotificationModel(
    id: '4',
    title: 'Trip Completed',
    message: 'You have reached your destination: Main Gate.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    type: NotificationType.trip,
    amount: 2.50,
    isCredit: false,
    isRead: true,
  ),
  NotificationModel(
    id: '5',
    title: 'Insufficient Funds',
    message: 'Your last ticket purchase failed due to insufficient funds.',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    type: NotificationType.transaction,
    amount: 5.00,
    isCredit: false,
    isRead: true,
  ),
];
