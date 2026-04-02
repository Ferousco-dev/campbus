import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

// ─── Admin Bar Chart ──────────────────────────────────────────────────────────
class AdminBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final String labelKey;
  final String valueKey;
  final double height;
  final Color? barColor;

  const AdminBarChart({
    super.key,
    required this.data,
    required this.labelKey,
    required this.valueKey,
    this.height = 120,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final max = data.fold<double>(
        0, (m, d) => (d[valueKey] as double) > m ? d[valueKey] as double : m);

    return SizedBox(
      height: height + 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((d) {
          final val = d[valueKey] as double;
          final ratio = max == 0 ? 0.0 : val / max;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Value label
                  Text(
                    val >= 1000 ? '₦${(val / 1000).toStringAsFixed(0)}K' : '₦${val.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 8,
                      color: AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    height: height * ratio.clamp(0.05, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          barColor ?? AppColors.primary,
                          (barColor ?? AppColors.primaryLight).withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Label
                  Text(
                    d[labelKey] as String,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
