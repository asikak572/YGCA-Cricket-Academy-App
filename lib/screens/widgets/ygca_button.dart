import 'package:flutter/material.dart';

import '../../core/responsive/responsive_text.dart';

enum YgcaButtonType {
  primary,
  secondary,
  outlined,
  text,
  danger,
}

class YgcaButton extends StatelessWidget {
  const YgcaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = YgcaButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height = 52,
    this.borderRadius = 16,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.elevation,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final YgcaButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? elevation;
  final TextStyle? textStyle;

  ButtonStyle _buttonStyle(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color resolvedBackground;
    Color resolvedForeground;
    Color resolvedBorder;
    double resolvedElevation;

    switch (type) {
      case YgcaButtonType.primary:
        resolvedBackground = backgroundColor ?? colorScheme.primary;
        resolvedForeground = foregroundColor ?? colorScheme.onPrimary;
        resolvedBorder = borderColor ?? Colors.transparent;
        resolvedElevation = elevation ?? 4;
        break;

      case YgcaButtonType.secondary:
        resolvedBackground = backgroundColor ?? colorScheme.secondary;
        resolvedForeground = foregroundColor ?? colorScheme.onSecondary;
        resolvedBorder = borderColor ?? Colors.transparent;
        resolvedElevation = elevation ?? 2;
        break;

      case YgcaButtonType.outlined:
        resolvedBackground = backgroundColor ?? Colors.transparent;
        resolvedForeground = foregroundColor ?? colorScheme.primary;
        resolvedBorder = borderColor ?? colorScheme.primary;
        resolvedElevation = elevation ?? 0;
        break;

      case YgcaButtonType.text:
        resolvedBackground = backgroundColor ?? Colors.transparent;
        resolvedForeground = foregroundColor ?? colorScheme.primary;
        resolvedBorder = borderColor ?? Colors.transparent;
        resolvedElevation = elevation ?? 0;
        break;

      case YgcaButtonType.danger:
        resolvedBackground = backgroundColor ?? colorScheme.error;
        resolvedForeground = foregroundColor ?? colorScheme.onError;
        resolvedBorder = borderColor ?? Colors.transparent;
        resolvedElevation = elevation ?? 4;
        break;
    }

    return ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return resolvedBackground.withOpacity(0.55);
        }
        return resolvedBackground;
      }),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return resolvedForeground.withOpacity(0.75);
        }
        return resolvedForeground;
      }),
      elevation: WidgetStatePropertyAll(resolvedElevation),
      padding: WidgetStatePropertyAll(
        padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: resolvedBorder,
            width: type == YgcaButtonType.outlined ? 1.4 : 0,
          ),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          fontSize: ResponsiveText.button(context),
          fontWeight: FontWeight.w800,
        ).merge(textStyle),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.pressed)) {
          return resolvedForeground.withOpacity(0.10);
        }
        return null;
      }),
    );
  }

  Widget _content(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: foregroundColor ?? Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    final textWidget = Flexible(
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );

    if (icon == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [textWidget],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        textWidget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    Widget button;

    switch (type) {
      case YgcaButtonType.outlined:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: _buttonStyle(context),
          child: _content(context),
        );
        break;

      case YgcaButtonType.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: _buttonStyle(context),
          child: _content(context),
        );
        break;

      case YgcaButtonType.primary:
      case YgcaButtonType.secondary:
      case YgcaButtonType.danger:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: _buttonStyle(context),
          child: _content(context),
        );
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: button,
    );
  }
}
