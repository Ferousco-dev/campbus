import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Segmented gender toggle (Male / Female) for the registration form.
class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: hasError ? AppColors.error : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _GenderChip(
                label: 'Male',
                icon: Icons.male_rounded,
                isSelected: selectedGender == 'Male',
                hasError: hasError,
                onTap: () => onChanged('Male'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderChip(
                label: 'Female',
                icon: Icons.female_rounded,
                isSelected: selectedGender == 'Female',
                hasError: hasError,
                onTap: () => onChanged('Female'),
              ),
            ),
          ],
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(height: 4),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  errorText ?? '',
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          crossFadeState:
              hasError ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool hasError;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        height: 50,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError && !isSelected
                ? AppColors.error.withOpacity(0.5)
                : isSelected
                    ? AppColors.primary
                    : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
