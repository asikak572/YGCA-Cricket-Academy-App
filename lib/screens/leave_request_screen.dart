import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_text.dart';

import 'notification_service.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  String _localizedStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return AppStrings.pending;
      case 'approved':
        return AppStrings.approved;
      case 'rejected':
        return AppStrings.rejected;
      default:
        return value;
    }
  }

  List<String> _stringList(dynamic value) {
    final result = <String>[];

    if (value is List) {
      for (final item in value) {
        final text = _text(item);
        if (text.isNotEmpty) result.add(text);
      }
    }

    return result;
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

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        userData = {};
        loadingUser = false;
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!mounted) return;

    if (!doc.exists) {
      setState(() {
        userData = {};
        loadingUser = false;
      });
      return;
    }

    final data = doc.data() ?? {};
    final loadedRole = _text(data['role']);

    final parentLinkedIds = <String>{};

    final linkedChildrenIds = data['linkedChildrenIds'];
    if (linkedChildrenIds is List) {
      for (final item in linkedChildrenIds) {
        final value = _text(item);
        if (value.isNotEmpty) parentLinkedIds.add(value);
      }
    }

    final childId = _text(data['childId']);
    if (childId.isNotEmpty) parentLinkedIds.add(childId);

    final studentId = _text(data['studentId']);
    if (studentId.isNotEmpty) parentLinkedIds.add(studentId);

    final userEmail = _lower(
      _text(data['email']).isNotEmpty ? _text(data['email']) : user.email ?? '',
    );

    if (loadedRole == 'Parent') {
      if (userEmail.isNotEmpty) {
        final byParentEmailLower = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmailLower', isEqualTo: userEmail)
            .get();

        for (final doc in byParentEmailLower.docs) {
          parentLinkedIds.add(doc.id);
        }

        final byParentEmail = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmail', isEqualTo: userEmail)
            .get();

        for (final doc in byParentEmail.docs) {
          parentLinkedIds.add(doc.id);
        }
      }

      final byParentUid = await FirebaseFirestore.instance
          .collection('students')
          .where('parentUid', isEqualTo: user.uid)
          .get();

      for (final doc in byParentUid.docs) {
        parentLinkedIds.add(doc.id);
      }
    }

    setState(() {
      userData = {
        'uid': user.uid,
        'authEmail': user.email ?? '',
        ...data,
        if (loadedRole == 'Parent') 'linkedChildrenIds': parentLinkedIds.toList(),
      };
      loadingUser = false;
    });
  }

  Future<Map<String, dynamic>?> _getStudentDoc(String studentId) async {
    final studentDoc =
        await FirebaseFirestore.instance.collection('students').doc(studentId).get();

    if (studentDoc.exists && studentDoc.data() != null) {
      return {
        'studentId': studentId,
        ...studentDoc.data()!,
      };
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(studentId).get();

    if (userDoc.exists && userDoc.data() != null) {
      return {
        'studentId': studentId,
        ...userDoc.data()!,
      };
    }

    return null;
  }

  Query<Map<String, dynamic>> _leaveQuery() {
    final role = _text(userData['role']);
    final uid = _text(userData['uid']);

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('leave_requests');

    if (role == 'Admin') {
      return query;
    }

    if (role == 'Student') {
      return query.where('studentId', isEqualTo: uid);
    }

    if (role == 'Parent') {
      final linkedChildrenIds = _stringList(userData['linkedChildrenIds']);

      if (linkedChildrenIds.isEmpty) {
        return query.where('parentId', isEqualTo: uid);
      }

      if (linkedChildrenIds.length == 1) {
        return query.where('studentId', isEqualTo: linkedChildrenIds.first);
      }

      return query.where(
        'studentId',
        whereIn: linkedChildrenIds.take(10).toList(),
      );
    }

    if (role == 'Coach') {
      final assignedBatches = _stringList(userData['assignedBatches']);

      final assignedBatch = _text(userData['assignedBatch']);
      final batch = _text(userData['batch']);

      if (assignedBatch.isNotEmpty && !assignedBatches.contains(assignedBatch)) {
        assignedBatches.add(assignedBatch);
      }

      if (batch.isNotEmpty && !assignedBatches.contains(batch)) {
        assignedBatches.add(batch);
      }

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

    return query.where('studentId', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortLeaveDocs(
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

  String _autoMakeupBatch(String originalBatch) {
    final batch = originalBatch.trim();
    final lower = batch.toLowerCase();

    String day = '';

    if (batch.contains(':')) {
      day = batch.split(':').first.trim();
    }

    final prefix = day.isNotEmpty ? '$day: ' : '';

    if (lower.contains('morning') || lower.contains('am')) {
      return '${prefix}4:00 PM – 6:00 PM';
    }

    if (lower.contains('evening') || lower.contains('pm')) {
      return '${prefix}7:00 AM – 9:00 AM';
    }

    return '${prefix}Alternate Makeup Batch';
  }

  Future<void> _createMakeupSessionForLeave({
    required String leaveRequestId,
    required Map<String, dynamic> leaveData,
  }) async {
    final studentId = _text(leaveData['studentId']);

    final studentName = _text(
      _text(leaveData['studentName']).isNotEmpty
          ? leaveData['studentName']
          : leaveData['name'],
    );

    final originalBatch = _text(leaveData['batch']);

    final leaveDate = _text(
      _text(leaveData['date']).isNotEmpty
          ? leaveData['date']
          : leaveData['leaveDate'],
    );

    final reason = _text(leaveData['reason']);

    String parentUid = _text(
      _text(leaveData['parentId']).isNotEmpty
          ? leaveData['parentId']
          : leaveData['parentUid'],
    );

    if (studentId.isNotEmpty) {
      final studentData = await _getStudentDoc(studentId);

      if (studentData != null && parentUid.isEmpty) {
        parentUid = _text(studentData['parentUid']);
      }
    }

    final makeupBatch = _autoMakeupBatch(originalBatch);

    final makeupDocRef =
        FirebaseFirestore.instance.collection('makeup_sessions').doc(leaveRequestId);

    await makeupDocRef.set({
      'leaveRequestId': leaveRequestId,
      'studentId': studentId,
      'studentName': studentName,
      'parentUid': parentUid,
      'batch': originalBatch,
      'originalBatch': originalBatch,
      'makeupBatch': makeupBatch,
      'leaveDate': leaveDate,
      'cancelledDate': leaveDate,
      'reason': reason,
      'status': 'Pending',
      'createdFrom': 'Leave Request',
      'approvedBy': _text(userData['uid']),
      'approvedByRole': _text(userData['role']),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('leave_requests').doc(leaveRequestId).set({
      'makeupSessionCreated': true,
      'makeupSessionId': leaveRequestId,
      'makeupBatch': makeupBatch,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required String docId,
    required String status,
    required Map<String, dynamic> leaveData,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('leave_requests').doc(docId).set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (status == "Approved") {
        await _createMakeupSessionForLeave(
          leaveRequestId: docId,
          leaveData: leaveData,
        );
      }

      try {
        await NotificationService.leaveStatus(
          studentName: _text(
            _text(leaveData['studentName']).isNotEmpty
                ? leaveData['studentName']
                : leaveData['name'],
          ),
          status: status,
        );
      } catch (_) {}

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "Approved"
                ? AppStrings.leaveApprovedMakeupCreated
                : AppStrings.leaveRejected,
          ),
          backgroundColor: status == "Approved" ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.updateFailed}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteLeave(BuildContext context, String docId) async {
    await FirebaseFirestore.instance.collection('leave_requests').doc(docId).delete();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.leaveRequestDeleted),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
        title: Text(
          AppStrings.deleteLeaveRequest,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          AppStrings.deleteLeaveRequestConfirm,
          style: TextStyle(color: _secondaryText(isDark)),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteLeave(context, docId);
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Rejected") return Colors.redAccent;
    return Colors.orange;
  }

  bool _canApprove(String role) {
    return role == 'Admin' || role == 'Coach';
  }

  bool _canDelete(String role) {
    return role == 'Admin';
  }

  bool _canCreate(String role) {
    return role == 'Student' || role == 'Parent';
  }

  bool _showMakeupInfo(Map<String, dynamic> data) {
    return _text(data['makeupBatch']).isNotEmpty ||
        data['makeupSessionCreated'] == true;
  }

  Future<void> _openLeaveForm() async {
    final submitted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => LeaveFormScreen(userData: userData),
      ),
    );

    if (!mounted) return;

    if (submitted == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.leaveRequestSubmitted),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  int _countByStatus(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String status,
  ) {
    int count = 0;

    for (final doc in docs) {
      final currentStatus =
          _text(doc.data()['status']).isEmpty ? 'Pending' : _text(doc.data()['status']);

      if (currentStatus == status) count++;
    }

    return count;
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
            final role = _text(userData['role']);

            return Scaffold(
          backgroundColor: _bg(isDark),
          floatingActionButton: _canCreate(role)
              ? FloatingActionButton.extended(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                  onPressed: _openLeaveForm,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    AppStrings.newLeave,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                )
              : null,
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
                : userData.isEmpty
                    ? Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: _messageCard(
                              isDark,
                              AppStrings.userDataNotFound,
                              Icons.person_off_rounded,
                            ),
                          ),
                        ],
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _leaveQuery().snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                _topHeader(context, isDark),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        ResponsivePadding.horizontal(context),
                                      ),
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

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Column(
                              children: [
                                _topHeader(context, isDark),
                                const Expanded(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ],
                            );
                          }

                          final requests = _sortLeaveDocs(snapshot.data?.docs ?? []);

                          final pending = _countByStatus(requests, "Pending");
                          final approved = _countByStatus(requests, "Approved");
                          final rejected = _countByStatus(requests, "Rejected");

                          return Column(
                            children: [
                              _topHeader(context, isDark),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      _heroBanner(
                                        isDark: isDark,
                                        total: requests.length,
                                        pending: pending,
                                        approved: approved,
                                        rejected: rejected,
                                      ),
                                      const SizedBox(height: 14),
                                      _sectionTitle(AppStrings.leaveRequestsTitle, isDark),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal:
                                              ResponsivePadding.horizontal(context),
                                        ),
                                        child: requests.isEmpty
                                            ? _emptyCard(isDark)
                                            : Column(
                                                children: requests.map((doc) {
                                                  final data = doc.data();

                                                  final name = _text(
                                                    _text(data['name']).isNotEmpty
                                                        ? data['name']
                                                        : data['studentName'],
                                                  );

                                                  final batch = _text(data['batch']);

                                                  final date = _text(
                                                    _text(data['date']).isNotEmpty
                                                        ? data['date']
                                                        : data['leaveDate'],
                                                  );

                                                  final reason =
                                                      _text(data['reason']);

                                                  final status =
                                                      _text(data['status']).isEmpty
                                                          ? 'Pending'
                                                          : _text(data['status']);

                                                  final requestedBy =
                                                      _text(data['requestedBy'])
                                                              .isEmpty
                                                          ? 'Unknown'
                                                          : _text(
                                                              data['requestedBy'],
                                                            );

                                                  return _leaveCard(
                                                    context: context,
                                                    isDark: isDark,
                                                    docId: doc.id,
                                                    data: data,
                                                    name: name,
                                                    batch: batch,
                                                    date: date,
                                                    reason: reason,
                                                    status: status,
                                                    requestedBy: requestedBy,
                                                    role: role,
                                                  );
                                                }).toList(),
                                              ),
                                      ),
                                      const SizedBox(height: 90),
                                    ],
                                  ),
                                ),
                              ),
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
                  AppStrings.leaveRequestsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: ResponsiveText.heading(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.approvalMakeupFlow,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: ResponsiveText.small(context),
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

  Widget _heroBanner({
    required bool isDark,
    required int total,
    required int pending,
    required int approved,
    required int rejected,
  }) {
    return Container(
      height: 220,
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        12,
        ResponsivePadding.horizontal(context),
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
              Icons.event_available_rounded,
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
                    Icons.event_available_rounded,
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
                      width: 230,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.academy.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: ResponsiveText.statLabel(context),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.leave.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ResponsiveText.hero(context),
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.center.toUpperCase(),
                            style: TextStyle(
                              color: gold,
                              fontSize: ResponsiveText.heroSubtitle(context),
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _heroChip("${AppStrings.total}: $total"),
                              _heroChip("${AppStrings.pending}: $pending"),
                              _heroChip("${AppStrings.approved}: $approved"),
                              _heroChip("${AppStrings.rejected}: $rejected"),
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
      constraints: const BoxConstraints(maxWidth: 155),
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
          fontSize: ResponsiveText.small(context),
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
                  fontSize: ResponsiveText.cardTitle(context),
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

  Widget _leaveCard({
    required BuildContext context,
    required bool isDark,
    required String docId,
    required Map<String, dynamic> data,
    required String name,
    required String batch,
    required String date,
    required String reason,
    required String status,
    required String requestedBy,
    required String role,
  }) {
    final statusColor = _getStatusColor(status);

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
                      name.isEmpty ? AppStrings.unknownStudent : name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: ResponsiveText.cardTitle(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      batch.isEmpty ? AppStrings.noBatch : batch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText(isDark),
                        fontSize: ResponsiveText.bodySmall(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _statusChip(_localizedStatus(status), statusColor),
              if (_canDelete(role))
                IconButton(
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.redAccent,
                    size: 21,
                  ),
                  onPressed: () => _confirmDelete(context, docId, isDark),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _row(isDark, AppStrings.leaveDate, date.isEmpty ? "-" : date),
          _row(isDark, AppStrings.reason, reason.isEmpty ? "-" : reason),
          _row(isDark, AppStrings.requestedBy, requestedBy),
          if (_showMakeupInfo(data))
            _row(
              isDark,
              AppStrings.makeupBatch,
              _text(data['makeupBatch']).isEmpty
                  ? AppStrings.created
                  : _text(data['makeupBatch']),
            ),
          if (status == "Pending" && _canApprove(role)) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await _updateStatus(
                        context: context,
                        docId: docId,
                        status: "Rejected",
                        leaveData: data,
                      );
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: Text(
                      AppStrings.reject,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? red : maroon,
                      foregroundColor: isDark ? Colors.white : gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      await _updateStatus(
                        context: context,
                        docId: docId,
                        status: "Approved",
                        leaveData: data,
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text(
                      AppStrings.approve,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          fontSize: ResponsiveText.small(context),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _row(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: ResponsiveText.bodySmall(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w800,
                fontSize: ResponsiveText.bodySmall(context),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border(isDark)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noLeaveRequestsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.leaveRequestsAppearHere,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _messageCard(bool isDark, String message, IconData icon) {
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaveFormScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const LeaveFormScreen({
    super.key,
    required this.userData,
  });

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController leaveDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  bool loadingChildren = true;
  bool submitting = false;

  List<Map<String, dynamic>> linkedChildren = [];
  Map<String, dynamic>? selectedChild;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    nameController.dispose();
    batchController.dispose();
    leaveDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  String get role => _text(widget.userData['role']);

  String get uid => _text(widget.userData['uid']);

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

  Future<Map<String, dynamic>?> _getStudentDoc(String studentId) async {
    final studentDoc =
        await FirebaseFirestore.instance.collection('students').doc(studentId).get();

    if (studentDoc.exists && studentDoc.data() != null) {
      return {
        'studentId': studentId,
        ...studentDoc.data()!,
      };
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(studentId).get();

    if (userDoc.exists && userDoc.data() != null) {
      return {
        'studentId': studentId,
        ...userDoc.data()!,
      };
    }

    return null;
  }

  Future<void> _loadInitialData() async {
    final children = await _getLinkedChildren();

    if (!mounted) return;

    linkedChildren = children;

    if (role == 'Student') {
      final studentData =
          linkedChildren.isNotEmpty ? linkedChildren.first : widget.userData;

      nameController.text = _text(
        _text(studentData['name']).isNotEmpty
            ? studentData['name']
            : studentData['studentName'],
      );

      batchController.text = _text(studentData['batch']);
    }

    if (role == 'Parent' && linkedChildren.length == 1) {
      selectedChild = linkedChildren.first;

      nameController.text = _text(
        _text(selectedChild!['name']).isNotEmpty
            ? selectedChild!['name']
            : selectedChild!['studentName'],
      );

      batchController.text = _text(selectedChild!['batch']);
    }

    setState(() {
      loadingChildren = false;
    });
  }

  Future<List<Map<String, dynamic>>> _getLinkedChildren() async {
    if (role == 'Student') {
      final studentData = await _getStudentDoc(uid);

      if (studentData != null) {
        return [studentData];
      }

      return [
        {
          'studentId': uid,
          'name': _text(widget.userData['name']),
          'batch': _text(widget.userData['batch']),
          'parentUid': _text(widget.userData['parentUid']),
        }
      ];
    }

    if (role != 'Parent') return [];

    final children = <Map<String, dynamic>>[];
    final ids = <String>{};

    final linkedChildrenIds = widget.userData['linkedChildrenIds'];

    if (linkedChildrenIds is List) {
      for (final id in linkedChildrenIds) {
        final value = _text(id);
        if (value.isNotEmpty) ids.add(value);
      }
    }

    final childId = _text(widget.userData['childId']);
    if (childId.isNotEmpty) ids.add(childId);

    final studentId = _text(widget.userData['studentId']);
    if (studentId.isNotEmpty) ids.add(studentId);

    for (final id in ids) {
      final childData = await _getStudentDoc(id);

      if (childData != null) {
        children.add(childData);
      }
    }

    final parentEmail = _lower(
      _text(widget.userData['email']).isNotEmpty
          ? _text(widget.userData['email'])
          : _text(widget.userData['authEmail']),
    );

    if (parentEmail.isNotEmpty) {
      final byParentEmailLower = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmailLower', isEqualTo: parentEmail)
          .get();

      for (final doc in byParentEmailLower.docs) {
        children.add({
          'studentId': doc.id,
          ...doc.data(),
        });
      }

      final byParentEmail = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmail', isEqualTo: parentEmail)
          .get();

      for (final doc in byParentEmail.docs) {
        children.add({
          'studentId': doc.id,
          ...doc.data(),
        });
      }
    }

    final byParentUid = await FirebaseFirestore.instance
        .collection('students')
        .where('parentUid', isEqualTo: uid)
        .get();

    for (final doc in byParentUid.docs) {
      children.add({
        'studentId': doc.id,
        ...doc.data(),
      });
    }

    return _dedupeChildren(children);
  }

  List<Map<String, dynamic>> _dedupeChildren(List<Map<String, dynamic>> input) {
    final ids = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final child in input) {
      final id = _text(child['studentId']);

      if (id.isNotEmpty && !ids.contains(id)) {
        ids.add(id);
        result.add(child);
      }
    }

    return result;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (picked == null) return;

    leaveDateController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
  }

  Future<void> _submitLeave() async {
    final name = nameController.text.trim();
    final batch = batchController.text.trim();
    final leaveDate = leaveDateController.text.trim();
    final reason = reasonController.text.trim();

    if (name.isEmpty || batch.isEmpty || leaveDate.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pleaseFillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String studentId = uid;
    String parentUid = '';
    String parentEmail = '';

    if (role == 'Parent') {
      if (selectedChild == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.pleaseSelectLinkedStudent),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      studentId = _text(selectedChild!['studentId']);
      parentUid = uid;
      parentEmail = _lower(
        _text(widget.userData['email']).isNotEmpty
            ? _text(widget.userData['email'])
            : _text(widget.userData['authEmail']),
      );

      if (studentId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.studentIdNotFound),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (role == 'Student') {
      final studentData =
          linkedChildren.isNotEmpty ? linkedChildren.first : <String, dynamic>{};

      parentUid = _text(studentData['parentUid']);
      parentEmail = _lower(_text(studentData['parentEmail']));
    }

    setState(() => submitting = true);

    try {
      await FirebaseFirestore.instance.collection('leave_requests').add({
        'studentId': studentId,
        'parentId': role == 'Parent' ? uid : '',
        'parentUid': parentUid,
        'parentEmail': parentEmail,
        'name': name,
        'studentName': name,
        'batch': batch,
        'date': leaveDate,
        'leaveDate': leaveDate,
        'reason': reason,
        'status': 'Pending',
        'requestedBy': role,
        'makeupSessionCreated': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.submitFailed}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = role == 'Student' || role == 'Parent';

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
            child: loadingChildren
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : !canSubmit
                    ? Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: _messageCard(
                              isDark,
                              AppStrings.cannotCreateLeaveRequest,
                              Icons.block_rounded,
                            ),
                          ),
                        ],
                      )
                    : role == 'Parent' && linkedChildren.isEmpty
                        ? Column(
                            children: [
                              _topHeader(context, isDark),
                              Expanded(
                                child: _messageCard(
                                  isDark,
                                  AppStrings.noLinkedStudentForParent,
                                  Icons.person_search_rounded,
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              ResponsivePadding.horizontal(context),
                              0,
                              ResponsivePadding.horizontal(context),
                              24,
                            ),
                            child: Column(
                              children: [
                                _topHeader(context, isDark),
                                _infoCard(isDark),
                                const SizedBox(height: 16),
                                if (role == 'Parent' && linkedChildren.length > 1)
                                  _studentDropdown(isDark),
                                if (role == 'Parent' && linkedChildren.length > 1)
                                  const SizedBox(height: 12),
                                _field(
                                  isDark: isDark,
                                  label: AppStrings.studentName,
                                  controller: nameController,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  isDark: isDark,
                                  label: AppStrings.batch,
                                  controller: batchController,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  isDark: isDark,
                                  label: AppStrings.leaveDate,
                                  controller: leaveDateController,
                                  readOnly: true,
                                  hint: AppStrings.selectLeaveDate,
                                  suffixIcon: Icons.calendar_month_rounded,
                                  onTap: _pickDate,
                                ),
                                const SizedBox(height: 12),
                                _field(
                                  isDark: isDark,
                                  label: AppStrings.reason,
                                  controller: reasonController,
                                  maxLines: 3,
                                  hint: AppStrings.enterLeaveReason,
                                ),
                                const SizedBox(height: 22),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? red : maroon,
                                      foregroundColor:
                                          isDark ? Colors.white : gold,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: submitting ? null : _submitLeave,
                                    icon: submitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Icon(Icons.send_rounded),
                                    label: Text(
                                      submitting
                                          ? AppStrings.submitting
                                          : AppStrings.submitLeave,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
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
                  AppStrings.newLeave.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: ResponsiveText.heading(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  AppStrings.submitLeaveRequest,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: ResponsiveText.small(context),
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

  Widget _infoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? gold.withOpacity(0.45) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? gold : maroon,
            size: 26,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.leaveInfoMessage,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: ResponsiveText.bodySmall(context),
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _studentDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: selectedChild == null ? null : _text(selectedChild!['studentId']),
      isExpanded: true,
      dropdownColor: _card(isDark),
      style: TextStyle(
        color: _primaryText(isDark),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: AppStrings.selectStudent,
        labelStyle: TextStyle(color: _secondaryText(isDark)),
        filled: true,
        fillColor: _card(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? red : maroon),
        ),
      ),
      items: linkedChildren.map((child) {
        final id = _text(child['studentId']);
        final name = _text(
          _text(child['name']).isNotEmpty ? child['name'] : child['studentName'],
        );
        final batch = _text(child['batch']);

        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            "$name - $batch",
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        final child = linkedChildren.firstWhere(
          (item) => _text(item['studentId']) == value,
        );

        setState(() {
          selectedChild = child;
          nameController.text = _text(
            _text(child['name']).isNotEmpty ? child['name'] : child['studentName'],
          );
          batchController.text = _text(child['batch']);
        });
      },
    );
  }

  Widget _field({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    int maxLines = 1,
    String? hint,
    IconData? suffixIcon,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      onTap: onTap,
      style: TextStyle(
        color: _primaryText(isDark),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: _secondaryText(isDark)),
        hintStyle: TextStyle(color: _secondaryText(isDark)),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(
                suffixIcon,
                color: isDark ? gold : maroon,
              ),
        filled: true,
        fillColor: _card(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? red : maroon),
        ),
      ),
    );
  }

  Widget _messageCard(bool isDark, String message, IconData icon) {
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
