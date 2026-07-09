import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_spacing.dart';
import '../core/responsive/responsive_radius.dart';
import '../core/responsive/responsive_text.dart';
import '../core/responsive/responsive_grid.dart';
import '../core/responsive/responsive_size.dart';

import 'widgets/ygca_drawer.dart';
import 'widgets/ygca_bottom_nav.dart';
import '../core/language/app_strings.dart';

import 'notification_screen.dart';
import 'student_attendance_module_screen.dart';
import 'student_performance_module_screen.dart';
import 'student_schedule_module_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
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
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  void _open(Widget screen) {
    _scaffoldKey.currentState?.closeDrawer();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  void _openRoute(String routeName) {
    _scaffoldKey.currentState?.closeDrawer();

    Navigator.pushNamed(context, routeName);
  }

  Future<void> _openStudentAttendanceModule() async {
    _scaffoldKey.currentState?.closeDrawer();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (!mounted) return;

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Student details not found"),
        ),
      );
      return;
    }

    final data = doc.data() ?? {};

    final name = _safeText(data, ['name', 'studentName'], 'Student');

    final batch = _safeText(
      data,
      ['batch', 'assignedBatch'],
      'Batch not assigned',
    );

    final rollNo = _safeText(
      data,
      ['rollNo', 'rollNumber', 'studentId'],
      'Not assigned',
    );

    final attendance = _safeText(
      data,
      ['attendancePercentage', 'attendance'],
      '0%',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StudentAttendanceModuleScreen(
          studentId: currentUser.uid,
          name: name,
          batch: batch,
          rollNo: rollNo,
          attendance: attendance,
        ),
      ),
    );
  }

  String _safeText(
    Map<String, dynamic> data,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = data[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }

    return fallback;
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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

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
  role: 'Student',
  username: 'Student User',
  onLogout: _logout,
),
          body: SafeArea(
            bottom: false,
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topBar(isDark),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Something went wrong",
                            style: TextStyle(color: _primaryText(isDark)),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topBar(isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Column(
                    children: [
                      _topBar(isDark),
                      Expanded(
                        child: Center(
                          child: Text(
                            "Student details not found",
                            style: TextStyle(color: _primaryText(isDark)),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final data = snapshot.data!.data() ?? {};

                final name = _safeText(data, ['name', 'studentName'], 'Student');

                final email = _safeText(
                  data,
                  ['email'],
                  currentUser.email ?? '',
                );

                final batch = _safeText(
                  data,
                  ['batch', 'assignedBatch'],
                  'Batch not assigned',
                );

                final rollNo = _safeText(
                  data,
                  ['rollNo', 'rollNumber', 'studentId'],
                  'Not assigned',
                );

                final approvalStatus = _safeText(
                  data,
                  ['approvalStatus', 'status'],
                  'Active',
                );

                final attendance = _safeText(
                  data,
                  ['attendancePercentage', 'attendance'],
                  '0%',
                );

                final feeStatus = _safeText(
                  data,
                  ['feeStatus'],
                  'Pending',
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.maxContentWidth(context),
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        bottom: ResponsiveSpacing.small(context),
                      ),
                      child: Column(
                        children: [
                      _topBar(isDark),
                      _studentHero(
                        isDark: isDark,
                        name: name,
                        email: email,
                        batch: batch,
                        rollNo: rollNo,
                      ),
                      SizedBox(height: ResponsiveSpacing.medium(context)),
                      _sectionTitle(
                        title: AppStrings.studentOverview,
                        isDark: isDark,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
                        child: GridView.count(
                          crossAxisCount: ResponsiveGrid.dashboardCount(context),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: ResponsiveSpacing.small(context) + 2,
                          mainAxisSpacing: ResponsiveSpacing.small(context) + 2,
                          childAspectRatio: ResponsiveGrid.dashboardCardRatio(context),
                          children: [
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.fact_check_rounded,
                              title: AppStrings.attendance,
                              value: attendance,
                              subtitle: AppStrings.overall,
                              color: Colors.green,
                            ),
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.sports_cricket_rounded,
                              title: AppStrings.batch,
                              value: batch,
                              subtitle: AppStrings.training,
                              color: Colors.orange,
                            ),
                            _overviewCard(
                              isDark: isDark,
                              icon: Icons.badge_rounded,
                              title: AppStrings.rollNo,
                              value: rollNo,
                              subtitle: AppStrings.studentId,
                              color: Colors.blueAccent,
                            ),
                           _overviewCard(
  isDark: isDark,
  icon: Icons.verified_rounded,
  title: AppStrings.status,
  value: approvalStatus.toLowerCase() == "approved"
      ? AppStrings.approved
      : approvalStatus,
  subtitle: feeStatus,
  color: Colors.purpleAccent,
),
                          ],
                        ),
                      ),
                      SizedBox(height: ResponsiveSpacing.medium(context)),
                      _sectionTitle(
                        title: AppStrings.quickActions,
                        isDark: isDark,
                      ),
                      _quickActions(isDark),
                          SizedBox(height: ResponsiveSpacing.small(context)),
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
                icon: Icons.fact_check_rounded,
                label: AppStrings.attendance,
                onTap: _openStudentAttendanceModule,
              ),
              YgcaBottomNavItem(
                icon: Icons.analytics_rounded,
                label: AppStrings.performance,
                onTap: () => _open(
                  const StudentPerformanceModuleScreen(),
                ),
              ),
              YgcaBottomNavItem(
                icon: Icons.payments_rounded,
                label: AppStrings.fees,
                onTap: () => _openRoute('/fees'),
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
        ResponsiveSpacing.small(context),
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
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  AppStrings.studentControlCenter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
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
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: ResponsiveSize.circleButton(context),
        height: ResponsiveSize.circleButton(context),
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
          size: 21,
        ),
      ),
    );
  }

  Widget _studentHero({
    required bool isDark,
    required String name,
    required String email,
    required String batch,
    required String rollNo,
  }) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "S";

    return Container(
      height: ResponsiveSize.heroHeight(context),
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        ResponsiveSpacing.small(context),
        ResponsivePadding.horizontal(context),
        0,
      ),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090909) : Colors.white,
        borderRadius: BorderRadius.circular(30),
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
                size: 170,
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
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 370;
                final avatarOuter = compact ? 92.0 : 118.0;
                final avatarInner = compact ? 74.0 : 96.0;
                final avatarLeft = compact ? 18.0 : 24.0;
                final avatarTop = compact ? 64.0 : 58.0;
                final textLeft = compact ? 120.0 : 154.0;

                return Stack(
                  children: [
                    Positioned(
                      left: avatarLeft,
                      top: avatarTop,
                      child: SizedBox(
                        width: avatarOuter,
                        height: avatarOuter,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: avatarOuter,
                              height: avatarOuter,
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
                              width: avatarInner,
                              height: avatarInner,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? Colors.black.withOpacity(0.35)
                                    : Colors.white.withOpacity(0.55),
                                border: Border.all(
                                  color: isDark
                                      ? red.withOpacity(0.45)
                                      : red.withOpacity(0.20),
                                  width: 1.2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: TextStyle(
                                    color: isDark ? gold : maroon,
                                    fontSize: compact ? 30 : 38,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: textLeft,
                      top: compact ? 34 : 38,
                      right: 18,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: compact ? 190 : 230,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.goodMorning,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? gold : red,
                                  fontSize: compact ? 10.5 : 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: compact ? 1.7 : 2.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: compact ? 25 : 30,
                                  height: 0.98,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                AppStrings.studentDashboard,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark ? gold : red,
                                  fontSize: compact ? 15 : 17,
                                  height: 1.0,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 58,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: isDark ? gold : red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF374151),
                                  fontSize: compact ? 10.5 : 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                "${AppStrings.batch}: $batch",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF64748B),
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                "${AppStrings.rollNo}: $rollNo",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white60
                                      : const Color(0xFF64748B),
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: Row(
        children: [
          Flexible(
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.32) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? color.withOpacity(0.08) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.isMobile(context) ? 40 : 44,
            height: ResponsiveHelper.isMobile(context) ? 40 : 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(isDark ? 0.15 : 0.10),
              border: Border.all(color: color.withOpacity(0.35)),
            ),
            child: Icon(icon, color: color, size: ResponsiveHelper.isMobile(context) ? 22 : 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: ResponsiveText.heading(context),
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
                        fontSize: ResponsiveText.tiny(context),
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
                        fontSize: ResponsiveText.tiny(context) - 0.5,
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
        padding: EdgeInsets.symmetric(horizontal: ResponsivePadding.horizontal(context)),
        children: [
          _quickActionCard(
            isDark: isDark,
            icon: Icons.fact_check_rounded,
            title: AppStrings.myAttendance,
            color: Colors.green,
            onTap: _openStudentAttendanceModule,
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.analytics_rounded,
            title: AppStrings.myPerformance,
            color: Colors.blue,
            onTap: () => _open(
              const StudentPerformanceModuleScreen(),
            ),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.calendar_month_rounded,
            title: AppStrings.mySchedule,
            color: Colors.purpleAccent,
            onTap: () => _open(
              const StudentScheduleModuleScreen(),
            ),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.payments_rounded,
            title: AppStrings.feeStatus,
            color: Colors.orange,
            onTap: () => _openRoute('/fees'),
          ),
          _quickActionCard(
            isDark: isDark,
            icon: Icons.notifications_rounded,
            title: AppStrings.academyUpdates,
            color: Colors.redAccent,
            onTap: () => _open(const NotificationScreen()),
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: ResponsiveSize.quickActionWidth(context),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? red.withOpacity(0.30) : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? red.withOpacity(0.08) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: ResponsiveText.tiny(context),
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

class _ComingSoonScreen extends StatelessWidget {
  final String title;

  const _ComingSoonScreen({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF7F0000),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "$title screen will be connected here.",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}