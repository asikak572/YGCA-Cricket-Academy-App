import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

import 'notification_screen.dart';
import 'leave_request_screen.dart';
import 'parent_attendance_module_screen.dart';
import 'parent_fee_module_screen.dart';
import 'parent_schedule_module_screen.dart';
import 'parent_performance_module_screen.dart';
import 'edit_profile_screen.dart';
import 'widgets/ygca_drawer.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  String _safeText(Map<String, dynamic> data, String key, String fallback) {
    final value = data[key];

    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }

    return fallback;
  }

  int _percentValue(String text) {
    return int.tryParse(text.replaceAll('%', '').trim()) ?? 0;
  }

  Future<Map<String, dynamic>?> _loadLinkedChild(
    Map<String, dynamic> parentData,
    String? authEmail,
  ) async {
    final linkedChildrenIds = parentData['linkedChildrenIds'];

    if (linkedChildrenIds is List && linkedChildrenIds.isNotEmpty) {
      final childId = linkedChildrenIds.first.toString().trim();

      if (childId.isNotEmpty) {
        final childDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(childId)
            .get();

        if (childDoc.exists && childDoc.data() != null) {
          return {
            'childId': childId,
            ...childDoc.data()!,
          };
        }
      }
    }

    final parentEmailFromDoc =
        parentData['email']?.toString().trim().toLowerCase() ?? '';
    final parentEmailFromAuth = authEmail?.trim().toLowerCase() ?? '';

    final parentEmail = parentEmailFromDoc.isNotEmpty
        ? parentEmailFromDoc
        : parentEmailFromAuth;

    if (parentEmail.isEmpty) {
      return null;
    }

    final childQuery = await FirebaseFirestore.instance
        .collection('students')
        .where('parentEmail', isEqualTo: parentEmail)
        .limit(1)
        .get();

    if (childQuery.docs.isEmpty) {
      return null;
    }

    final childDoc = childQuery.docs.first;

    return {
      'childId': childDoc.id,
      ...childDoc.data(),
    };
  }

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
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('No user logged in')),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          drawer: YgcaDrawer(
            role: 'Parent',
            navItems: [
              YgcaNavItem(
                icon: Icons.home_rounded,
                label: 'Dashboard',
                onTap: () {},
              ),
              YgcaNavItem(
                icon: Icons.fact_check_rounded,
                label: 'Attendance Module',
                onTap: () => _open(
                  context,
                  const ParentAttendanceModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Performance Module',
                onTap: () => _open(
                  context,
                  const ParentPerformanceModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.payments_rounded,
                label: 'Fee Module',
                onTap: () => _open(
                  context,
                  const ParentFeeModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.calendar_month_rounded,
                label: 'Schedule Module',
                onTap: () => _open(
                  context,
                  const ParentScheduleModuleScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.event_note_rounded,
                label: 'Apply Leave',
                onTap: () => _open(
                  context,
                  const LeaveRequestScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.person_rounded,
                label: 'Edit Profile',
                onTap: () => _open(
                  context,
                  const EditProfileScreen(),
                ),
              ),
              YgcaNavItem(
                icon: Icons.notifications_rounded,
                label: 'Notifications',
                onTap: () => _open(
                  context,
                  const NotificationScreen(),
                ),
              ),
            ],
            onLogout: () => _logout(context),
          ),
          body: SafeArea(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser.uid)
                  .snapshots(),
              builder: (context, parentSnapshot) {
                if (parentSnapshot.hasError) {
                  return _messageBody(
                    context: context,
                    isDark: isDark,
                    message: 'Error: ${parentSnapshot.error}',
                  );
                }

                if (parentSnapshot.connectionState == ConnectionState.waiting) {
                  return _loadingBody(context, isDark);
                }

                if (!parentSnapshot.hasData || !parentSnapshot.data!.exists) {
                  return _messageBody(
                    context: context,
                    isDark: isDark,
                    message: 'Parent details not found',
                  );
                }

                final parentData = parentSnapshot.data!.data() ?? {};
                final parentName = _safeText(parentData, 'name', 'Parent');
                final parentEmail =
                    _safeText(parentData, 'email', currentUser.email ?? '');

                return FutureBuilder<Map<String, dynamic>?>(
                  future: _loadLinkedChild(parentData, currentUser.email),
                  builder: (context, childSnapshot) {
                    if (childSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _loadingBody(context, isDark);
                    }

                    if (childSnapshot.hasError) {
                      return _messageBody(
                        context: context,
                        isDark: isDark,
                        message: 'Child loading error: ${childSnapshot.error}',
                      );
                    }

                    final childData = childSnapshot.data;

                    final childName = childData == null
                        ? 'Child not assigned'
                        : _safeText(childData, 'name', 'Child not assigned');

                    final childBatch = childData == null
                        ? 'Batch not assigned'
                        : _safeText(childData, 'batch', 'Batch not assigned');

                    final rollNo = childData == null
                        ? 'Not assigned'
                        : _safeText(childData, 'rollNo', 'Not assigned');

                    final attendance = childData == null
                        ? '0%'
                        : _safeText(childData, 'attendance', '0%');

                    final feeStatus = childData == null
                        ? 'Pending'
                        : _safeText(childData, 'feeStatus', 'Pending');

                    final attendanceNumber = _percentValue(attendance);

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _topBar(context, isDark, parentName),
                          _childHero(
                            isDark: isDark,
                            childName: childName,
                            parentName: parentName,
                            parentEmail: parentEmail,
                            childBatch: childBatch,
                            rollNo: rollNo,
                            attendance: attendance,
                            feeStatus: feeStatus,
                          ),
                          const SizedBox(height: 18),
                          _sectionTitle('PARENT OVERVIEW', isDark),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.05,
                              children: [
                                _statCard(
                                  isDark: isDark,
                                  icon: Icons.verified_rounded,
                                  title: 'ATTENDANCE',
                                  value: '$attendanceNumber%',
                                  subtitle: attendanceNumber >= 75
                                      ? 'Good Progress'
                                      : 'Needs Focus',
                                  color: Colors.green,
                                ),
                                _statCard(
                                  isDark: isDark,
                                  icon: Icons.currency_rupee_rounded,
                                  title: 'FEE STATUS',
                                  value: feeStatus,
                                  subtitle:
                                      feeStatus == 'Paid' ? 'No Due' : 'Check Fees',
                                  color: Colors.orange,
                                ),
                                _statCard(
                                  isDark: isDark,
                                  icon: Icons.groups_rounded,
                                  title: 'BATCH',
                                  value: childBatch,
                                  subtitle: 'Assigned Batch',
                                  color: Colors.blueAccent,
                                ),
                                _statCard(
                                  isDark: isDark,
                                  icon: Icons.tag_rounded,
                                  title: 'ROLL NO.',
                                  value: rollNo,
                                  subtitle: 'Student ID',
                                  color: Colors.purpleAccent,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _sectionTitle('QUICK ACTIONS', isDark),
                          SizedBox(
                            height: 116,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                _quickAction(
                                  context,
                                  isDark,
                                  Icons.fact_check_rounded,
                                  'Child\nAttendance',
                                  Colors.orange,
                                  () => _open(
                                    context,
                                    const ParentAttendanceModuleScreen(),
                                  ),
                                ),
                                _quickAction(
                                  context,
                                  isDark,
                                  Icons.bar_chart_rounded,
                                  'Child\nPerformance',
                                  Colors.green,
                                  () => _open(
                                    context,
                                    const ParentPerformanceModuleScreen(),
                                  ),
                                ),
                                _quickAction(
                                  context,
                                  isDark,
                                  Icons.payments_rounded,
                                  'Fee\nStatus',
                                  Colors.blue,
                                  () => _open(
                                    context,
                                    const ParentFeeModuleScreen(),
                                  ),
                                ),
                                _quickAction(
                                  context,
                                  isDark,
                                  Icons.calendar_month_rounded,
                                  'Training\nSchedule',
                                  Colors.teal,
                                  () => _open(
                                    context,
                                    const ParentScheduleModuleScreen(),
                                  ),
                                ),
                                _quickAction(
                                  context,
                                  isDark,
                                  Icons.notifications_active_rounded,
                                  'Academy\nNotice',
                                  Colors.redAccent,
                                  () => _open(
                                    context,
                                    const NotificationScreen(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _sectionTitle('MODULE ACCESS', isDark),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.38,
                              children: [
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.fact_check_rounded,
                                  'Attendance',
                                  'View child attendance',
                                  Colors.orange,
                                  () => _open(
                                    context,
                                    const ParentAttendanceModuleScreen(),
                                  ),
                                ),
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.bar_chart_rounded,
                                  'Performance',
                                  'Progress reports',
                                  Colors.green,
                                  () => _open(
                                    context,
                                    const ParentPerformanceModuleScreen(),
                                  ),
                                ),
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.payments_rounded,
                                  'Fee Module',
                                  'Payment and status',
                                  Colors.blue,
                                  () => _open(
                                    context,
                                    const ParentFeeModuleScreen(),
                                  ),
                                ),
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.calendar_month_rounded,
                                  'Schedule',
                                  'Training sessions',
                                  Colors.teal,
                                  () => _open(
                                    context,
                                    const ParentScheduleModuleScreen(),
                                  ),
                                ),
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.event_note_rounded,
                                  'Apply Leave',
                                  'Request child leave',
                                  Colors.brown,
                                  () => _open(
                                    context,
                                    const LeaveRequestScreen(),
                                  ),
                                ),
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.person_rounded,
                                  'Edit Profile',
                                  'Update parent details',
                                  Colors.indigo,
                                  () => _open(
                                    context,
                                    const EditProfileScreen(),
                                  ),
                                ),
                                _moduleCard(
                                  context,
                                  isDark,
                                  Icons.notifications_active_rounded,
                                  'Notifications',
                                  'Academy updates',
                                  Colors.redAccent,
                                  () => _open(
                                    context,
                                    const NotificationScreen(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          _childProgressCard(
                            isDark: isDark,
                            attendanceNumber: attendanceNumber,
                            attendance: attendance,
                            feeStatus: feeStatus,
                          ),
                          const SizedBox(height: 18),
                          _activityCard(isDark),
                          const SizedBox(height: 18),
                          _footer(isDark),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _loadingBody(BuildContext context, bool isDark) {
    return Column(
      children: [
        _topBar(context, isDark, 'Parent'),
        const Expanded(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }

  Widget _messageBody({
    required BuildContext context,
    required bool isDark,
    required String message,
  }) {
    return Column(
      children: [
        _topBar(context, isDark, 'Parent'),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, bool isDark, String parentName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          Builder(
            builder: (drawerContext) {
              return _circleButton(
                isDark: isDark,
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(drawerContext).openDrawer(),
              );
            },
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 46,
            height: 46,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YGCA',
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Parent Control Center',
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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
                onTap: () => _open(context, const NotificationScreen()),
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
          const SizedBox(width: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
          const SizedBox(width: 8),
          _circleButton(
            isDark: isDark,
            icon: Icons.logout_rounded,
            onTap: () => _logout(context),
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
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? red.withOpacity(0.12) : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
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

  Widget _childHero({
    required bool isDark,
    required String childName,
    required String parentName,
    required String parentEmail,
    required String childBatch,
    required String rollNo,
    required String attendance,
    required String feeStatus,
  }) {
    final initials = childName
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.22) : maroon.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_hero_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          Colors.black.withOpacity(0.90),
                          darkMaroon.withOpacity(0.88),
                          red.withOpacity(0.35),
                        ]
                      : [
                          maroon.withOpacity(0.92),
                          maroon.withOpacity(0.70),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -24,
            child: Icon(
              Icons.family_restroom_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Text(
                    initials.isNotEmpty ? initials : 'C',
                    style: const TextStyle(
                      color: maroon,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CHILD PROGRESS',
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            childName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: gold,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PARENT VIEW',
                              style: TextStyle(
                                color: maroon,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Parent: $parentName',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            parentEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip('Roll No: $rollNo'),
                              _heroChip('Fee: $feeStatus'),
                            ],
                          ),
                          const SizedBox(height: 7),
                          _heroChip('Batch: $childBatch'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
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
              fontSize: 16,
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

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF151515),
                  const Color(0xFF1A0808),
                  color.withOpacity(0.16),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  color.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDark ? color.withOpacity(0.12) : Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 135,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color.withOpacity(0.18),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 105,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.16),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? red.withOpacity(0.25) : _border(isDark),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isDark ? Colors.black.withOpacity(0.30) : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.22),
                    red.withOpacity(0.10),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.40)),
              ),
              child: Icon(icon, color: color, size: 23),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _childProgressCard({
    required bool isDark,
    required int attendanceNumber,
    required String attendance,
    required String feeStatus,
  }) {
    final progress = (attendanceNumber.clamp(0, 100)) / 100;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF180808),
                  const Color(0xFF0F0F0F),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.18),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: red.withOpacity(0.18),
            child: Icon(
              Icons.insights_rounded,
              color: gold,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Child Progress Summary',
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Attendance $attendance • Fee $feeStatus',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      attendanceNumber >= 75 ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            attendanceNumber >= 75 ? 'GOOD' : 'FOCUS',
            style: TextStyle(
              color: attendanceNumber >= 75 ? Colors.green : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.55) : gold.withOpacity(0.9),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          _activityRow(
            isDark,
            Icons.check_circle_rounded,
            'Attendance updated recently',
            Colors.green,
          ),
          _activityRow(
            isDark,
            Icons.sports_cricket_rounded,
            'Training schedule available',
            Colors.blue,
          ),
          _activityRow(
            isDark,
            Icons.payments_rounded,
            'Fee status is visible',
            Colors.orange,
          ),
          _activityRow(
            isDark,
            Icons.notifications_rounded,
            'New academy notifications',
            Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _activityRow(
    bool isDark,
    IconData icon,
    String title,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  maroon,
                  darkMaroon,
                  Colors.black,
                ]
              : [
                  maroon,
                  red.withOpacity(0.85),
                  darkMaroon,
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.7), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _footerItem(Icons.favorite_rounded, 'Passion'),
          _footerItem(Icons.star_rounded, 'Discipline'),
          _footerItem(Icons.emoji_events_rounded, 'Success'),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, color: gold, size: 25),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
