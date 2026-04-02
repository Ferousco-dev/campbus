import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback? onWalletTap;
  final VoidCallback? onShopTap;
  final VoidCallback? onPurchasesTap;

  const QuickActionsGrid({
    super.key,
    this.onWalletTap,
    this.onShopTap,
    this.onPurchasesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _ActionTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Wallet',
                sublabel: 'Manage funds',
                iconColor: AppColors.primary,
                iconBg: AppColors.primarySurface,
                comingSoon: false,
                onTap: onWalletTap,
              ),
              _ActionTile(
                icon: Icons.storefront_rounded,
                label: 'Shop',
                sublabel: 'Buy items',
                iconColor: const Color(0xFF00A36E),
                iconBg: const Color(0xFFE6FAF3),
                comingSoon: false,
                onTap: onShopTap,
              ),
              const _ActionTile(
                icon: Icons.people_alt_rounded,
                label: 'Contribute',
                sublabel: 'Coming soon',
                iconColor: AppColors.textMuted,
                iconBg: Color(0xFFF3F4F8),
                comingSoon: true,
              ),
              _ActionTile(
                icon: Icons.shopping_bag_rounded,
                label: 'Purchases',
                sublabel: 'View orders',
                iconColor: const Color(0xFF9B5CF6),
                iconBg: const Color(0xFFF3EEFF),
                comingSoon: false,
                onTap: onPurchasesTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color iconColor;
  final Color iconBg;
  final bool comingSoon;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.iconColor,
    required this.iconBg,
    required this.comingSoon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: comingSoon ? 0.55 : 1.0,
      child: GestureDetector(
        onTap: comingSoon ? null : onTap,
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
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
