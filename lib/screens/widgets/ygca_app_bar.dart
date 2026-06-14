import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared YGCA-branded AppBar for module & sub-screens.
///
/// Premium design: maroon background, gold accent on back arrow,
/// subtle drop shadow for depth, white status bar icons.
///
/// Usage:
/// ```dart
/// appBar: const YgcaAppBar(title: "Attendance Module"),
/// ```
class YgcaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const YgcaAppBar({super.key, required this.title, this.actions});

  final String title;

  /// Optional trailing action widgets (e.g. filter, search icons).
  final List<Widget>? actions;

  static const Color _maroon = Color(0xFF7F0000);
  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _maroon,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AppBar(
        backgroundColor: _maroon,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,

        // Premium shadow via Material decoration
        shadowColor: Colors.black38,
        surfaceTintColor: Colors.transparent,

        // Back arrow in gold for premium look
        iconTheme: const IconThemeData(color: _gold, size: 22),

        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: 0.3,
          ),
        ),

        // Subtle bottom border for depth
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x00D4AF37),
                  Color(0x88D4AF37),
                  Color(0x00D4AF37),
                ],
              ),
            ),
          ),
        ),

        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}
