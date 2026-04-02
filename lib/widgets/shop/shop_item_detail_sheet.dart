import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_item_model.dart';
import '../../theme/app_theme.dart';
import '../../screens/shop/checkout_screen.dart';

class ShopItemDetailSheet extends StatelessWidget {
  final ShopItem item;

  const ShopItemDetailSheet({super.key, required this.item});

  static void show(BuildContext context, ShopItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShopItemDetailSheet(item: item),
    );
  }

  // Category-based colors
  static const Map<ShopCategory, _CategoryStyle> _styles = {
    ShopCategory.wifi: _CategoryStyle(
      iconBg: Color(0xFFE6FAF3),
      iconColor: Color(0xFF00A36E),
    ),
    ShopCategory.campusLife: _CategoryStyle(
      iconBg: Color(0xFFFFF4E6),
      iconColor: Color(0xFFE88B00),
    ),
    ShopCategory.academic: _CategoryStyle(
      iconBg: Color(0xFFF3EEFF),
      iconColor: Color(0xFF9B5CF6),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final style = _styles[item.category]!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: style.iconBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(item.icon, size: 34, color: style.iconColor),
          ),

          const SizedBox(height: 16),

          // Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              item.name,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 6),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              item.description,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Recurring label
          if (item.isRecurring) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.autorenew_rounded,
                      size: 14, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Auto-renewable',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Divider
          const Divider(color: AppColors.divider, height: 1),

          const SizedBox(height: 16),

          // Price section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Price',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          item.formattedPrice,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (item.hasDiscount) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.formattedOriginalPrice,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.successBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Save ₦${(item.originalPrice! - item.price).toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stock info
          if (item.availability == AvailabilityStatus.limited &&
              item.stockCount != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE88B00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Only ${item.stockCount} left — hurry!',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE88B00),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Add to Cart
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${item.name} added to cart',
                            style: const TextStyle(
                                fontFamily: 'Sora', fontSize: 13),
                          ),
                          backgroundColor: AppColors.textPrimary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          action: SnackBarAction(
                            label: 'Undo',
                            textColor: Colors.white,
                            onPressed: () {},
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_shopping_cart_rounded,
                              size: 18, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Buy Now
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(
                            items: [item],
                            totalAmount: item.price,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded,
                              size: 18, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Buy Now',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryStyle {
  final Color iconBg;
  final Color iconColor;

  const _CategoryStyle({required this.iconBg, required this.iconColor});
}
