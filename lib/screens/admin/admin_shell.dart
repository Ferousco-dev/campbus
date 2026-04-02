import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/admin_users_page.dart';
import 'pages/admin_wallet_page.dart';
import 'pages/admin_transport_page.dart';
import 'pages/admin_shop_page.dart';
import 'pages/admin_transactions_page.dart';
import 'pages/admin_notifications_page.dart';
import 'pages/admin_support_page.dart';
import 'pages/admin_roles_page.dart';
import 'pages/admin_audit_page.dart';

// ─── Admin Shell ──────────────────────────────────────────────────────────────
// Main layout for admin panel. Uses a sidebar + IndexedStack pattern.

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _sidebarExpanded = true;

  final List<_AdminNavItem> _navItems = const [
    _AdminNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
    _AdminNavItem(icon: Icons.people_rounded, label: 'Users'),
    _AdminNavItem(icon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
    _AdminNavItem(icon: Icons.directions_bus_rounded, label: 'Transport'),
    _AdminNavItem(icon: Icons.storefront_rounded, label: 'Shop'),
    _AdminNavItem(icon: Icons.receipt_long_rounded, label: 'Transactions'),
    _AdminNavItem(icon: Icons.notifications_rounded, label: 'Notifications'),
    _AdminNavItem(icon: Icons.headset_mic_rounded, label: 'Support'),
    _AdminNavItem(icon: Icons.admin_panel_settings_rounded, label: 'Roles'),
    _AdminNavItem(icon: Icons.history_rounded, label: 'Audit Log'),
  ];

  final List<Widget> _pages = const [
    AdminDashboardPage(),
    AdminUsersPage(),
    AdminWalletPage(),
    AdminTransportPage(),
    AdminShopPage(),
    AdminTransactionsPage(),
    AdminNotificationsPage(),
    AdminSupportPage(),
    AdminRolesPage(),
    AdminAuditPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        drawer: isMobile ? Drawer(child: _buildSidebar()) : null,
        body: Builder(
          builder: (context) {
            return Row(
              children: [
                // ── Sidebar ─────────────────────────────────────────────
                if (!isMobile)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _sidebarExpanded ? 240 : 72,
                    child: _buildSidebar(),
                  ),

                // ── Content ─────────────────────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(context, isMobile),
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _pages,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      color: const Color(0xFF0D1335),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: Colors.white, size: 22),
                  ),
                  if (_sidebarExpanded) ...[
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CampusRide',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Admin Panel',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 24),

            // Nav items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final item = _navItems[i];
                  final isActive = _selectedIndex == i;
                  return _buildNavTile(item, isActive, i);
                },
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Bottom actions
            Padding(
              padding: const EdgeInsets.all(8),
              child: _buildNavAction(
                icon: Icons.arrow_back_ios_rounded,
                label: 'Back to App',
                onTap: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTile(_AdminNavItem item, bool isActive, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedIndex = index);
          if (MediaQuery.of(context).size.width < 768) {
            Navigator.pop(context); // Close drawer on mobile
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: _sidebarExpanded ? 14 : 10,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4), width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: _sidebarExpanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 20,
                color: isActive ? Colors.white : Colors.white54,
              ),
              if (_sidebarExpanded) ...[
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? Colors.white : Colors.white60,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _sidebarExpanded ? 14 : 10,
          vertical: 12,
        ),
        child: Row(
          mainAxisAlignment: _sidebarExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white38),
            if (_sidebarExpanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  color: Colors.white38,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isMobile) {
    final title = _navItems[_selectedIndex].label;
    return SafeArea(
      bottom: false,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Toggle sidebar
            GestureDetector(
              onTap: () {
                if (isMobile) {
                  Scaffold.of(context).openDrawer();
                } else {
                  setState(() => _sidebarExpanded = !_sidebarExpanded);
                }
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  (!isMobile && _sidebarExpanded)
                      ? Icons.menu_open_rounded
                      : Icons.menu_rounded,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Admin badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded,
                      size: 12, color: AppColors.primary),
                  SizedBox(width: 5),
                  Text(
                    'Super Admin',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminNavItem {
  final IconData icon;
  final String label;
  const _AdminNavItem({required this.icon, required this.label});
}
