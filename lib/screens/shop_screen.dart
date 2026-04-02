import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/shop_item_model.dart';
import '../theme/app_theme.dart';
import '../widgets/shop/shop_search_bar.dart';
import '../widgets/shop/shop_banner_carousel.dart';
import '../widgets/shop/shop_category_chips.dart';
import '../widgets/shop/shop_section_header.dart';
import '../widgets/shop/shop_item_card.dart';
import '../widgets/shop/shop_item_detail_sheet.dart';
import 'shop/cart_screen.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final TextEditingController _searchController = TextEditingController();
  ShopCategory? _selectedCategory;
  String _searchQuery = '';
  int _cartCount = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShopItem> get _filteredItems {
    return sampleShopItems.where((item) {
      // Category filter
      if (_selectedCategory != null && item.category != _selectedCategory) {
        return false;
      }
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  Map<ShopCategory, List<ShopItem>> get _groupedItems {
    final grouped = <ShopCategory, List<ShopItem>>{};
    for (final item in _filteredItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }

  String _categoryTitle(ShopCategory cat) {
    switch (cat) {
      case ShopCategory.wifi:
        return 'WiFi & Connectivity';
      case ShopCategory.campusLife:
        return 'Campus Life';
      case ShopCategory.academic:
        return 'Academic';
    }
  }

  void _onItemTap(ShopItem item) {
    ShopItemDetailSheet.show(context, item);
  }

  void _onItemLongPress(ShopItem item) {
    setState(() => _cartCount++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item.name} added to cart',
          style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () => setState(() => _cartCount--),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedItems;
    final hasResults = grouped.isNotEmpty;

    // Define section order
    const sectionOrder = [
      ShopCategory.wifi,
      ShopCategory.campusLife,
      ShopCategory.academic,
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ───────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: false,
              toolbarHeight: 60,
              title: const Text(
                'Shop',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                    },
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            size: 20,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_cartCount > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$_cartCount',
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // ── Content ───────────────────────────────────────────────
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 4),

                // Search
                ShopSearchBar(
                  controller: _searchController,
                  onChanged: (q) => setState(() => _searchQuery = q),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                ),

                const SizedBox(height: 16),

                // Banner (hide during search)
                if (_searchQuery.isEmpty) ...[
                  const ShopBannerCarousel(),
                  const SizedBox(height: 18),
                ],

                // Category chips
                ShopCategoryChips(
                  selectedCategory: _selectedCategory,
                  onSelected: (cat) =>
                      setState(() => _selectedCategory = cat),
                ),

                const SizedBox(height: 20),

                // ── Item Sections ─────────────────────────────────────
                if (!hasResults) _buildEmptyState(),

                if (hasResults)
                  ...sectionOrder
                      .where((cat) => grouped.containsKey(cat))
                      .expand((cat) => [
                            ShopSectionHeader(
                              title: _categoryTitle(cat),
                              onViewAll: () {},
                            ),
                            const SizedBox(height: 12),
                            _buildItemGrid(grouped[cat]!),
                            const SizedBox(height: 24),
                          ]),

                const SizedBox(height: 20),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemGrid(List<ShopItem> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ShopItemCard(
            item: item,
            onTap: () => _onItemTap(item),
            onLongPress: () => _onItemLongPress(item),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 34,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items found',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different keyword or browse categories',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
