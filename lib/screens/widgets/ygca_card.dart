import 'package:flutter/material.dart';

class YgcaCard extends StatelessWidget {
  const YgcaCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 18,
    this.elevation = 0,
    this.width,
    this.height,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  final Color? backgroundColor;
  final Color? borderColor;

  final double borderRadius;
  final double elevation;

  final double? width;
  final double? height;

  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor =
        backgroundColor ?? theme.cardColor;

    final effectiveBorderColor =
        borderColor ?? theme.dividerColor.withOpacity(0.35);

    final card = Material(
      color: effectiveBackgroundColor,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: clipBehavior,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: effectiveBorderColor,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (margin == null) {
      return card;
    }

    return Padding(
      padding: margin!,
      child: card,
    );
  }
}