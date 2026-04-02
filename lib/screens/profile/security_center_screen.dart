import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {
  bool _biometricEnabled = true;
  bool _loginAlertsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Security Center',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSecurityOption(
            icon: Icons.fingerprint_rounded,
            iconColor: const Color(0xFF00A36E),
            iconBg: const Color(0xFFE6FAF3),
            title: 'Biometric Login',
            subtitle: 'Use Face ID or Touch ID to log in',
            trailing: Switch.adaptive(
              value: _biometricEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _biometricEnabled = val);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSecurityOption(
            icon: Icons.notifications_active_rounded,
            iconColor: const Color(0xFFF4A200),
            iconBg: const Color(0xFFFFF8E6),
            title: 'Login Alerts',
            subtitle: 'Get notified of new logins',
            trailing: Switch.adaptive(
              value: _loginAlertsEnabled,
              activeColor: AppColors.primary,
              onChanged: (val) {
                setState(() => _loginAlertsEnabled = val);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildSecurityOption(
            icon: Icons.password_rounded,
            iconColor: const Color(0xFF9B5CF6),
            iconBg: const Color(0xFFF3EEFF),
            title: 'Change Transaction PIN',
            subtitle: 'Update your 4-digit security PIN',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _buildSecurityOption(
            icon: Icons.lock_reset_rounded,
            iconColor: const Color(0xFF0096C7),
            iconBg: const Color(0xFFE6F6FF),
            title: 'Change Password',
            subtitle: 'Update your account login password',
            onTap: () {},
          ),
          const SizedBox(height: 32),
          const Text(
            'Active Sessions',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.phone_android_rounded, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'iPhone 13 Pro',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lagos, Nigeria • Active now',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing
            else if (onTap != null)
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
