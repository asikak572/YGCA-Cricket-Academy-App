import 'package:flutter/material.dart';

import '../../core/responsive/responsive_text.dart';

class YgcaDropdown<T> extends StatelessWidget {
  const YgcaDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
    this.hint,
    this.validator,
    this.enabled = true,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.borderRadius = 16,
    this.contentPadding,
    this.isExpanded = true,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  final IconData? prefixIcon;
  final String? hint;
  final String? Function(T?)? validator;

  final bool enabled;
  final bool isExpanded;

  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;

  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveFillColor =
        fillColor ??
        theme.inputDecorationTheme.fillColor ??
        theme.cardColor;

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

    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      dropdownColor: theme.cardColor,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: colorScheme.primary,
      ),
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
        filled: true,
        fillColor: effectiveFillColor,
        contentPadding:
            contentPadding ??
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
      selectedItemBuilder: (context) {
        return items.map((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: ResponsiveText.fontFamily,
                fontSize: ResponsiveText.input(context),
                fontWeight: FontWeight.w600,
                color: effectiveTextColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: item.child,
            ),
          );
        }).toList();
      },
    );
  }
}