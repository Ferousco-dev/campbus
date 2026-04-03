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
  final String? iconKey;
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
    this.iconKey,
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

  factory ShopItem.fromFirestore(String id, Map<String, dynamic> data) {
    final category = _categoryFromString(data['category'] as String?);
    final availability = _availabilityFromString(
        data['availability'] as String?);
    final iconKey = data['iconKey'] as String?;

    return ShopItem(
      id: id,
      name: data['name'] as String? ?? 'Item',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      category: category,
      availability: availability,
      tag: data['tag'] as String?,
      icon: _iconFromKey(iconKey, category),
      iconKey: iconKey,
      imagePath: data['imagePath'] as String?,
      originalPrice: (data['originalPrice'] as num?)?.toDouble(),
      stockCount: data['stockCount'] as int?,
      isRecurring: data['isRecurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    final iconValue = iconKey ?? _iconKeyFromIcon(icon, category);
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': _categoryToString(category),
      'availability': _availabilityToString(availability),
      'tag': tag,
      'iconKey': iconValue,
      'imagePath': imagePath,
      'originalPrice': originalPrice,
      'stockCount': stockCount,
      'isRecurring': isRecurring,
    };
  }
}

ShopCategory _categoryFromString(String? value) {
  switch (value) {
    case 'wifi':
      return ShopCategory.wifi;
    case 'campusLife':
      return ShopCategory.campusLife;
    case 'academic':
      return ShopCategory.academic;
    default:
      return ShopCategory.wifi;
  }
}

String _categoryToString(ShopCategory category) {
  switch (category) {
    case ShopCategory.wifi:
      return 'wifi';
    case ShopCategory.campusLife:
      return 'campusLife';
    case ShopCategory.academic:
      return 'academic';
  }
}

AvailabilityStatus _availabilityFromString(String? value) {
  switch (value) {
    case 'available':
      return AvailabilityStatus.available;
    case 'limited':
      return AvailabilityStatus.limited;
    case 'unavailable':
      return AvailabilityStatus.unavailable;
    case 'comingSoon':
      return AvailabilityStatus.comingSoon;
    default:
      return AvailabilityStatus.available;
  }
}

String _availabilityToString(AvailabilityStatus status) {
  switch (status) {
    case AvailabilityStatus.available:
      return 'available';
    case AvailabilityStatus.limited:
      return 'limited';
    case AvailabilityStatus.unavailable:
      return 'unavailable';
    case AvailabilityStatus.comingSoon:
      return 'comingSoon';
  }
}

IconData _iconFromKey(String? key, ShopCategory category) {
  switch (key) {
    case 'wifi':
      return Icons.wifi_rounded;
    case 'celebration':
      return Icons.celebration_rounded;
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'print':
      return Icons.print_rounded;
    case 'lock':
      return Icons.lock_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'quiz':
      return Icons.quiz_rounded;
    default:
      switch (category) {
        case ShopCategory.wifi:
          return Icons.wifi_rounded;
        case ShopCategory.campusLife:
          return Icons.celebration_rounded;
        case ShopCategory.academic:
          return Icons.menu_book_rounded;
      }
  }
}

String _iconKeyFromIcon(IconData icon, ShopCategory category) {
  if (icon == Icons.wifi_rounded) return 'wifi';
  if (icon == Icons.celebration_rounded) return 'celebration';
  if (icon == Icons.restaurant_rounded) return 'restaurant';
  if (icon == Icons.print_rounded) return 'print';
  if (icon == Icons.lock_rounded) return 'lock';
  if (icon == Icons.menu_book_rounded) return 'book';
  if (icon == Icons.quiz_rounded) return 'quiz';

  switch (category) {
    case ShopCategory.wifi:
      return 'wifi';
    case ShopCategory.campusLife:
      return 'celebration';
    case ShopCategory.academic:
      return 'book';
  }
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
