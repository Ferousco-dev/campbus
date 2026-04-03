import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';
import '../../services/payments/paystack_service.dart';
import '../../services/wallet/wallet_service.dart';
import '../shared/success_screen.dart';

class PaymentProviderScreen extends StatefulWidget {
  final double amount;

  const PaymentProviderScreen({super.key, required this.amount});

  @override
  State<PaymentProviderScreen> createState() => _PaymentProviderScreenState();
}

class _PaymentProviderScreenState extends State<PaymentProviderScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;

  void _onPay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError('Please sign in to continue.');
      return;
    }
    final email = user.email ?? '';
    if (email.isEmpty) {
      _showError('Add an email to your account to continue.');
      return;
    }

    setState(() => _isProcessing = true);

    final result = await PaystackService.charge(
      email: email,
      amount: widget.amount,
    );

    if (!mounted) return;
    if (!result.success) {
      setState(() => _isProcessing = false);
      _showError(result.message);
      return;
    }

    try {
      await WalletService.recordTopUp(
        userId: user.uid,
        amount: widget.amount,
        reference: result.reference,
        methodLabel: _methodLabel(_selectedMethod),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showError('Unable to update wallet. Please try again.');
      return;
    }

    if (!mounted) return;
    setState(() => _isProcessing = false);

    final description = result.isDemo
        ? 'Demo mode: ${AppUtils.formatCurrency(widget.amount)} credited to your wallet.'
        : 'You have successfully added ${AppUtils.formatCurrency(widget.amount)} to your wallet balance. You can now use it for rides and purchases.';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          title: 'Top-Up Successful',
          description: description,
          primaryButtonLabel: 'Back to Wallet',
          onPrimaryPressed: () => Navigator.pop(context),
          secondaryButtonLabel: 'View Receipt',
          onSecondaryPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  String _methodLabel(int method) {
    switch (method) {
      case 1:
        return 'Bank Transfer';
      case 2:
        return 'USSD';
      case 0:
      default:
        return 'Card';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'Sora')),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Fund Wallet'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              const Text(
                                'Amount to deposit',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppUtils.formatCurrency(widget.amount),
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                        
                        const Text(
                          'Payment Method',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _PaymentMethodTile(
                          icon: Icons.credit_card_rounded,
                          title: 'Saved Card',
                          subtitle: 'Mastercard ending in •••• 4092',
                          isSelected: _selectedMethod == 0,
                          onTap: () => setState(() => _selectedMethod = 0),
                        ),
                        const SizedBox(height: 12),
                        _PaymentMethodTile(
                          icon: Icons.account_balance_rounded,
                          title: 'Bank Transfer',
                          subtitle: 'Use your dedicated virtual account',
                          isSelected: _selectedMethod == 1,
                          onTap: () => setState(() => _selectedMethod = 1),
                        ),
                        const SizedBox(height: 12),
                        _PaymentMethodTile(
                          icon: Icons.dialpad_rounded,
                          title: 'USSD',
                          subtitle: 'Dial code on your mobile network',
                          isSelected: _selectedMethod == 2,
                          onTap: () => setState(() => _selectedMethod = 2),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Button
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _onPay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Pay ${AppUtils.formatCurrency(widget.amount)}',
                              style: const TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textMuted.withOpacity(0.5),
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
