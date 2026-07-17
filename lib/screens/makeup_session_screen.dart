import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_text.dart';
import '../core/responsive/responsive_padding.dart';

class MakeupSessionScreen extends StatefulWidget {
  const MakeupSessionScreen({super.key});

  @override
  State<MakeupSessionScreen> createState() => _MakeupSessionScreenState();
}

class _MakeupSessionScreenState extends State<MakeupSessionScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool isLoadingUser = true;
  String uid = '';
  String email = '';
  String role = '';

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

  String _localizedStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return AppStrings.pending;
      case 'scheduled':
        return AppStrings.scheduled;
      case 'completed':
        return AppStrings.completed;
      default:
        return value;
    }
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
      setState(() => isLoadingUser = false);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      if (!mounted) return;
      setState(() => isLoadingUser = false);
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
      isLoadingUser = false;
    });
  }

  Query<Map<String, dynamic>> _makeupQuery() {
    final collection =
        FirebaseFirestore.instance.collection('makeup_sessions');

    if (role == 'Admin') {
      return collection;
    }

    if (role == 'Coach') {
      if (assignedBatches.isEmpty) {
        return collection.where('batch', isEqualTo: '__NO_ASSIGNED_BATCH__');
      }

      if (assignedBatches.length == 1) {
        return collection.where('batch', isEqualTo: assignedBatches.first);
      }

      return collection.where(
        'batch',
        whereIn: assignedBatches.take(10).toList(),
      );
    }

    if (role == 'Parent') {
      if (linkedChildrenIds.isEmpty) {
        return collection.where('parentUid', isEqualTo: uid);
      }

      if (linkedChildrenIds.length == 1) {
        return collection.where('studentId', isEqualTo: linkedChildrenIds.first);
      }

      return collection.where(
        'studentId',
        whereIn: linkedChildrenIds.take(10).toList(),
      );
    }

    if (role == 'Student') {
      return collection.where('studentId', isEqualTo: uid);
    }

    return collection.where('studentId', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortSessions(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> sessions,
  ) {
    final sorted = [...sessions];

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

  Future<void> _scheduleMakeup(
    BuildContext context,
    String docId,
  ) async {
    final scheduled = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleMakeupSessionScreen(
          docId: docId,
          uid: uid,
        ),
      ),
    );

    if (!mounted) return;

    if (scheduled == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.makeupSessionScheduled),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markCompleted(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('makeup_sessions')
          .doc(docId)
          .set({
        'status': 'Completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.makeupSessionMarkedCompleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.updateFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteSession(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('makeup_sessions')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.makeupSessionDeleted),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${AppStrings.deleteFailed}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, String docId, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
        title: Text(
          AppStrings.deleteMakeupSession,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          AppStrings.deleteMakeupSessionConfirm,
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
              await _deleteSession(context, docId);
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == AppStrings.completed) return Colors.blueAccent;
    if (status == "Pending") return Colors.orange;
    if (status == "Scheduled") return Colors.green;
    return Colors.purpleAccent;
  }

  IconData _statusIcon(String status) {
    if (status == AppStrings.completed) return Icons.check_circle_rounded;
    if (status == "Pending") return Icons.pending_actions_rounded;
    if (status == "Scheduled") return Icons.calendar_month_rounded;
    return Icons.event_repeat_rounded;
  }

  bool get _canManage {
    return role == 'Admin' || role == 'Coach';
  }

  bool get _canDelete {
    return role == 'Admin';
  }

  int _countStatus(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String status,
  ) {
    int count = 0;

    for (final doc in docs) {
      final current =
          _text(doc.data()['status']).isEmpty ? AppStrings.pending : _text(doc.data()['status']);

      if (current == status) count++;
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

            return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: isLoadingUser
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _makeupQuery().snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return _errorView(
                          context,
                          snapshot.error.toString(),
                          isDark,
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

                      final sessions = _sortSessions(snapshot.data?.docs ?? []);

                      final scheduled = _countStatus(sessions, "Scheduled");
                      final completed = _countStatus(sessions, AppStrings.completed);
                      final pending = _countStatus(sessions, "Pending");

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroBanner(
                              isDark: isDark,
                              total: sessions.length,
                              scheduled: scheduled,
                              completed: completed,
                              pending: pending,
                            ),
                           
                            const SizedBox(height: 18),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: _infoBanner(isDark),
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle(AppStrings.makeupSessionList, isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: sessions.isEmpty
                                  ? _emptyCard(isDark)
                                  : Column(
                                      children: sessions.map((doc) {
                                        final data = doc.data();

                                        final studentName =
                                            _text(data['studentName']).isNotEmpty
                                                ? _text(data['studentName'])
                                                : _text(data['name']);

                                        final batch = _text(data['batch']).isNotEmpty
                                            ? _text(data['batch'])
                                            : _text(data['originalBatch']);

                                        final originalBatch =
                                            _text(data['originalBatch']).isNotEmpty
                                                ? _text(data['originalBatch'])
                                                : batch;

                                        final cancelledDate =
                                            _text(data['cancelledDate']).isNotEmpty
                                                ? _text(data['cancelledDate'])
                                                : _text(data['leaveDate']);

                                        final cancelledTime =
                                            _text(data['cancelledTime']).isNotEmpty
                                                ? _text(data['cancelledTime'])
                                                : _text(data['leaveTime']);

                                        final reason = _text(data['reason']);
                                        final makeupDate = _text(data['makeupDate']);
                                        final makeupTime = _text(data['makeupTime']);
                                        final makeupBatch = _text(data['makeupBatch']);

                                        final status = _text(data['status']).isEmpty
                                            ? AppStrings.pending
                                            : _text(data['status']);

                                        return _makeupCard(
                                          context: context,
                                          isDark: isDark,
                                          docId: doc.id,
                                          studentName: studentName,
                                          batch: batch,
                                          originalBatch: originalBatch,
                                          cancelledDate: cancelledDate,
                                          cancelledTime: cancelledTime,
                                          reason: reason,
                                          makeupDate: makeupDate,
                                          makeupTime: makeupTime,
                                          makeupBatch: makeupBatch,
                                          status: _localizedStatus(status),
                                          statusColor: _statusColor(status),
                                          icon: _statusIcon(status),
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

  Widget _errorView(BuildContext context, String error, bool isDark) {
    return Column(
      children: [
        _topHeader(context, isDark),
        Expanded(
          child: Center(
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
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                    size: 40,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.unableLoadMakeupSessions,
                    style: TextStyle(
                      color: _primaryText(isDark),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveText.small(context),
                      color: _secondaryText(isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
                    AppStrings.makeupSessionsTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: ResponsiveText.heading(context),
                    fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  AppStrings.scheduleCompletionCenter,
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
    required int scheduled,
    required int completed,
    required int pending,
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
              Icons.event_repeat_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 300;

                final icon = CircleAvatar(
                  radius: compact ? 40 : 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.event_repeat_rounded,
                    color: maroon,
                    size: compact ? 36 : 42,
                  ),
                );

                final content = FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: compact ? Alignment.center : Alignment.centerLeft,
                  child: SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: compact
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.academy.toUpperCase(),
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: gold,
                            fontSize: ResponsiveText.statLabel(context),
                            fontWeight: FontWeight.w500,
                            height: 1.15,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          AppStrings.makeup.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveText.hero(context),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                            height: 1.15,
                          ),
                        ),
                        Text(
                          AppStrings.sessions.toUpperCase(),
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: gold,
                            fontSize: ResponsiveText.heroSubtitle(context),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0,
                            height: 1.15,
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
                            _heroChip("${AppStrings.total}: $total"),
                            _heroChip("${AppStrings.scheduled}: $scheduled"),
                            _heroChip("${AppStrings.pending}: $pending"),
                            _heroChip("${AppStrings.completed}: $completed"),
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
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            color: red,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                color: isDark ? Colors.white : maroon,
                fontSize: ResponsiveText.title(context),
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
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: 130,
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
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: ResponsiveText.statValue(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: ResponsiveText.small(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                subtitle,
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
    );
  }
Widget _infoBanner(bool isDark) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card(isDark),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: isDark ? gold.withOpacity(0.55) : gold.withOpacity(0.85),
      ),
      boxShadow: [
        BoxShadow(
          color: isDark ? gold.withOpacity(0.08) : Colors.black.withOpacity(0.05),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: gold.withOpacity(0.16),
          child: Icon(
            Icons.info_outline_rounded,
            color: gold,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppStrings.makeupInfoMessage,
            style: TextStyle(
              fontSize: ResponsiveText.bodySmall(context),
              color: _secondaryText(isDark),
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _makeupCard({
    required BuildContext context,
    required bool isDark,
    required String docId,
    required String studentName,
    required String batch,
    required String originalBatch,
    required String cancelledDate,
    required String cancelledTime,
    required String reason,
    required String makeupDate,
    required String makeupTime,
    required String makeupBatch,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    final isPending = status == "Pending";
    final canComplete = status == "Scheduled";

    final makeupText = makeupDate.isEmpty
        ? AppStrings.notScheduled
        : makeupTime.isEmpty
            ? makeupDate
            : "$makeupDate • $makeupTime";

    final titleText = studentName.isNotEmpty
        ? studentName
        : batch.isNotEmpty
            ? batch
            : AppStrings.makeupSession;

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
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 320;

              final titleRow = Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: maroon,
                    child: Icon(icon, color: gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      titleText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w900,
                        fontSize: ResponsiveText.cardTitle(context),
                      ),
                    ),
                  ),
                ],
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleRow,
                    const SizedBox(height: 8),
                    _statusChip(status, statusColor),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: titleRow),
                  _statusChip(status, statusColor),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          if (studentName.isNotEmpty) _detailRow(isDark, AppStrings.student, studentName),
          _detailRow(isDark, AppStrings.originalBatch, originalBatch),
          if (makeupBatch.isNotEmpty) _detailRow(isDark, AppStrings.makeupBatch, makeupBatch),
          _detailRow(isDark, AppStrings.leaveCancelledDate, cancelledDate),
          if (cancelledTime.isNotEmpty) _detailRow(isDark, AppStrings.time, cancelledTime),
          _detailRow(isDark, AppStrings.reason, reason),
          _detailRow(isDark, AppStrings.makeupDate, makeupText),
          if (_canManage) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 320;

                Widget mainAction;

                if (isPending) {
                  mainAction = ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? red : maroon,
                      foregroundColor: isDark ? Colors.white : gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _scheduleMakeup(context, docId),
                    icon: const Icon(Icons.calendar_month_rounded, size: 16),
                    label: Text(
                      AppStrings.schedule,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  );
                } else if (canComplete) {
                  mainAction = ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _markCompleted(context, docId),
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                    label: Text(
                      AppStrings.complete,
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  );
                } else {
                 mainAction = Padding(
  padding: const EdgeInsets.symmetric(vertical: 10),
  child: Text(
    AppStrings.completed,
    style: const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w900,
    ),
  ),
);
                }

                final deleteButton = _canDelete
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => _confirmDelete(context, docId, isDark),
                      )
                    : null;

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      mainAction,
                      if (deleteButton != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: deleteButton,
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: mainAction),
                    if (deleteButton != null) ...[
                      const SizedBox(width: 8),
                      deleteButton,
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(bool isDark, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B0B0B) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border(isDark)),
      ),
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
              value.isEmpty ? AppStrings.notAdded : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
                fontSize: ResponsiveText.bodySmall(context),
              ),
            ),
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
          fontSize: ResponsiveText.small(context),
          fontWeight: FontWeight.w900,
        ),
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
            Icons.event_repeat_rounded,
            size: 40,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noMakeupSessionsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.approvedLeaveCreatesMakeup,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}

class ScheduleMakeupSessionScreen extends StatefulWidget {
  final String docId;
  final String uid;

  const ScheduleMakeupSessionScreen({
    super.key,
    required this.docId,
    required this.uid,
  });

  @override
  State<ScheduleMakeupSessionScreen> createState() =>
      _ScheduleMakeupSessionScreenState();
}

class _ScheduleMakeupSessionScreenState
    extends State<ScheduleMakeupSessionScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color gold = Color(0xFFD4AF37);

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
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

  Future<void> _pickDate() async {
  final isDark = ThemeController.themeMode.value == ThemeMode.dark;
  final now = DateTime.now();

  final picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 2),
    initialEntryMode: DatePickerEntryMode.calendarOnly,
    builder: (context, child) {
      final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

      return Theme(
        data: baseTheme.copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: red,
                  onPrimary: Colors.white,
                  surface: Color(0xFF111111),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: maroon,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF111827),
                ),
          dialogBackgroundColor:
              isDark ? const Color(0xFF111111) : Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: isDark ? gold : maroon,
            ),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );

  if (picked == null) return;

  dateController.text =
      "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
}

  Future<void> _pickTime() async {
  final isDark = ThemeController.themeMode.value == ThemeMode.dark;

  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    initialEntryMode: TimePickerEntryMode.dialOnly,
    builder: (context, child) {
      final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

      return Theme(
        data: baseTheme.copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(
                  primary: red,
                  onPrimary: Colors.white,
                  surface: Color(0xFF111111),
                  onSurface: Colors.white,
                )
              : const ColorScheme.light(
                  primary: maroon,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Color(0xFF111827),
                ),
          dialogBackgroundColor:
              isDark ? const Color(0xFF111111) : Colors.white,
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: isDark ? gold : maroon,
            ),
          ),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );

  if (picked == null) return;
  if (!mounted) return;

  timeController.text = picked.format(context);
}

  Future<void> _saveSchedule() async {
    final date = dateController.text.trim();
    final time = timeController.text.trim();

    if (date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pleaseFillDateTime),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => saving = true);

    try {
      await FirebaseFirestore.instance
          .collection('makeup_sessions')
          .doc(widget.docId)
          .set({
        'makeupDate': date,
        'makeupTime': time,
        'status': 'Scheduled',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': 'Makeup Session Scheduled',
          'message': 'Makeup session scheduled on $date at $time',
          'targetRole': 'All',
          'type': 'Announcement',
          'createdBy': widget.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {}

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.scheduleFailed}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => saving = false);
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
            child: SingleChildScrollView(
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
                  const SizedBox(height: 18),
                  _input(
                    isDark: isDark,
                    label: AppStrings.makeupDate,
                    controller: dateController,
                    hint: AppStrings.selectDate,
                    icon: Icons.calendar_month_rounded,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 14),
                  _input(
                    isDark: isDark,
                    label: AppStrings.makeupTime,
                    controller: timeController,
                    hint: AppStrings.selectTime,
                    icon: Icons.access_time_rounded,
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? red : maroon,
                        foregroundColor: isDark ? Colors.white : gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: saving ? null : _saveSchedule,
                      icon: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: Text(
                        saving ? AppStrings.saving : AppStrings.saveSchedule,
                        style: const TextStyle(fontWeight: FontWeight.w900),
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
                  AppStrings.scheduleMakeupTitle,
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
                  AppStrings.addDateAndTime,
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
              AppStrings.selectMakeupDateTimeInfo,
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

  Widget _input({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
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
        suffixIcon: Icon(
          icon,
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
}