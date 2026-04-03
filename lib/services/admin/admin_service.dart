import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/admin/admin_models.dart';
import '../../models/shop_item_model.dart';
import '../../models/wallet_models.dart';

class AdminService {
  AdminService._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Users ──────────────────────────────────────────────────────────────────
  static Future<List<AdminUser>> fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs
        .map((doc) => AdminUser.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<AdminUser?> fetchUserById(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return AdminUser.fromFirestore(doc.id, doc.data()!);
  }

  static Future<bool> updateUserCardStatus(
      String userId, AdminCardStatus status) async {
    await _firestore.collection('users').doc(userId).set({
      'cardStatus': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  static Future<bool> updateUserTier(String userId, AdminUserTier tier) async {
    await _firestore.collection('users').doc(userId).set({
      'tier': tier.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  // ── Transactions ───────────────────────────────────────────────────────────
  static Future<List<WalletTransaction>> fetchAllTransactions() async {
    final snapshot = await _firestore
        .collectionGroup('transactions')
        .orderBy('date', descending: true)
        .limit(200)
        .get();

    return snapshot.docs
        .map((doc) => WalletTransaction.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  static Future<bool> issueRefund(String transactionId, double amount) async {
    await _firestore.collection('admin_audit').add({
      'adminName': 'System',
      'action': 'Issued refund',
      'target': 'TX: $transactionId · ₦${amount.toStringAsFixed(0)}',
      'timestamp': FieldValue.serverTimestamp(),
      'ipAddress': '0.0.0.0',
      'module': 'Wallet',
    });
    return true;
  }

  // ── Transport ──────────────────────────────────────────────────────────────
  static Future<List<AdminRoute>> fetchRoutes() async {
    final snapshot = await _firestore.collection('routes').get();
    return snapshot.docs
        .map((doc) => AdminRoute.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<bool> updateRoute(
    String routeId, {
    double? fare,
    RouteStatus? status,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (fare != null) data['fare'] = fare;
    if (status != null) data['status'] = status.name;

    await _firestore.collection('routes').doc(routeId).set(
          data,
          SetOptions(merge: true),
        );
    return true;
  }

  static Future<List<AdminVehicle>> fetchVehicles() async {
    final snapshot = await _firestore.collection('vehicles').get();
    return snapshot.docs
        .map((doc) => AdminVehicle.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<bool> updateVehicleStatus(
      String vehicleId, VehicleStatus status) async {
    await _firestore.collection('vehicles').doc(vehicleId).set({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  // ── Shop ──────────────────────────────────────────────────────────────────
  static Future<List<ShopItem>> fetchShopItems() async {
    final snapshot = await _firestore.collection('shop_items').get();
    return snapshot.docs
        .map((doc) => ShopItem.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<String> addShopItem(ShopItem item) async {
    final ref = _firestore.collection('shop_items').doc();
    await ref.set({
      ...item.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  static Future<bool> updateShopItem(ShopItem item) async {
    await _firestore
        .collection('shop_items')
        .doc(item.id)
        .set({
          ...item.toFirestore(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    return true;
  }

  static Future<bool> deleteShopItem(String itemId) async {
    await _firestore.collection('shop_items').doc(itemId).delete();
    return true;
  }

  // ── Support ───────────────────────────────────────────────────────────────
  static Future<List<SupportTicket>> fetchTickets() async {
    final snapshot = await _firestore.collection('support_tickets').get();
    return snapshot.docs
        .map((doc) => SupportTicket.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<bool> replyToTicket(String ticketId, String message) async {
    final reply = SupportMessage(
      sender: 'admin',
      senderName: 'Admin',
      message: message,
      timestamp: DateTime.now(),
    ).toFirestore();

    await _firestore.collection('support_tickets').doc(ticketId).set({
      'messages': FieldValue.arrayUnion([reply]),
      'status': TicketStatus.inProgress.name,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  static Future<bool> resolveTicket(String ticketId) async {
    await _firestore.collection('support_tickets').doc(ticketId).set({
      'status': TicketStatus.resolved.name,
      'resolvedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  static Future<List<AdminNotification>> fetchSentNotifications() async {
    final snapshot = await _firestore
        .collection('admin_notifications')
        .orderBy('sentAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AdminNotification.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<bool> sendNotification({
    required String title,
    required String message,
    required String type,
    required String audience,
  }) async {
    await _firestore.collection('admin_notifications').add({
      'title': title,
      'message': message,
      'type': type,
      'audience': audience,
      'sentAt': FieldValue.serverTimestamp(),
      'delivered': 0,
      'total': 0,
    });
    return true;
  }

  // ── Roles ─────────────────────────────────────────────────────────────────
  static Future<List<RolePermission>> fetchRoles() async {
    final snapshot = await _firestore.collection('admin_roles').get();
    return snapshot.docs
        .map((doc) => RolePermission.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  static Future<bool> updateRolePermission(
      String roleId, String module, bool value) async {
    await _firestore.collection('admin_roles').doc(roleId).set({
      'permissions.$module': value,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  static Future<bool> updateUserRole(String userId, String role) async {
    await _firestore.collection('users').doc(userId).set({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return true;
  }

  // ── Audit Log ─────────────────────────────────────────────────────────────
  static Future<List<AuditLogEntry>> fetchAuditLog({int limit = 50}) async {
    final snapshot = await _firestore
        .collection('admin_audit')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs
        .map((doc) => AuditLogEntry.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  // ── Dashboard KPIs ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> fetchDashboardKPIs() async {
    final usersSnap = await _firestore.collection('users').get();
    final totalUsers = usersSnap.size;
    final activeCards = usersSnap.docs
        .where((doc) => doc.data()['cardStatus'] == 'active')
        .length;

    final ticketsSnap = await _firestore.collection('support_tickets').get();
    final openTickets = ticketsSnap.docs.where((doc) {
      final status = doc.data()['status'] as String?;
      return status == 'open' || status == 'inProgress';
    }).length;

    final shopSnap = await _firestore.collection('shop_items').get();
    final shopItems = shopSnap.size;
    final lowStockCount = shopSnap.docs.where((doc) {
      final stock = doc.data()['stockCount'];
      if (stock is num) return stock.toInt() <= 10;
      return false;
    }).length;

    final txSnap = await _firestore
        .collectionGroup('transactions')
        .orderBy('date', descending: true)
        .limit(500)
        .get();
    final txs = txSnap.docs
        .map((doc) => WalletTransaction.fromFirestore(doc.data(), doc.id))
        .toList();

    final totalRevenue = txs
        .where((t) => t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final today = DateTime.now();
    final todayRevenue = txs
        .where((t) => t.isCredit && _isSameDay(t.date, today))
        .fold(0.0, (sum, t) => sum + t.amount);

    final todayTrips = txs
        .where((t) => t.category == TxCategory.transport)
        .where((t) => _isSameDay(t.date, today))
        .length;

    final weeklyRevenue = _buildWeeklyRevenue(txs);
    final weeklyTotal = weeklyRevenue.fold<double>(
      0,
      (sum, item) => sum + (item['amount'] as double),
    );
    final currentWeekStart = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));
    final previousWeekStart = currentWeekStart.subtract(const Duration(days: 7));
    final previousWeekEnd = currentWeekStart.subtract(const Duration(milliseconds: 1));
    final previousWeekTotal =
        _sumCreditsInRange(txs, previousWeekStart, previousWeekEnd);
    final weeklyChangePct = previousWeekTotal > 0
        ? ((weeklyTotal - previousWeekTotal) / previousWeekTotal) * 100
        : null;
    final categoryBreakdown = _buildCategoryBreakdown(txs);
    final recentActivity = await fetchAuditLog(limit: 4);

    return {
      'totalUsers': totalUsers,
      'activeCards': activeCards,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'todayTrips': todayTrips,
      'openTickets': openTickets,
      'shopItems': shopItems,
      'lowStockCount': lowStockCount,
      'weeklyRevenue': weeklyRevenue,
      'weeklyTotal': weeklyTotal,
      'weeklyChangePct': weeklyChangePct,
      'categoryBreakdown': categoryBreakdown,
      'recentActivity': recentActivity,
    };
  }

  static List<Map<String, dynamic>> _buildWeeklyRevenue(
      List<WalletTransaction> txs) {
    final now = DateTime.now();
    final days = List.generate(7, (index) => now.subtract(Duration(days: 6 - index)));
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final data = <Map<String, dynamic>>[];
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final sum = txs
          .where((t) => t.isCredit && _isSameDay(t.date, day))
          .fold(0.0, (s, t) => s + t.amount);
      data.add({'day': labels[day.weekday - 1], 'amount': sum});
    }
    return data;
  }

  static List<Map<String, dynamic>> _buildCategoryBreakdown(
      List<WalletTransaction> txs) {
    final Map<TxCategory, double> totals = {
      for (final cat in TxCategory.values) cat: 0,
    };

    for (final tx in txs.where((t) => t.isCredit)) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }

    return totals.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {
              'label': _categoryLabel(entry.key),
              'amount': entry.value,
              'color': _categoryColor(entry.key),
            })
        .toList();
  }

  static String _categoryLabel(TxCategory category) {
    switch (category) {
      case TxCategory.transport:
        return 'Transport';
      case TxCategory.topup:
        return 'Top-up';
      case TxCategory.purchase:
        return 'Purchase';
      case TxCategory.subscription:
        return 'Subscription';
      case TxCategory.refund:
        return 'Refund';
      case TxCategory.wifi:
        return 'WiFi';
    }
  }

  static Color _categoryColor(TxCategory category) {
    switch (category) {
      case TxCategory.transport:
        return const Color(0xFF1A3FD8);
      case TxCategory.topup:
        return const Color(0xFF00B37E);
      case TxCategory.purchase:
        return const Color(0xFF9B5CF6);
      case TxCategory.subscription:
        return const Color(0xFFE08C00);
      case TxCategory.refund:
        return const Color(0xFF00A3CC);
      case TxCategory.wifi:
        return const Color(0xFF5C7CFA);
    }
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static double _sumCreditsInRange(
    List<WalletTransaction> txs,
    DateTime start,
    DateTime end,
  ) {
    return txs
        .where((t) => t.isCredit)
        .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}
