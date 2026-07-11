import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class SessionHistoryScreen extends StatefulWidget {
  const SessionHistoryScreen({super.key});

  @override
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loading = true;

  String uid = '';
  String role = '';
  String email = '';

  List<String> allowedBatches = [];
  List<_HistoryItem> historyItems = [];

  @override
  void initState() {
    super.initState();
    _loadSessionHistory();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  String _localizedStatus(String value) {
    final lower = value.trim().toLowerCase();

    if (lower == 'completed') return AppStrings.completed;
    if (lower == 'cancelled' || lower == 'canceled') {
      return AppStrings.cancelled;
    }

    return value;
  }

  String _localizedShortDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return AppStrings.mon;
      case DateTime.tuesday:
        return AppStrings.tue;
      case DateTime.wednesday:
        return AppStrings.wed;
      case DateTime.thursday:
        return AppStrings.thu;
      case DateTime.friday:
        return AppStrings.fri;
      case DateTime.saturday:
        return AppStrings.sat;
      case DateTime.sunday:
        return AppStrings.sun;
      default:
        return '';
    }
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

  void _addBatch(Set<String> batches, dynamic value) {
    final batch = _text(value);
    if (batch.isNotEmpty) {
      batches.add(batch);
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

  bool get _needsBatch {
    return role == 'Coach' || role == 'Student' || role == 'Parent';
  }

  bool get _hasNoAssignedBatch {
    return !loading && _needsBatch && allowedBatches.isEmpty;
  }

  DateTime get _now => DateTime.now();

  Future<void> _loadCoachAssignedBatches(Set<String> batches) async {
    try {
      final assignments = await FirebaseFirestore.instance
          .collection('coach_session_assignments')
          .where('coachId', isEqualTo: uid)
          .get();

      for (final doc in assignments.docs) {
        final data = doc.data();

        _addBatch(batches, data['batch']);
        _addBatch(batches, data['batchName']);
        _addBatch(batches, data['assignedBatch']);

        for (final batch in _listFromDynamic(data['assignedBatches'])) {
          _addBatch(batches, batch);
        }
      }
    } catch (_) {
      // Keep screen stable if collection/index is not available yet.
    }
  }

  Future<void> _loadSessionHistory() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      historyItems = [];
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loading = false);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        if (!mounted) return;
        setState(() => loading = false);
        return;
      }

      final userData = userDoc.data() ?? {};
      final loadedRole = _text(userData['role']);

      final batches = <String>{};

      for (final batch in _listFromDynamic(userData['assignedBatches'])) {
        _addBatch(batches, batch);
      }

      _addBatch(batches, userData['assignedBatch']);
      _addBatch(batches, userData['batch']);
      _addBatch(batches, userData['batchName']);
      _addBatch(batches, userData['batchText']);

      if (loadedRole == 'Coach') {
        await _loadCoachAssignedBatches(batches);
      }

      if (loadedRole == 'Student') {
        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(uid)
            .get();

        if (studentDoc.exists && studentDoc.data() != null) {
          final studentData = studentDoc.data() ?? {};
          _addBatch(batches, studentData['batch']);
          _addBatch(batches, studentData['batchName']);
          _addBatch(batches, studentData['batchText']);
        }
      }

      if (loadedRole == 'Parent') {
        final childIds = <String>{};

        for (final id in _listFromDynamic(userData['linkedChildrenIds'])) {
          if (id.isNotEmpty) childIds.add(id);
        }

        final childId = _text(userData['childId']);
        if (childId.isNotEmpty) childIds.add(childId);

        final studentId = _text(userData['studentId']);
        if (studentId.isNotEmpty) childIds.add(studentId);

        final parentEmail = _lower(
          _text(userData['email']).isNotEmpty
              ? _text(userData['email'])
              : email,
        );

        if (parentEmail.isNotEmpty) {
          final byParentEmailLower = await FirebaseFirestore.instance
              .collection('students')
              .where('parentEmailLower', isEqualTo: parentEmail)
              .get();

          for (final doc in byParentEmailLower.docs) {
            childIds.add(doc.id);
            final childData = doc.data();
            _addBatch(batches, childData['batch']);
            _addBatch(batches, childData['batchName']);
            _addBatch(batches, childData['batchText']);
          }

          final byParentEmail = await FirebaseFirestore.instance
              .collection('students')
              .where('parentEmail', isEqualTo: parentEmail)
              .get();

          for (final doc in byParentEmail.docs) {
            childIds.add(doc.id);
            final childData = doc.data();
            _addBatch(batches, childData['batch']);
            _addBatch(batches, childData['batchName']);
            _addBatch(batches, childData['batchText']);
          }
        }

        final byParentUid = await FirebaseFirestore.instance
            .collection('students')
            .where('parentUid', isEqualTo: uid)
            .get();

        for (final doc in byParentUid.docs) {
          childIds.add(doc.id);
          final childData = doc.data();
          _addBatch(batches, childData['batch']);
          _addBatch(batches, childData['batchName']);
          _addBatch(batches, childData['batchText']);
        }

        for (final id in childIds) {
          final childDoc = await FirebaseFirestore.instance
              .collection('students')
              .doc(id)
              .get();

          if (childDoc.exists && childDoc.data() != null) {
            final childData = childDoc.data() ?? {};
            _addBatch(batches, childData['batch']);
            _addBatch(batches, childData['batchName']);
            _addBatch(batches, childData['batchText']);
          }
        }
      }

      final loadedItems = <_HistoryItem>[];

      if (!_roleNeedsBatchButEmpty(loadedRole, batches)) {
        loadedItems.addAll(
          await _loadTrainingHistory(
            loadedRole: loadedRole,
            batches: batches,
          ),
        );

        loadedItems.addAll(
          await _loadMatchHistory(
            loadedRole: loadedRole,
            batches: batches,
          ),
        );

        loadedItems.addAll(
          await _loadCancelledHistory(
            loadedRole: loadedRole,
            batches: batches,
          ),
        );
      }

      loadedItems.sort((a, b) {
        return b.date.compareTo(a.date);
      });

      if (!mounted) return;

      setState(() {
        role = loadedRole;
        allowedBatches = batches.toList();
        historyItems = loadedItems;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.unableLoadSessionHistory}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _roleNeedsBatchButEmpty(String currentRole, Set<String> batches) {
    return (currentRole == 'Coach' ||
            currentRole == 'Student' ||
            currentRole == 'Parent') &&
        batches.isEmpty;
  }

  Future<List<_HistoryItem>> _loadTrainingHistory({
    required String loadedRole,
    required Set<String> batches,
  }) async {
    final result = <_HistoryItem>[];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('training_schedules')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (!_canShowBatchItem(loadedRole, batches, data)) continue;

        final date = _historyDateFromTraining(data);
        if (date == null) continue;
        if (date.isAfter(_now)) continue;

        final time = _text(data['time']).isEmpty ? AppStrings.noTime : _text(data['time']);
        final batch =
            _text(data['batch']).isEmpty ? AppStrings.noBatch : _text(data['batch']);
        final type =
            _text(data['type']).isEmpty ? AppStrings.trainingSession : _text(data['type']);

        result.add(
          _HistoryItem(
            title: type,
            subtitle: "${AppStrings.trainingSessionCompletedFor} $batch",
            time: time,
            batch: batch,
            category: AppStrings.training,
            status: "Completed",
            date: date,
            icon: _trainingIcon(type),
            color: _trainingColor(type),
          ),
        );
      }
    } catch (_) {
      // Keep stable.
    }

    return result;
  }

  Future<List<_HistoryItem>> _loadMatchHistory({
    required String loadedRole,
    required Set<String> batches,
  }) async {
    final result = <_HistoryItem>[];

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('matches').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (!_canShowBatchItem(loadedRole, batches, data)) continue;

        final date = _parseDate(data['date']);
        if (date == null) continue;
        if (date.isAfter(_now)) continue;

        final title =
            _text(data['title']).isEmpty ? AppStrings.matchSchedule : _text(data['title']);

        final opponent = _text(data['opponent']);
        final venue = _text(data['venue']);
        final status = _text(data['status']).isEmpty
            ? AppStrings.completed
            : _text(data['status']);
        final time = _text(data['time']).isEmpty ? AppStrings.noTime : _text(data['time']);
        final batch =
            _text(data['batch']).isEmpty ? AppStrings.allBatches : _text(data['batch']);

        final subtitleParts = <String>[];

        if (opponent.isNotEmpty) subtitleParts.add("${AppStrings.vs} $opponent");
        if (venue.isNotEmpty) subtitleParts.add(venue);
        subtitleParts.add(batch);

        result.add(
          _HistoryItem(
            title: title,
            subtitle: subtitleParts.join(" • "),
            time: time,
            batch: batch,
            category: "Match",
            status: status,
            date: date,
            icon: Icons.sports_cricket_rounded,
            color: Colors.orange,
          ),
        );
      }
    } catch (_) {
      // Keep stable.
    }

    return result;
  }

  Future<List<_HistoryItem>> _loadCancelledHistory({
    required String loadedRole,
    required Set<String> batches,
  }) async {
    final result = <_HistoryItem>[];

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('cancelled_sessions').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        if (!_canShowBatchItem(loadedRole, batches, data)) continue;

        final dateValue = _text(data['date']).isNotEmpty
            ? data['date']
            : data['cancelledDate'];

        final date = _parseDate(dateValue);
        if (date == null) continue;
        if (date.isAfter(_now)) continue;

        final time = _text(data['time']).isNotEmpty
            ? _text(data['time'])
            : _text(data['cancelledTime']).isNotEmpty
                ? _text(data['cancelledTime'])
                : AppStrings.noTime;

        final batch =
            _text(data['batch']).isEmpty ? AppStrings.noBatch : _text(data['batch']);

        final reason = _text(data['reason']).isEmpty
            ? AppStrings.sessionCancelled
            : _text(data['reason']);

        final status = _text(data['status']).isEmpty
            ? AppStrings.cancelled
            : _text(data['status']);

        result.add(
          _HistoryItem(
            title: AppStrings.cancelledSession,
            subtitle: reason,
            time: time,
            batch: batch,
            category: "Cancelled",
            status: status,
            date: date,
            icon: Icons.cancel_rounded,
            color: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      // Keep stable.
    }

    return result;
  }

  bool _canShowBatchItem(
    String loadedRole,
    Set<String> batches,
    Map<String, dynamic> data,
  ) {
    if (loadedRole == 'Admin') return true;

    final itemBatch = _text(data['batch']);

    if (itemBatch.isEmpty) {
      return true;
    }

    return batches.contains(itemBatch);
  }

  DateTime? _historyDateFromTraining(Map<String, dynamic> data) {
    final dateValue = data['date'];

    if (dateValue != null && _text(dateValue).isNotEmpty) {
      return _parseDate(dateValue);
    }

    final createdAt = data['createdAt'];

    if (createdAt != null) {
      return _parseDate(createdAt);
    }

    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    final text = _text(value);

    if (text.isEmpty) return null;

    try {
      return DateTime.parse(text);
    } catch (_) {
      return null;
    }
  }

  IconData _trainingIcon(String type) {
    final lower = type.toLowerCase();

    if (lower.contains("fitness")) return Icons.fitness_center_rounded;
    if (lower.contains("bat")) return Icons.sports_cricket_rounded;
    if (lower.contains("bowl")) return Icons.sports_baseball_rounded;
    if (lower.contains("field")) return Icons.sports_handball_rounded;

    return Icons.event_available_rounded;
  }

  Color _trainingColor(String type) {
    final lower = type.toLowerCase();

    if (lower.contains("fitness")) return Colors.green;
    if (lower.contains("bat")) return Colors.orange;
    if (lower.contains("bowl")) return Colors.blueAccent;
    if (lower.contains("field")) return Colors.purpleAccent;

    return Colors.teal;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day-$month-${date.year}';
  }

  String _shortDay(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
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
            child: loading
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : RefreshIndicator(
                    onRefresh: _loadSessionHistory,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          _topHeader(context, isDark),
                          _heroBanner(isDark),
                          const SizedBox(height: 18),
                          _summaryRow(isDark),
                          const SizedBox(height: 18),
                          _sectionTitle(AppStrings.sessionHistory.toUpperCase(), isDark),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: _hasNoAssignedBatch
                                ? _messageCard(
                                    isDark: isDark,
                                    icon: Icons.groups_rounded,
                                    title: AppStrings.noBatchAssigned,
                                    message: role == 'Coach'
                                        ? AppStrings.askAdminAssignBatchSession
                                        : AppStrings.noHistoryBecauseNoBatch,
                                  )
                                : historyItems.isEmpty
                                    ? _messageCard(
                                        isDark: isDark,
                                        icon: Icons.history_rounded,
                                        title: AppStrings.noSessionHistoryAvailable,
                                        message:
                                            AppStrings.noPastTrainingOrMatches,
                                      )
                                    : Column(
                                        children: historyItems.map((item) {
                                          return _historyTile(
                                            isDark: isDark,
                                            item: item,
                                          );
                                        }).toList(),
                                      ),
                          ),
                        ],
                      ),
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
                    AppStrings.sessionHistory.toUpperCase(),
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
                  AppStrings.pastTrainingMatchCancelledSessions,
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
            icon: Icons.refresh_rounded,
            onTap: _loadSessionHistory,
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

  Widget _heroBanner(bool isDark) {
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
              Icons.history_rounded,
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
                    Icons.history_rounded,
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
                            "YGCA",
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            AppStrings.session.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
                            AppStrings.history.toUpperCase(),
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
                              _heroChip("${AppStrings.records}: ${historyItems.length}"),
                              _heroChip(AppStrings.training),
                              _heroChip(AppStrings.matches),
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

  Widget _summaryRow(bool isDark) {
    final trainingCount =
        historyItems.where((item) => item.category == AppStrings.training).length;
    final matchCount =
        historyItems.where((item) => item.category == "Match").length;
    final cancelledCount =
        historyItems.where((item) => item.category == "Cancelled").length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              isDark: isDark,
              title: AppStrings.training,
              value: trainingCount.toString(),
              icon: Icons.event_available_rounded,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              isDark: isDark,
              title: AppStrings.matches,
              value: matchCount.toString(),
              icon: Icons.sports_cricket_rounded,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              isDark: isDark,
              title: AppStrings.cancelled,
              value: cancelledCount.toString(),
              icon: Icons.cancel_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required bool isDark,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _secondaryText(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w700,
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
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

  Widget _historyTile({
    required bool isDark,
    required _HistoryItem item,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? item.color.withOpacity(0.07)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  item.color.withOpacity(isDark ? 0.35 : 0.20),
                  item.color.withOpacity(isDark ? 0.14 : 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withOpacity(0.28)),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _smallChip(
                      isDark: isDark,
                      text: _formatDate(item.date),
                      icon: Icons.calendar_today_rounded,
                      color: item.color,
                    ),
                    _smallChip(
                      isDark: isDark,
                      text: _localizedShortDay(item.date),
                      icon: Icons.today_rounded,
                      color: item.color,
                    ),
                    _smallChip(
                      isDark: isDark,
                      text: item.time,
                      icon: Icons.access_time_rounded,
                      color: item.color,
                    ),
                    _smallChip(
                      isDark: isDark,
                      text: _localizedStatus(item.status),
                      icon: Icons.verified_rounded,
                      color: item.color,
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

  Widget _smallChip({
    required bool isDark,
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.20)),
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
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
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
            icon,
            size: 42,
            color: _secondaryText(isDark),
          ),
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
    );
  }
}

class _HistoryItem {
  final String title;
  final String subtitle;
  final String time;
  final String batch;
  final String category;
  final String status;
  final DateTime date;
  final IconData icon;
  final Color color;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.batch,
    required this.category,
    required this.status,
    required this.date,
    required this.icon,
    required this.color,
  });
}