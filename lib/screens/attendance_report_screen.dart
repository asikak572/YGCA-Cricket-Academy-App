import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

import 'widgets/ygca_app_bar.dart';

class AttendanceReportScreen extends StatelessWidget {
  const AttendanceReportScreen({super.key});

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

  int _toPercent(int present, int total) {
    if (total == 0) return 0;
    return ((present / total) * 100).round();
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
          backgroundColor: _bg(isDark),
          appBar: YgcaAppBar(title: AppStrings.attendanceReports),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _messageCard(
                    isDark: isDark,
                    icon: Icons.error_outline_rounded,
                    title: AppStrings.somethingWentWrong,
                    message: snapshot.error.toString(),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final records = snapshot.data?.docs ?? [];

                int totalRecords = records.length;
                int presentCount = 0;
                int absentCount = 0;

                final Map<String, Map<String, dynamic>> studentSummary = {};
                final Map<String, Map<String, int>> batchSummary = {};

                for (final record in records) {
                  final data = record.data() as Map<String, dynamic>;

                  final studentId = data['studentId']?.toString() ?? '';
                  final studentName =
                      data['studentName']?.toString() ?? AppStrings.noName;
                  final batch = data['batch']?.toString() ?? AppStrings.noBatch;
                  final status = data['status']?.toString() ?? AppStrings.absent;

                  if (status == AppStrings.present) {
                    presentCount++;
                  } else {
                    absentCount++;
                  }

                  studentSummary.putIfAbsent(studentId, () {
                    return {
                      'name': studentName,
                      'batch': batch,
                      'present': 0,
                      'absent': 0,
                      'total': 0,
                    };
                  });

                  studentSummary[studentId]!['total']++;

                  if (status == AppStrings.present) {
                    studentSummary[studentId]!['present']++;
                  } else {
                    studentSummary[studentId]!['absent']++;
                  }

                  batchSummary.putIfAbsent(batch, () {
                    return {'present': 0, 'absent': 0, 'total': 0};
                  });

                  batchSummary[batch]!['total'] =
                      (batchSummary[batch]!['total'] ?? 0) + 1;

                  if (status == AppStrings.present) {
                    batchSummary[batch]!['present'] =
                        (batchSummary[batch]!['present'] ?? 0) + 1;
                  } else {
                    batchSummary[batch]!['absent'] =
                        (batchSummary[batch]!['absent'] ?? 0) + 1;
                  }
                }

                final attendancePercent =
                    _toPercent(presentCount, totalRecords);

                final allStudents = studentSummary.values.toList();

                allStudents.sort((a, b) {
                  final aTotal = a['total'] as int;
                  final bTotal = b['total'] as int;
                  final aPresent = a['present'] as int;
                  final bPresent = b['present'] as int;

                  final aPercent = _toPercent(aPresent, aTotal);
                  final bPercent = _toPercent(bPresent, bTotal);

                  return bPercent.compareTo(aPercent);
                });

                final topStudents = allStudents.take(3).toList();

                final lowAttendance = allStudents.where((student) {
                  final total = student['total'] as int;
                  final present = student['present'] as int;
                  final percent = _toPercent(present, total);
                  return percent < 75;
                }).toList();

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _heroReportCard(
                        context: context,
                        isDark: isDark,
                        attendancePercent: attendancePercent,
                        totalRecords: totalRecords,
                        presentCount: presentCount,
                        absentCount: absentCount,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate(
                          [
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.totalRecords,
                              value: totalRecords.toString(),
                              icon: Icons.list_alt_rounded,
                              color: gold,
                            ),
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.present,
                              value: presentCount.toString(),
                              icon: Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.absent,
                              value: absentCount.toString(),
                              icon: Icons.cancel_rounded,
                              color: Colors.redAccent,
                            ),
                            _statCard(
                              isDark: isDark,
                              title: AppStrings.attendancePercentage,
                              value: "$attendancePercent%",
                              icon: Icons.percent_rounded,
                              color: Colors.blueAccent,
                            ),
                          ],
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.18,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.batchWiseSummary, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          batchSummary.isEmpty
                              ? [
                                  _emptySmall(
                                    isDark,
                                    AppStrings.noBatchReportAvailable,
                                  ),
                                ]
                              : batchSummary.entries.map((entry) {
                                  final batch = entry.key;
                                  final present = entry.value['present'] ?? 0;
                                  final absent = entry.value['absent'] ?? 0;
                                  final total = entry.value['total'] ?? 0;
                                  final percent = _toPercent(present, total);

                                  return _batchCard(
                                    isDark: isDark,
                                    batch: batch,
                                    present: present,
                                    absent: absent,
                                    percent: percent,
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.topAttendanceStudents, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          topStudents.isEmpty
                              ? [
                                  _emptySmall(
                                    isDark,
                                    AppStrings.noStudentDataAvailable,
                                  ),
                                ]
                              : topStudents.map((student) {
                                  final total = student['total'] as int;
                                  final present = student['present'] as int;
                                  final percent = _toPercent(present, total);

                                  return _topStudentCard(
                                    isDark: isDark,
                                    name: student['name'].toString(),
                                    batch: student['batch'].toString(),
                                    percent: percent,
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(
                        AppStrings.studentAttendanceSummary,
                        isDark,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          studentSummary.isEmpty
                              ? [
                                  _emptySmall(
                                    isDark,
                                    AppStrings.noAttendanceDataAvailable,
                                  ),
                                ]
                              : studentSummary.values.map((student) {
                                  final total = student['total'] as int;
                                  final present = student['present'] as int;
                                  final absent = student['absent'] as int;
                                  final percent = _toPercent(present, total);

                                  return _studentSummaryCard(
                                    isDark: isDark,
                                    name: student['name'].toString(),
                                    batch: student['batch'].toString(),
                                    present: present,
                                    absent: absent,
                                    percent: percent,
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.lowAttendanceAlert, isDark),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          lowAttendance.isEmpty
                              ? [_successCard(isDark)]
                              : lowAttendance.map((student) {
                                  final total = student['total'] as int;
                                  final present = student['present'] as int;
                                  final percent = _toPercent(present, total);

                                  return _studentAlertCard(
                                    isDark: isDark,
                                    name: student['name'].toString(),
                                    batch: student['batch'].toString(),
                                    percent: percent,
                                  );
                                }).toList(),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 28)),
                  ],
                );
              },
            ),
          ),
            );
          },
        );
      },
    );
  }

  Widget _heroReportCard({
    required BuildContext context,
    required bool isDark,
    required int attendancePercent,
    required int totalRecords,
    required int presentCount,
    required int absentCount,
  }) {
    String health = AppStrings.needsAttention;
    Color healthColor = Colors.redAccent;

    if (attendancePercent >= 90) {
      health = AppStrings.excellent;
      healthColor = Colors.green;
    } else if (attendancePercent >= 75) {
      health = AppStrings.good;
      healthColor = Colors.orange;
    }

    final progress = attendancePercent.clamp(0, 100) / 100;

    return Container(
      height: 245,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.20) : maroon.withOpacity(0.16),
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
                          maroon.withOpacity(0.72),
                          Colors.black.withOpacity(0.25),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Positioned(
            right: -25,
            bottom: -25,
            child: Icon(
              Icons.analytics_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 155,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.fact_check_rounded,
                    color: maroon,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 235,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.academy.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.attendance.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.report.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress.toDouble(),
                              backgroundColor: Colors.white24,
                              color: gold,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "$attendancePercent% ${AppStrings.overallAttendance}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.total}: $totalRecords"),
                              _heroChip("${AppStrings.present}: $presentCount"),
                              _heroChip("${AppStrings.absent}: $absentCount"),
                              _statusChip(health, healthColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.pdfExportLater),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.11),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: gold.withOpacity(0.7)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.download_rounded, color: gold, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      AppStrings.export,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
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

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.75)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: gold,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            color: isDark
                ? color.withOpacity(0.10)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isDark ? gold : maroon,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
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

  Widget _batchCard({
    required bool isDark,
    required String batch,
    required int present,
    required int absent,
    required int percent,
  }) {
    return _infoListCard(
      isDark: isDark,
      leadingColor: maroon,
      leading: const Icon(Icons.groups_rounded, color: gold),
      title: batch,
      subtitle: "${AppStrings.present}: $present • ${AppStrings.absent}: $absent",
      trailing: _percentChip(percent),
    );
  }

  Widget _topStudentCard({
    required bool isDark,
    required String name,
    required String batch,
    required int percent,
  }) {
    return _infoListCard(
      isDark: isDark,
      leadingColor: gold,
      leading: const Icon(Icons.emoji_events_rounded, color: maroon),
      title: name,
      subtitle: batch,
      trailing: _percentChip(percent),
    );
  }

  Widget _studentSummaryCard({
    required bool isDark,
    required String name,
    required String batch,
    required int present,
    required int absent,
    required int percent,
  }) {
    return _infoListCard(
      isDark: isDark,
      leadingColor: maroon,
      leading: Text(
        name.isNotEmpty ? name[0].toUpperCase() : "?",
        style: const TextStyle(
          color: gold,
          fontWeight: FontWeight.w900,
        ),
      ),
      title: name,
      subtitle: "$batch\n${AppStrings.present}: $present • ${AppStrings.absent}: $absent",
      trailing: _percentChip(percent),
      isThreeLine: true,
    );
  }

  Widget _studentAlertCard({
    required bool isDark,
    required String name,
    required String batch,
    required int percent,
  }) {
    return _infoListCard(
      isDark: isDark,
      leadingColor: Colors.red.withOpacity(0.13),
      leading: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.redAccent,
      ),
      title: name,
      subtitle: batch,
      trailing: _alertChip("$percent%"),
    );
  }

  Widget _infoListCard({
    required bool isDark,
    required Color leadingColor,
    required Widget leading,
    required String title,
    required String subtitle,
    required Widget trailing,
    bool isThreeLine = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.24) : _border(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: leadingColor,
            child: leading,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? AppStrings.unknown : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: isThreeLine ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing,
        ],
      ),
    );
  }

  Widget _percentChip(int percent) {
    Color color = Colors.redAccent;

    if (percent >= 90) {
      color = Colors.green;
    } else if (percent >= 75) {
      color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.24)),
      ),
      child: Text(
        "$percent%",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _alertChip(String percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.24)),
      ),
      child: Text(
        percent,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _successCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.green.withOpacity(0.35) : _border(isDark),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEAF8EF),
            child: Icon(Icons.check_circle_rounded, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.noLowAttendanceStudents,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.allStudentsAbove75,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySmall(bool isDark, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _secondaryText(isDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card(isDark),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border(isDark)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _secondaryText(isDark), size: 42),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}