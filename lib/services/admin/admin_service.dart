// ─── Admin Service — API Hook Stubs ──────────────────────────────────────────
// Replace these stubs with real HTTP/Supabase calls when backend is ready.
// Each method returns a Future with simulated network delay.

import '../admin/admin_models.dart';
import '../shop_item_model.dart';
import '../wallet_models.dart';

class AdminService {
  static const _delay = Duration(milliseconds: 400);

  // ── Users ──────────────────────────────────────────────────────────────────
  // TODO: GET /api/admin/users
  static Future<List<AdminUser>> fetchUsers() async {
    await Future.delayed(_delay);
    return adminUsers;
  }

  // TODO: GET /api/admin/users/:id
  static Future<AdminUser?> fetchUserById(String id) async {
    await Future.delayed(_delay);
    return adminUsers.where((u) => u.id == id).firstOrNull;
  }

  // TODO: PATCH /api/admin/users/:id/card-status
  static Future<bool> updateUserCardStatus(String userId, AdminCardStatus status) async {
    await Future.delayed(_delay);
    return true; // Simulate success
  }

  // TODO: PATCH /api/admin/users/:id/tier
  static Future<bool> updateUserTier(String userId, AdminUserTier tier) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Transactions ───────────────────────────────────────────────────────────
  // TODO: GET /api/admin/transactions?page=&filter=&category=
  static Future<List<WalletTransaction>> fetchAllTransactions() async {
    await Future.delayed(_delay);
    return walletTransactions;
  }

  // TODO: POST /api/admin/transactions/refund
  static Future<bool> issueRefund(String transactionId, double amount) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Transport ──────────────────────────────────────────────────────────────
  // TODO: GET /api/admin/routes
  static Future<List<AdminRoute>> fetchRoutes() async {
    await Future.delayed(_delay);
    return adminRoutes;
  }

  // TODO: PATCH /api/admin/routes/:id
  static Future<bool> updateRoute(String routeId, {double? fare, RouteStatus? status}) async {
    await Future.delayed(_delay);
    return true;
  }

  // TODO: GET /api/admin/vehicles
  static Future<List<AdminVehicle>> fetchVehicles() async {
    await Future.delayed(_delay);
    return adminVehicles;
  }

  // TODO: PATCH /api/admin/vehicles/:id/status
  static Future<bool> updateVehicleStatus(String vehicleId, VehicleStatus status) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Shop ──────────────────────────────────────────────────────────────────
  // TODO: GET /api/admin/shop/items
  static Future<List<ShopItem>> fetchShopItems() async {
    await Future.delayed(_delay);
    return sampleShopItems;
  }

  // TODO: POST /api/admin/shop/items
  static Future<bool> addShopItem(ShopItem item) async {
    await Future.delayed(_delay);
    return true;
  }

  // TODO: PATCH /api/admin/shop/items/:id
  static Future<bool> updateShopItem(ShopItem item) async {
    await Future.delayed(_delay);
    return true;
  }

  // TODO: DELETE /api/admin/shop/items/:id
  static Future<bool> deleteShopItem(String itemId) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Support ───────────────────────────────────────────────────────────────
  // TODO: GET /api/admin/support/tickets
  static Future<List<SupportTicket>> fetchTickets() async {
    await Future.delayed(_delay);
    return adminTickets;
  }

  // TODO: POST /api/admin/support/tickets/:id/reply
  static Future<bool> replyToTicket(String ticketId, String message) async {
    await Future.delayed(_delay);
    return true;
  }

  // TODO: PATCH /api/admin/support/tickets/:id/resolve
  static Future<bool> resolveTicket(String ticketId) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  // TODO: GET /api/admin/notifications
  static Future<List<AdminNotification>> fetchSentNotifications() async {
    await Future.delayed(_delay);
    return adminSentNotifications;
  }

  // TODO: POST /api/admin/notifications/send
  static Future<bool> sendNotification({
    required String title,
    required String message,
    required String type,
    required String audience,
  }) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Roles ─────────────────────────────────────────────────────────────────
  // TODO: GET /api/admin/roles
  static Future<List<RolePermission>> fetchRoles() async {
    await Future.delayed(_delay);
    return adminRoles;
  }

  // TODO: PATCH /api/admin/roles/:id
  static Future<bool> updateRolePermission(String roleId, String module, bool value) async {
    await Future.delayed(_delay);
    return true;
  }

  // ── Audit Log ─────────────────────────────────────────────────────────────
  // TODO: GET /api/admin/audit-log
  static Future<List<AuditLogEntry>> fetchAuditLog() async {
    await Future.delayed(_delay);
    return adminAuditLog;
  }

  // ── Dashboard KPIs ────────────────────────────────────────────────────────
  // TODO: GET /api/admin/dashboard/kpis
  static Future<Map<String, dynamic>> fetchDashboardKPIs() async {
    await Future.delayed(_delay);
    return {
      'totalUsers': 1960,
      'activeCards': 1284,
      'totalRevenue': 437500.0,
      'todayRevenue': 58400.0,
      'todayTrips': 847,
      'openTickets': 2,
      'shopItems': sampleShopItems.length,
      'monthlyGrowth': 12.4,
    };
  }
}
