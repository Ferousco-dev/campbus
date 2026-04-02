import 'package:flutter/material.dart';
import '../../models/student_card_model.dart';
import '../../theme/app_theme.dart';

class CardInfoPanel extends StatelessWidget {
  final StudentCardModel card;

  const CardInfoPanel({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
            icon: Icons.badge_outlined,
            label: 'Student ID',
            value: card.studentId,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Department',
            value: card.department,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.layers_outlined,
            label: 'Level',
            value: card.level,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Session',
            value: card.session,
          ),
          _Divider(),
          _InfoRow(
            icon: Icons.credit_card_rounded,
            label: 'Card Status',
            value: card.isActive ? 'Active' : 'Inactive',
            valueColor: card.isActive ? AppColors.success : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.divider);
  }
}
