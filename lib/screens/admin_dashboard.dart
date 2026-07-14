import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/ygca_drawer.dart';
import 'widgets/ygca_bottom_nav.dart';
import '../theme/theme_controller.dart';

import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_spacing.dart';
import '../core/responsive/responsive_grid.dart';
import '../core/responsive/responsive_size.dart';
import '../core/responsive/responsive_radius.dart';
import '../core/responsive/responsive_text.dart';

import 'student_list_screen.dart';
import '../core/language/app_strings.dart';
import 'notification_screen.dart';
import 'reports_dashboard_screen.dart';
import 'attendance_module_screen.dart';
import 'fee_module_screen.dart';
import 'coach_module_screen.dart';
import 'schedule_module_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);
  String _timeGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return AppStrings.goodMorning;
  } else if (hour < 17) {
    return AppStrings.goodAfternoon;
  } else {
    return AppStrings.goodEvening;
  }
}

  static const String logoAsset = 'assets/images/ygca_logo.jpg';

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _open(Widget screen) {
    _scaffoldKey.currentState?.closeDrawer();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Color _bg(bool isDark) {
    return isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  }

  Color _card(bool isDark) {
    return isDark ? const Color(0xFF111111) : Colors.white;
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
        return ValueListenableBuilder<String>(
          valueListenable: ThemeController.language,
          builder: (context, language, __) {
            final isDark = mode == ThemeMode.dark;

            return Scaffold(
          key: _scaffoldKey,
          backgroundColor: _bg(isDark),
          drawer: YgcaDrawer(
            role: 'Admin',
            username: AppStrings.adminUser,
            onLogout: _logout,
          ),
          body: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.maxContentWidth(context),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        children: [
                          _topBar(isDark),
                          _heroCard(isDark),
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          _sectionTitle(
                            title: AppStrings.academyOverview,
                            isDark: isDark,
                            showViewAll: true,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  ResponsivePadding.horizontal(context),
                            ),
                            child: GridView.count(
                              crossAxisCount:
                                  ResponsiveGrid.dashboardCount(context),
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  ResponsiveGrid.dashboardCardRatio(context),
                              children: [
                                _overviewCard(
                                  isDark: isDark,
                                  icon: Icons.groups_rounded,
                                  title: AppStrings.totalStudents,
                                  value: "248",
                                  subtitle: AppStrings.registeredPlayers,
                                  color: red,
                                ),
                                _overviewCard(
                                  isDark: isDark,
                                  icon: Icons.verified_rounded,
                                  title: AppStrings.attendance,
                                  value: "75%",
                                  subtitle: AppStrings.todayAverage,
                                  color: Colors.green,
                                ),
                                _overviewCard(
                                  isDark: isDark,
                                  icon: Icons.receipt_long_rounded,
                                  title: AppStrings.pendingFees,
                                  value: "₹2.45L",
                                  subtitle: AppStrings.students28,
                                  color: Colors.orange,
                                ),
                                _overviewCard(
                                  isDark: isDark,
                                  icon: Icons.calendar_month_rounded,
                                  title: AppStrings.sessions,
                                  value: "6",
                                  subtitle: AppStrings.thisWeek,
                                  color: Colors.purpleAccent,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: ResponsiveSpacing.medium(context)),
                          _sectionTitle(
                            title: AppStrings.quickActions,
                            isDark: isDark,
                            showViewAll: false,
                          ),
                          _quickActions(isDark),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: YgcaBottomNav(
            currentIndex: 0,
            items: [
              YgcaBottomNavItem(
                icon: Icons.home_rounded,
                label: AppStrings.home,
                onTap: () {},
              ),
              YgcaBottomNavItem(
                icon: Icons.people_rounded,
                label: AppStrings.students,
                onTap: () => _open(const StudentListScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.fact_check_rounded,
                label: AppStrings.attendance,
                onTap: () => _open(const AttendanceModuleScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.calendar_month_rounded,
                label: AppStrings.schedule,
                onTap: () => _open(const ScheduleModuleScreen()),
              ),
              YgcaBottomNavItem(
                icon: Icons.more_horiz_rounded,
                label: AppStrings.more,
                onTap: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
            ],
          ),
            );
          },
        );
      },
    );
  }

  Widget _topBar(bool isDark) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context) - 2,
        8,
        ResponsivePadding.horizontal(context) - 2,
        6,
      ),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.menu_rounded,
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 10),
          Image.asset(
            logoAsset,
            width: ResponsiveSize.logo(context),
            height: ResponsiveSize.logo(context),
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "YGCA",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: ResponsiveText.heading(context) + 1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppStrings.adminControlCenter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: ResponsiveText.small(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _circleButton(
                isDark: isDark,
                icon: Icons.notifications_none_rounded,
                onTap: () => _open(const NotificationScreen()),
              ),
              Positioned(
                right: 3,
                top: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 7),
          _circleButton(
            isDark: isDark,
            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            onTap: ThemeController.toggleTheme,
          ),
          const SizedBox(width: 7),
          _circleButton(
            isDark: isDark,
            icon: Icons.logout_rounded,
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required bool isDark,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final size = ResponsiveSize.circleButton(context);

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: red.withOpacity(isDark ? 0.34 : 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDark ? Colors.white : maroon,
          size: ResponsiveHelper.isDesktop(context) ? 23 : 21,
        ),
      ),
    );
  }
    Widget _heroCard(bool isDark) {
    return Container(
      height: ResponsiveSize.heroHeight(context),
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        8,
        ResponsivePadding.horizontal(context),
        0,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090909) : Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveRadius.large(context)),
        border: Border.all(
          color: red.withOpacity(isDark ? 0.60 : 0.75),
          width: 1.15,
        ),
        boxShadow: [
          BoxShadow(
            color: red.withOpacity(isDark ? 0.22 : 0.10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.76 : 0.16,
              child: Image.asset(
                'assets/images/home_hero_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.92),
                          Colors.black.withOpacity(0.78),
                          red.withOpacity(0.28),
                        ]
                      : [
                          Colors.white.withOpacity(0.96),
                          Colors.white.withOpacity(0.88),
                          red.withOpacity(0.05),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -6,
            top: 18,
            bottom: 0,
            child: Opacity(
              opacity: isDark ? 0.30 : 0.10,
              child: Icon(
                Icons.sports_cricket_rounded,
                size: ResponsiveHelper.isDesktop(context)
                    ? 210
                    : ResponsiveHelper.isTablet(context)
                        ? 190
                        : 170,
                color: red,
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroClosedBorderPainter(
                color: isDark ? gold.withOpacity(0.85) : red.withOpacity(0.65),
              ),
            ),
          ),
          Positioned(
            left: ResponsiveHelper.isMobile(context) ? 24 : 34,
            top: ResponsiveHelper.isMobile(context) ? 58 : 72,
            child: SizedBox(
              width: ResponsiveHelper.isMobile(context) ? 118 : 136,
              height: ResponsiveHelper.isMobile(context) ? 118 : 136,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: ResponsiveHelper.isMobile(context) ? 118 : 136,
                    height: ResponsiveHelper.isMobile(context) ? 118 : 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? gold.withOpacity(0.65)
                            : red.withOpacity(0.35),
                        width: 1.6,
                      ),
                    ),
                  ),
                  Container(
                    width: ResponsiveHelper.isMobile(context) ? 96 : 110,
                    height: ResponsiveHelper.isMobile(context) ? 96 : 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? red.withOpacity(0.45)
                            : red.withOpacity(0.20),
                        width: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ResponsiveHelper.isMobile(context) ? 72 : 84,
                    height: ResponsiveHelper.isMobile(context) ? 72 : 84,
                    child: Image.asset(
                      logoAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: ResponsiveHelper.isMobile(context) ? 154 : 190,
            top: ResponsiveHelper.isMobile(context) ? 44 : 58,
            right: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_timeGreeting()},",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? gold : red,
                    fontSize: ResponsiveText.small(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.admin,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: ResponsiveText.title(context),
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.adminControlDashboard,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? gold : red,
                    fontSize: ResponsiveText.heading(context),
                    height: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: isDark ? gold : red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.adminHeroDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : const Color(0xFF374151),
                    fontSize: ResponsiveText.small(context),
                    height: 1.28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
    required bool showViewAll,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context) + 2,
        0,
        ResponsivePadding.horizontal(context) + 2,
        10,
      ),
      child: Row(
        children: [
          SizedBox(
            width: showViewAll ? 158 : 170,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: isDark ? gold : const Color(0xFF111827),
                  fontSize: ResponsiveText.heading(context) - 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              color: red.withOpacity(isDark ? 0.58 : 0.55),
            ),
          ),
          if (showViewAll) ...[
            const SizedBox(width: 8),
            Text(
              AppStrings.viewAll,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: ResponsiveText.small(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(
              Icons.chevron_right_rounded,
              color: red,
              size: 19,
            ),
          ],
        ],
      ),
    );
  }

  Widget _overviewCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.isDesktop(context) ? 14 : 10,
        vertical: ResponsiveHelper.isDesktop(context) ? 10 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF121212),
                  const Color(0xFF171717),
                  color.withOpacity(0.14),
                ]
              : [
                  Colors.white,
                  Colors.white,
                  color.withOpacity(0.04),
                ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
        border: Border.all(
          color: isDark ? red.withOpacity(0.32) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? color.withOpacity(0.08)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isDesktop(context) ? 50 : 44,
            height: ResponsiveHelper.isDesktop(context) ? 50 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isDark ? 0.15 : 0.10),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.isDesktop(context) ? 27 : 24,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: ResponsiveHelper.isDesktop(context) ? 120 : 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: ResponsiveText.heading(context) + 1,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: ResponsiveText.small(context),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: ResponsiveText.tiny(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions(bool isDark) {
    return SizedBox(
      height: ResponsiveSize.quickActionHeight(context),
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsivePadding.horizontal(context),
        ),
        children: [
          _quickActionCard(
            isDark: isDark,
            icon: Icons.person_add_alt_1_rounded,
            title: AppStrings.studentApproval,
            color: Colors.green,
            onTap: () => _open(const StudentListScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.sports_rounded,
            title: AppStrings.coachCenter,
            color: Colors.redAccent,
            onTap: () => _open(CoachModuleScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.fact_check_rounded,
            title: AppStrings.markAttendance,
            color: Colors.blue,
            onTap: () => _open(const AttendanceModuleScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.calendar_month_rounded,
            title: AppStrings.scheduleModule,
            color: Colors.purpleAccent,
            onTap: () => _open(const ScheduleModuleScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.analytics_rounded,
            title: AppStrings.reportsCenter,
            color: Colors.teal,
            onTap: () => _open(const ReportsDashboardScreen()),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.account_balance_wallet_rounded,
            title: AppStrings.feesAndDues,
            color: Colors.orange,
            onTap: () => _open(FeeModuleScreen()),
          ),
        ],
      ),
    );
  }

  Widget _quickActionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
      onTap: onTap,
      child: Container(
        width: ResponsiveSize.quickActionWidth(context),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
          border: Border.all(
            color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: ResponsiveHelper.isDesktop(context) ? 28 : 25,
            ),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: ResponsiveText.small(context),
                height: 1.12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroClosedBorderPainter extends CustomPainter {
  final Color color;

  _HeroClosedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final outerPaint = Paint()
      ..color = color.withOpacity(0.28)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final outer = RRect.fromRectAndRadius(
      Rect.fromLTWH(10, 10, size.width - 20, size.height - 20),
      const Radius.circular(26),
    );

    final inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
      const Radius.circular(22),
    );

    canvas.drawRRect(outer, outerPaint);
    canvas.drawRRect(inner, outerPaint);

    canvas.drawLine(const Offset(28, 28), const Offset(70, 28), accentPaint);
    canvas.drawLine(const Offset(28, 28), const Offset(28, 70), accentPaint);
    canvas.drawLine(const Offset(40, 40), const Offset(70, 40), accentPaint);
    canvas.drawLine(const Offset(40, 40), const Offset(40, 70), accentPaint);

    canvas.drawLine(
      Offset(size.width - 28, 28),
      Offset(size.width - 70, 28),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 28, 28),
      Offset(size.width - 28, 70),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, 40),
      Offset(size.width - 70, 40),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, 40),
      Offset(size.width - 40, 70),
      accentPaint,
    );

    canvas.drawLine(
      Offset(28, size.height - 28),
      Offset(70, size.height - 28),
      accentPaint,
    );
    canvas.drawLine(
      Offset(28, size.height - 28),
      Offset(28, size.height - 70),
      accentPaint,
    );
    canvas.drawLine(
      Offset(40, size.height - 40),
      Offset(70, size.height - 40),
      accentPaint,
    );
    canvas.drawLine(
      Offset(40, size.height - 40),
      Offset(40, size.height - 70),
      accentPaint,
    );

    canvas.drawLine(
      Offset(size.width - 28, size.height - 28),
      Offset(size.width - 70, size.height - 28),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 28, size.height - 28),
      Offset(size.width - 28, size.height - 70),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, size.height - 40),
      Offset(size.width - 70, size.height - 40),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width - 40, size.height - 40),
      Offset(size.width - 40, size.height - 70),
      accentPaint,
    );

    canvas.drawCircle(const Offset(88, 28), 3, dotPaint);
    canvas.drawCircle(Offset(size.width - 88, 28), 3, dotPaint);
    canvas.drawCircle(Offset(88, size.height - 28), 3, dotPaint);
    canvas.drawCircle(Offset(size.width - 88, size.height - 28), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}