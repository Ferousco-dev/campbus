import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CardStatusInfo extends StatelessWidget {
  final bool isActive;

  const CardStatusInfo({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.nfc_rounded,
            iconColor: AppColors.primary,
            iconBg: AppColors.primarySurface,
            label: 'NFC Transport',
            value: isActive ? 'Ready to scan' : 'Disabled',
            valueColor: isActive ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.credit_card_rounded,
            iconColor: const Color(0xFF9B5CF6),
            iconBg: const Color(0xFFF3EEFF),
            label: 'Card Type',
            value: 'Student Transport ID',
            valueColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.security_rounded,
            iconColor: const Color(0xFF00A36E),
            iconBg: const Color(0xFFE6FAF3),
            label: 'Security',
            value: 'PIN Protected',
            valueColor: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
