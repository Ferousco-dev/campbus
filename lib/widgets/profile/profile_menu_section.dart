import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileMenuSection extends StatelessWidget {
  final List<ProfileMenuItem> items;

  const ProfileMenuSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _ProfileMenuTile(item: items[i]),
            if (i < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Divider(height: 1, color: AppColors.divider),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final ProfileMenuItem item;

  const _ProfileMenuTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.iconBg ?? AppColors.primarySurface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                item.icon,
                size: 20,
                color: item.iconColor ?? AppColors.primary,
              ),
            ),

            const SizedBox(width: 14),

            // Label + sublabel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (item.sublabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.sublabel!,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Badge (optional)
            if (item.badge != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.badge!,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

            // Chevron or custom trailing
            item.trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
          ],
        ),
      ),
    );
  }
}

class ProfileMenuItem {
  final IconData icon;
  final Color? iconColor;
  final Color? iconBg;
  final String label;
  final String? sublabel;
  final String? badge;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileMenuItem({
    required this.icon,
    this.iconColor,
    this.iconBg,
    required this.label,
    this.sublabel,
    this.badge,
    this.trailing,
    this.onTap,
  });
}
