import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animController;
  bool _showTagline = false;

  @override
  void initState() {
    super.initState();
    // Use an animation controller that goes forward and back to create a continuous "pulse" and "float" motion
    _animController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _playAnimation();
  }

  void _playAnimation() async {
    // Show the tagline shortly after init
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _showTagline = true);

    // Wait and then route
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, 
      ),
      child: Scaffold(
        // Solid blue exactly standard to the app theme
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // Floating geometric UI / Icons in background
            _buildBackgroundItem(Icons.directions_bus_rounded, -40, 100, 160, 0.05, 0.2),
            _buildBackgroundItem(Icons.credit_card_rounded, 250, 480, 200, 0.03, -0.1),
            _buildBackgroundItem(Icons.confirmation_num_rounded, -60, 620, 140, 0.04, 0.15),
            _buildBackgroundItem(Icons.local_taxi_rounded, 280, 80, 110, 0.02, -0.2),
            
            // Main Centerpiece
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing Logo
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      // Pulse smoothly between 0.95 and 1.05
                      final scale = 0.95 + (_animController.value * 0.1);
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 28),
                  
                  // Text with Sweep/Shimmer effect
                  const ShimmerText(
                    text: 'Campus Wallet',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),
                  
                  // Tagline fades in
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeIn,
                    opacity: _showTagline ? 1.0 : 0.0,
                    child: Text(
                      'Your ride, your wallet.',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundItem(IconData icon, double baseX, double baseY, double size, double speed, double angle) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        // Combine panning and subtle bouncing
        final dx = baseX + (_animController.value * 50 * speed * 20); 
        final dy = baseY + (math.sin(_animController.value * math.pi) * 15 * speed * 10);
        return Positioned(
          left: dx,
          top: dy,
          child: Transform.rotate(
            angle: angle,
            child: child!,
          ),
        );
      },
      child: Icon(
        icon,
        size: size,
        color: Colors.white.withOpacity(0.04), // Exceptionally subtle watermark look
      ),
    );
  }
}

// Custom Shimmer Widget for text effect
class ShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ShimmerText({super.key, required this.text, required this.style});

  @override
  State<ShimmerText> createState() => _ShimmerTextState();
}

class _ShimmerTextState extends State<ShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final slide = _shimmerController.value;
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.6), 
                Colors.white, 
                Colors.white.withOpacity(0.6)
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: const Alignment(-1.5, 0),
              end: const Alignment(1.5, 0),
              // Drive the gradient horizontally
              transform: _SlidingGradientTransform(slidePercent: slide),
            ).createShader(bounds);
          },
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Width translation maps slidePercent (0 to 1) from -0.5 width to +1.5 width
    final dx = bounds.width * (slidePercent * 2 - 0.5);
    return Matrix4.translationValues(dx, 0, 0);
  }
}
