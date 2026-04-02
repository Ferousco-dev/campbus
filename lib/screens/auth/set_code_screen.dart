import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/code_dots.dart';
import '../../widgets/auth/auth_keypad.dart';
import '../../widgets/auth/auth_app_bar.dart';
import '../../utils/auth/validators.dart';

/// Set 6-Digit Code screen — 2-step flow: enter code → confirm code.
class SetCodeScreen extends StatefulWidget {
  const SetCodeScreen({super.key});

  @override
  State<SetCodeScreen> createState() => _SetCodeScreenState();
}

class _SetCodeScreenState extends State<SetCodeScreen>
    with SingleTickerProviderStateMixin {
  String _code = '';
  String _firstCode = '';
  int _step = 1; // 1 = enter, 2 = confirm
  bool _isError = false;
  bool _isSuccess = false;
  int _mismatchCount = 0;
  String? _errorMessage;
  bool _showWeakWarning = false;

  late AnimationController _crossfadeController;

  @override
  void initState() {
    super.initState();
    _crossfadeController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _crossfadeController.dispose();
    super.dispose();
  }

  void _onDigit(int digit) {
    if (_code.length >= 6 || _isSuccess) return;

    setState(() {
      _code += digit.toString();
      _isError = false;
      _errorMessage = null;
    });

    if (_code.length == 6) {
      if (_step == 1) {
        _handleStep1Complete();
      } else {
        _handleStep2Complete();
      }
    }
  }

  void _onBackspace() {
    if (_code.isEmpty) return;
    setState(() {
      _code = _code.substring(0, _code.length - 1);
      _isError = false;
      _errorMessage = null;
      _showWeakWarning = false;
    });
  }

  Future<void> _handleStep1Complete() async {
    // Check for weak code
    if (AuthValidators.isWeakCode(_code)) {
      setState(() => _showWeakWarning = true);
      return; // User can still proceed via "Use anyway" or change
    }

    _advanceToStep2();
  }

  void _advanceToStep2() {
    setState(() {
      _firstCode = _code;
      _code = '';
      _step = 2;
      _showWeakWarning = false;
    });
  }

  Future<void> _handleStep2Complete() async {
    if (_code == _firstCode) {
      // Success!
      setState(() => _isSuccess = true);
      HapticFeedback.mediumImpact();

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) _showSuccessOverlay();
    } else {
      // Mismatch
      _mismatchCount++;
      setState(() {
        _isError = true;
        _errorMessage = 'Codes don\'t match. Try again.';
      });
      HapticFeedback.heavyImpact();

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _code = '';
          _isError = false;
        });

        // After 3 failures, offer to start over
        if (_mismatchCount >= 3) {
          setState(() {
            _errorMessage = null;
          });
          _showStartOverDialog();
        }
      }
    }
  }

  void _showStartOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Start over?',
          style: TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'You\'ve had trouble confirming your code. Would you like to set a new one?',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep trying',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _step = 1;
                _code = '';
                _firstCode = '';
                _mismatchCount = 0;
                _errorMessage = null;
              });
            },
            child: const Text(
              'Start over',
              style: TextStyle(
                fontFamily: 'Sora',
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessOverlay() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, _, __) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'You\'re all set!',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your account is ready.\nWelcome to CampusRide!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto-navigate after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    });
  }

  void _skipToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AuthAppBar(
          showBack: true,
          onSkip: _skipToHome,
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Lock icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Title (crossfade between steps)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey(_step),
                  children: [
                    Text(
                      _step == 1 ? 'Set your code' : 'Confirm your code',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _step == 1
                          ? 'Choose a 6-digit code you\'ll remember'
                          : 'Re-enter your 6-digit code to confirm',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Step indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Row(
                  children: [
                    _StepDot(
                      label: '1',
                      isActive: true,
                      isCompleted: _step == 2,
                    ),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: _step == 2
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    _StepDot(
                      label: '2',
                      isActive: _step == 2,
                      isCompleted: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Step $_step of 2',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),

              const SizedBox(height: 28),

              // Code dots
              CodeDots(
                filledCount: _code.length,
                isError: _isError,
                isSuccess: _isSuccess,
              ),

              // Error message
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 28,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _errorMessage != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _errorMessage ?? '',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),

              // Weak code warning
              if (_showWeakWarning)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFF4A200).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFF4A200),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'This code is easy to guess',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B6914),
                              ),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: _advanceToStep2,
                              child: const Text(
                                'Use anyway →',
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF4A200),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Keypad (no biometric button here)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: AuthKeypad(
                  onDigitTap: _onDigit,
                  onBackspace: _onBackspace,
                  onBiometric: null, // No biometric on set-code screen
                ),
              ),

              SizedBox(height: bottomPadding + 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive || isCompleted
            ? AppColors.primary
            : AppColors.surface,
        border: Border.all(
          color: isActive || isCompleted
              ? AppColors.primary
              : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppColors.textMuted,
                ),
              ),
      ),
    );
  }
}
