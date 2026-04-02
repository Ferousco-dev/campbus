import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class PinConfirmationSheet extends StatefulWidget {
  final double amount;
  final String recipientName;
  final VoidCallback onSuccess;

  const PinConfirmationSheet({
    super.key,
    required this.amount,
    required this.recipientName,
    required this.onSuccess,
  });

  static void show({
    required BuildContext context,
    required double amount,
    required String recipientName,
    required VoidCallback onSuccess,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PinConfirmationSheet(
        amount: amount,
        recipientName: recipientName,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<PinConfirmationSheet> createState() => _PinConfirmationSheetState();
}

class _PinConfirmationSheetState extends State<PinConfirmationSheet> {
  String _pin = '';
  bool _isProcessing = false;

  void _onKeyPress(String key) {
    if (_isProcessing) return;
    
    if (_pin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() => _pin += key);
      
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_isProcessing || _pin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  Future<void> _verifyPin() async {
    setState(() => _isProcessing = true);
    
    // Simulate verification
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    // If correct (we simulate all correct for mockup)
    HapticFeedback.mediumImpact();
    
    Navigator.pop(context); // Close sheet
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const Text(
            'Confirm Transfer',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sending ${AppUtils.formatCurrency(widget.amount)} to\n${widget.recipientName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // PIN Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) {
              bool isFilled = index < _pin.length;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.primary : AppColors.border,
                  border: Border.all(
                    color: isFilled ? AppColors.primary : AppColors.textMuted.withOpacity(0.3),
                    width: isFilled ? 0 : 2,
                  ),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 48),
          
          if (_isProcessing)
            const SizedBox(
              height: 280,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else
            // Custom Keypad
            SizedBox(
              height: 280,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['1', '2', '3'].map((e) => _key(e)).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['4', '5', '6'].map((e) => _key(e)).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['7', '8', '9'].map((e) => _key(e)).toList(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const SizedBox(width: 60), // Spacer
                        _key('0'),
                        SizedBox(
                          width: 60,
                          child: IconButton(
                            onPressed: _onDelete,
                            icon: const Icon(Icons.backspace_rounded, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _key(String text) {
    return GestureDetector(
      onTap: () => _onKeyPress(text),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 60,
        alignment: Alignment.center,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
