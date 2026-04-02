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
    if (mounted) setState(() { _items = items; _filtered = items; _loading = false; });
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(children: [
            Expanded(child: AdminSearchBar(controller: _search, hint: 'Search items…', onChanged: (_) => _applyFilter())),
            const SizedBox(width: 12),
            AdminActionButton(label: 'Add Item', icon: Icons.add_rounded, onTap: () => _showItemForm(context, null)),
          ]),
        ),
        // Category filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.background,
          child: Row(children: [
            _catChip('All', null),
            const SizedBox(width: 8),
            _catChip('WiFi', ShopCategory.wifi),
            const SizedBox(width: 8),
            _catChip('Campus Life', ShopCategory.campusLife),
            const SizedBox(width: 8),
            _catChip('Academic', ShopCategory.academic),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.background,
          child: Row(children: const [
            Expanded(flex: 3, child: Text('ITEM', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(flex: 2, child: Text('CATEGORY', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('PRICE', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            Expanded(child: Text('STATUS', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8))),
            SizedBox(width: 80),
          ]),
        ),
        Container(height: 1, color: AppColors.border),
        // Items list
        Expanded(
          child: ListView.builder(
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _buildItemRow(_filtered[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildItemRow(ShopItem item) {
    final availColor = item.availability == AvailabilityStatus.available ? const Color(0xFF00B37E) : item.availability == AvailabilityStatus.limited ? const Color(0xFFE08C00) : const Color(0xFFE03E3E);
    final availLabel = item.availability == AvailabilityStatus.available ? 'Available' : item.availability == AvailabilityStatus.limited ? 'Limited' : 'Out of Stock';
    final catLabel = item.category == ShopCategory.wifi ? 'WiFi' : item.category == ShopCategory.campusLife ? 'Campus Life' : 'Academic';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(flex: 3, child: Row(children: [
            Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)), child: Icon(item.icon, color: AppColors.primary, size: 18)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.name, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(item.description, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
          ])),
          Expanded(flex: 2, child: Text(catLabel, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, color: AppColors.textSecondary))),
          Expanded(child: Text(item.formattedPrice, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
          Expanded(child: AdminStatusChip(label: availLabel, color: availColor)),
          SizedBox(width: 80, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(onTap: () => _showItemForm(context, item), child: const Icon(Icons.edit_rounded, size: 16, color: AppColors.textSecondary)),
            const SizedBox(width: 12),
            GestureDetector(onTap: () => _confirmDelete(context, item), child: const Icon(Icons.delete_rounded, size: 16, color: Color(0xFFE03E3E))),
          ])),
        ],
      ),
    );
  }

  Widget _catChip(String label, ShopCategory? cat) {
    final active = _filter == cat;
    return GestureDetector(
      onTap: () { setState(() => _filter = cat); _applyFilter(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  void _showItemForm(BuildContext context, ShopItem? item) {
    final nameCtrl = TextEditingController(text: item?.name ?? '');
    final priceCtrl = TextEditingController(text: item?.price.toStringAsFixed(0) ?? '');
    final descCtrl = TextEditingController(text: item?.description ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
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
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(ctx);
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
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('"${item.name}" deleted', style: const TextStyle(fontFamily: 'Sora')),
              backgroundColor: const Color(0xFFE03E3E),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }, child: const Text('Delete', style: TextStyle(fontFamily: 'Sora', color: Color(0xFFE03E3E), fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
