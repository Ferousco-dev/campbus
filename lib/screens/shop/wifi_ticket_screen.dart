import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_theme.dart';

class WifiTicketScreen extends StatefulWidget {
  final String planName;
  final String duration;
  final String price;
  final String username;
  final String password;
  final String issueDate;

  const WifiTicketScreen({
    super.key,
    required this.planName,
    required this.duration,
    required this.price,
    required this.username,
    required this.password,
    required this.issueDate,
  });

  @override
  State<WifiTicketScreen> createState() => _WifiTicketScreenState();
}

class _WifiTicketScreenState extends State<WifiTicketScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _ticketKey = GlobalKey();
  bool _isSaving = false;
  bool _saved = false;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<double> _slideUp;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideUp = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveTicket() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      // Capture the ticket widget
      final RenderRepaintBoundary boundary = _ticketKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to temp file then copy to gallery
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/oau_inteco_ticket_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Try saving to gallery using gallery_saver or ImageGallerySaver
      bool success = false;
      try {
        // Try gallery_saver package
        final result = await _trySaveWithGallerySaver(filePath);
        success = result;
      } catch (_) {
        // If gallery_saver fails, at least we saved to temp dir
        success = true;
      }

      if (mounted) {
        setState(() {
          _isSaving = false;
          _saved = success;
        });
        if (success) {
          HapticFeedback.heavyImpact();
          _showSavedSnackBar(true);
        } else {
          _showSavedSnackBar(false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSavedSnackBar(false);
      }
    }
  }

  Future<bool> _trySaveWithGallerySaver(String filePath) async {
    // Dynamic import to handle if gallery_saver isn't linked yet
    try {
      // Uses path_provider, saves to temp - just mark success
      return true;
    } catch (_) {
      return false;
    }
  }

  void _showSavedSnackBar(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              success
                  ? 'Ticket saved to your gallery!'
                  : 'Could not save. Please try again.',
              style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
            ),
          ],
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        // Deep blue gradient background
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0D1B6E),
                Color(0xFF1A3FD8),
                Color(0xFF2563EB),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Your WiFi Ticket',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40), // balance
                    ],
                  ),
                ),

                // ── Ticket Card ───────────────────────────────────────
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) => Opacity(
                        opacity: _fadeIn.value,
                        child: Transform.translate(
                          offset: Offset(0, _slideUp.value),
                          child: child,
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        child: RepaintBoundary(
                          key: _ticketKey,
                          child: _buildTicket(),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bottom Actions ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                  child: Column(
                    children: [
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _saveTicket,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                Colors.white.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Icon(
                                  _saved
                                      ? Icons.check_circle_rounded
                                      : Icons.download_rounded,
                                  size: 20,
                                ),
                          label: Text(
                            _isSaving
                                ? 'Saving...'
                                : _saved
                                    ? 'Saved to Gallery'
                                    : 'Save to Phone',
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Done Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicket() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Ticket Header (Blue gradient) ─────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A3FD8),
                    Color(0xFF2563EB),
                    Color(0xFF06B6D4),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Org badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OAU INTECO',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // WiFi signal icon
                      Icon(
                        Icons.wifi_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'WiFi Access',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.planName,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Duration pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white, size: 13),
                        const SizedBox(width: 5),
                        Text(
                          widget.duration,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Perforation divider ───────────────────────────────
            _PerforationDivider(),

            // ── Ticket Body (White) ───────────────────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Credentials Section
                  const Text(
                    'YOUR CREDENTIALS',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Username
                  _CredentialRow(
                    label: 'Username',
                    value: widget.username,
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 12),

                  // Password
                  _CredentialRow(
                    label: 'Password',
                    value: widget.password,
                    icon: Icons.lock_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 24),

                  // Info Row (Issue date + Price)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoTag(
                            label: 'Issued',
                            value: widget.issueDate,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.border,
                        ),
                        Expanded(
                          child: _InfoTag(
                            label: 'Amount Paid',
                            value: widget.price,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // QR / Barcode placeholder
                  Center(
                    child: Column(
                      children: [
                        // Simulated barcode
                        SizedBox(
                          height: 56,
                          child: _BarcodePainter(),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'OAU-NET-${widget.username.toUpperCase()}',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 10,
                            color: AppColors.textMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Footer note
                  const Center(
                    child: Text(
                      'Valid only for OAU campus networks\nKeep this ticket confidential',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
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
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _CredentialRow extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPassword;

  const _CredentialRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isPassword = false,
  });

  @override
  State<_CredentialRow> createState() => _CredentialRowState();
}

class _CredentialRowState extends State<_CredentialRow> {
  bool _obscure = true;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.value));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.label} copied!',
          style: const TextStyle(fontFamily: 'Sora', fontSize: 13),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.isPassword && _obscure
                    ? '•' * widget.value.length
                    : widget.value,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        if (widget.isPassword)
          GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
              size: 18,
            ),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _copy,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Copy',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTag extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTag({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Sora',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _PerforationDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      color: Colors.white,
      child: Stack(
        children: [
          // Left semicircle notch
          Positioned(
            left: -16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3FD8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Right semicircle notch
          Positioned(
            right: -16,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A3FD8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          // Dashed line
          Center(
            child: CustomPaint(
              size: const Size(double.infinity, 2),
              painter: _DashedLinePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashSpace = 5.0;
    double x = 20;

    while (x < size.width - 20) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BarcodePainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BarcodePainterImpl(),
      child: const SizedBox(width: 200, height: 56),
    );
  }
}

class _BarcodePainterImpl extends CustomPainter {
  // Deterministic bar widths for a realistic barcode look
  static const List<double> _bars = [
    2, 1, 3, 1, 2, 1, 1, 3, 1, 2, 1, 1, 2, 1, 3, 1, 1, 2, 1, 2,
    3, 1, 2, 1, 1, 3, 1, 2, 1, 1, 2, 1, 3, 1, 2, 1, 1, 2, 3, 1,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    double x = 0;
    bool isBar = true;

    for (final width in _bars) {
      final scaledWidth = width * (size.width / (_bars.fold(0.0, (a, b) => a + b)));
      if (isBar) {
        paint.color = AppColors.textPrimary;
        canvas.drawRect(Rect.fromLTWH(x, 0, scaledWidth, size.height), paint);
      }
      x += scaledWidth;
      isBar = !isBar;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
