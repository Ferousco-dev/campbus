import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Animated 6-dot code indicator with fill, error shake, and success states.
class CodeDots extends StatefulWidget {
  final int filledCount;
  final bool isError;
  final bool isSuccess;

  const CodeDots({
    super.key,
    required this.filledCount,
    this.isError = false,
    this.isSuccess = false,
  });

  @override
  State<CodeDots> createState() => CodeDotsState();
}

class CodeDotsState extends State<CodeDots> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late List<AnimationController> _scaleControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();

    // Shake animation
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 12, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));

    // Individual dot scale animations
    _scaleControllers = List.generate(6, (i) {
      return AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
    });
    _scaleAnimations = _scaleControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeOut));
    }).toList();
  }

  @override
  void didUpdateWidget(CodeDots oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger scale pop when a new dot fills
    if (widget.filledCount > oldWidget.filledCount && widget.filledCount <= 6) {
      final idx = widget.filledCount - 1;
      _scaleControllers[idx].forward(from: 0);
      HapticFeedback.lightImpact();
    }

    // Trigger shake on error
    if (widget.isError && !oldWidget.isError) {
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (final c in _scaleControllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// Programmatically trigger the shake animation (call from parent).
  void shake() {
    _shakeController.forward(from: 0);
    HapticFeedback.heavyImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (index) {
          final isFilled = index < widget.filledCount;
          final dotColor = widget.isError
              ? AppColors.error
              : widget.isSuccess
                  ? AppColors.success
                  : isFilled
                      ? AppColors.primary
                      : Colors.transparent;
          final borderColor = widget.isError
              ? AppColors.error
              : widget.isSuccess
                  ? AppColors.success
                  : isFilled
                      ? AppColors.primary
                      : AppColors.border;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 16),
            child: ScaleTransition(
              scale: _scaleAnimations[index],
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  border: Border.all(
                    color: borderColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
