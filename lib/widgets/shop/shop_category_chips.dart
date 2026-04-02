import 'package:flutter/material.dart';
import '../../models/shop_item_model.dart';
import '../../theme/app_theme.dart';

class ShopCategoryChips extends StatelessWidget {
  final ShopCategory? selectedCategory;
  final ValueChanged<ShopCategory?> onSelected;

  const ShopCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  static const _categories = [
    _ChipData(null, 'All', Icons.apps_rounded),
    _ChipData(ShopCategory.wifi, 'WiFi', Icons.wifi_rounded),
    _ChipData(ShopCategory.campusLife, 'Campus Life', Icons.local_activity_rounded),
    _ChipData(ShopCategory.academic, 'Academic', Icons.school_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = _categories[index];
          final isSelected = selectedCategory == chip.category;
          return GestureDetector(
            onTap: () => onSelected(chip.category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    chip.icon,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    chip.label,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChipData {
  final ShopCategory? category;
  final String label;
  final IconData icon;

  const _ChipData(this.category, this.label, this.icon);
}
