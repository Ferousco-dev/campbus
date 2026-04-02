import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/auth_app_bar.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/gender_selector.dart';
import '../../utils/auth/validators.dart';
import 'set_code_screen.dart';

/// Create Account screen — registration form with field validation.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _fullNameController = TextEditingController();
  final _matricController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;

  // Error states
  String? _fullNameError;
  String? _matricError;
  String? _emailError;
  String? _phoneError;
  String? _dobError;
  String? _genderError;

  bool _submitted = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _matricController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAll() {
    setState(() {
      _submitted = true;
      _fullNameError = AuthValidators.fullName(_fullNameController.text);
      _matricError = AuthValidators.matricNumber(_matricController.text);
      _emailError = AuthValidators.email(_emailController.text);
      _phoneError = AuthValidators.phone(_phoneController.text);
      _dobError = AuthValidators.dateOfBirth(_dateOfBirth);
      _genderError = AuthValidators.gender(_gender);
    });
  }

  bool get _isValid =>
      _fullNameError == null &&
      _matricError == null &&
      _emailError == null &&
      _phoneError == null &&
      _dobError == null &&
      _genderError == null;

  void _onContinue() {
    _validateAll();
    if (!_isValid) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SetCodeScreen(),
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

  void _skipToHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1980),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(
                  fontFamily: 'Sora',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        if (_submitted) {
          _dobError = AuthValidators.dateOfBirth(_dateOfBirth);
        }
      });
    }
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
        body: Column(
          children: [
            // Scrollable form
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 8),

                  // Header
                  const Text(
                    'Create your\naccount',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join thousands of students using CampusRide',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 1. Full Name
                        AuthInputField(
                          label: 'Full Name',
                          placeholder: 'e.g. John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                          controller: _fullNameController,
                          keyboardType: TextInputType.name,
                          errorText: _fullNameError,
                          onChanged: (_) {
                            if (_submitted) {
                              setState(() {
                                _fullNameError = AuthValidators.fullName(
                                    _fullNameController.text);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2. Matric Number
                        AuthInputField(
                          label: 'Matric Number',
                          placeholder: 'e.g. STU/2024/00142',
                          prefixIcon: Icons.school_outlined,
                          controller: _matricController,
                          errorText: _matricError,
                          onChanged: (_) {
                            if (_submitted) {
                              setState(() {
                                _matricError = AuthValidators.matricNumber(
                                    _matricController.text);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Date of Birth
                        AuthInputField(
                          label: 'Date of Birth',
                          placeholder: 'DD / MM / YYYY',
                          prefixIcon: Icons.calendar_today_outlined,
                          readOnly: true,
                          onTap: _pickDate,
                          errorText: _dobError,
                          controller: TextEditingController(
                            text: _dateOfBirth != null
                                ? DateFormat('dd / MM / yyyy')
                                    .format(_dateOfBirth!)
                                : '',
                          ),
                          suffix: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.textMuted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 4. Email
                        AuthInputField(
                          label: 'Email Address',
                          placeholder: 'student@uni.edu',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          onChanged: (_) {
                            if (_submitted) {
                              setState(() {
                                _emailError = AuthValidators.email(
                                    _emailController.text);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 5. Phone Number
                        AuthInputField(
                          label: 'Phone Number',
                          placeholder: 'e.g. 9072182889',
                          prefixIcon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          errorText: _phoneError,
                          prefix: Container(
                            margin: const EdgeInsets.only(left: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '+234',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          onChanged: (_) {
                            if (_submitted) {
                              setState(() {
                                _phoneError = AuthValidators.phone(
                                    _phoneController.text);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // 6. Gender
                        GenderSelector(
                          selectedGender: _gender,
                          errorText: _genderError,
                          onChanged: (val) {
                            setState(() {
                              _gender = val;
                              if (_submitted) {
                                _genderError = AuthValidators.gender(_gender);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Terms text
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                      children: [
                        const TextSpan(text: 'By continuing, you agree to our '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' & '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Continue button (pinned at bottom)
            Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, bottomPadding + 16),
              child: _ContinueButton(onTap: _onContinue),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width CTA button used on auth forms.
class _ContinueButton extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _ContinueButton({
    required this.onTap,
    this.label = 'Continue',
  });

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
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
    );
  }
}
