import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class WalletBalanceHero extends StatefulWidget {
  final double balance;
  final double monthlyIncome;
  final double monthlySpent;

  const WalletBalanceHero({
    super.key,
    required this.balance,
    required this.monthlyIncome,
    required this.monthlySpent,
  });

  @override
  State<WalletBalanceHero> createState() => _WalletBalanceHeroState();
}

class _WalletBalanceHeroState extends State<WalletBalanceHero>
    with SingleTickerProviderStateMixin {
  bool _balanceVisible = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A3FD8),
            Color(0xFF0F2AA0),
            Color(0xFF0A1F8F),
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 50,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) => Opacity(
                opacity: _pulseAnimation.value * 0.06,
                child: child,
              ),
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'My Wallet',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _balanceVisible = !_balanceVisible),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                        child: Icon(
                          _balanceVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white.withOpacity(0.75),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Balance label
                Text(
                  'Available Balance',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),

                // Balance amount
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _balanceVisible
                        ? AppUtils.formatCurrency(widget.balance)
                        : '₦ ••••••',
                    key: ValueKey(_balanceVisible),
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.1),
                ),

                const SizedBox(height: 16),

                // Income / Spent row
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Income this month',
                        amount: widget.monthlyIncome,
                        icon: Icons.arrow_downward_rounded,
                        iconColor: const Color(0xFF00C6AE),
                        visible: _balanceVisible,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    Expanded(
                      child: _MiniStat(
                        label: 'Spent this month',
                        amount: widget.monthlySpent,
                        icon: Icons.arrow_upward_rounded,
                        iconColor: const Color(0xFFFF6B6B),
                        visible: _balanceVisible,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _HeroActionButton(
                        label: 'Add Money',
                        icon: Icons.add_rounded,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroActionButton(
                        label: 'Transfer',
                        icon: Icons.swap_horiz_rounded,
                        onTap: () {},
                        outlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final bool visible;

  const _MiniStat({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  visible ? AppUtils.formatCurrency(amount) : '₦ ••••',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _HeroActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: outlined
              ? Border.all(color: Colors.white.withOpacity(0.35), width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: outlined ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: outlined ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
