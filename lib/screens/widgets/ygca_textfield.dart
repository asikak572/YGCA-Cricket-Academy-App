import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/responsive/responsive_text.dart';

class YgcaTextField extends StatelessWidget {
  const YgcaTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.cursorColor,
    this.borderRadius = 16,
    this.contentPadding,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? cursorColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveFillColor =
        fillColor ?? theme.inputDecorationTheme.fillColor ?? theme.cardColor;

    final effectiveBorderColor =
        borderColor ?? theme.dividerColor.withOpacity(0.45);

    final effectiveFocusedBorderColor =
        focusedBorderColor ?? colorScheme.primary;

    final effectiveTextColor =
        textColor ?? theme.textTheme.bodyMedium?.color;

    final effectiveLabelColor =
        labelColor ?? theme.textTheme.bodySmall?.color;

    final effectiveHintColor =
        hintColor ?? theme.hintColor;

    final effectiveCursorColor =
        cursorColor ?? colorScheme.primary;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: obscureText ? 1 : maxLines,
      minLines: obscureText ? 1 : minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      cursorColor: effectiveCursorColor,
      style: TextStyle(
        fontFamily: ResponsiveText.fontFamily,
        fontSize: ResponsiveText.input(context),
        fontWeight: FontWeight.w600,
        color: effectiveTextColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null
            ? null
            : Icon(
                prefixIcon,
                color: colorScheme.primary,
              ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: effectiveFillColor,
        counterText: maxLength == null ? null : '',
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
        labelStyle: TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          fontSize: ResponsiveText.input(context),
          fontWeight: FontWeight.w600,
          color: effectiveLabelColor,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          fontSize: ResponsiveText.small(context),
          fontWeight: FontWeight.w700,
          color: effectiveFocusedBorderColor,
        ),
        hintStyle: TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          fontSize: ResponsiveText.bodySmall(context),
          fontWeight: FontWeight.w500,
          color: effectiveHintColor,
        ),
        errorStyle: TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          fontSize: ResponsiveText.small(context),
          fontWeight: FontWeight.w600,
          color: colorScheme.error,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: effectiveBorderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: effectiveBorderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: effectiveFocusedBorderColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: effectiveBorderColor.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
