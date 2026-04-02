import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../theme/app_theme.dart';
import '../utils/app_utils.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final bool showDivider;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.showDivider = true,
  });

  IconData _getCategoryIcon() {
    switch (transaction.category) {
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'topup':
        return Icons.add_circle_outline_rounded;
      case 'purchase':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  Color _getCategoryColor() {
    switch (transaction.category) {
      case 'transport':
        return AppColors.primary;
      case 'topup':
        return AppColors.success;
      case 'purchase':
        return const Color(0xFF9B5CF6);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getCategoryBg() {
    switch (transaction.category) {
      case 'transport':
        return AppColors.primarySurface;
      case 'topup':
        return AppColors.successBg;
      case 'purchase':
        return const Color(0xFFF3EEFF);
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountColor =
        transaction.isCredit ? AppColors.success : AppColors.error;
    final amountPrefix = transaction.isCredit ? '+' : '-';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getCategoryBg(),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  size: 20,
                  color: _getCategoryColor(),
                ),
              ),
              const SizedBox(width: 13),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      AppUtils.formatDate(transaction.date),
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

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$amountPrefix${AppUtils.formatCurrency(transaction.amount)}',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: transaction.isCredit
                          ? AppColors.successBg
                          : AppColors.errorBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      transaction.isCredit ? 'Credit' : 'Debit',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: amountColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: AppColors.divider,
            ),
          ),
      ],
    );
  }
}
