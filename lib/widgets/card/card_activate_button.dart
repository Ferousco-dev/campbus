import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

class CardActivateButton extends StatefulWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const CardActivateButton({
    super.key,
    required this.isActive,
    required this.onToggle,
  });

  @override
  State<CardActivateButton> createState() => _CardActivateButtonState();
}

class _CardActivateButtonState extends State<CardActivateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() async {
    HapticFeedback.mediumImpact();
    await _controller.forward();
    await _controller.reverse();
    widget.onToggle(!widget.isActive);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 54,
          decoration: BoxDecoration(
            gradient: widget.isActive
                ? const LinearGradient(
                    colors: [Color(0xFFFF4D4D), Color(0xFFCC1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF1A3FD8), Color(0xFF0A1F8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (widget.isActive ? AppColors.error : AppColors.primary)
                    .withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  widget.isActive ? Icons.block_rounded : Icons.nfc_rounded,
                  key: ValueKey(widget.isActive),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.isActive ? 'Deactivate Card' : 'Activate Card',
                  key: ValueKey(widget.isActive),
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
