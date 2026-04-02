import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ─── Admin Section Header ─────────────────────────────────────────────────────
class AdminSectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const AdminSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (action != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              action!,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Admin Status Chip ────────────────────────────────────────────────────────
class AdminStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AdminStatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Sora',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── Admin Table Row ──────────────────────────────────────────────────────────
class AdminTableRow extends StatelessWidget {
  final List<String> cells;
  final List<double> flex;
  final bool isHeader;
  final VoidCallback? onTap;

  const AdminTableRow({
    super.key,
    required this.cells,
    required this.flex,
    this.isHeader = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isHeader ? AppColors.background : Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: List.generate(cells.length, (i) {
            return Expanded(
              flex: (flex[i] * 10).toInt(),
              child: Text(
                cells[i],
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: isHeader ? 11 : 13,
                  fontWeight:
                      isHeader ? FontWeight.w700 : FontWeight.w400,
                  color: isHeader ? AppColors.textMuted : AppColors.textPrimary,
                  letterSpacing: isHeader ? 0.5 : 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Admin Search Bar ─────────────────────────────────────────────────────────
class AdminSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const AdminSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontFamily: 'Sora',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

// ─── Admin Action Button ──────────────────────────────────────────────────────
class AdminActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final bool outlined;

  const AdminActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : c,
          borderRadius: BorderRadius.circular(10),
          border: outlined ? Border.all(color: c) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: outlined ? c : Colors.white),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: outlined ? c : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
