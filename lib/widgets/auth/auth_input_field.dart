import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Styled TextFormField for auth screens with icon, focus glow, and error state.
class AuthInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final IconData prefixIcon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final String? errorText;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final Widget? prefix;
  final Widget? suffix;
  final int maxLines;

  const AuthInputField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.prefixIcon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasError => widget.errorText != null && widget.errorText!.isNotEmpty;

  Color get _borderColor {
    if (_hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.border;
  }

  Color get _iconColor {
    if (_hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.textMuted;
  }

  Color get _labelColor {
    if (_hasError) return AppColors.error;
    return AppColors.textSecondary;
  }

  Color get _bgColor {
    if (_hasError) return AppColors.errorBg;
    return AppColors.surface;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 8),

        // Input field
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _borderColor,
              width: _isFocused || _hasError ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused && !_hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    widget.prefixIcon,
                    size: 20,
                    color: _iconColor,
                  ),
                ),
              ],
              Expanded(
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  keyboardType: widget.keyboardType,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  onChanged: widget.onChanged,
                  maxLines: widget.maxLines,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                widget.suffix!,
                const SizedBox(width: 12),
              ],
            ],
          ),
        ),

        // Error text
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: const SizedBox(height: 4),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText ?? '',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
          crossFadeState: _hasError
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
        ),
      ],
    );
  }
}
