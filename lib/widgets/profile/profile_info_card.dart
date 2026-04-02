import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final List<ProfileInfoRow> rows;

  const ProfileInfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _ProfileInfoTile(row: rows[i]),
            if (i < rows.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Divider(height: 1, color: AppColors.divider),
              ),
          ],
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final ProfileInfoRow row;

  const _ProfileInfoTile({required this.row});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: row.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            // Label
            Text(
              row.label,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // Value
            if (row.value != null)
              Text(
                row.value!,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: row.valueColor ?? AppColors.textPrimary,
                ),
              ),
            if (row.onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow {
  final String label;
  final String? value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const ProfileInfoRow({
    required this.label,
    this.value,
    this.valueColor,
    this.onTap,
  });
}
