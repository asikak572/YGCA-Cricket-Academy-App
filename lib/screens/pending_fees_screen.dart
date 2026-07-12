import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class PendingFeesScreen extends StatefulWidget {
  const PendingFeesScreen({super.key});

  @override
  State<PendingFeesScreen> createState() => _PendingFeesScreenState();
}

class _PendingFeesScreenState extends State<PendingFeesScreen> {
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

  Query<Map<String, dynamic>> _pendingFeesQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('fees');

    if (role == 'Admin') {
      return query;
    }

    if (role == 'Coach') {
      if (assignedBatches.isEmpty) {
        return query.where('batch', isEqualTo: '__NO_ASSIGNED_BATCH__');
      }

      if (assignedBatches.length == 1) {
        return query.where('batch', isEqualTo: assignedBatches.first);
      }

      return query.where(
        'batch',
        whereIn: assignedBatches.take(10).toList(),
      );
    }

    if (role == 'Student') {
      return query.where('studentId', isEqualTo: uid);
    }

    if (role == 'Parent') {
      if (linkedChildrenIds.isEmpty) {
        return query.where('parentUid', isEqualTo: uid);
      }

      if (linkedChildrenIds.length == 1) {
        return query.where('studentId', isEqualTo: linkedChildrenIds.first);
      }

      return query.where(
        'studentId',
        whereIn: linkedChildrenIds.take(10).toList(),
      );
    }

    return query.where('studentId', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortPendingDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final pendingDocs = docs.where((doc) {
      final pending = _toInt(doc.data()['pendingAmount']);
      return pending > 0;
    }).toList();

    pendingDocs.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return pendingDocs;
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
                    stream: _pendingFeesQuery().snapshots(),
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

                      final pendingStudents =
                          _sortPendingDocs(snapshot.data?.docs ?? []);

                      int totalPending = 0;
                      int totalPaid = 0;

                      for (final doc in pendingStudents) {
                        final data = doc.data();
                        totalPending += _toInt(data['pendingAmount']);
                        totalPaid += _toInt(data['paidAmount']);
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroBanner(
                              isDark: isDark,
                              totalPending: totalPending,
                              pendingCount: pendingStudents.length,
                              totalPaid: totalPaid,
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.pendingOverview, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.18,
                                children: [
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.warning_amber_rounded,
                                    title: AppStrings.pending.toUpperCase(),
                                    value: "₹$totalPending",
                                    subtitle: AppStrings.totalAmount,
                                    color: Colors.orange,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.groups_rounded,
                                    title: "STUDENTS",
                                    value: pendingStudents.length.toString(),
                                    subtitle: AppStrings.withDue,
                                    color: Colors.redAccent,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.payments_rounded,
                                    title: "PAID",
                                    value: "₹$totalPaid",
                                    subtitle: AppStrings.collected,
                                    color: Colors.green,
                                  ),
                                  _statCard(
                                    isDark: isDark,
                                    icon: Icons.receipt_long_rounded,
                                    title: "RECORDS",
                                    value: pendingStudents.length.toString(),
                                    subtitle: AppStrings.feeEntries,
                                    color: Colors.purpleAccent,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.pendingFeeList, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: pendingStudents.isEmpty
                                  ? _emptyCard(isDark)
                                  : Column(
                                      children: pendingStudents.map((doc) {
                                        final data = doc.data();

                                        final name =
                                            _text(data['studentName']).isEmpty
                                                ? AppStrings.unknown
                                                : _text(data['studentName']);

                                        final studentId =
                                            _text(data['studentId']);

                                        final batch = _text(data['batch']);

                                        final totalFee =
                                            _toInt(data['totalFee']);

                                        final paidAmount =
                                            _toInt(data['paidAmount']);

                                        final pendingAmount =
                                            _toInt(data['pendingAmount']);

                                        final date =
                                            _formatDate(data['createdAt']);

                                        return _pendingCard(
                                          isDark: isDark,
                                          name: name,
                                          studentId: studentId,
                                          batch: batch,
                                          totalFee: totalFee,
                                          paidAmount: paidAmount,
                                          pendingAmount: pendingAmount,
                                          date: date,
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
                Text(
                  AppStrings.pendingFeesTitle,
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
                  AppStrings.trackUnpaidStudentDues,
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

  Widget _heroBanner({
    required bool isDark,
    required int totalPending,
    required int pendingCount,
    required int totalPaid,
  }) {
    return Container(
      height: 220,
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
              Icons.warning_amber_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
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
                    Icons.currency_rupee_rounded,
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
                            AppStrings.pending.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.fees.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.due}: ₹$totalPending"),
                              _heroChip("${AppStrings.students}: $pendingCount"),
                              _heroChip("${AppStrings.paid}: ₹$totalPaid"),
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
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 165),
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

  Widget _statCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
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
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
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

  Widget _pendingCard({
    required bool isDark,
    required String name,
    required String studentId,
    required String batch,
    required int totalFee,
    required int paidAmount,
    required int pendingAmount,
    required String date,
  }) {
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
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: maroon,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                  style: const TextStyle(
                    color: gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      batch.isEmpty ? "ID: $studentId" : "$batch • $date",
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
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.25),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      AppStrings.pending,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip(
                isDark: isDark,
                icon: Icons.payments_rounded,
                text: "${AppStrings.paid} ₹$paidAmount",
                color: Colors.green,
              ),
              _chip(
                isDark: isDark,
                icon: Icons.warning_amber_rounded,
                text: "${AppStrings.due} ₹$pendingAmount",
                color: Colors.redAccent,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(
                    isDark ? 0.13 : 0.09,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.24),
                  ),
                ),
                child: Text(
                  "₹$pendingAmount",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
          Flexible(
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
          ),
        ],
      ),
    );
  }

  Widget _emptyCard(bool isDark) {
    return Container(
      width: double.infinity,
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
            size: 40,
            color: Colors.green,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noPendingFeesFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.allStudentsAreClear,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}