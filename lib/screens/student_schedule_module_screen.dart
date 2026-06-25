import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

import 'widgets/ygca_app_bar.dart';

import 'match_schedule_screen.dart';
import 'training_schedule_screen.dart';

class StudentScheduleModuleScreen extends StatelessWidget {
  const StudentScheduleModuleScreen({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
  }

  Color _border(bool isDark) {
    return isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  }

  Color _primaryText(bool isDark) {
    return isDark ? Colors.white : const Color(0xFF111827);
  }

  Color _secondaryText(bool isDark) {
    return isDark ? Colors.white60 : const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          appBar: const YgcaAppBar(title: "Schedule Module"),
          body: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _header(isDark),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                SliverToBoxAdapter(
                  child: _infoCard(isDark),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 18),
                ),
                SliverToBoxAdapter(
                  child: _sectionTitle("SCHEDULE ACCESS", isDark),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  sliver: SliverGrid(
                    delegate: SliverChildListDelegate(
                      [
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.sports_cricket_rounded,
                          title: "Match Schedule",
                          subtitle: "View upcoming matches",
                          color: const Color(0xFF8B5CF6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MatchScheduleScreen(),
                              ),
                            );
                          },
                        ),
                        _moduleCard(
                          context: context,
                          isDark: isDark,
                          icon: Icons.calendar_today_rounded,
                          title: "Training Schedule",
                          subtitle: "View academy training sessions",
                          color: const Color(0xFF0F766E),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TrainingScheduleScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.40),
                ]
              : [
                  maroon,
                  darkMaroon,
                  Colors.black.withOpacity(0.85),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -24,
            child: Icon(
              Icons.calendar_month_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 112,
            ),
          ),
          Column(
            children: [
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.30),
                  shape: BoxShape.circle,
                  border: Border.all(color: gold.withOpacity(0.85)),
                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.16),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: gold,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "SCHEDULE MODULE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "View your match schedule and training timetable",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.78),
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.42) : gold.withOpacity(0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: gold.withOpacity(0.16),
            child: Icon(
              Icons.info_outline_rounded,
              color: isDark ? gold : maroon,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Students can view match and training schedules. Schedule updates are controlled by Admin and Coach.",
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? gold : maroon,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: isDark ? red.withOpacity(0.45) : gold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moduleCard({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark ? color.withOpacity(0.34) : _border(isDark),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? color.withOpacity(0.14)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.62),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.26),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 27),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : color.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: isDark ? gold : maroon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}