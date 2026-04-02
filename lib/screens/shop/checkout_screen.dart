import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../models/shop_item_model.dart';
import '../../utils/app_utils.dart';
import '../shared/success_screen.dart';
import 'wifi_ticket_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<ShopItem>? items;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    this.items,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;

  bool get _hasWifi =>
      widget.items?.any((item) => item.category == ShopCategory.wifi) ?? false;

  void _onPay() async {
    setState(() => _isProcessing = true);

    // Simulate API call for purchase
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_hasWifi) {
      // Find the WiFi item to get plan name
      final wifiItem = widget.items!.firstWhere(
        (item) => item.category == ShopCategory.wifi,
      );

      // Determine duration label from plan name
      String duration;
      if (wifiItem.name.toLowerCase().contains('weekly')) {
        duration = '7 Days Access';
      } else if (wifiItem.name.toLowerCase().contains('monthly')) {
        duration = '30 Days Access';
      } else {
        duration = '24 Hours Access';
      }

      // Generate random-but-realistic credentials (frontend-only)
      final now = DateTime.now();
      final suffix = (1000 + now.millisecond % 9000).toString();
      final username = 'stu_oau_$suffix';
      const password = 'WiFi@OAU2026';

      final issueDate =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WifiTicketScreen(
            planName: wifiItem.name,
            duration: duration,
            price: AppUtils.formatCurrency(widget.totalAmount),
            username: username,
            password: password,
            issueDate: issueDate,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            title: 'Payment Successful',
            description:
                'Your purchase of ${AppUtils.formatCurrency(widget.totalAmount)} was successful. Your items will be activated shortly.',
            primaryButtonLabel: 'Back to Shop',
            onPrimaryPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            secondaryButtonLabel: 'View Receipt',
            onSecondaryPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      );
    }
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
          title: const Text('Checkout'),
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
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            if (widget.items != null)
                              ...widget.items!.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1x ${item.name}',
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      item.formattedPrice,
                                      style: const TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            const Divider(color: AppColors.border, height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  AppUtils.formatCurrency(widget.totalAmount),
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Campus Wallet',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Available: ₦12,350.00',
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
                            const Icon(Icons.check_circle_rounded, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bottom Button
                Container(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
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
                              'Pay ${AppUtils.formatCurrency(widget.totalAmount)}',
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
