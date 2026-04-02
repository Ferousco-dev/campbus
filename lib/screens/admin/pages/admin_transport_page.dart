import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/admin/admin_models.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminTransportPage extends StatefulWidget {
  const AdminTransportPage({super.key});
  @override
  State<AdminTransportPage> createState() => _AdminTransportPageState();
}

class _AdminTransportPageState extends State<AdminTransportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<AdminRoute> _routes = [];
  List<AdminVehicle> _vehicles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  Future<void> _load() async {
    final r = await AdminService.fetchRoutes();
    final v = await AdminService.fetchVehicles();
    if (mounted) setState(() { _routes = r; _vehicles = v; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        // Summary
        Container(
          width: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Row(
              children: [
                _stat('Routes', '${_routes.length}', AppColors.primary),
                const SizedBox(width: 16),
                _stat('Active', '${_routes.where((r) => r.status == RouteStatus.active).length}', const Color(0xFF00B37E)),
                const SizedBox(width: 16),
                _stat('Vehicles', '${_vehicles.length}', const Color(0xFFE08C00)),
                const SizedBox(width: 16),
                _stat('Monthly Revenue', '₦1.39M', const Color(0xFF9B5CF6)),
              ],
            ),
          ),
        ),
        Container(height: 1, color: AppColors.border),
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tab,
            labelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w500),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [Tab(height: 54, text: 'Routes'), Tab(height: 54, text: 'Vehicles')],
          ),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [_buildRoutes(), _buildVehicles()],
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontFamily: 'Sora', fontSize: 24, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildRoutes() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _routes.length,
      itemBuilder: (_, i) {
        final route = _routes[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(6)), child: Text(route.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary))),
                  const Spacer(),
                  AdminStatusChip(label: route.statusLabel, color: route.statusColor),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text('${route.from}  →  ${route.to}', style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _routeStat(Icons.payments_rounded, '₦${route.fare.toStringAsFixed(0)} / trip'),
                  _routeStat(Icons.directions_bus_rounded, '${route.vehicleCount} vehicles'),
                  _routeStat(Icons.people_rounded, '${route.dailyPassengers}/day'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(8)),
                    child: Text('₦${(route.monthlyRevenue / 1000).toStringAsFixed(0)}K/mo', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionBtn('Edit Fare', () {}),
                  const SizedBox(width: 8),
                  _actionBtn(route.status == RouteStatus.active ? 'Deactivate' : 'Activate', () {}, danger: route.status == RouteStatus.active),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _routeStat(IconData icon, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: AppColors.textMuted),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  Widget _actionBtn(String label, VoidCallback onTap, {bool danger = false}) {
    final color = danger ? const Color(0xFFE03E3E) : AppColors.primary;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: color)),
      ),
    );
  }

  Widget _buildVehicles() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      itemBuilder: (_, i) {
        final v = _vehicles[i];
        final statusColor = v.status == VehicleStatus.active ? const Color(0xFF00B37E) : v.status == VehicleStatus.maintenance ? const Color(0xFFE08C00) : const Color(0xFF6B7A99);
        final statusLabel = v.status == VehicleStatus.active ? 'Active' : v.status == VehicleStatus.maintenance ? 'Maintenance' : 'Inactive';
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))]),
          child: Row(
            children: [
              Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.directions_bus_filled_rounded, color: AppColors.primary, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.plateNumber, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('${v.routeName} · ${v.capacity} seats · ${v.driverName}', style: const TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
              ])),
              AdminStatusChip(label: statusLabel, color: statusColor),
            ],
          ),
        );
      },
    );
  }
}
