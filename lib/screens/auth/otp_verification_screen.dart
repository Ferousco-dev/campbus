import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'set_code_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onVerify() async {
    if (_codeController.text.length != 4) return;
    
    setState(() => _isProcessing = true);
    
    // Simulate verification
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const SetCodeScreen(), // Reusing SetCodeScreen for reset
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Enter OTP',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'We\'ve sent a 4-digit code to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              // Hidden TextField with visible boxes
              Stack(
                alignment: Alignment.center,
                children: [
                  // Real text field hidden
                  Opacity(
                    opacity: 0,
                    child: TextField(
                      controller: _codeController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      onChanged: (val) {
                        setState(() {});
                        if (val.length == 4) {
                          _onVerify();
                        }
                      },
                    ),
                  ),
                  
                  // Faux boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      final text = _codeController.text;
                      final isFilled = index < text.length;
                      final isActive = index == text.length;
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 60,
                        height: 70,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? AppColors.primary : (isFilled ? AppColors.textPrimary : AppColors.border),
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          isFilled ? text[index] : '',
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Re-send option
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Didn\'t receive the code? ',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            // Logic to resend here
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Code resent!')),
                            );
                          },
                          child: const Text(
                            'Resend',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _codeController.text.length == 4 ? _onVerify : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Verify',
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
        ),
      ),
    );
  }
}
