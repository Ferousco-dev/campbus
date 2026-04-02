import 'package:flutter/material.dart';
import '../../models/wallet_models.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_utils.dart';

class SpendingChartCard extends StatefulWidget {
  final List<SpendingDataPoint> weeklyData;
  final List<SpendingDataPoint> monthlyData;

  const SpendingChartCard({
    super.key,
    required this.weeklyData,
    required this.monthlyData,
  });

  @override
  State<SpendingChartCard> createState() => _SpendingChartCardState();
}

class _SpendingChartCardState extends State<SpendingChartCard>
    with SingleTickerProviderStateMixin {
  bool _isWeekly = true;
  int? _hoveredIndex;
  late AnimationController _animController;
  late Animation<double> _chartAnimation;

  List<SpendingDataPoint> get _activeData =>
      _isWeekly ? widget.weeklyData : widget.monthlyData;

  double get _totalSpent =>
      _activeData.fold(0.0, (sum, point) => sum + point.amount);

  double get _maxAmount {
    double max = 0;
    for (final point in _activeData) {
      if (point.amount > max) max = point.amount;
    }
    return max == 0 ? 1 : max;
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePeriod(bool weekly) {
    if (_isWeekly == weekly) return;
    setState(() {
      _isWeekly = weekly;
      _hoveredIndex = null;
    });
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spending Overview',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${AppUtils.formatCurrency(_totalSpent)}',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Toggle
                _PeriodToggle(
                  isWeekly: _isWeekly,
                  onToggle: _togglePeriod,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Chart
            AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, _) {
                return SizedBox(
                  height: 160,
                  child: _buildChart(),
                );
              },
            ),

            // Hovered tooltip
            if (_hoveredIndex != null) ...[
              const SizedBox(height: 12),
              _ChartTooltip(
                dataPoint: _activeData[_hoveredIndex!],
                total: _totalSpent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        final chartHeight = constraints.maxHeight - 24; // space for labels
        final barCount = _activeData.length;
        final spacing = 8.0;
        final barWidth =
            (chartWidth - (spacing * (barCount - 1))) / barCount;

        return Column(
          children: [
            // Bars area
            SizedBox(
              height: chartHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(barCount, (index) {
                  final point = _activeData[index];
                  final heightFraction =
                      (point.amount / _maxAmount) * _chartAnimation.value;
                  final barHeight =
                      (chartHeight - 8) * heightFraction.clamp(0.0, 1.0);
                  final isHovered = _hoveredIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _hoveredIndex =
                              _hoveredIndex == index ? null : index;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: spacing / 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Amount label on hover
                            AnimatedOpacity(
                              duration:
                                  const Duration(milliseconds: 200),
                              opacity: isHovered ? 1.0 : 0.0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  AppUtils.formatCurrency(point.amount),
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            // Bar
                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              height: barHeight.clamp(4.0, chartHeight - 20),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(6),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: isHovered
                                      ? [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ]
                                      : [
                                          AppColors.primary
                                              .withOpacity(0.7),
                                          AppColors.primary
                                              .withOpacity(0.4),
                                        ],
                                ),
                                boxShadow: isHovered
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset:
                                              const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            // Labels row
            Row(
              children: List.generate(barCount, (index) {
                final isHovered = _hoveredIndex == index;
                return Expanded(
                  child: Center(
                    child: Text(
                      _activeData[index].label,
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: isHovered
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isHovered
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final bool isWeekly;
  final ValueChanged<bool> onToggle;

  const _PeriodToggle({
    required this.isWeekly,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleOption(
            label: 'Weekly',
            isActive: isWeekly,
            onTap: () => onToggle(true),
          ),
          _ToggleOption(
            label: 'Monthly',
            isActive: !isWeekly,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ChartTooltip extends StatelessWidget {
  final SpendingDataPoint dataPoint;
  final double total;

  const _ChartTooltip({required this.dataPoint, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage =
        total > 0 ? ((dataPoint.amount / total) * 100).toStringAsFixed(1) : '0';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            dataPoint.label,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '${AppUtils.formatCurrency(dataPoint.amount)}  ·  $percentage%',
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
