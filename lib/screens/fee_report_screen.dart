import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../services/pdf_service.dart';
import '../services/excel_service.dart';

class FeeReportScreen extends StatefulWidget {
  const FeeReportScreen({super.key});

  @override
  State<FeeReportScreen> createState() => _FeeReportScreenState();
}

class _FeeReportScreenState extends State<FeeReportScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;

  String uid = '';
  String role = '';
  String email = '';

  List<String> assignedBatches = [];
  List<String> linkedChildrenIds = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.round();

    final cleaned = value
        .toString()
        .replaceAll("₹", "")
        .replaceAll(",", "")
        .trim();

    return int.tryParse(cleaned) ?? 0;
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

  List<String> _listFromDynamic(dynamic value) {
    final result = <String>[];

    if (value is List) {
      for (final item in value) {
        final text = _text(item);
        if (text.isNotEmpty) result.add(text);
      }
    }

    return result;
  }

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    final data = userDoc.data() ?? {};
    final loadedRole = _text(data['role']);

    final batches = _listFromDynamic(data['assignedBatches']);

    final assignedBatch = _text(data['assignedBatch']);
    final batch = _text(data['batch']);

    if (assignedBatch.isNotEmpty && !batches.contains(assignedBatch)) {
      batches.add(assignedBatch);
    }

    if (batch.isNotEmpty && !batches.contains(batch)) {
      batches.add(batch);
    }

    final children = <String>{};

    for (final id in _listFromDynamic(data['linkedChildrenIds'])) {
      children.add(id);
    }

    final childId = _text(data['childId']);
    if (childId.isNotEmpty) children.add(childId);

    final studentId = _text(data['studentId']);
    if (studentId.isNotEmpty) children.add(studentId);

    final parentEmail = _lower(
      _text(data['email']).isNotEmpty ? _text(data['email']) : email,
    );

    if (loadedRole == 'Parent') {
      if (parentEmail.isNotEmpty) {
        final byParentEmailLower = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmailLower', isEqualTo: parentEmail)
            .get();

        for (final doc in byParentEmailLower.docs) {
          children.add(doc.id);
        }

        final byParentEmail = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmail', isEqualTo: parentEmail)
            .get();

        for (final doc in byParentEmail.docs) {
          children.add(doc.id);
        }
      }

      final byParentUid = await FirebaseFirestore.instance
          .collection('students')
          .where('parentUid', isEqualTo: uid)
          .get();

      for (final doc in byParentUid.docs) {
        children.add(doc.id);
      }
    }

    if (!mounted) return;

    setState(() {
      role = loadedRole;
      assignedBatches = batches;
      linkedChildrenIds = children.toList();
      loadingUser = false;
    });
  }

  int _amount(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data.containsKey(key) && data[key] != null) {
        return _toInt(data[key]);
      }
    }

    return 0;
  }

  DateTime _createdAt(Map<String, dynamic> data) {
    final value = data['createdAt'];

    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  int _totalFee(Map<String, dynamic> data) {
    return _amount(data, [
      'totalFee',
      'feeAmount',
      'totalAmount',
      'amount',
    ]);
  }

  int _paidAmount(Map<String, dynamic> data) {
    return _amount(data, [
      'paidAmount',
      'amountPaid',
      'paid',
      'collectedAmount',
    ]);
  }

  int _pendingAmount(Map<String, dynamic> data) {
    final total = _totalFee(data);
    final paid = _paidAmount(data);

    final firebasePending = _amount(data, [
      'pendingAmount',
      'balanceAmount',
      'dueAmount',
      'remainingAmount',
    ]);

    if (firebasePending > 0) return firebasePending;

    final calculatedPending = total - paid;
    return calculatedPending < 0 ? 0 : calculatedPending;
  }

  String _studentName(Map<String, dynamic> data) {
    final name = _text(data['studentName']);
    if (name.isNotEmpty) return name;

    final name2 = _text(data['name']);
    if (name2.isNotEmpty) return name2;

    return AppStrings.unknownStudent;
  }

  String _studentId(Map<String, dynamic> data) {
    final id = _text(data['studentId']);
    if (id.isNotEmpty) return id;

    final id2 = _text(data['uid']);
    if (id2.isNotEmpty) return id2;

    return '';
  }

  String _paymentStatus(Map<String, dynamic> data) {
    final total = _totalFee(data);
    final paid = _paidAmount(data);
    final pending = _pendingAmount(data);

    final rawStatus = _text(
      data['paymentStatus'] ?? data['feeStatus'] ?? data['status'],
    ).toLowerCase();

    if (total > 0 && paid >= total) return 'Paid';
    if (paid > 0 && pending > 0) return 'Partial';
    if (paid == 0 && total > 0) return 'Pending';

    if (rawStatus.contains('paid') && !rawStatus.contains('unpaid')) {
      return 'Paid';
    }

    if (rawStatus.contains('partial')) return 'Partial';
    if (rawStatus.contains('pending')) return 'Pending';
    if (rawStatus.contains('unpaid')) return 'Unpaid';

    return 'Pending';
  }

  String _localizedStatus(String status) {
    switch (status.trim().toLowerCase()) {
      case 'paid':
        return AppStrings.paid;
      case 'partial':
        return AppStrings.partiallyPaid;
      case 'unpaid':
        return AppStrings.unpaid;
      case 'pending':
        return AppStrings.pending;
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.deepOrange;
    }
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _queryByChunks({
    required String field,
    required List<String> values,
  }) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    for (int i = 0; i < values.length; i += 10) {
      final end = i + 10 > values.length ? values.length : i + 10;
      final chunk = values.sublist(i, end);

      final snapshot = await FirebaseFirestore.instance
          .collection('fees')
          .where(field, whereIn: chunk)
          .get();

      docs.addAll(snapshot.docs);
    }

    return docs;
  }

  Future<List<Map<String, dynamic>>> _getFeeRecords() async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];

    if (role == 'Admin') {
      final snapshot = await FirebaseFirestore.instance.collection('fees').get();
      docs.addAll(snapshot.docs);
    } else if (role == 'Coach') {
      if (assignedBatches.isNotEmpty) {
        docs.addAll(
          await _queryByChunks(
            field: 'batch',
            values: assignedBatches.take(10).toList(),
          ),
        );
      }
    } else if (role == 'Student') {
      final snapshot = await FirebaseFirestore.instance
          .collection('fees')
          .where('studentId', isEqualTo: uid)
          .get();

      docs.addAll(snapshot.docs);
    } else if (role == 'Parent') {
      if (linkedChildrenIds.isNotEmpty) {
        docs.addAll(
          await _queryByChunks(
            field: 'studentId',
            values: linkedChildrenIds.take(10).toList(),
          ),
        );
      } else {
        final byParentUid = await FirebaseFirestore.instance
            .collection('fees')
            .where('parentUid', isEqualTo: uid)
            .get();

        docs.addAll(byParentUid.docs);

        if (email.isNotEmpty) {
          final byParentEmailLower = await FirebaseFirestore.instance
              .collection('fees')
              .where('parentEmailLower', isEqualTo: email)
              .get();

          docs.addAll(byParentEmailLower.docs);

          final byParentEmail = await FirebaseFirestore.instance
              .collection('fees')
              .where('parentEmail', isEqualTo: email)
              .get();

          docs.addAll(byParentEmail.docs);
        }
      }
    }

    final unique = <String, Map<String, dynamic>>{};

    for (final doc in docs) {
      unique[doc.id] = {
        'docId': doc.id,
        ...doc.data(),
      };
    }

    final records = unique.values.toList();

    records.sort((a, b) => _createdAt(b).compareTo(_createdAt(a)));

    return records;
  }

  Future<void> _generatePdf(BuildContext context) async {
    try {
      final records = await _getFeeRecords();

      int totalFee = 0;
      int collected = 0;
      int pending = 0;
      int paidRecords = 0;

      for (final data in records) {
        final total = _totalFee(data);
        final paid = _paidAmount(data);
        final pendingAmount = _pendingAmount(data);
        final status = _paymentStatus(data);

        totalFee += total;
        collected += paid;
        pending += pendingAmount;

        if (status == 'Paid') {
          paidRecords++;
        }
      }

      await PdfService.generateFeeReportPdf(
        totalFee: totalFee,
        collected: collected,
        pending: pending,
        paidStudents: paidRecords,
        feeRecords: records,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.pdfReportGenerated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.pdfFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateExcel(BuildContext context) async {
    try {
      final records = await _getFeeRecords();

      await ExcelService.generateFeeReportExcel(
        feeRecords: records,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.excelReportGenerated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.excelFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getFeeRecords(),
                    builder: (context, snapshot) {
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

                      final feeRecords = snapshot.data ?? [];

                      int totalFee = 0;
                      int collected = 0;
                      int pending = 0;
                      int paidRecords = 0;
                      int partialRecords = 0;
                      int pendingRecords = 0;

                      for (final data in feeRecords) {
                        final total = _totalFee(data);
                        final paid = _paidAmount(data);
                        final pendingAmount = _pendingAmount(data);
                        final status = _paymentStatus(data);

                        totalFee += total;
                        collected += paid;
                        pending += pendingAmount;

                        if (status == 'Paid') {
                          paidRecords++;
                        } else if (status == 'Partial') {
                          partialRecords++;
                        } else {
                          pendingRecords++;
                        }
                      }

                      final collectionPercent = totalFee == 0
                          ? 0
                          : ((collected / totalFee) * 100).round();

                      final pendingFeeRecords = feeRecords.where((data) {
                        final status = _paymentStatus(data);
                        final pendingAmount = _pendingAmount(data);

                        return status != 'Paid' || pendingAmount > 0;
                      }).toList();

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroCard(
                              isDark: isDark,
                              collectionPercent: collectionPercent,
                              collected: collected,
                              totalFee: totalFee,
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.feeReportSummary, isDark),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsivePadding.horizontal(context),
                              ),
                              child: GridView.count(
                                crossAxisCount:
                                    ResponsiveHelper.isTablet(context) ||
                                            ResponsiveHelper.isDesktop(context)
                                        ? 4
                                        : 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.18,
                                children: [
                                  _statCard(
                                    isDark: isDark,
                                    title: AppStrings.totalFee,
                                    value: "₹$totalFee",
                                    icon: Icons.account_balance_wallet_rounded,
                                    color: gold,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    title: AppStrings.collected,
                                    value: "₹$collected",
                                    icon: Icons.check_circle_rounded,
                                    color: Colors.green,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    title: AppStrings.pending,
                                    value: "₹$pending",
                                    icon: Icons.warning_amber_rounded,
                                    color: Colors.orange,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    title: AppStrings.paidRecords,
                                    value: paidRecords.toString(),
                                    icon: Icons.verified_rounded,
                                    color: Colors.blueAccent,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _smallStatusCard(
                                      isDark: isDark,
                                      title: AppStrings.partiallyPaid,
                                      value: partialRecords.toString(),
                                      color: Colors.orange,
                                      icon: Icons.timelapse_rounded,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _smallStatusCard(
                                      isDark: isDark,
                                      title: AppStrings.pending,
                                      value: pendingRecords.toString(),
                                      color: Colors.redAccent,
                                      icon: Icons.pending_actions_rounded,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.paymentRecords, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: feeRecords.isEmpty
                                  ? _emptyCard(
                                      isDark,
                                      AppStrings.noFeeRecordsFound,
                                      AppStrings.noFeeRecordForUser,
                                      Icons.receipt_long_rounded,
                                    )
                                  : Column(
                                      children: feeRecords.map((data) {
                                        final name = _studentName(data);
                                        final studentId = _studentId(data);
                                        final total = _totalFee(data);
                                        final paid = _paidAmount(data);
                                        final pendingAmount =
                                            _pendingAmount(data);

                                        final status = _paymentStatus(data);
                                        final color = _statusColor(status);

                                        final progress = total == 0
                                            ? 0.0
                                            : (paid / total).clamp(0.0, 1.0);

                                        return _collectionTile(
                                          isDark: isDark,
                                          title: name,
                                          subtitle: studentId.isEmpty
                                              ? AppStrings.studentIdNotFound
                                              : "ID: $studentId",
                                          status: status,
                                          amount: "₹$paid / ₹$total",
                                          progress: progress,
                                          pending: status == 'Paid'
                                              ? AppStrings.fullyPaid
                                              : "${AppStrings.pending} ₹$pendingAmount",
                                          statusColor: color,
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.pendingFeeRecords, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: pendingFeeRecords.isEmpty
                                  ? _emptyCard(
                                      isDark,
                                      AppStrings.noPendingFees,
                                      AppStrings.allFeeRecordsCompleted,
                                      Icons.check_circle_rounded,
                                    )
                                  : Column(
                                      children: pendingFeeRecords.map((data) {
                                        final status = _paymentStatus(data);
                                        final color = _statusColor(status);

                                        return _pendingStudentCard(
                                          isDark: isDark,
                                          name: _studentName(data),
                                          batch: _studentId(data).isEmpty
                                              ? AppStrings.studentIdNotFound
                                              : "ID: ${_studentId(data)}",
                                          amount:
                                              "₹${_pendingAmount(data)}",
                                          status: status,
                                          color: color,
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.feeReportsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  AppStrings.collectionSummaryExports,
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
          _circleButton(
            isDark: isDark,
            icon: Icons.picture_as_pdf_rounded,
            onTap: () => _generatePdf(context),
          ),
          const SizedBox(width: 8),
          _circleButton(
            isDark: isDark,
            icon: Icons.table_chart_rounded,
            onTap: () => _generateExcel(context),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeController.themeMode,
            builder: (context, mode, _) {
              final dark = mode == ThemeMode.dark;

              return _circleButton(
                isDark: isDark,
                icon: dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
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

  Widget _heroCard({
    required bool isDark,
    required int collectionPercent,
    required int collected,
    required int totalFee,
  }) {
    final progress = (collectionPercent / 100).clamp(0.0, 1.0);
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = ResponsivePadding.horizontal(context);

    return Container(
      height: isMobile ? 200 : 220,
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        0,
      ),
      padding: EdgeInsets.all(isMobile ? 12 : 18),
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
              size: 150,
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 34 : 46,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.analytics_rounded,
                  color: maroon,
                  size: isMobile ? 32 : 42,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 14),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: isMobile ? 205 : 235,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.feeCollection.toUpperCase(),
                          style: TextStyle(
                            color: gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "$collectionPercent%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          AppStrings.completed,
                          style: TextStyle(
                            color: gold,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(gold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹$collected ${AppStrings.collectedFrom} ₹$totalFee",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                  fontSize: 20,
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

  Widget _smallStatusCard({
    required bool isDark,
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: _border(isDark)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: _secondaryText(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _collectionTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required String status,
    required String amount,
    required double progress,
    required String pending,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              _statusChip(_localizedStatus(status), statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              subtitle,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  amount,
                  style: TextStyle(
                    color: isDark ? gold : maroon,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                pending,
                style: TextStyle(
                  color: statusColor,
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
              value: progress,
              backgroundColor:
                  isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingStudentCard({
    required bool isDark,
    required String name,
    required String batch,
    required String amount,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : _border(isDark),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: maroon,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.w900,
              ),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$batch • ${_localizedStatus(status)}",
                  maxLines: 2,
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
          _statusChip(amount, color),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _emptyCard(
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
