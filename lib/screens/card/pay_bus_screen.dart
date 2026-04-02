import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/shop_item_model.dart';
import '../shop/checkout_screen.dart';

class TransportVehicle {
  final String id;
  final String name;
  final String route;
  final double fare;
  final IconData icon;
  final bool isBus;

  const TransportVehicle({
    required this.id,
    required this.name,
    required this.route,
    required this.fare,
    required this.icon,
    this.isBus = true,
  });
}

class PayBusScreen extends StatefulWidget {
  const PayBusScreen({super.key});

  @override
  State<PayBusScreen> createState() => _PayBusScreenState();
}

class _PayBusScreenState extends State<PayBusScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<TransportVehicle> _vehicles = const [
    TransportVehicle(
      id: 'BUS-104',
      name: 'Campus Shuttle (Blue)',
      route: 'Main Gate ➔ Faculty of Science',
      fare: 250.0,
      icon: Icons.directions_bus_rounded,
    ),
    TransportVehicle(
      id: 'BUS-105',
      name: 'Campus Shuttle (Red)',
      route: 'Hostel ➔ Library Complex',
      fare: 200.0,
      icon: Icons.directions_bus_rounded,
    ),
    TransportVehicle(
      id: 'BUS-108',
      name: 'Express Shuttle',
      route: 'Main Gate ➔ Medical College',
      fare: 300.0,
      icon: Icons.directions_bus_rounded,
    ),
    TransportVehicle(
      id: 'TRI-042',
      name: 'Tricycle 042',
      route: 'Science ➔ Market Area',
      fare: 150.0,
      icon: Icons.electric_rickshaw_rounded,
      isBus: false,
    ),
    TransportVehicle(
      id: 'TRI-019',
      name: 'Tricycle 019',
      route: 'Hostel ➔ Stadium',
      fare: 150.0,
      icon: Icons.electric_rickshaw_rounded,
      isBus: false,
    ),
  ];

  List<TransportVehicle> get _filteredVehicles {
    if (_searchQuery.isEmpty) return _vehicles;
    final q = _searchQuery.toLowerCase();
    return _vehicles.where((v) {
      return v.id.toLowerCase().contains(q) ||
          v.name.toLowerCase().contains(q) ||
          v.route.toLowerCase().contains(q);
    }).toList();
  }

  void _onVehicleTap(TransportVehicle vehicle) {
    HapticFeedback.lightImpact();
    // Reusing standard Shop Checkout Screen for fare payment!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          items: [
            ShopItem(
              id: vehicle.id,
              name: '${vehicle.name} Fare',
              description: vehicle.route,
              price: vehicle.fare,
              category: ShopCategory.campusLife,
              icon: vehicle.icon,
              availability: AvailabilityStatus.available,
            )
          ],
          totalAmount: vehicle.fare,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = _filteredVehicles;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pay Transport'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Internal search UI
            Padding(
              padding: const EdgeInsets.all(24),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Bus ID or Route (e.g. BUS-104)',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Available Vehicles',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: vehicles.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        return _VehicleTile(
                          vehicle: v,
                          onTap: () => _onVehicleTap(v),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.bus_alert_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No vehicles found',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check the Bus ID and try searching again',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleTile extends StatelessWidget {
  final TransportVehicle vehicle;
  final VoidCallback onTap;

  const _VehicleTile({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: vehicle.isBus
                    ? const Color(0xFFE6FAF3)
                    : const Color(0xFFFFF4E6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                vehicle.icon,
                color: vehicle.isBus
                    ? const Color(0xFF00A36E)
                    : const Color(0xFFE88B00),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        vehicle.id,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.route,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '₦${vehicle.fare.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
