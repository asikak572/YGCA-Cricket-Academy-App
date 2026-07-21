import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_padding.dart';

class DueFeeAnalyticsScreen extends StatefulWidget {
  const DueFeeAnalyticsScreen({super.key});

  @override
  State<DueFeeAnalyticsScreen> createState() => _DueFeeAnalyticsScreenState();
}

class _DueFeeAnalyticsScreenState extends State<DueFeeAnalyticsScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _feesStream;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _studentsSubscription;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<String> _searchQuery = ValueNotifier<String>('');

  final Map<String, String> _rollNoByStudentId = <String, String>{};
  final Map<String, String> _rollNoByNameBatch = <String, String>{};

  @override
  void initState() {
    super.initState();
    _feesStream = _feesQuery().snapshots();
    _studentsSubscription = FirebaseFirestore.instance
        .collection('students')
        .snapshots()
        .listen(_updateStudentRollNumbers);
  }

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchQuery.dispose();
    super.dispose();
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

  Query<Map<String, dynamic>> _feesQuery() {
    return FirebaseFirestore.instance.collection('fees');
  }

  String _studentLookupKey(String name, String batch) {
    return '${name.trim().toLowerCase()}|${batch.trim().toLowerCase()}';
  }

  String _rollNoFromStudentData(Map<String, dynamic> data) {
    for (final key in ['rollNo', 'rollNumber', 'studentRollNo']) {
      final value = _text(data[key]);
      if (value.isNotEmpty) return value;
    }
    return '';
  }

  void _updateStudentRollNumbers(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final byId = <String, String>{};
    final byNameBatch = <String, String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final rollNo = _rollNoFromStudentData(data);
      if (rollNo.isEmpty) continue;

      byId[doc.id] = rollNo;

      final name = _text(data['name']).isNotEmpty
          ? _text(data['name'])
          : _text(data['studentName']);
      final batch = _text(data['batch']);
      if (name.isNotEmpty) {
        byNameBatch[_studentLookupKey(name, batch)] = rollNo;
        byNameBatch.putIfAbsent(
          _studentLookupKey(name, ''),
          () => rollNo,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _rollNoByStudentId
        ..clear()
        ..addAll(byId);
      _rollNoByNameBatch
        ..clear()
        ..addAll(byNameBatch);
    });
  }

  String _resolvedRollNo(Map<String, dynamic> data) {
    final directRollNo = _rollNoFromStudentData(data);
    if (directRollNo.isNotEmpty) return directRollNo;

    for (final key in ['studentId', 'studentDocId', 'studentUid']) {
      final studentId = _text(data[key]);
      final rollNo = _rollNoByStudentId[studentId];
      if (rollNo != null && rollNo.isNotEmpty) return rollNo;
    }

    final name = _text(data['studentName']).isNotEmpty
        ? _text(data['studentName'])
        : _text(data['name']);
    final batch = _text(data['batch']);

    return _rollNoByNameBatch[_studentLookupKey(name, batch)] ??
        _rollNoByNameBatch[_studentLookupKey(name, '')] ??
        '';
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _dueDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String searchValue,
  ) {
    final query = searchValue.trim().toLowerCase();

    final dues = docs.where((doc) {
      final data = doc.data();
      final pendingAmount = _toInt(data['pendingAmount']);
      final status = _text(data['status']).isNotEmpty
          ? _text(data['status']).toLowerCase()
          : pendingAmount > 0
              ? "pending"
              : "paid";

      return pendingAmount > 0 || status == "pending";
    }).toList();

    if (query.isEmpty) return dues;

    return dues.where((doc) {
      final data = doc.data();

      final studentName = _text(data['studentName']).toLowerCase();
      final name = _text(data['name']).toLowerCase();
      final rollNo = _resolvedRollNo(data).toLowerCase();
      final batch = _text(data['batch']).toLowerCase();

      return studentName.contains(query) ||
          name.contains(query) ||
          rollNo.contains(query) ||
          batch.contains(query);
    }).toList();
  }

  String _riskLabel(int pendingAmount) {
    if (pendingAmount >= 10000) return AppStrings.highDue;
    if (pendingAmount >= 5000) return AppStrings.mediumDue;
    if (pendingAmount > 0) return AppStrings.lowDue;
    return AppStrings.noDue;
  }

  Color _riskColor(int pendingAmount) {
    if (pendingAmount >= 10000) return Colors.redAccent;
    if (pendingAmount >= 5000) return Colors.orange;
    if (pendingAmount > 0) return Colors.blueAccent;
    return Colors.green;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortByDueAmount(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aDue = _toInt(a.data()['pendingAmount']);
      final bDue = _toInt(b.data()['pendingAmount']);

      return bDue.compareTo(aDue);
    });

    return sorted;
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
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _feesStream,
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

                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                final allDocs = snapshot.data?.docs ?? [];
                final allDueDocs = _sortByDueAmount(_dueDocs(allDocs, ''));

                int totalPending = 0;
                int highDueCount = 0;
                int mediumDueCount = 0;
                int lowDueCount = 0;

                for (final doc in allDueDocs) {
                  final data = doc.data();
                  final pendingAmount = _toInt(data['pendingAmount']);

                  totalPending += pendingAmount;

                  if (pendingAmount >= 10000) {
                    highDueCount++;
                  } else if (pendingAmount >= 5000) {
                    mediumDueCount++;
                  } else if (pendingAmount > 0) {
                    lowDueCount++;
                  }
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _topHeader(context, isDark)),
                    SliverToBoxAdapter(
                      child: _analyticsHeader(
                        isDark: isDark,
                        totalStudents: allDocs.length,
                        dueStudents: allDueDocs.length,
                        totalPending: totalPending,
                        highDueCount: highDueCount,
                        mediumDueCount: mediumDueCount,
                        lowDueCount: lowDueCount,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(child: _searchBox(isDark)),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: _sectionTitle(AppStrings.dueFeeAnalyticsTitle, isDark),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: _searchQuery,
                      builder: (context, query, _) {
                        final dueDocs =
                            _sortByDueAmount(_dueDocs(allDocs, query));

                        return SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsivePadding.horizontal(context),
                          ),
                          sliver: dueDocs.isEmpty
                              ? SliverToBoxAdapter(child: _emptyCard(isDark))
                              : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = dueDocs[index];
                                  final data = doc.data();

                                  final studentName =
                                      _text(data['studentName']).isNotEmpty
                                          ? _text(data['studentName'])
                                          : _text(data['name']).isNotEmpty
                                              ? _text(data['name'])
                                              : AppStrings.unknownStudent;

                                  final resolvedRollNo =
                                      _resolvedRollNo(data);
                                  final rollNo = resolvedRollNo.isNotEmpty
                                      ? resolvedRollNo
                                      : AppStrings.noRollNo;

                                  final batch = _text(data['batch']).isNotEmpty
                                      ? _text(data['batch'])
                                      : AppStrings.noBatch;

                                  final paidAmount = _toInt(
                                    data['amount'] ?? data['paidAmount'],
                                  );

                                  final pendingAmount =
                                      _toInt(data['pendingAmount']);

                                  final totalFee = _toInt(data['totalFee']) > 0
                                      ? _toInt(data['totalFee'])
                                      : paidAmount + pendingAmount;

                                  return _dueCard(
                                    isDark: isDark,
                                    studentName: studentName,
                                    rollNo: rollNo,
                                    batch: batch,
                                    totalFee: totalFee,
                                    paidAmount: paidAmount,
                                    pendingAmount: pendingAmount,
                                  );
                                },
                                childCount: dueDocs.length,
                              ),
                                ),
                        );
                      },
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
                  AppStrings.dueFeeAnalyticsTitle,
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
                  AppStrings.studentWisePendingFeeAnalysis,
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

  Widget _analyticsHeader({
    required bool isDark,
    required int totalStudents,
    required int dueStudents,
    required int totalPending,
    required int highDueCount,
    required int mediumDueCount,
    required int lowDueCount,
  }) {
    final duePercent =
        totalStudents == 0 ? 0.0 : (dueStudents / totalStudents) * 100;

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
                radius: 30,
                backgroundColor: maroon,
                child: const Icon(
                  Icons.warning_rounded,
                  color: gold,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppStrings.analyzePendingFeesPriority,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: duePercent / 100,
              minHeight: 9,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                duePercent >= 50 ? Colors.redAccent : Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${duePercent.toStringAsFixed(0)}% ${AppStrings.studentsHavePendingDues}",
            style: TextStyle(
              color: duePercent >= 50 ? Colors.redAccent : Colors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.totalDue,
                  value: "₹$totalPending",
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.dueStudents,
                  value: dueStudents.toString(),
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.high,
                  value: highDueCount.toString(),
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.medium,
                  value: mediumDueCount.toString(),
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _miniBox(
                  isDark: isDark,
                  label: AppStrings.low,
                  value: lowDueCount.toString(),
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniBox({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
              fontSize: 15,
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

  Widget _searchBox(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        textInputAction: TextInputAction.search,
        onChanged: (value) {
          _searchQuery.value = value;
        },
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded,
            color: isDark ? Colors.white54 : maroon,
          ),
          hintText: AppStrings.searchDueStudents,
          hintStyle: TextStyle(
            color: _secondaryText(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
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

  Widget _dueCard({
    required bool isDark,
    required String studentName,
    required String rollNo,
    required String batch,
    required int totalFee,
    required int paidAmount,
    required int pendingAmount,
  }) {
    final risk = _riskLabel(pendingAmount);
    final color = _riskColor(pendingAmount);

    final paidPercent =
        totalFee == 0 ? 0.0 : (paidAmount / totalFee).clamp(0, 1).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.14),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
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
                      "$rollNo • $batch",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.13 : 0.09),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: Text(
                  risk,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: paidPercent,
              minHeight: 8,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.10)
                  : Colors.black.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: AppStrings.total,
                  value: "₹$totalFee",
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: AppStrings.paid,
                  value: "₹$paidAmount",
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _amountBox(
                  isDark: isDark,
                  label: AppStrings.due,
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

  Widget _amountBox({
    required bool isDark,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 12.5,
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
            Icons.verified_rounded,
            size: 42,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noDueFeesFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.noPendingFeeRecordsAvailable,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
