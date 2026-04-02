import 'package:flutter/material.dart';
import '../../models/wallet_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class WalletTransactionItem extends StatelessWidget {
  final WalletTransaction transaction;
  final bool showDivider;
  final VoidCallback? onGenerateReceipt;

  const WalletTransactionItem({
    super.key,
    required this.transaction,
    this.showDivider = true,
    this.onGenerateReceipt,
  });

  @override
  Widget build(BuildContext context) {
    final amountColor =
        transaction.isCredit ? AppColors.success : AppColors.error;
    final amountPrefix = transaction.isCredit ? '+' : '-';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              // Main row
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: transaction.categoryBgColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      transaction.categoryIcon,
                      size: 20,
                      color: transaction.categoryColor,
                    ),
                  ),
                  const SizedBox(width: 13),

                  // Title + subtitle
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

                  const SizedBox(width: 8),

                  // Amount + badge
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
                      const SizedBox(height: 4),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: transaction.categoryBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.categoryLabel,
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: transaction.categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Receipt action row
              _ReceiptActionRow(
                receiptStatus: transaction.receiptStatus,
                reference: transaction.reference,
                onGenerate: onGenerateReceipt,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}

class _ReceiptActionRow extends StatelessWidget {
  final ReceiptStatus receiptStatus;
  final String? reference;
  final VoidCallback? onGenerate;

  const _ReceiptActionRow({
    required this.receiptStatus,
    this.reference,
    this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Reference
          if (reference != null) ...[
            Icon(
              Icons.tag_rounded,
              size: 12,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              reference!,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const Spacer(),
          // Receipt button
          GestureDetector(
            onTap: receiptStatus == ReceiptStatus.available
                ? onGenerate
                : null,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _receiptBgColor,
                borderRadius: BorderRadius.circular(8),
                border: receiptStatus == ReceiptStatus.available
                    ? Border.all(
                        color: AppColors.primary.withOpacity(0.2))
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _receiptIcon,
                    size: 12,
                    color: _receiptColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _receiptLabel,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _receiptColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color get _receiptBgColor {
    switch (receiptStatus) {
      case ReceiptStatus.available:
        return AppColors.primarySurface;
      case ReceiptStatus.pending:
        return const Color(0xFFFFF6E5);
      case ReceiptStatus.notAvailable:
        return AppColors.background;
    }
  }

  Color get _receiptColor {
    switch (receiptStatus) {
      case ReceiptStatus.available:
        return AppColors.primary;
      case ReceiptStatus.pending:
        return const Color(0xFFE08C00);
      case ReceiptStatus.notAvailable:
        return AppColors.textMuted;
    }
  }

  IconData get _receiptIcon {
    switch (receiptStatus) {
      case ReceiptStatus.available:
        return Icons.receipt_long_rounded;
      case ReceiptStatus.pending:
        return Icons.hourglass_top_rounded;
      case ReceiptStatus.notAvailable:
        return Icons.receipt_long_outlined;
    }
  }

  String get _receiptLabel {
    switch (receiptStatus) {
      case ReceiptStatus.available:
        return 'Generate Receipt';
      case ReceiptStatus.pending:
        return 'Processing';
      case ReceiptStatus.notAvailable:
        return 'No Receipt';
    }
  }
}
