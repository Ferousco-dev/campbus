import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/auth/auth_service.dart';
import '../services/user/user_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/profile/profile_app_bar.dart';
import '../widgets/profile/profile_header_card.dart';
import '../widgets/profile/profile_info_card.dart';
import '../widgets/profile/profile_menu_section.dart';
import '../widgets/profile/profile_logout_button.dart';
import 'profile/edit_nickname_screen.dart';
import 'profile/edit_address_screen.dart';
import 'transactions_screen.dart';
import 'profile/security_center_screen.dart';
import 'profile/customer_service_screen.dart';
import 'profile/invite_friends_screen.dart';
import 'admin/admin_shell.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _tierLabel(String? value) {
    switch (value) {
      case 'tier2':
        return 'Tier 2';
      case 'tier3':
        return 'Tier 3';
      case 'tier1':
      default:
        return 'Tier 1';
    }
  }

  bool _canUpgradeTier(String? value) => value != 'tier3';

  DateTime? _dateFromFirestore(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'Not set';
    return DateFormat('MMM d, yyyy').format(value);
  }

  String _displayValue(String? value) {
    if (value == null) return 'Not set';
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not set' : trimmed;
  }

  bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;

  String _addressText(Map<String, dynamic>? address) {
    final street = (address?['street'] as String?)?.trim() ?? '';
    final cityState = (address?['cityState'] as String?)?.trim() ?? '';
    if (street.isEmpty && cityState.isEmpty) return 'Not set';
    if (street.isEmpty) return cityState;
    if (cityState.isEmpty) return street;
    return '$street, $cityState';
  }

  void _showRatingDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFFF6B35),
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enjoying Campus Wallet?',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap a star to rate it on the App Store.',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Thanks for your rating!',
                              style: TextStyle(fontFamily: 'Sora', fontSize: 13),
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          ),
                        );
                      },
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFF6B35),
                        size: 40,
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVerificationStatus(BuildContext context, String title, String value, bool isVerified) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  isVerified ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  color: isVerified ? AppColors.success : AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isVerified ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVerified ? Icons.verified_user_rounded : Icons.error_outline_rounded,
                        color: isVerified ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isVerified ? 'Verified Account' : 'Unverified Account',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontWeight: FontWeight.w600,
                          color: isVerified ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Please sign in to view your profile.',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserProfileService.userStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final data = snapshot.data?.data() ?? {};
          final fullNameRaw =
              data['fullName'] as String? ?? user.displayName ?? '';
          final nicknameRaw = data['nickname'] as String?;
          final fullName = _displayValue(fullNameRaw);
          final nickname = _displayValue(
              nicknameRaw ?? (fullNameRaw.isNotEmpty ? fullNameRaw.split(' ').first : ''));
          final greetingName = _hasValue(nicknameRaw)
              ? nicknameRaw!.trim()
              : (fullNameRaw.isNotEmpty
                  ? fullNameRaw.split(' ').first
                  : 'User');
          final studentId = _displayValue(
              data['studentId'] as String? ??
                  data['matricNumber'] as String?);
          final tierValue = data['tier'] as String? ?? 'tier1';
          final phoneRaw = data['phone'] as String?;
          final phone = _displayValue(phoneRaw);
          final gender = _displayValue(data['gender'] as String?);
          final dob = _formatDate(_dateFromFirestore(data['dateOfBirth']));
          final emailRaw = data['email'] as String? ?? user.email;
          final email = _displayValue(emailRaw);
          final addressText =
              _addressText(data['address'] as Map<String, dynamic>?);
          final isEmailVerified =
              data['isEmailVerified'] as bool? ?? user.emailVerified;
          final isPhoneVerified = data['isVerified'] as bool? ?? false;
          final role = (data['role'] as String?) ?? 'user';
          final isAdmin = role == 'superAdmin' ||
              role == 'moderator' ||
              role == 'supportAgent' ||
              role == 'shopManager';

          final accountItems = <ProfileMenuItem>[
            if (isAdmin)
              ProfileMenuItem(
                icon: Icons.admin_panel_settings_rounded,
                iconColor: const Color(0xFF1A3FD8),
                iconBg: const Color(0xFFEEF2FF),
                label: 'Admin Panel',
                sublabel: 'Manage app data & users',
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminShell()),
                  );
                },
              ),
            ProfileMenuItem(
              icon: Icons.receipt_long_rounded,
              label: 'Transaction History',
              sublabel: 'View all your transactions',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TransactionsScreen()),
                );
              },
            ),
          ];

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: ProfileAppBar(
              name: greetingName,
              onSettingsTap: isAdmin
                  ? () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdminShell()),
                      );
                    }
                  : null,
            ),
            body: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 36),
              children: [
                const SizedBox(height: 20),

                // Header card
                ProfileHeaderCard(
                  name: fullName,
                  studentId: studentId,
                  tier: _tierLabel(tierValue),
                  canUpgrade: _canUpgradeTier(tierValue),
                ),

            const SizedBox(height: 20),

            // Personal details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Personal Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),

            const SizedBox(height: 12),

            ProfileInfoCard(
              rows: [
                ProfileInfoRow(
                  label: 'Full Name',
                  value: fullName,
                ),
                ProfileInfoRow(
                  label: 'Mobile Number',
                  value: phone,
                  onTap: _hasValue(phoneRaw)
                      ? () {
                          HapticFeedback.lightImpact();
                          _showVerificationStatus(
                            context,
                            'Mobile Number',
                            phone,
                            isPhoneVerified,
                          );
                        }
                      : null,
                ),
                ProfileInfoRow(
                  label: 'Nickname',
                  value: nickname,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditNicknameScreen(currentNickname: nicknameRaw ?? ''),
                      ),
                    );
                  },
                ),
                ProfileInfoRow(
                  label: 'Gender',
                  value: gender,
                ),
                ProfileInfoRow(
                  label: 'Date of Birth',
                  value: dob,
                ),
                ProfileInfoRow(
                  label: 'Email',
                  value: email,
                  onTap: _hasValue(emailRaw)
                      ? () {
                          HapticFeedback.lightImpact();
                          _showVerificationStatus(
                            context,
                            'Email Address',
                            email,
                            isEmailVerified,
                          );
                        }
                      : null,
                ),
                ProfileInfoRow(
                  label: 'Address',
                  value: addressText,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditAddressScreen(
                          currentStreet:
                              (data['address'] as Map<String, dynamic>?)?['street']
                                      as String? ??
                                  '',
                          currentCityState:
                              (data['address'] as Map<String, dynamic>?)?['cityState']
                                      as String? ??
                                  '',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Account section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),

            const SizedBox(height: 12),

            ProfileMenuSection(
              items: accountItems,
            ),

            const SizedBox(height: 20),

            // Support section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Support & More',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),

            const SizedBox(height: 12),

            ProfileMenuSection(
              items: [
                ProfileMenuItem(
                  icon: Icons.security_rounded,
                  iconColor: const Color(0xFF00A36E),
                  iconBg: const Color(0xFFE6FAF3),
                  label: 'Security Center',
                  sublabel: 'Protect your funds',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SecurityCenterScreen()),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.headset_mic_rounded,
                  iconColor: const Color(0xFF0096C7),
                  iconBg: const Color(0xFFE6F6FF),
                  label: 'Customer Service',
                  sublabel: 'Get help anytime',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerServiceScreen()),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.card_giftcard_rounded,
                  iconColor: const Color(0xFFF4A200),
                  iconBg: const Color(0xFFFFF8E6),
                  label: 'Invite Friends',
                  sublabel: 'Earn bonus on referrals',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InviteFriendsScreen()),
                    );
                  },
                ),
                ProfileMenuItem(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFF6B35),
                  iconBg: const Color(0xFFFFF1EC),
                  label: 'Rate Us',
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showRatingDialog(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Logout
            ProfileLogoutButton(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => _LogoutDialog(),
                );
              },
            ),

            const SizedBox(height: 16),

            // Version
            Center(
              child: Text(
                'Campus Wallet v1.0.0',
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Log Out',
        style: TextStyle(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontSize: 17,
        ),
      ),
      content: const Text(
        'Are you sure you want to log out of your account?',
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
            'Cancel',
            style: TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // Close dialog
            await AuthService.signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
          child: const Text(
            'Log Out',
            style: TextStyle(
              fontFamily: 'Sora',
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
