import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════

enum AdminUserTier { tier1, tier2, tier3 }
enum AdminCardStatus { active, inactive, blocked }
enum RouteStatus { active, inactive, underMaintenance }
enum VehicleStatus { active, inactive, maintenance }
enum TicketStatus { open, inProgress, resolved, closed }
enum TicketPriority { low, medium, high, urgent }
enum AdminRole { superAdmin, moderator, supportAgent, shopManager }

// ═══════════════════════════════════════════════════════════
// ADMIN USER
// ═══════════════════════════════════════════════════════════

class AdminUser {
  final String id;
  final String fullName;
  final String nickname;
  final String studentId;
  final String email;
  final String phone;
  final String faculty;
  final String department;
  final String level;
  final AdminUserTier tier;
  final double walletBalance;
  final AdminCardStatus cardStatus;
  final bool isVerified;
  final bool isEmailVerified;
  final DateTime joinDate;
  final int totalTransactions;
  final double totalSpent;

  const AdminUser({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.studentId,
    required this.email,
    required this.phone,
    required this.faculty,
    required this.department,
    required this.level,
    required this.tier,
    required this.walletBalance,
    required this.cardStatus,
    required this.isVerified,
    required this.isEmailVerified,
    required this.joinDate,
    required this.totalTransactions,
    required this.totalSpent,
  });

  String get tierLabel {
    switch (tier) {
      case AdminUserTier.tier1:
        return 'Tier 1';
      case AdminUserTier.tier2:
        return 'Tier 2';
      case AdminUserTier.tier3:
        return 'Tier 3';
    }
  }

  Color get tierColor {
    switch (tier) {
      case AdminUserTier.tier1:
        return const Color(0xFF6B7A99);
      case AdminUserTier.tier2:
        return const Color(0xFF1A3FD8);
      case AdminUserTier.tier3:
        return const Color(0xFFF4A200);
    }
  }

  String get cardStatusLabel {
    switch (cardStatus) {
      case AdminCardStatus.active:
        return 'Active';
      case AdminCardStatus.inactive:
        return 'Inactive';
      case AdminCardStatus.blocked:
        return 'Blocked';
    }
  }

  Color get cardStatusColor {
    switch (cardStatus) {
      case AdminCardStatus.active:
        return const Color(0xFF00B37E);
      case AdminCardStatus.inactive:
        return const Color(0xFF6B7A99);
      case AdminCardStatus.blocked:
        return const Color(0xFFE03E3E);
    }
  }
}

// ═══════════════════════════════════════════════════════════
// TRANSPORT ROUTE
// ═══════════════════════════════════════════════════════════

class AdminRoute {
  final String id;
  final String name;
  final String from;
  final String to;
  final double fare;
  final RouteStatus status;
  final int vehicleCount;
  final double dailyRevenue;
  final double monthlyRevenue;
  final int dailyPassengers;
  final String operatingHours;

  const AdminRoute({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.fare,
    required this.status,
    required this.vehicleCount,
    required this.dailyRevenue,
    required this.monthlyRevenue,
    required this.dailyPassengers,
    required this.operatingHours,
  });

  String get statusLabel {
    switch (status) {
      case RouteStatus.active:
        return 'Active';
      case RouteStatus.inactive:
        return 'Inactive';
      case RouteStatus.underMaintenance:
        return 'Maintenance';
    }
  }

  Color get statusColor {
    switch (status) {
      case RouteStatus.active:
        return const Color(0xFF00B37E);
      case RouteStatus.inactive:
        return const Color(0xFF6B7A99);
      case RouteStatus.underMaintenance:
        return const Color(0xFFE08C00);
    }
  }
}

// ═══════════════════════════════════════════════════════════
// VEHICLE
// ═══════════════════════════════════════════════════════════

class AdminVehicle {
  final String id;
  final String plateNumber;
  final String routeId;
  final String routeName;
  final int capacity;
  final VehicleStatus status;
  final String driverName;
  final String driverPhone;

  const AdminVehicle({
    required this.id,
    required this.plateNumber,
    required this.routeId,
    required this.routeName,
    required this.capacity,
    required this.status,
    required this.driverName,
    required this.driverPhone,
  });
}

// ═══════════════════════════════════════════════════════════
// SUPPORT TICKET
// ═══════════════════════════════════════════════════════════

class SupportMessage {
  final String sender; // 'user' | 'admin'
  final String senderName;
  final String message;
  final DateTime timestamp;

  const SupportMessage({
    required this.sender,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}

class SupportTicket {
  final String id;
  final String userId;
  final String userName;
  final String subject;
  final TicketStatus status;
  final TicketPriority priority;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<SupportMessage> messages;

  const SupportTicket({
    required this.id,
    required this.userId,
    required this.userName,
    required this.subject,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.resolvedAt,
    required this.messages,
  });

  String get statusLabel {
    switch (status) {
      case TicketStatus.open:
        return 'Open';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
      case TicketStatus.closed:
        return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case TicketStatus.open:
        return const Color(0xFF1A3FD8);
      case TicketStatus.inProgress:
        return const Color(0xFFE08C00);
      case TicketStatus.resolved:
        return const Color(0xFF00B37E);
      case TicketStatus.closed:
        return const Color(0xFF6B7A99);
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TicketPriority.low:
        return 'Low';
      case TicketPriority.medium:
        return 'Medium';
      case TicketPriority.high:
        return 'High';
      case TicketPriority.urgent:
        return 'Urgent';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case TicketPriority.low:
        return const Color(0xFF6B7A99);
      case TicketPriority.medium:
        return const Color(0xFF1A3FD8);
      case TicketPriority.high:
        return const Color(0xFFE08C00);
      case TicketPriority.urgent:
        return const Color(0xFFE03E3E);
    }
  }
}

// ═══════════════════════════════════════════════════════════
// AUDIT LOG
// ═══════════════════════════════════════════════════════════

class AuditLogEntry {
  final String id;
  final String adminName;
  final String action;
  final String target;
  final DateTime timestamp;
  final String ipAddress;
  final String module;

  const AuditLogEntry({
    required this.id,
    required this.adminName,
    required this.action,
    required this.target,
    required this.timestamp,
    required this.ipAddress,
    required this.module,
  });
}

// ═══════════════════════════════════════════════════════════
// ROLE PERMISSION
// ═══════════════════════════════════════════════════════════

class RolePermission {
  final String id;
  final String roleName;
  final AdminRole role;
  final Map<String, bool> permissions; // module -> canAccess
  final int userCount;
  final Color color;

  const RolePermission({
    required this.id,
    required this.roleName,
    required this.role,
    required this.permissions,
    required this.userCount,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════
// KPI DATA
// ═══════════════════════════════════════════════════════════

class AdminKPI {
  final String title;
  final String value;
  final String change; // e.g. "+12.4%"
  final bool isPositive;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const AdminKPI({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

// ═══════════════════════════════════════════════════════════
// COMPOSED NOTIFICATION (admin send)
// ═══════════════════════════════════════════════════════════

class AdminNotification {
  final String id;
  final String title;
  final String message;
  final String type; // transaction | system | promo | trip
  final String audience; // All | Tier 1 | Tier 2
  final DateTime sentAt;
  final int delivered;
  final int total;

  const AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.audience,
    required this.sentAt,
    required this.delivered,
    required this.total,
  });

  double get deliveryRate => total == 0 ? 0 : delivered / total;
}

// ═══════════════════════════════════════════════════════════
// ─── DUMMY DATA ─────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════

final List<AdminUser> adminUsers = [
  AdminUser(
    id: 'u1', fullName: 'Oluwaferanmi Oresajo', nickname: 'Feranmi',
    studentId: 'STU/2024/00142', email: 'feranmi@oauife.edu.ng',
    phone: '+234 907 218 2889', faculty: 'Engineering',
    department: 'Computer Engineering', level: '300L',
    tier: AdminUserTier.tier1, walletBalance: 12350.00,
    cardStatus: AdminCardStatus.active, isVerified: true,
    isEmailVerified: true, joinDate: DateTime(2024, 9, 1),
    totalTransactions: 47, totalSpent: 28500,
  ),
  AdminUser(
    id: 'u2', fullName: 'Amara Okonkwo', nickname: 'Amara',
    studentId: 'STU/2023/00089', email: 'amara@oauife.edu.ng',
    phone: '+234 812 344 5566', faculty: 'Science',
    department: 'Physics', level: '400L',
    tier: AdminUserTier.tier2, walletBalance: 45000.00,
    cardStatus: AdminCardStatus.active, isVerified: true,
    isEmailVerified: true, joinDate: DateTime(2023, 9, 5),
    totalTransactions: 112, totalSpent: 98200,
  ),
  AdminUser(
    id: 'u3', fullName: 'Bola Adeleke', nickname: 'Bolaji',
    studentId: 'STU/2025/00321', email: 'bola@oauife.edu.ng',
    phone: '+234 703 112 9900', faculty: 'Arts',
    department: 'English', level: '100L',
    tier: AdminUserTier.tier1, walletBalance: 1200.00,
    cardStatus: AdminCardStatus.inactive, isVerified: false,
    isEmailVerified: false, joinDate: DateTime(2025, 1, 15),
    totalTransactions: 8, totalSpent: 2400,
  ),
  AdminUser(
    id: 'u4', fullName: 'Chukwuemeka Nwosu', nickname: 'Emeka',
    studentId: 'STU/2022/00054', email: 'emeka@oauife.edu.ng',
    phone: '+234 815 776 3421', faculty: 'Medicine',
    department: 'Anatomy', level: '500L',
    tier: AdminUserTier.tier2, walletBalance: 67500.00,
    cardStatus: AdminCardStatus.active, isVerified: true,
    isEmailVerified: true, joinDate: DateTime(2022, 9, 2),
    totalTransactions: 234, totalSpent: 145000,
  ),
  AdminUser(
    id: 'u5', fullName: 'Fatimah Lawal', nickname: 'Fati',
    studentId: 'STU/2024/00278', email: 'fatimah@oauife.edu.ng',
    phone: '+234 802 445 7731', faculty: 'Social Sciences',
    department: 'Economics', level: '200L',
    tier: AdminUserTier.tier1, walletBalance: 5800.00,
    cardStatus: AdminCardStatus.blocked, isVerified: false,
    isEmailVerified: true, joinDate: DateTime(2024, 2, 10),
    totalTransactions: 23, totalSpent: 12500,
  ),
  AdminUser(
    id: 'u6', fullName: 'Kelechi Eze', nickname: 'Kels',
    studentId: 'STU/2023/00156', email: 'kelechi@oauife.edu.ng',
    phone: '+234 906 118 2200', faculty: 'Engineering',
    department: 'Mechanical Engineering', level: '300L',
    tier: AdminUserTier.tier1, walletBalance: 3400.00,
    cardStatus: AdminCardStatus.active, isVerified: true,
    isEmailVerified: false, joinDate: DateTime(2023, 10, 1),
    totalTransactions: 56, totalSpent: 31200,
  ),
  AdminUser(
    id: 'u7', fullName: 'Ngozi Ifeanyi', nickname: 'Ngozi',
    studentId: 'STU/2025/00402', email: 'ngozi@oauife.edu.ng',
    phone: '+234 810 223 5566', faculty: 'Law',
    department: 'International Law', level: '100L',
    tier: AdminUserTier.tier1, walletBalance: 800.00,
    cardStatus: AdminCardStatus.inactive, isVerified: false,
    isEmailVerified: false, joinDate: DateTime(2025, 3, 5),
    totalTransactions: 4, totalSpent: 1200,
  ),
  AdminUser(
    id: 'u8', fullName: 'Oluwaseun Adeyemi', nickname: 'Seun',
    studentId: 'STU/2021/00033', email: 'seun@oauife.edu.ng',
    phone: '+234 901 334 8899', faculty: 'Agriculture',
    department: 'Crop Science', level: '500L',
    tier: AdminUserTier.tier3, walletBalance: 125000.00,
    cardStatus: AdminCardStatus.active, isVerified: true,
    isEmailVerified: true, joinDate: DateTime(2021, 9, 1),
    totalTransactions: 389, totalSpent: 312000,
  ),
];

final List<AdminRoute> adminRoutes = [
  AdminRoute(
    id: 'r1', name: 'Route 12',
    from: 'Main Gate', to: 'Faculty of Engineering',
    fare: 150, status: RouteStatus.active,
    vehicleCount: 4, dailyRevenue: 18000,
    monthlyRevenue: 396000, dailyPassengers: 120,
    operatingHours: '7:00 AM – 8:00 PM',
  ),
  AdminRoute(
    id: 'r2', name: 'Route 7',
    from: 'Moremi Hall', to: 'Student Union Building',
    fare: 100, status: RouteStatus.active,
    vehicleCount: 3, dailyRevenue: 12000,
    monthlyRevenue: 264000, dailyPassengers: 120,
    operatingHours: '6:30 AM – 9:00 PM',
  ),
  AdminRoute(
    id: 'r3', name: 'Route 5',
    from: 'Off-campus (Ede Rd)', to: 'Main Gate',
    fare: 200, status: RouteStatus.active,
    vehicleCount: 6, dailyRevenue: 28800,
    monthlyRevenue: 633600, dailyPassengers: 144,
    operatingHours: '5:30 AM – 10:00 PM',
  ),
  AdminRoute(
    id: 'r4', name: 'Route 3',
    from: 'Library', to: 'Sports Complex',
    fare: 50, status: RouteStatus.inactive,
    vehicleCount: 0, dailyRevenue: 0,
    monthlyRevenue: 0, dailyPassengers: 0,
    operatingHours: 'Inactive',
  ),
  AdminRoute(
    id: 'r5', name: 'Route 9',
    from: 'Medical Complex', to: 'Main Gate',
    fare: 150, status: RouteStatus.underMaintenance,
    vehicleCount: 2, dailyRevenue: 4500,
    monthlyRevenue: 99000, dailyPassengers: 30,
    operatingHours: '8:00 AM – 5:00 PM',
  ),
];

final List<AdminVehicle> adminVehicles = [
  AdminVehicle(id: 'v1', plateNumber: 'OY 452 MSF', routeId: 'r1', routeName: 'Route 12', capacity: 18, status: VehicleStatus.active, driverName: 'Saheed Adeyemi', driverPhone: '08012345678'),
  AdminVehicle(id: 'v2', plateNumber: 'OY 118 KFG', routeId: 'r1', routeName: 'Route 12', capacity: 18, status: VehicleStatus.active, driverName: 'Ademola Osinuga', driverPhone: '08023456789'),
  AdminVehicle(id: 'v3', plateNumber: 'OY 774 ABN', routeId: 'r2', routeName: 'Route 7', capacity: 14, status: VehicleStatus.active, driverName: 'Kunle Bello', driverPhone: '08034567890'),
  AdminVehicle(id: 'v4', plateNumber: 'OY 339 XYZ', routeId: 'r3', routeName: 'Route 5', capacity: 25, status: VehicleStatus.maintenance, driverName: 'John Okeke', driverPhone: '08045678901'),
  AdminVehicle(id: 'v5', plateNumber: 'OY 221 LMN', routeId: 'r5', routeName: 'Route 9', capacity: 18, status: VehicleStatus.inactive, driverName: 'Taiwo Ajayi', driverPhone: '08056789012'),
];

final List<SupportTicket> adminTickets = [
  SupportTicket(
    id: 'TKT-001', userId: 'u3', userName: 'Bola Adeleke',
    subject: 'Card not activating after payment',
    status: TicketStatus.open, priority: TicketPriority.high,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    messages: [
      SupportMessage(sender: 'user', senderName: 'Bola Adeleke', message: 'I paid for card activation but it still shows inactive. Please help!', timestamp: DateTime.now().subtract(const Duration(hours: 2))),
    ],
  ),
  SupportTicket(
    id: 'TKT-002', userId: 'u5', userName: 'Fatimah Lawal',
    subject: 'Card was blocked without notice',
    status: TicketStatus.inProgress, priority: TicketPriority.urgent,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    messages: [
      SupportMessage(sender: 'user', senderName: 'Fatimah Lawal', message: 'My card was blocked and I cannot make any trips. This is urgent!', timestamp: DateTime.now().subtract(const Duration(hours: 5))),
      SupportMessage(sender: 'admin', senderName: 'Admin', message: 'We are reviewing your account. This was flagged due to unusual activity. We will unblock it once verified.', timestamp: DateTime.now().subtract(const Duration(hours: 4))),
    ],
  ),
  SupportTicket(
    id: 'TKT-003', userId: 'u1', userName: 'Feranmi Oresajo',
    subject: 'WiFi ticket credentials not working',
    status: TicketStatus.resolved, priority: TicketPriority.medium,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    resolvedAt: DateTime.now().subtract(const Duration(hours: 20)),
    messages: [
      SupportMessage(sender: 'user', senderName: 'Feranmi Oresajo', message: 'The WiFi credentials from my ticket are not connecting.', timestamp: DateTime.now().subtract(const Duration(days: 1))),
      SupportMessage(sender: 'admin', senderName: 'Admin', message: 'New credentials have been issued to your ticket. Please check the app.', timestamp: DateTime.now().subtract(const Duration(hours: 20))),
    ],
  ),
  SupportTicket(
    id: 'TKT-004', userId: 'u2', userName: 'Amara Okonkwo',
    subject: 'Refund not received for cancelled route',
    status: TicketStatus.open, priority: TicketPriority.medium,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    messages: [
      SupportMessage(sender: 'user', senderName: 'Amara Okonkwo', message: 'Route 3 was cancelled 3 days ago and I have not received my refund of ₦150.', timestamp: DateTime.now().subtract(const Duration(days: 2))),
    ],
  ),
  SupportTicket(
    id: 'TKT-005', userId: 'u6', userName: 'Kelechi Eze',
    subject: 'App crashes on checkout',
    status: TicketStatus.closed, priority: TicketPriority.low,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    resolvedAt: DateTime.now().subtract(const Duration(days: 4)),
    messages: [
      SupportMessage(sender: 'user', senderName: 'Kelechi Eze', message: 'App crashes when I try to checkout from the shop.', timestamp: DateTime.now().subtract(const Duration(days: 5))),
      SupportMessage(sender: 'admin', senderName: 'Admin', message: 'This has been fixed in the latest update. Please update the app.', timestamp: DateTime.now().subtract(const Duration(days: 4))),
    ],
  ),
];

final List<AuditLogEntry> adminAuditLog = [
  AuditLogEntry(id: 'a1', adminName: 'Super Admin', action: 'Updated shop item price', target: 'Inteco WiFi (₦100 → ₦120)', timestamp: DateTime.now().subtract(const Duration(minutes: 10)), ipAddress: '192.168.1.1', module: 'Shop'),
  AuditLogEntry(id: 'a2', adminName: 'Shop Manager', action: 'Added new shop item', target: 'Convocation Pass 2026', timestamp: DateTime.now().subtract(const Duration(hours: 1)), ipAddress: '192.168.1.4', module: 'Shop'),
  AuditLogEntry(id: 'a3', adminName: 'Support Agent', action: 'Resolved ticket', target: 'TKT-003', timestamp: DateTime.now().subtract(const Duration(hours: 2)), ipAddress: '10.0.0.14', module: 'Support'),
  AuditLogEntry(id: 'a4', adminName: 'Super Admin', action: 'Blocked user account', target: 'Fatimah Lawal (STU/2024/00278)', timestamp: DateTime.now().subtract(const Duration(hours: 3)), ipAddress: '192.168.1.1', module: 'Users'),
  AuditLogEntry(id: 'a5', adminName: 'Super Admin', action: 'Changed route fare', target: 'Route 5 (₦150 → ₦200)', timestamp: DateTime.now().subtract(const Duration(hours: 6)), ipAddress: '192.168.1.1', module: 'Transport'),
  AuditLogEntry(id: 'a6', adminName: 'Moderator', action: 'Sent push notification', target: 'Weekend Promo (All users)', timestamp: DateTime.now().subtract(const Duration(days: 1)), ipAddress: '10.0.0.22', module: 'Notifications'),
  AuditLogEntry(id: 'a7', adminName: 'Super Admin', action: 'Issued refund', target: '₦150 → Amara Okonkwo', timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)), ipAddress: '192.168.1.1', module: 'Wallet'),
  AuditLogEntry(id: 'a8', adminName: 'Shop Manager', action: 'Updated stock count', target: 'Convocation Pass (50 → 23)', timestamp: DateTime.now().subtract(const Duration(days: 2)), ipAddress: '192.168.1.4', module: 'Shop'),
  AuditLogEntry(id: 'a9', adminName: 'Super Admin', action: 'Activated vehicle route', target: 'OY 452 MSF → Route 12', timestamp: DateTime.now().subtract(const Duration(days: 3)), ipAddress: '192.168.1.1', module: 'Transport'),
  AuditLogEntry(id: 'a10', adminName: 'Support Agent', action: 'Upgraded user tier', target: 'Seun Adeyemi (Tier 2 → Tier 3)', timestamp: DateTime.now().subtract(const Duration(days: 4)), ipAddress: '10.0.0.14', module: 'Users'),
];

final List<RolePermission> adminRoles = [
  RolePermission(
    id: 'role1', roleName: 'Super Admin', role: AdminRole.superAdmin,
    userCount: 2, color: const Color(0xFF1A3FD8),
    permissions: {
      'Dashboard': true, 'Users': true, 'Wallet': true,
      'Transport': true, 'Shop': true, 'Transactions': true,
      'Notifications': true, 'Support': true, 'Roles': true, 'Audit Log': true,
    },
  ),
  RolePermission(
    id: 'role2', roleName: 'Moderator', role: AdminRole.moderator,
    userCount: 3, color: const Color(0xFF9B5CF6),
    permissions: {
      'Dashboard': true, 'Users': true, 'Wallet': false,
      'Transport': true, 'Shop': false, 'Transactions': true,
      'Notifications': true, 'Support': true, 'Roles': false, 'Audit Log': false,
    },
  ),
  RolePermission(
    id: 'role3', roleName: 'Support Agent', role: AdminRole.supportAgent,
    userCount: 5, color: const Color(0xFF00A3CC),
    permissions: {
      'Dashboard': true, 'Users': true, 'Wallet': false,
      'Transport': false, 'Shop': false, 'Transactions': false,
      'Notifications': false, 'Support': true, 'Roles': false, 'Audit Log': false,
    },
  ),
  RolePermission(
    id: 'role4', roleName: 'Shop Manager', role: AdminRole.shopManager,
    userCount: 2, color: const Color(0xFFE08C00),
    permissions: {
      'Dashboard': true, 'Users': false, 'Wallet': false,
      'Transport': false, 'Shop': true, 'Transactions': true,
      'Notifications': false, 'Support': false, 'Roles': false, 'Audit Log': false,
    },
  ),
];

final List<AdminNotification> adminSentNotifications = [
  AdminNotification(id: 'n1', title: 'Weekend Promo!', message: 'Enjoy 20% off all intra-campus trips this weekend. Apply promo code WKND20.', type: 'promo', audience: 'All Users', sentAt: DateTime.now().subtract(const Duration(days: 1)), delivered: 1845, total: 1960),
  AdminNotification(id: 'n2', title: 'System Maintenance', message: 'CampusRide systems will be down for maintenance tonight from 2 AM to 4 AM.', type: 'system', audience: 'All Users', sentAt: DateTime.now().subtract(const Duration(hours: 2)), delivered: 1900, total: 1960),
  AdminNotification(id: 'n3', title: 'Tier 2 Upgrade Offer', message: 'Upgrade to Tier 2 now and enjoy higher spending limits and priority support.', type: 'promo', audience: 'Tier 1', sentAt: DateTime.now().subtract(const Duration(days: 3)), delivered: 1200, total: 1400),
  AdminNotification(id: 'n4', title: 'Route 3 Suspended', message: 'We regret to inform you that Route 3 has been temporarily suspended due to vehicle maintenance.', type: 'system', audience: 'All Users', sentAt: DateTime.now().subtract(const Duration(days: 5)), delivered: 1950, total: 1960),
];

// Weekly revenue for chart (7 days)
final List<Map<String, dynamic>> adminWeeklyRevenue = [
  {'day': 'Mon', 'amount': 58000.0},
  {'day': 'Tue', 'amount': 72000.0},
  {'day': 'Wed', 'amount': 65000.0},
  {'day': 'Thu', 'amount': 91000.0},
  {'day': 'Fri', 'amount': 84000.0},
  {'day': 'Sat', 'amount': 45000.0},
  {'day': 'Sun', 'amount': 22000.0},
];

// Category breakdown
final List<Map<String, dynamic>> adminCategoryBreakdown = [
  {'label': 'Transport', 'amount': 285000.0, 'color': Color(0xFF1A3FD8)},
  {'label': 'WiFi', 'amount': 72000.0, 'color': Color(0xFF5C7CFA)},
  {'label': 'Shop', 'amount': 45000.0, 'color': Color(0xFF9B5CF6)},
  {'label': 'Subscription', 'amount': 31500.0, 'color': Color(0xFFE08C00)},
];
