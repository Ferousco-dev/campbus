import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Auth-specific AppBar with back arrow and optional "Skip for now" trailing button.
class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;

  const AuthAppBar({
    super.key,
    this.showBack = true,
    this.onBack,
    this.onSkip,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            )
          : null,
      actions: [
        if (onSkip != null)
          TextButton(
            onPressed: onSkip,
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
