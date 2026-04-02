import 'package:flutter/material.dart';
import 'student_card_widget.dart';

class StackedCardsDisplay extends StatelessWidget {
  final String studentName;
  final String studentId;
  final String course;
  final String level;
  final bool isActive;

  const StackedCardsDisplay({
    super.key,
    required this.studentName,
    required this.studentId,
    required this.course,
    required this.level,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Back card — rotated, bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            child: Transform.rotate(
              angle: -0.06,
              child: Opacity(
                opacity: isActive ? 1.0 : 0.5,
                child: StudentCardWidget(
                  studentName: studentName,
                  studentId: studentId,
                  course: course,
                  level: level,
                  isActive: isActive,
                  variant: CardVariant.secondary,
                ),
              ),
            ),
          ),

          // Front card — rotated, top-right
          Positioned(
            top: 0,
            right: 0,
            child: Transform.rotate(
              angle: 0.04,
              child: StudentCardWidget(
                studentName: studentName,
                studentId: studentId,
                course: course,
                level: level,
                isActive: isActive,
                variant: CardVariant.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
