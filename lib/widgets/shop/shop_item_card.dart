import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/shop_item_model.dart';
import '../../theme/app_theme.dart';

class ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
  });

  // Category-based colors (consistent with QuickActionsGrid)
  static const Map<ShopCategory, _CategoryStyle> _categoryStyles = {
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
    final style = _categoryStyles[item.category]!;
    final bool dimmed = !item.isAvailable;

    return GestureDetector(
      onTap: dimmed ? () => _showUnavailableSnack(context) : onTap,
      onLongPress: dimmed
          ? null
          : () {
              HapticFeedback.mediumImpact();
              onLongPress?.call();
            },
      child: Opacity(
        opacity: dimmed ? 0.45 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: icon + badges
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: style.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item.icon, size: 22, color: style.iconColor),
                  ),
                  const Spacer(),
                  // Tag / Discount badges
                  Flexible(child: _buildBadges()),
                ],
              ),

              const SizedBox(height: 12),

              // Name
              Text(
                item.name,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 2),

              // Description
              Text(
                item.description,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Price row
              _buildPriceRow(),

              // Availability label
              if (item.availability == AvailabilityStatus.limited &&
                  item.stockCount != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Only ${item.stockCount} left',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE88B00),
                    ),
                  ),
                ),

              if (item.availability == AvailabilityStatus.unavailable)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Sold Out',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),

              if (item.availability == AvailabilityStatus.comingSoon)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadges() {
    final widgets = <Widget>[];

    // Discount badge
    if (item.hasDiscount) {
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '-${item.discountPercent.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Tag badge
    if (item.tag != null) {
      final tagColor = _tagColor(item.tag!);
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: tagColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            item.tag!,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: tagColor,
            ),
          ),
        ),
      );
    }

    return Wrap(spacing: 4, runSpacing: 4, alignment: WrapAlignment.end, children: widgets);
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          item.formattedPrice,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (item.hasDiscount) ...[
          const SizedBox(width: 5),
          Text(
            item.formattedOriginalPrice,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textMuted,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Popular':
        return AppColors.primary;
      case 'New':
        return const Color(0xFF00C6AE);
      case 'Best Value':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showUnavailableSnack(BuildContext context) {
    final message = item.availability == AvailabilityStatus.comingSoon
        ? '${item.name} is coming soon!'
        : '${item.name} is currently sold out';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _CategoryStyle {
  final Color iconBg;
  final Color iconColor;

  const _CategoryStyle({required this.iconBg, required this.iconColor});
}
