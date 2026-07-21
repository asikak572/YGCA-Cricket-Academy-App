import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';

import 'notification_service.dart';

class FeeManagementScreen extends StatefulWidget {
  const FeeManagementScreen({super.key});

  @override
  State<FeeManagementScreen> createState() => _FeeManagementScreenState();
}

class _FeeManagementScreenState extends State<FeeManagementScreen> {
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

  String _localizedFeeStatus(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized == 'paid') return AppStrings.paid;
    if (normalized == 'pending') return AppStrings.pending;
    if (normalized == 'unpaid') return AppStrings.unpaid;
    if (normalized == 'partial' || normalized == 'partially paid') {
      return AppStrings.partiallyPaid;
    }

    return value;
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

  Query<Map<String, dynamic>> _feeQuery() {
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

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortFeeDocs(
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

  bool get _canAddPayment {
    return role == 'Admin';
  }

  Future<void> _addPaymentDialog(BuildContext context, bool isDark) async {
    String? selectedStudentId;
    String selectedStudentName = '';
    String selectedBatch = '';
    String selectedParentUid = '';
    String selectedParentEmail = '';

    final totalFeeController = TextEditingController();
    final paidAmountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
              title: Text(
                AppStrings.addFeePayment,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('students')
                          .orderBy('name')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text(
                            AppStrings.noStudentsFound,
                            style: TextStyle(color: _secondaryText(isDark)),
                          );
                        }

                        final students = snapshot.data!.docs;

                        return DropdownButtonFormField<String>(
                          value: selectedStudentId,
                          isExpanded: true,
                          dropdownColor:
                              isDark ? const Color(0xFF111111) : Colors.white,
                          style: TextStyle(
                            color: _primaryText(isDark),
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            labelText: AppStrings.selectStudent,
                            labelStyle: TextStyle(
                              color: _secondaryText(isDark),
                            ),
                            border: const OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: _border(isDark)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: isDark ? red : maroon),
                            ),
                          ),
                          items: students.map((doc) {
                            final data = doc.data();

                            final name = _text(data['name']).isNotEmpty
                                ? _text(data['name'])
                                : _text(data['studentName']).isNotEmpty
                                    ? _text(data['studentName'])
                                    : AppStrings.noName;

                            final batch = _text(data['batch']).isNotEmpty
                                ? _text(data['batch'])
                                : AppStrings.noBatch;

                            return DropdownMenuItem<String>(
                              value: doc.id,
                              child: Text(
                                "$name - $batch",
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            final selectedDoc = students.firstWhere(
                              (doc) => doc.id == value,
                            );

                            final data = selectedDoc.data();

                            setDialogState(() {
                              selectedStudentId = selectedDoc.id;

                              selectedStudentName =
                                  _text(data['name']).isNotEmpty
                                      ? _text(data['name'])
                                      : _text(data['studentName']);

                              selectedBatch = _text(data['batch']);
                              selectedParentUid = _text(data['parentUid']);
                              selectedParentEmail =
                                  _lower(_text(data['parentEmail']));
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _dialogField(
                      isDark: isDark,
                      label: AppStrings.totalFee,
                      controller: totalFeeController,
                      keyboardType: TextInputType.number,
                    ),
                    _dialogField(
                      isDark: isDark,
                      label: AppStrings.paidAmount,
                      controller: paidAmountController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.cancel,
                    style: TextStyle(color: isDark ? Colors.white70 : maroon),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                  ),
                  onPressed: () async {
                    if (selectedStudentId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.pleaseSelectStudent),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final totalFee =
                        int.tryParse(totalFeeController.text.trim()) ?? 0;

                    final paidAmount =
                        int.tryParse(paidAmountController.text.trim()) ?? 0;

                    if (totalFee <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.enterValidTotalFee),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (paidAmount < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppStrings.enterValidPaidAmount),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final pending = totalFee - paidAmount;
                    final safePending = pending < 0 ? 0 : pending;
                    // Store a language-independent value in Firestore.
                    // The UI translates this value when it is displayed.
                    final status = safePending <= 0 ? 'Paid' : 'Pending';

                    try {
                      await FirebaseFirestore.instance.collection('fees').add({
                        'studentId': selectedStudentId,
                        'studentName': selectedStudentName,
                        'batch': selectedBatch,
                        'parentUid': selectedParentUid,
                        'parentEmail': selectedParentEmail,
                        'parentEmailLower': selectedParentEmail,
                        'totalFee': totalFee,
                        'paidAmount': paidAmount,
                        'pendingAmount': safePending,
                        'status': status,
                        'createdBy': uid,
                        'createdAt': FieldValue.serverTimestamp(),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });

                      await FirebaseFirestore.instance
                          .collection('students')
                          .doc(selectedStudentId)
                          .set({
                        'totalFee': totalFee,
                        'paidAmount': paidAmount,
                        'pendingAmount': safePending,
                        'feeStatus': status,
                        'lastFeeUpdatedAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));

                      if (safePending > 0 && selectedStudentId != null) {
                        try {
                          await NotificationService.feeReminder(
                            studentName: selectedStudentName,
                            studentId: selectedStudentId!,
                            pendingAmount: safePending,
                          );
                        } catch (_) {}
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.feePaymentSaved),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${AppStrings.saveFailed}: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(AppStrings.save),
                ),
              ],
            );
          },
        );
      },
    );

    totalFeeController.dispose();
    paidAmountController.dispose();
  }

  Widget _dialogField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryText(isDark)),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? red : maroon),
          ),
        ),
      ),
    );
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
          floatingActionButton: _canAddPayment
              ? SafeArea(
                  child: FloatingActionButton.extended(
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                    onPressed: () => _addPaymentDialog(context, isDark),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      AppStrings.addPayment,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                    stream: _feeQuery().snapshots(),
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

                      final fees = _sortFeeDocs(snapshot.data?.docs ?? []);

                      int totalCollection = 0;
                      int totalPending = 0;

                      for (final doc in fees) {
                        final data = doc.data();
                        totalCollection += _toInt(data['paidAmount']);
                        totalPending += _toInt(data['pendingAmount']);
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroCard(
                              isDark: isDark,
                              totalCollection: totalCollection,
                              totalPending: totalPending,
                              records: fees.length,
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.feeRecords, isDark),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: ResponsivePadding.horizontal(context),
                              ),
                              child: fees.isEmpty
                                  ? _emptyCard(isDark)
                                  : Column(
                                      children: fees.map((doc) {
                                        final data = doc.data();

                                        final name =
                                            _text(data['studentName']).isEmpty
                                                ? AppStrings.unknownStudent
                                                : _text(data['studentName']);

                                        final batch = _text(data['batch']);

                                        final total = _toInt(data['totalFee']);
                                        final paid = _toInt(data['paidAmount']);
                                        final pending =
                                            _toInt(data['pendingAmount']);

                                        // Derive the canonical status from the
                                        // amount so older records containing a
                                        // translated status also display in the
                                        // currently selected language.
                                        final canonicalStatus =
                                            pending <= 0 ? 'Paid' : 'Pending';
                                        final localizedStatus =
                                            _localizedFeeStatus(canonicalStatus);

                                        return _feeTile(
                                          isDark: isDark,
                                          name: name,
                                          batch: batch,
                                          total: "₹$total",
                                          paid: "₹$paid",
                                          pending: "₹$pending",
                                          status: localizedStatus,
                                          statusColor: pending <= 0
                                              ? Colors.green
                                              : Colors.orange,
                                        );
                                      }).toList(),
                                    ),
                            ),
                            const SizedBox(height: 90),
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
                  AppStrings.feeManagementTitle,
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
                  _canAddPayment
                      ? AppStrings.collectManageStudentFees
                      : AppStrings.viewFeePaymentRecords,
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

  Widget _heroCard({
    required bool isDark,
    required int totalCollection,
    required int totalPending,
    required int records,
  }) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final horizontalPadding = ResponsivePadding.horizontal(context);

    return Container(
      height: isMobile ? 215 : 230,
      margin: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        0,
      ),
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
              Icons.currency_rupee_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // A normal phone still has enough room for the original
                // horizontal hero. Stack only on extremely narrow screens.
                final compact = constraints.maxWidth < 240;

                final icon = CircleAvatar(
                  radius: compact ? 40 : 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.currency_rupee_rounded,
                    color: maroon,
                    size: compact ? 36 : 42,
                  ),
                );

                final content = FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: compact ? Alignment.center : Alignment.centerLeft,
                  child: SizedBox(
                    width: 235,
                    child: Column(
                      crossAxisAlignment: compact
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.totalCollection,
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          "₹$totalCollection",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          AppStrings.feeRecordsTitle,
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: gold,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: compact
                              ? WrapAlignment.center
                              : WrapAlignment.start,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _heroChip("${AppStrings.pending}: ₹$totalPending"),
                            _heroChip("${AppStrings.records}: $records"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                if (compact) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      const SizedBox(height: 10),
                      Expanded(child: content),
                    ],
                  );
                }

                return Row(
                  children: [
                    icon,
                    const SizedBox(width: 14),
                    Expanded(child: content),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
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

  Widget _emptyCard(bool isDark) {
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
            Icons.receipt_long_rounded,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noFeeRecordsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _canAddPayment
                ? AppStrings.clickAddPaymentCreateOne
                : AppStrings.noFeeRecordsAvailable,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _feeTile({
    required bool isDark,
    required String name,
    required String batch,
    required String total,
    required String paid,
    required String pending,
    required String status,
    required Color statusColor,
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
        children: [
          Row(
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      batch.isEmpty ? AppStrings.noBatch : batch,
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
              _statusChip(status, statusColor),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              // Keep Total, Paid and Pending in one row on normal phones.
              // Use the wrapped fallback only on exceptionally narrow widths.
              if (constraints.maxWidth < 260) {
                final boxWidth = (constraints.maxWidth - 8) / 2;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: boxWidth,
                      child: _amountBox(
                        isDark: isDark,
                        title: AppStrings.total,
                        amount: total,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(
                      width: boxWidth,
                      child: _amountBox(
                        isDark: isDark,
                        title: AppStrings.paid,
                        amount: paid,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(
                      width: boxWidth,
                      child: _amountBox(
                        isDark: isDark,
                        title: AppStrings.pending,
                        amount: pending,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _amountBox(
                      isDark: isDark,
                      title: AppStrings.total,
                      amount: total,
                      color: Colors.blueAccent,
                    ),
                  ),
                  Expanded(
                    child: _amountBox(
                      isDark: isDark,
                      title: AppStrings.paid,
                      amount: paid,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _amountBox(
                      isDark: isDark,
                      title: AppStrings.pending,
                      amount: pending,
                      color: Colors.orange,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _amountBox({
    required bool isDark,
    required String title,
    required String amount,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
