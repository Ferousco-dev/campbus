import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/shop_item_model.dart';
import '../../../services/admin/admin_service.dart';
import '../../../theme/app_theme.dart';
import '../widgets/admin_section_header.dart';

class AdminShopPage extends StatefulWidget {
  const AdminShopPage({super.key});
  @override
  State<AdminShopPage> createState() => _AdminShopPageState();
}

class _AdminShopPageState extends State<AdminShopPage> {
  List<ShopItem> _items = [];
  bool _loading = true;
  ShopCategory? _filter;
  final _search = TextEditingController();
  List<ShopItem> _filtered = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final items = await AdminService.fetchShopItems();
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
      _applyFilter();
    }
  }

  void _applyFilter() {
    setState(() {
      _filtered = _items.where((item) {
        final q = _search.text.toLowerCase();
        final matchSearch = q.isEmpty || item.name.toLowerCase().contains(q);
        final matchCat = _filter == null || item.category == _filter;
        return matchSearch && matchCat;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: Colors.white,
          child: Row(children: [
            Expanded(child: AdminSearchBar(controller: _search, hint: 'Search items…', onChanged: (_) => _applyFilter())),
            const SizedBox(width: 16),
            AdminActionButton(label: 'Add Item', icon: Icons.add_rounded, onTap: () => _showItemForm(context, null)),
          ]),
        ),
        // Category filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.background,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _catChip('All', null),
              const SizedBox(width: 12),
              _catChip('WiFi', ShopCategory.wifi),
              const SizedBox(width: 12),
              _catChip('Campus Life', ShopCategory.campusLife),
              const SizedBox(width: 12),
              _catChip('Academic', ShopCategory.academic),
            ]),
          ),
        ),
        Container(height: 1, color: AppColors.border),
        // Items list
        Expanded(
          child: Container(
            color: AppColors.background,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 24),
              itemCount: _filtered.length,
              itemBuilder: (_, i) => _buildItemListTile(_filtered[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {Color color = AppColors.textSecondary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _buildItemListTile(ShopItem item) {
    final availColor = _availabilityColor(item.availability);
    final availLabel = _availabilityLabel(item.availability);
    final catLabel = _categoryLabel(item.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(14)),
            child: Icon(item.icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(item.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 12),
                    AdminStatusChip(label: availLabel, color: availColor),
                  ]
                ),
                const SizedBox(height: 6),
                Text(item.description, style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(item.formattedPrice, style: const TextStyle(fontFamily: 'Sora', fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Text('· $catLabel', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textMuted)),
                  ]
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _iconBtn(Icons.edit_rounded, () => _showItemForm(context, item)),
              const SizedBox(width: 8),
              _iconBtn(Icons.delete_rounded, () => _confirmDelete(context, item), color: const Color(0xFFE03E3E)),
            ]
          )
        ]
      )
    );
  }

  Widget _catChip(String label, ShopCategory? cat) {
    final active = _filter == cat;
    return GestureDetector(
      onTap: () { setState(() => _filter = cat); _applyFilter(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  void _showItemForm(BuildContext context, ShopItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl = TextEditingController(text: item?.price.toStringAsFixed(0) ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');
    final tagCtrl = TextEditingController(text: item?.tag ?? '');
    final stockCtrl = TextEditingController(text: item?.stockCount?.toString() ?? '');
    final originalPriceCtrl = TextEditingController(text: item?.originalPrice?.toStringAsFixed(0) ?? '');
    ShopCategory selectedCategory = item?.category ?? ShopCategory.wifi;
    AvailabilityStatus selectedAvailability = item?.availability ?? AvailabilityStatus.available;
    bool isRecurring = item?.isRecurring ?? false;
    String? iconKey = item?.iconKey;
    if (iconKey == null || !_iconOptions.containsKey(iconKey)) {
      iconKey = _defaultIconKey(selectedCategory);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item == null ? 'Add Shop Item' : 'Edit Item', style: const TextStyle(fontFamily: 'Sora', fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 20),
              _field('Item Name', nameCtrl),
              const SizedBox(height: 14),
              _field('Price (₦)', priceCtrl, inputType: TextInputType.number),
              const SizedBox(height: 14),
              _field('Description', descCtrl),
              const SizedBox(height: 14),
              _field('Tag (optional)', tagCtrl),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _field('Original Price', originalPriceCtrl, inputType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Stock Count', stockCtrl, inputType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<ShopCategory>(
                value: selectedCategory,
                items: ShopCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_categoryLabel(cat), style: const TextStyle(fontFamily: 'Sora', fontSize: 13)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setSheetState(() {
                    selectedCategory = value;
                    iconKey = _defaultIconKey(selectedCategory);
                  });
                },
                decoration: _dropdownDecoration('Category'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<AvailabilityStatus>(
                value: selectedAvailability,
                items: AvailabilityStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(_availabilityLabel(status), style: const TextStyle(fontFamily: 'Sora', fontSize: 13)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setSheetState(() => selectedAvailability = value);
                },
                decoration: _dropdownDecoration('Availability'),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: iconKey,
                items: _iconOptions.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value, size: 16, color: AppColors.textPrimary),
                        const SizedBox(width: 8),
                        Text(_iconLabel(entry.key), style: const TextStyle(fontFamily: 'Sora', fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setSheetState(() => iconKey = value),
                decoration: _dropdownDecoration('Icon'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: isRecurring,
                onChanged: (val) => setSheetState(() => isRecurring = val),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.primary,
                title: const Text('Recurring item', style: TextStyle(fontFamily: 'Sora', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                subtitle: const Text('Charge this item on a recurring basis', style: TextStyle(fontFamily: 'Sora', fontSize: 11, color: AppColors.textSecondary)),
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
                onPressed: () async {
                  final name = nameCtrl.text.trim();
                  final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                  if (name.isEmpty || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Enter a valid name and price', style: TextStyle(fontFamily: 'Sora')),
                      backgroundColor: Color(0xFFE03E3E),
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.fromLTRB(20, 0, 20, 16),
                    ));
                    return;
                  }

                  final originalPrice = double.tryParse(originalPriceCtrl.text.trim());
                  final stockCount = int.tryParse(stockCtrl.text.trim());
                  final itemData = ShopItem(
                    id: item?.id ?? '',
                    name: name,
                    description: descCtrl.text.trim(),
                    price: price,
                    category: selectedCategory,
                    availability: selectedAvailability,
                    tag: tagCtrl.text.trim().isEmpty ? null : tagCtrl.text.trim(),
                    icon: _iconFromKey(iconKey, selectedCategory),
                    iconKey: iconKey,
                    imagePath: item?.imagePath,
                    originalPrice: (originalPrice ?? 0) > 0 ? originalPrice : null,
                    stockCount: stockCount,
                    isRecurring: isRecurring,
                  );

                  Navigator.pop(ctx);
                  setState(() => _loading = true);
                  if (item == null) {
                    await AdminService.addShopItem(itemData);
                  } else {
                    await AdminService.updateShopItem(itemData);
                  }
                  await _load();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(item == null ? 'Item added ✓' : 'Item updated ✓', style: const TextStyle(fontFamily: 'Sora')),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: Text(item == null ? 'Add Item' : 'Save Changes', style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType inputType = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextField(
        controller: ctrl,
        keyboardType: inputType,
        style: const TextStyle(fontFamily: 'Sora', fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        ),
      ),
    ]);
  }

  void _confirmDelete(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Item?', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
        content: Text('Are you sure you want to remove "${item.name}" from the shop?', style: const TextStyle(fontFamily: 'Sora', fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontFamily: 'Sora', color: AppColors.textSecondary))),
          TextButton(onPressed: () {
            Navigator.pop(context);
            setState(() => _loading = true);
            AdminService.deleteShopItem(item.id).then((_) async {
              await _load();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('"${item.name}" deleted', style: const TextStyle(fontFamily: 'Sora')),
                backgroundColor: const Color(0xFFE03E3E),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            });
          }, child: const Text('Delete', style: TextStyle(fontFamily: 'Sora', color: Color(0xFFE03E3E), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }

  String _categoryLabel(ShopCategory category) {
    switch (category) {
      case ShopCategory.wifi:
        return 'WiFi';
      case ShopCategory.campusLife:
        return 'Campus Life';
      case ShopCategory.academic:
        return 'Academic';
    }
  }

  String _availabilityLabel(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return 'Available';
      case AvailabilityStatus.limited:
        return 'Limited';
      case AvailabilityStatus.unavailable:
        return 'Out of Stock';
      case AvailabilityStatus.comingSoon:
        return 'Coming Soon';
    }
  }

  Color _availabilityColor(AvailabilityStatus status) {
    switch (status) {
      case AvailabilityStatus.available:
        return const Color(0xFF00B37E);
      case AvailabilityStatus.limited:
        return const Color(0xFFE08C00);
      case AvailabilityStatus.unavailable:
        return const Color(0xFFE03E3E);
      case AvailabilityStatus.comingSoon:
        return const Color(0xFF6B7A99);
    }
  }

  final Map<String, IconData> _iconOptions = const {
    'wifi': Icons.wifi_rounded,
    'celebration': Icons.celebration_rounded,
    'restaurant': Icons.restaurant_rounded,
    'print': Icons.print_rounded,
    'lock': Icons.lock_rounded,
    'book': Icons.menu_book_rounded,
    'quiz': Icons.quiz_rounded,
  };

  String _iconLabel(String key) {
    switch (key) {
      case 'wifi':
        return 'WiFi';
      case 'celebration':
        return 'Celebration';
      case 'restaurant':
        return 'Food';
      case 'print':
        return 'Printing';
      case 'lock':
        return 'Locker';
      case 'book':
        return 'Book';
      case 'quiz':
        return 'Quiz';
      default:
        return 'Item';
    }
  }

  String _defaultIconKey(ShopCategory category) {
    switch (category) {
      case ShopCategory.wifi:
        return 'wifi';
      case ShopCategory.campusLife:
        return 'celebration';
      case ShopCategory.academic:
        return 'book';
    }
  }

  IconData _iconFromKey(String? key, ShopCategory category) {
    final resolved = key ?? _defaultIconKey(category);
    return _iconOptions[resolved] ?? Icons.shopping_bag_outlined;
  }
}
