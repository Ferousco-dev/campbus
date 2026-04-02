import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/card/stacked_cards_display.dart';
import '../widgets/card/card_activate_button.dart';
import '../widgets/card/card_status_info.dart';
import 'card/pay_bus_screen.dart';

class CardScreen extends StatefulWidget {
  const CardScreen({super.key});

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen>
    with SingleTickerProviderStateMixin {
  bool _isCardActive = false;
  late AnimationController _bannerAnim;

  @override
  void initState() {
    super.initState();
    _bannerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _bannerAnim.dispose();
    super.dispose();
  }

  void _handleToggle(bool newState) {
    setState(() => _isCardActive = newState);
    _bannerAnim.reset();
    _bannerAnim.forward();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        backgroundColor: newState ? const Color(0xFF00B37E) : const Color(0xFFE03E3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            Icon(
              newState ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              newState ? 'Card activated successfully' : 'Card deactivated',
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
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
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 60,
              title: const Text(
                'My Card',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),

                // Status banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isCardActive ? AppColors.successBg : AppColors.errorBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _isCardActive
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isCardActive ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _isCardActive
                                  ? 'Your student card is active and ready for bus scans'
                                  : 'Your student card is currently inactive',
                              key: ValueKey(_isCardActive),
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _isCardActive ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Stacked cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StackedCardsDisplay(
                    studentName: 'Oluwaferanmi',
                    studentId: 'STU/2024/00142',
                    course: 'Computer Sci.',
                    level: '300L',
                    isActive: _isCardActive,
                  ),
                ),

                const SizedBox(height: 36),

                // Card Details label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Card Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CardStatusInfo(isActive: _isCardActive),
                ),

                const SizedBox(height: 28),

                // Activate / Deactivate button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CardActivateButton(
                    isActive: _isCardActive,
                    onToggle: _handleToggle,
                  ),
                ),

                const SizedBox(height: 12),

                // Fallback bus pay button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PayBusScreen()),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text(
                        'Pay Bus Fare (No card?)',
                        style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _isCardActive
                          ? 'Deactivate if your card is lost or stolen to prevent unauthorized use.'
                          : 'Activate your card to enable NFC scanning at bus stops.',
                      key: ValueKey(_isCardActive),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
