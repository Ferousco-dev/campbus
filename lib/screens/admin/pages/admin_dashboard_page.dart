import 'package:flutter/material.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_kpi_card.dart';
import '../widgets/admin_bar_chart.dart';
import '../widgets/admin_section_header.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _loading = true;
  Map<String, dynamic> _kpis = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await AdminService.fetchDashboardKPIs();
    if (mounted) setState(() { _kpis = data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final openTickets = _kpis['openTickets'] as int? ?? 0;
    final lowStockCount = _kpis['lowStockCount'] as int? ?? 0;
    final weeklyRevenue = List<Map<String, dynamic>>.from(
      _kpis['weeklyRevenue'] ?? const <Map<String, dynamic>>[],
    );
    final categoryBreakdown = List<Map<String, dynamic>>.from(
      _kpis['categoryBreakdown'] ?? const <Map<String, dynamic>>[],
    );
    final recentActivity = _kpis['recentActivity'] as List<AuditLogEntry>? ?? [];
    final weeklyTotal = (_kpis['weeklyTotal'] as num?)?.toDouble() ?? 0;
    final weeklyChangePct = (_kpis['weeklyChangePct'] as num?)?.toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Alerts ────────────────────────────────────────────────
          if (openTickets > 0) ...[
            _buildAlert(
              icon: Icons.error_outline_rounded,
              color: const Color(0xFFE03E3E),
              bg: const Color(0xFFFFF0F0),
              message:
                  '$openTickets support ticket${openTickets == 1 ? '' : 's'} open and unassigned',
            ),
            const SizedBox(height: 8),
          ],
          if (lowStockCount > 0) ...[
            _buildAlert(
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFFE08C00),
              bg: const Color(0xFFFFF8E6),
              message:
                  '$lowStockCount shop item${lowStockCount == 1 ? '' : 's'} low on stock',
            ),
            const SizedBox(height: 8),
          ],
          if (openTickets > 0 || lowStockCount > 0) const SizedBox(height: 16),

          // ── KPI Cards ─────────────────────────────────────────────
          const AdminSectionHeader(title: 'Overview'),
          const SizedBox(height: 16),
          _buildKPIGrid(context),
          const SizedBox(height: 28),

          // ── Revenue Chart ─────────────────────────────────────────
          const AdminSectionHeader(title: 'Weekly Revenue'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatCompactCurrency(weeklyTotal),
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Total this week · ${_formatWeeklyChange(weeklyChangePct)}',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (weeklyRevenue.isEmpty)
                  const Text(
                    'No revenue data yet.',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  AdminBarChart(
                    data: weeklyRevenue,
                    labelKey: 'day',
                    valueKey: 'amount',
                    height: 140,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Category Breakdown ────────────────────────────────────
          const AdminSectionHeader(title: 'Revenue by Category'),
          const SizedBox(height: 16),
          _buildCategoryBreakdown(categoryBreakdown),
          const SizedBox(height: 28),

          // ── Recent Activity ───────────────────────────────────────
          const AdminSectionHeader(title: 'Recent Activity'),
          const SizedBox(height: 16),
          _buildRecentActivity(recentActivity),
        ],
      ),
    );
  }

  Widget _buildAlert({
    required IconData icon,
    required Color color,
    required Color bg,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: 'Sora', fontSize: 13, color: color, fontWeight: FontWeight.w600),
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.6), size: 20),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(BuildContext context) {
    final totalUsers = _kpis['totalUsers'] as int? ?? 0;
    final activeCards = _kpis['activeCards'] as int? ?? 0;
    final totalRevenue = (_kpis['totalRevenue'] as num?)?.toDouble() ?? 0;
    final todayTrips = _kpis['todayTrips'] as int? ?? 0;
    final openTickets = _kpis['openTickets'] as int? ?? 0;
    final shopItems = _kpis['shopItems'] as int? ?? 0;
    final kpis = [
      AdminKPI(title: 'Total Users', value: '$totalUsers', change: '—', isPositive: true, icon: Icons.people_rounded, color: AppColors.primary, bgColor: AppColors.primarySurface),
      AdminKPI(title: 'Active Cards', value: '$activeCards', change: '—', isPositive: true, icon: Icons.credit_card_rounded, color: const Color(0xFF00B37E), bgColor: const Color(0xFFE6FAF4)),
      AdminKPI(title: 'Total Revenue', value: _formatCompactCurrency(totalRevenue), change: '—', isPositive: true, icon: Icons.payments_rounded, color: const Color(0xFF9B5CF6), bgColor: const Color(0xFFF3EEFF)),
      AdminKPI(title: "Today's Trips", value: '$todayTrips', change: '—', isPositive: false, icon: Icons.directions_bus_rounded, color: const Color(0xFFE08C00), bgColor: const Color(0xFFFFF6E5)),
      AdminKPI(title: 'Open Tickets', value: '$openTickets', change: '—', isPositive: false, icon: Icons.headset_mic_rounded, color: const Color(0xFFE03E3E), bgColor: const Color(0xFFFFF0F0)),
      AdminKPI(title: 'Shop Items', value: '$shopItems', change: '—', isPositive: true, icon: Icons.storefront_rounded, color: const Color(0xFF00A3CC), bgColor: const Color(0xFFE5F8FC)),
    ];

    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width < 600 ? 2 : (width < 900 ? 3 : 4);
    final double childAspectRatio = width < 600 ? 1.05 : 1.4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kpis.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (_, i) => AdminKpiCard(kpi: kpis[i]),
    );
  }

  Widget _buildCategoryBreakdown(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Text(
        'No category data yet.',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      );
    }
    final total =
        data.fold<double>(0, (sum, item) => sum + (item['amount'] as double));
    return Column(
      children: data.map((item) {
        final pct = (item['amount'] as double) / total;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: item['color'] as Color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(item['label'] as String, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ]
                  ),
                  Text(
                    '₦${((item['amount'] as double) / 1000).toStringAsFixed(0)}K',
                    style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: (item['color'] as Color).withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivity(List<AuditLogEntry> activity) {
    if (activity.isEmpty) {
      return const Text(
        'No recent activity yet.',
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Column(
      children: activity.take(4).map((entry) {
        final moduleColors = {
          'Shop': const Color(0xFF9B5CF6),
          'Users': AppColors.primary,
          'Transport': const Color(0xFFE08C00),
          'Wallet': const Color(0xFF00B37E),
          'Notifications': const Color(0xFF00A3CC),
          'Support': const Color(0xFFE03E3E),
        };
        final moduleColor = moduleColors[entry.module] ?? AppColors.textSecondary;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               CircleAvatar(radius: 20, backgroundColor: AppColors.primarySurface, child: Text(entry.adminName.substring(0, 1), style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary))),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       children: [
                         Expanded(child: Text(entry.action, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                         const SizedBox(width: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(color: moduleColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                           child: Text(entry.module, style: TextStyle(fontFamily: 'Sora', fontSize: 9, fontWeight: FontWeight.w700, color: moduleColor), maxLines: 1),
                         )
                       ]
                     ),
                     const SizedBox(height: 6),
                     Row(
                       children: [
                         Expanded(child: Text('${entry.target} · by ${entry.adminName}', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                         const SizedBox(width: 12),
                         Text(_timeAgo(entry.timestamp), style: const TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                       ]
                     )
                   ],
                 ),
               ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _formatCompactCurrency(double value) {
    if (value >= 1000000) {
      return '₦${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '₦${(value / 1000).toStringAsFixed(1)}K';
    }
    return '₦${value.toStringAsFixed(0)}';
  }

  String _formatWeeklyChange(double? pct) {
    if (pct == null) return 'no prior week data';
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}% from last week';
  }
}
