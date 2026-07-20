import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';

class CoachSalaryReportsScreen extends StatefulWidget {
  const CoachSalaryReportsScreen({super.key});

  @override
  State<CoachSalaryReportsScreen> createState() =>
      _CoachSalaryReportsScreenState();
}

class _CoachSalaryReportsScreenState extends State<CoachSalaryReportsScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;

  String uid = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  bool get _isAdmin => role == 'Admin';

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    uid = user.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    final data = userDoc.data() ?? {};

    if (!mounted) return;

    setState(() {
      role = _text(data['role']);
      loadingUser = false;
    });
  }

  Query<Map<String, dynamic>> _salaryQuery() {
    final query = FirebaseFirestore.instance.collection('coach_salaries');

    if (role == 'Admin') {
      return query;
    }

    if (role == 'Coach') {
      return query.where('coachUid', isEqualTo: uid);
    }

    return query.where('coachUid', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortSalaryDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return sorted;
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return AppStrings.noDate;

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();

        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      }

      if (timestamp is DateTime) {
        return "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}";
      }

      return timestamp.toString();
    } catch (_) {
      return AppStrings.noDate;
    }
  }

  Color _statusColor(String status) {
    return status == "Paid" ? Colors.green : Colors.orange;
  }

  String _statusLabel(String status) {
    return status == "Paid" ? AppStrings.paid : AppStrings.pending;
  }

  double _paidPercentage({
    required int paidAmount,
    required int totalAmount,
  }) {
    if (totalAmount == 0) return 0;
    return (paidAmount / totalAmount) * 100;
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
          resizeToAvoidBottomInset: true,
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: loadingUser
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _salaryQuery().snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            _topHeader(context, isDark),
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Text(
                                    "${AppStrings.error}: ${snapshot.error}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: [
                            _topHeader(context, isDark),
                            const Expanded(
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ],
                        );
                      }

                      final salaryDocs =
                          _sortSalaryDocs(snapshot.data?.docs ?? []);

                      int totalAmount = 0;
                      int paidAmount = 0;
                      int pendingAmount = 0;
                      int paidCount = 0;
                      int pendingCount = 0;

                      for (final doc in salaryDocs) {
                        final data = doc.data();
                        final salary = _toInt(data['salary']);
                        final status = _text(data['status']).isEmpty
                            ? 'Pending'
                            : _text(data['status']);

                        totalAmount += salary;

                        if (status == "Paid") {
                          paidAmount += salary;
                          paidCount++;
                        } else {
                          pendingAmount += salary;
                          pendingCount++;
                        }
                      }

                      final percentage = _paidPercentage(
                        paidAmount: paidAmount,
                        totalAmount: totalAmount,
                      );

                      return CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: _topHeader(context, isDark),
                          ),
                          SliverToBoxAdapter(
                            child: _reportHeader(
                              isDark: isDark,
                              totalAmount: totalAmount,
                              paidAmount: paidAmount,
                              pendingAmount: pendingAmount,
                              percentage: percentage,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverToBoxAdapter(
                            child: _summaryGrid(
                              isDark: isDark,
                              totalRecords: salaryDocs.length,
                              paidCount: paidCount,
                              pendingCount: pendingCount,
                              paidPercentage: percentage,
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 18)),
                          SliverToBoxAdapter(
                            child: _sectionTitle(AppStrings.salaryReportSummary.toUpperCase(), isDark),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: _reportSummaryCard(
                                isDark: isDark,
                                totalAmount: totalAmount,
                                paidAmount: paidAmount,
                                pendingAmount: pendingAmount,
                                paidCount: paidCount,
                                pendingCount: pendingCount,
                                totalRecords: salaryDocs.length,
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 18)),
                          SliverToBoxAdapter(
                            child: _sectionTitle(AppStrings.recentSalaryRecords.toUpperCase(), isDark),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ResponsivePadding.horizontal(context),
                            ),
                            sliver: salaryDocs.isEmpty
                                ? SliverToBoxAdapter(child: _emptyCard(isDark))
                                : SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final doc = salaryDocs[index];
                                        final data = doc.data();

                                        final name =
                                            _text(data['coachName']).isEmpty
                                                ? AppStrings.unknownCoach
                                                : _text(data['coachName']);

                                        final salary = _toInt(data['salary']);

                                        final status =
                                            _text(data['status']).isEmpty
                                                ? 'Pending'
                                                : _text(data['status']);

                                        final date =
                                            _formatDate(data['createdAt']);

                                        return _recentRecordCard(
                                          isDark: isDark,
                                          name: name,
                                          salary: salary,
                                          status: status,
                                          date: date,
                                        );
                                      },
                                      childCount: salaryDocs.length,
                                    ),
                                  ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
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

  Widget _topHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(
        children: [
          _circleButton(
            isDark: isDark,
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
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
                  AppStrings.salaryReports.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _isAdmin
                      ? AppStrings.overallCoachSalaryAnalytics
                      : AppStrings.yourSalaryReportSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
          color: _card(isDark),
          shape: BoxShape.circle,
          border: Border.all(color: _border(isDark)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? red.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
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

  Widget _reportHeader({
    required bool isDark,
    required int totalAmount,
    required int paidAmount,
    required int pendingAmount,
    required double percentage,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF130202),
                  const Color(0xFF1A0505),
                  red.withOpacity(0.18),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFFBF2),
                  gold.withOpacity(0.20),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? red.withOpacity(0.30) : gold.withOpacity(0.75),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: maroon,
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: gold,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.salaryReportCenter,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      AppStrings.viewPaidPendingTotalSalaryAnalytics,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _progressBar(
            isDark: isDark,
            percentage: percentage,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: AppStrings.total,
                  value: "₹$totalAmount",
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: AppStrings.paid,
                  value: "₹$paidAmount",
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: AppStrings.pending,
                  value: "₹$pendingAmount",
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar({
    required bool isDark,
    required double percentage,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              AppStrings.paidCompletion,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Text(
              "${percentage.toStringAsFixed(0)}%",
              style: TextStyle(
                color: percentage >= 80 ? Colors.green : Colors.orange,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 9,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.10)
                : Colors.black.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage >= 80 ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _amountBox({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryGrid({
    required bool isDark,
    required int totalRecords,
    required int paidCount,
    required int pendingCount,
    required double paidPercentage,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsivePadding.horizontal(context),
      ),
      child: GridView.count(
        crossAxisCount: ResponsiveHelper.isTablet(context) ||
                ResponsiveHelper.isDesktop(context)
            ? 4
            : 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio:
            ResponsiveHelper.isMobile(context) ? 1.25 : 1.45,
        children: [
          _summaryCard(
            isDark: isDark,
            icon: Icons.receipt_long_rounded,
            title: AppStrings.records,
            value: totalRecords.toString(),
            color: Colors.blueAccent,
          ),
          _summaryCard(
            isDark: isDark,
            icon: Icons.verified_rounded,
            title: AppStrings.paid,
            value: paidCount.toString(),
            color: Colors.green,
          ),
          _summaryCard(
            isDark: isDark,
            icon: Icons.pending_actions_rounded,
            title: AppStrings.pending,
            value: pendingCount.toString(),
            color: Colors.orange,
          ),
          _summaryCard(
            isDark: isDark,
            icon: Icons.percent_rounded,
            title: AppStrings.completion,
            value: "${paidPercentage.toStringAsFixed(0)}%",
            color: Colors.purpleAccent,
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: color.withOpacity(0.14),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
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

  Widget _reportSummaryCard({
    required bool isDark,
    required int totalAmount,
    required int paidAmount,
    required int pendingAmount,
    required int paidCount,
    required int pendingCount,
    required int totalRecords,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _reportRow(
            isDark: isDark,
            title: AppStrings.totalSalaryAmount,
            value: "₹$totalAmount",
            color: Colors.blueAccent,
          ),
          _divider(isDark),
          _reportRow(
            isDark: isDark,
            title: AppStrings.paidSalaryAmount,
            value: "₹$paidAmount",
            color: Colors.green,
          ),
          _divider(isDark),
          _reportRow(
            isDark: isDark,
            title: AppStrings.pendingSalaryAmount,
            value: "₹$pendingAmount",
            color: Colors.orange,
          ),
          _divider(isDark),
          _reportRow(
            isDark: isDark,
            title: AppStrings.totalSalaryRecords,
            value: totalRecords.toString(),
            color: Colors.purpleAccent,
          ),
          _divider(isDark),
          _reportRow(
            isDark: isDark,
            title: AppStrings.paidPendingCount,
            value: "$paidCount / $pendingCount",
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 18,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }

  Widget _reportRow({
    required bool isDark,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _recentRecordCard({
    required bool isDark,
    required String name,
    required int salary,
    required String status,
    required String date,
  }) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.25)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: statusColor.withOpacity(0.16),
            child: Icon(
              status == "Paid"
                  ? Icons.verified_rounded
                  : Icons.pending_actions_rounded,
              color: statusColor,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                      isDark: isDark,
                      icon: Icons.currency_rupee_rounded,
                      text: "₹$salary",
                      color: Colors.blueAccent,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.verified_rounded,
                      text: _statusLabel(status),
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noSalaryReportsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.noSalaryRecordsToGenerateReports,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
