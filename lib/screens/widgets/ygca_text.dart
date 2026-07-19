import 'package:flutter/material.dart';

import '../../core/responsive/responsive_text.dart';
enum YgcaTextType {
  hero,
  heroSubtitle,
  pageTitle,
  heading,
  title,
  sectionTitle,
  cardTitle,
  cardSubtitle,
  body,
  bodySmall,
  small,
  tiny,
  caption,
  statValue,
  statLabel,
  button,
  bottomNav,
  input,
  dialogTitle,
  dialogBody,
}

class YgcaText extends StatelessWidget {
  const YgcaText(
    this.text, {
    super.key,
    this.type = YgcaTextType.body,
    this.style,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.height,
    this.letterSpacing,
    this.textDecoration,
    this.selectable = false,
    this.strutStyle,
    this.textDirection,
  });

  final String text;
  final YgcaTextType type;
  final TextStyle? style;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final double? height;
  final double? letterSpacing;
  final TextDecoration? textDecoration;
  final bool selectable;
  final StrutStyle? strutStyle;
  final TextDirection? textDirection;

  double _fontSize(BuildContext context) {
    switch (type) {
      case YgcaTextType.hero:
        return ResponsiveText.hero(context);
      case YgcaTextType.heroSubtitle:
        return ResponsiveText.heroSubtitle(context);
      case YgcaTextType.pageTitle:
        return ResponsiveText.pageTitle(context);
      case YgcaTextType.heading:
        return ResponsiveText.heading(context);
      case YgcaTextType.title:
        return ResponsiveText.title(context);
      case YgcaTextType.sectionTitle:
        return ResponsiveText.sectionTitle(context);
      case YgcaTextType.cardTitle:
        return ResponsiveText.cardTitle(context);
      case YgcaTextType.cardSubtitle:
        return ResponsiveText.cardSubtitle(context);
      case YgcaTextType.body:
        return ResponsiveText.body(context);
      case YgcaTextType.bodySmall:
        return ResponsiveText.bodySmall(context);
      case YgcaTextType.small:
        return ResponsiveText.small(context);
      case YgcaTextType.tiny:
        return ResponsiveText.tiny(context);
      case YgcaTextType.caption:
        return ResponsiveText.caption(context);
      case YgcaTextType.statValue:
        return ResponsiveText.statValue(context);
      case YgcaTextType.statLabel:
        return ResponsiveText.statLabel(context);
      case YgcaTextType.button:
        return ResponsiveText.button(context);
      case YgcaTextType.bottomNav:
        return ResponsiveText.bottomNav(context);
      case YgcaTextType.input:
        return ResponsiveText.input(context);
      case YgcaTextType.dialogTitle:
        return ResponsiveText.dialogTitle(context);
      case YgcaTextType.dialogBody:
        return ResponsiveText.dialogBody(context);
    }
  }

  TextStyle _defaultStyle(BuildContext context) {
    final theme = Theme.of(context);

    return TextStyle(
      fontFamily: ResponsiveText.fontFamily,
      fontSize: _fontSize(context),
      color: color ?? theme.textTheme.bodyMedium?.color,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
      decoration: textDecoration,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = _defaultStyle(context).merge(style);

    if (selectable) {
      return SelectableText(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        style: effectiveStyle,
        strutStyle: strutStyle,
        textDirection: textDirection,
      );
    }

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      style: effectiveStyle,
      strutStyle: strutStyle,
      textDirection: textDirection,
    );
  }
}
