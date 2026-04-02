import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class WalletSummaryCards extends StatelessWidget {
  final int totalTransactions;
  final double avgTransaction;
  final double biggestSpend;
  final String topCategory;

  const WalletSummaryCards({
    super.key,
    required this.totalTransactions,
    required this.avgTransaction,
    required this.biggestSpend,
    required this.topCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Insights',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.receipt_long_rounded,
                  label: 'Transactions',
                  value: '$totalTransactions',
                  color: AppColors.primary,
                  bgColor: AppColors.primarySurface,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightCard(
                  icon: Icons.analytics_outlined,
                  label: 'Avg. Spend',
                  value: AppUtils.formatCurrency(avgTransaction),
                  color: const Color(0xFF00A36E),
                  bgColor: const Color(0xFFE6FAF3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Biggest Spend',
                  value: AppUtils.formatCurrency(biggestSpend),
                  color: const Color(0xFFE03E3E),
                  bgColor: const Color(0xFFFFF0F0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InsightCard(
                  icon: Icons.category_rounded,
                  label: 'Top Category',
                  value: topCategory,
                  color: const Color(0xFF9B5CF6),
                  bgColor: const Color(0xFFF3EEFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
