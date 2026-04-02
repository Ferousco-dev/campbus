import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class TierUpgradeScreen extends StatelessWidget {
  const TierUpgradeScreen({super.key});

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
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Account Tiers',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // Current Tier Status Hero
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'You are currently on',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Tier 1',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CurrentLimit(label: 'Max Balance', value: '₦50,000'),
                        _CurrentLimit(label: 'Daily Limit', value: '₦10,000'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              'Available Upgrades',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            // Tier 2 Card
            _TierUpgradeCard(
              title: 'Tier 2 (Silver)',
              icon: Icons.shield_rounded,
              iconColor: const Color(0xFF6B7A99),
              isActive: true, // They can upgrade to this
              limits: const {
                'Max Balance': '₦200,000',
                'Daily Transfer': '₦50,000',
              },
              requirements: const ['Verified BVN', 'National Identity Number (NIN)'],
              buttonLabel: 'Upgrade to Tier 2',
              onTap: () {
                // Navigate to Tier 2 KYC form
              },
            ),

            const SizedBox(height: 20),

            // Tier 3 Card
            _TierUpgradeCard(
              title: 'Tier 3 (Gold)',
              icon: Icons.workspace_premium_rounded,
              iconColor: const Color(0xFFF4A200),
              isActive: false, // Locked since they aren't Tier 2 yet
              limits: const {
                'Max Balance': 'Unlimited',
                'Daily Transfer': '₦1,000,000',
              },
              requirements: const [
                'Upgrade to Tier 2 first',
                'Valid Government ID',
                'Proof of Address',
              ],
              buttonLabel: 'Locked',
              onTap: null, // Disabled
            ),
            
            const SizedBox(height: 40), // Safe area
          ],
        ),
      ),
    );
  }
}

class _CurrentLimit extends StatelessWidget {
  final String label;
  final String value;

  const _CurrentLimit({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _TierUpgradeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isActive;
  final Map<String, String> limits;
  final List<String> requirements;
  final String buttonLabel;
  final VoidCallback? onTap;

  const _TierUpgradeCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isActive,
    required this.limits,
    required this.requirements,
    required this.buttonLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (!isActive)
                const Icon(
                  Icons.lock_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
            ],
          ),
          
          const SizedBox(height: 24),
          const Text(
            'Limits',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...limits.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      e.value,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              )),
          
          const SizedBox(height: 16),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),

          const Text(
            'Requirements',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isActive ? Icons.check_circle_rounded : Icons.circle_outlined,
                      size: 16,
                      color: isActive ? AppColors.success : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          
          const SizedBox(height: 24),
          
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  buttonLabel,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
