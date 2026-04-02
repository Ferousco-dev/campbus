import 'package:flutter/material.dart';
import '../../models/student_card_model.dart';
import '../../theme/app_theme.dart';

class StudentCardFront extends StatelessWidget {
  final StudentCardModel card;

  const StudentCardFront({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A3FD8),
            Color(0xFF0F2AA0),
            Color(0xFF0A1C8A),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.40),
            blurRadius: 30,
            offset: const Offset(0, 14),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative background circles
          Positioned(
            top: -28,
            right: -24,
            child: _Circle(size: 120, opacity: 0.07),
          ),
          Positioned(
            bottom: -36,
            left: -16,
            child: _Circle(size: 140, opacity: 0.05),
          ),
          Positioned(
            top: 50,
            right: 60,
            child: _Circle(size: 55, opacity: 0.06),
          ),

          // Subtle grid lines
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),

          // Active indicator strip (top)
          if (card.isActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C6AE), Color(0xFF00E6C8)],
                  ),
                ),
              ),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row — logo + status badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.directions_bus_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'CampusRide',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    _StatusBadge(isActive: card.isActive),
                  ],
                ),

                const Spacer(),

                // Card number
                Text(
                  card.cardNumber,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Bottom row — name + ID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARD HOLDER',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.fullName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'STUDENT ID',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.studentId,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

// ──────────────────────────────────────────────
// Back side of the card
// ──────────────────────────────────────────────

class StudentCardBack extends StatelessWidget {
  final StudentCardModel card;

  const StudentCardBack({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: const Color(0xFF0D1B6E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -20,
            child: _Circle(size: 110, opacity: 0.06),
          ),
          Positioned(
            bottom: -30,
            right: -10,
            child: _Circle(size: 130, opacity: 0.05),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Magnetic strip
              Container(
                height: 48,
                margin: const EdgeInsets.only(top: 28),
                color: Colors.black.withOpacity(0.45),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BackInfoRow(label: 'Faculty', value: card.faculty),
                    const SizedBox(height: 8),
                    _BackInfoRow(label: 'Department', value: card.department),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _BackInfoRow(label: 'Level', value: card.level),
                        ),
                        Expanded(
                          child: _BackInfoRow(label: 'Session', value: card.session),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isActive;
  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF00C6AE).withOpacity(0.18)
            : Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00C6AE).withOpacity(0.5)
              : Colors.white.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFF00C6AE) : Colors.white38,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF00C6AE) : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _BackInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 8,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 2),
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

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
