import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

/// Custom numeric keypad for auth code entry screens.
/// Shows digits 1-9, 0, optional biometric button, and backspace.
class AuthKeypad extends StatelessWidget {
  final ValueChanged<int> onDigitTap;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool enabled;

  const AuthKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspace,
    this.onBiometric,
    this.enabled = true,
  });

  static const List<List<String>> _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['bio', '0', 'del'],
  ];

  static const Map<String, String> _subLabels = {
    '1': '',
    '2': 'ABC',
    '3': 'DEF',
    '4': 'GHI',
    '5': 'JKL',
    '6': 'MNO',
    '7': 'PQRS',
    '8': 'TUV',
    '9': 'WXYZ',
    '0': '',
  };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          children: _keys.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: row.map((key) {
                  return Expanded(child: _buildKey(key));
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key == 'bio') {
      if (onBiometric == null) return const SizedBox(height: 64);
      return _KeyButton(
        onTap: () {
          HapticFeedback.mediumImpact();
          onBiometric!();
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.fingerprint,
            size: 28,
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (key == 'del') {
      return _KeyButton(
        onTap: () {
          HapticFeedback.lightImpact();
          onBackspace();
        },
        child: const Icon(
          Icons.backspace_outlined,
          size: 22,
          color: AppColors.textSecondary,
        ),
      );
    }

    // Digit key
    final digit = int.parse(key);
    final subLabel = _subLabels[key] ?? '';

    return _KeyButton(
      onTap: () {
        HapticFeedback.lightImpact();
        onDigitTap(digit);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: 'Sora',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          if (subLabel.isNotEmpty)
            Text(
              subLabel,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 9,
                fontWeight: FontWeight.w400,
                color: AppColors.textMuted,
                letterSpacing: 2.0,
                height: 1.4,
              ),
            )
          else
            const SizedBox(height: 13),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeyButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primarySurface,
        highlightColor: AppColors.primarySurface.withOpacity(0.3),
        child: SizedBox(
          height: 64,
          child: Center(child: child),
        ),
      ),
    );
  }
}
