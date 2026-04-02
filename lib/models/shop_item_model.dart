import 'package:flutter/material.dart';

enum ShopCategory {
  wifi,
  campusLife,
  academic,
}

enum AvailabilityStatus {
  available,
  limited,
  unavailable,
  comingSoon,
}

class ShopItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final ShopCategory category;
  final AvailabilityStatus availability;
  final String? tag;
  final IconData icon;
  final String? imagePath;
  final double? originalPrice;
  final int? stockCount;
  final bool isRecurring;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.availability,
    this.tag,
    required this.icon,
    this.imagePath,
    this.originalPrice,
    this.stockCount,
    this.isRecurring = false,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  double get discountPercent =>
      hasDiscount ? ((originalPrice! - price) / originalPrice! * 100) : 0;
  String get formattedPrice => '₦${price.toStringAsFixed(0)}';
  String get formattedOriginalPrice =>
      originalPrice != null ? '₦${originalPrice!.toStringAsFixed(0)}' : '';

  bool get isAvailable =>
      availability == AvailabilityStatus.available ||
      availability == AvailabilityStatus.limited;
}

// ── Sample shop items ────────────────────────────────────────────────────────

final List<ShopItem> sampleShopItems = [
  // WiFi
  const ShopItem(
    id: 'wf_01',
    name: 'Inteco WiFi',
    description: '24hr campus-wide internet access',
    price: 100,
    category: ShopCategory.wifi,
    availability: AvailabilityStatus.available,
    icon: Icons.wifi_rounded,
  ),
  const ShopItem(
    id: 'wf_02',
    name: 'Inteco WiFi (Weekly)',
    description: '7 days of uninterrupted campus internet',
    price: 500,
    originalPrice: 700,
    category: ShopCategory.wifi,
    availability: AvailabilityStatus.available,
    tag: 'Best Value',
    icon: Icons.wifi_rounded,
    isRecurring: true,
  ),

  // Campus Life
  const ShopItem(
    id: 'cl_01',
    name: 'Convocation Pass',
    description: 'Gate A & B access • Apr 12',
    price: 1500,
    category: ShopCategory.campusLife,
    availability: AvailabilityStatus.limited,
    stockCount: 23,
    tag: 'New',
    icon: Icons.celebration_rounded,
  ),
  const ShopItem(
    id: 'cl_02',
    name: 'Cafeteria Voucher',
    description: '₦500 meal credit at any campus cafeteria',
    price: 500,
    category: ShopCategory.campusLife,
    availability: AvailabilityStatus.available,
    icon: Icons.restaurant_rounded,
  ),
  const ShopItem(
    id: 'cl_03',
    name: 'Cafeteria Voucher',
    description: '₦1,000 meal credit at any campus cafeteria',
    price: 1000,
    category: ShopCategory.campusLife,
    availability: AvailabilityStatus.available,
    tag: 'Popular',
    icon: Icons.restaurant_rounded,
  ),
  const ShopItem(
    id: 'cl_04',
    name: 'Printing Credits',
    description: '50 pages of B&W or 20 pages of colour printing',
    price: 250,
    category: ShopCategory.campusLife,
    availability: AvailabilityStatus.available,
    icon: Icons.print_rounded,
  ),
  const ShopItem(
    id: 'cl_05',
    name: 'Locker Rental',
    description: 'Semester-long locker at the main library',
    price: 3000,
    category: ShopCategory.campusLife,
    availability: AvailabilityStatus.limited,
    stockCount: 8,
    icon: Icons.lock_rounded,
  ),

  // Academic
  const ShopItem(
    id: 'ac_01',
    name: 'PHY 107 Manual',
    description: 'Prof. Adebayo • 2025/26 Edition',
    price: 1200,
    category: ShopCategory.academic,
    availability: AvailabilityStatus.available,
    icon: Icons.menu_book_rounded,
  ),
  const ShopItem(
    id: 'ac_02',
    name: 'CHM 101 Manual',
    description: 'Dr. Okonkwo • 2025/26 Edition',
    price: 1500,
    category: ShopCategory.academic,
    availability: AvailabilityStatus.unavailable,
    icon: Icons.menu_book_rounded,
  ),
  const ShopItem(
    id: 'ac_03',
    name: 'Past Questions Pack',
    description: '5-year compiled past questions & answers',
    price: 300,
    originalPrice: 500,
    category: ShopCategory.academic,
    availability: AvailabilityStatus.available,
    tag: 'Popular',
    icon: Icons.quiz_rounded,
  ),
];
