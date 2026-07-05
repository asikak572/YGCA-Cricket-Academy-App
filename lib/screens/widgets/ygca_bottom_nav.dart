import 'package:flutter/material.dart';

import '../../theme/theme_controller.dart';

class YgcaBottomNavItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const YgcaBottomNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class YgcaBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<YgcaBottomNavItem> items;

  const YgcaBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
  });

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  Color _navBg(bool isDark) {
    return isDark ? const Color(0xFF101010) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? red.withOpacity(0.28) : const Color(0xFFE5E7EB);
  }

  Color _inactive(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final bottomInset = MediaQuery.of(context).padding.bottom;

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              height: bottomInset > 0 ? 72 : 76,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              decoration: BoxDecoration(
                color: _navBg(isDark),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _border(isDark)),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? red.withOpacity(0.16)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final selected = index == currentIndex;

                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: item.onTap,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: selected
                              ? red.withOpacity(isDark ? 0.22 : 0.10)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                          border: selected
                              ? Border.all(
                                  color:
                                      red.withOpacity(isDark ? 0.55 : 0.25),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              color: selected ? red : _inactive(isDark),
                              size: selected ? 24 : 22,
                            ),
                            const SizedBox(height: 3),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label,
                                maxLines: 1,
                                style: TextStyle(
                                  color: selected ? red : _inactive(isDark),
                                  fontSize: 10,
                                  fontWeight: selected
                                      ? FontWeight.w900
                                      : FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}