import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/code_dots.dart';
import '../../widgets/auth/auth_keypad.dart';
import '../../widgets/auth/skip_button.dart';
import 'create_account_screen.dart';
import 'forgot_password_screen.dart';

/// Login screen — user enters a 6-digit code OR uses biometric auth.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _code = '';
  bool _isError = false;
  bool _isSuccess = false;
  bool _isLoading = false;
  int _attempts = 0;
  bool _isLocked = false;
  String? _errorMessage;
  final GlobalKey<CodeDotsState> _dotsKey = GlobalKey<CodeDotsState>();

  // Demo stored code (frontend-only)
  static const String _storedCode = '123456';
  static const int _maxAttempts = 5;

  void _onDigit(int digit) {
    if (_code.length >= 6 || _isLocked || _isLoading) return;

    setState(() {
      _code += digit.toString();
      _isError = false;
      _errorMessage = null;
    });

    if (_code.length == 6) {
      _verifyCode();
    }
  }

  void _onBackspace() {
    if (_code.isEmpty || _isLocked) return;
    setState(() {
      _code = _code.substring(0, _code.length - 1);
      _isError = false;
      _errorMessage = null;
    });
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);

    // Simulate verification delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (_code == _storedCode) {
      setState(() {
        _isSuccess = true;
        _isLoading = false;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) _navigateToHome();
    } else {
      _attempts++;
      setState(() {
        _isError = true;
        _isLoading = false;
        _errorMessage = _attempts >= _maxAttempts
            ? 'Too many attempts. Try again later.'
            : 'Incorrect code. Please try again.';
        _isLocked = _attempts >= _maxAttempts;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _code = '';
          _isError = false;
        });
      }
    }
  }

  void _onBiometric() {
    // Frontend-only: simulate biometric success
    setState(() => _isSuccess = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _navigateToHome();
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _navigateToCreateAccount() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CreateAccountScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
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
        body: SafeArea(
          child: Column(
            children: [
              // === Logo + Header ===
              const SizedBox(height: 40),
              // Logo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'CampusRide',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter your 6-digit code to\naccess your wallet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // === Code Dots ===
              CodeDots(
                key: _dotsKey,
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
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _isLocked
                            ? AppColors.error
                            : AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),

              // Attempts remaining
              if (_attempts > 2 && !_isLocked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${_maxAttempts - _attempts} attempts remaining',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),

              const Spacer(),

              // === Keypad ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: AuthKeypad(
                  onDigitTap: _onDigit,
                  onBackspace: _onBackspace,
                  onBiometric: _onBiometric,
                  enabled: !_isLocked && !_isLoading,
                ),
              ),

              const SizedBox(height: 16),

              // Create account link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account?  ",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToCreateAccount,
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              
              // Forgot password link
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                  );
                },
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip button
              SkipButton(onTap: _navigateToHome),

              SizedBox(height: bottomPadding + 8),
            ],
          ),
        ),
      ),
    );
  }
}
