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
    message: 'CampusRide systems will be down for maintenance tonight from 2 AM to 4 AM.',
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
