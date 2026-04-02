import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum CardVariant { primary, secondary }

class StudentCardWidget extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String course;
  final String level;
  final bool isActive;
  final CardVariant variant;

  const StudentCardWidget({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.course,
    required this.level,
    required this.isActive,
    this.variant = CardVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == CardVariant.primary;

    return Container(
      width: 260,
      height: 155,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isPrimary
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A3FD8),
                  Color(0xFF0A1F8F),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B6E),
                  Color(0xFF1A3FD8),
                ],
              ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(isPrimary ? 0.4 : 0.25),
            blurRadius: isPrimary ? 28 : 20,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),

          // Card chip
          Positioned(
            top: 18,
            left: 18,
            child: Container(
              width: 34,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD166),
                borderRadius: BorderRadius.circular(5),
              ),
              child: CustomPaint(
                painter: _ChipPainter(),
              ),
            ),
          ),

          // Status dot
          Positioned(
            top: 18,
            right: 18,
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? const Color(0xFF00C6AE)
                        : Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Card content
          Positioned(
            bottom: 18,
            left: 18,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  studentId,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _CardLabel(label: 'Course', value: course),
                    _CardLabel(label: 'Level', value: level, alignEnd: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _CardLabel({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.45),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0B429)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Horizontal lines
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
    // Vertical line center
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
  }

  @override
  bool shouldRepaint(_ChipPainter oldDelegate) => false;
}
