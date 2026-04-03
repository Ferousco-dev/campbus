import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/notification_model.dart';

class UserNotificationsService {
  UserNotificationsService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<NotificationModel>> notificationsStream(
    String uid, {
    int limit = 100,
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) =>
                  NotificationModel.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  static Future<void> markAsRead(String uid, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .set({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> deleteNotification(
      String uid, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  static Future<void> markAllRead(
    String uid,
    List<NotificationModel> notifications,
  ) async {
    final unread = notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;
    final batch = _firestore.batch();
    for (final notification in unread) {
      final ref = _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notification.id);
      batch.set(ref, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }
}
