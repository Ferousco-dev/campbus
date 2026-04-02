import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../screens/wallet/payment_provider_screen.dart';

class AddFundsSheet extends StatefulWidget {
  const AddFundsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFundsSheet(),
    );
  }

  @override
  State<AddFundsSheet> createState() => _AddFundsSheetState();
}

class _AddFundsSheetState extends State<AddFundsSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<double> _quickAmounts = [1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    // Auto focus the input field after render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQuickAmountTap(double amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _amountController.text = amount.toInt().toString();
      // Move cursor to the end
      _amountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length),
      );
    });
  }

  void _onContinue() {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Minimum deposit amount is ₦100',
            style: TextStyle(fontFamily: 'Sora', fontSize: 13),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    // Close the sheet
    Navigator.pop(context);
    
    // Navigate to payment provider screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentProviderScreen(amount: amount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 10,
        left: 24,
        right: 24,
        bottom: bottomPadding > 0 ? bottomPadding + 20 : 34,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const Text(
            'Deposit Funds',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the amount you want to add to your wallet.',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Amount Input
          Center(
            child: IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                focusNode: _focusNode,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixText: '₦ ',
                  prefixStyle: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  hintText: '0',
                  hintStyle: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted.withOpacity(0.5),
                  ),
                ),
                onChanged: (val) => setState(() {}),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Quick Amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _quickAmounts.map((amt) {
              return GestureDetector(
                onTap: () => _onQuickAmountTap(amt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    '+ ₦${amt.toInt()}',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 48),
          
          // Continue Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _amountController.text.isNotEmpty ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
