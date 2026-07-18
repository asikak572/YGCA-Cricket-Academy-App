import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';
import '../core/responsive/responsive_text.dart';

class TrainingScheduleScreen extends StatefulWidget {
  const TrainingScheduleScreen({super.key});

  @override
  State<TrainingScheduleScreen> createState() => _TrainingScheduleScreenState();
}

class _TrainingScheduleScreenState extends State<TrainingScheduleScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;

  String uid = '';
  String role = '';
  String email = '';

  List<String> allowedBatches = [];

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

  String _localizedDay(String value) {
    switch (value) {
      case 'Monday':
        return AppStrings.monday;
      case 'Tuesday':
        return AppStrings.tuesday;
      case 'Wednesday':
        return AppStrings.wednesday;
      case 'Thursday':
        return AppStrings.thursday;
      case 'Friday':
        return AppStrings.friday;
      case 'Saturday':
        return AppStrings.saturday;
      case 'Sunday':
        return AppStrings.sunday;
      default:
        return value;
    }
  }

  String _localizedStatus(String value) {
    final lower = value.trim().toLowerCase();

    if (lower == 'upcoming') return AppStrings.upcoming;
    if (lower == 'completed') return AppStrings.completed;
    if (lower == 'cancelled' || lower == 'canceled') {
      return AppStrings.cancelled;
    }
    if (lower == 'pending') return AppStrings.pending;

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

  bool get _isTamil {
    final language = ThemeController.language.value.trim().toLowerCase();
    return language == 'ta' || language == 'tamil';
  }

  FontWeight get _heavyWeight =>
      _isTamil ? FontWeight.w700 : FontWeight.w900;

  bool get _canManageTraining {
    return role == 'Admin';
  }

  bool get _needsBatch {
    return role == 'Coach' || role == 'Student' || role == 'Parent';
  }

  bool get _hasNoAssignedBatch {
    return !loadingUser && _needsBatch && allowedBatches.isEmpty;
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

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String _dayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
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
      // Keep screen stable even if assignment collection has no data/index.
    }
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

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        if (!mounted) return;
        setState(() => loadingUser = false);
        return;
      }

      final data = userDoc.data() ?? {};
      final loadedRole = _text(data['role']);

      final batches = <String>{};

      for (final batch in _listFromDynamic(data['assignedBatches'])) {
        _addBatch(batches, batch);
      }

      _addBatch(batches, data['assignedBatch']);
      _addBatch(batches, data['batch']);
      _addBatch(batches, data['batchName']);
      _addBatch(batches, data['batchText']);

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

        for (final id in _listFromDynamic(data['linkedChildrenIds'])) {
          if (id.isNotEmpty) childIds.add(id);
        }

        final childId = _text(data['childId']);
        if (childId.isNotEmpty) childIds.add(childId);

        final studentId = _text(data['studentId']);
        if (studentId.isNotEmpty) childIds.add(studentId);

        final parentEmail = _lower(
          _text(data['email']).isNotEmpty ? _text(data['email']) : email,
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

      if (!mounted) return;

      setState(() {
        role = loadedRole;
        allowedBatches = batches.toList();
        loadingUser = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loadingUser = false);
    }
  }

  Query<Map<String, dynamic>> _trainingQuery() {
    final query = FirebaseFirestore.instance.collection('training_schedules');

    if (role == 'Admin') {
      return query;
    }

    if (_needsBatch) {
      if (allowedBatches.isEmpty) {
        return query.where('batch', isEqualTo: '__NO_ASSIGNED_BATCH__');
      }

      if (allowedBatches.length == 1) {
        return query.where('batch', isEqualTo: allowedBatches.first);
      }

      return query.where('batch', whereIn: allowedBatches.take(10).toList());
    }

    return query.where('batch', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortSchedules(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

    sorted.sort((a, b) {
      final aDate = _parseDate(a.data()['date']);
      final bDate = _parseDate(b.data()['date']);

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return sorted;
  }

  Future<void> _deleteTraining(BuildContext context, String docId) async {
    if (!_canManageTraining) return;

    try {
      await FirebaseFirestore.instance
          .collection('training_schedules')
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.trainingScheduleDeleted),
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

  Future<void> _showAddTrainingDialog(BuildContext context, bool isDark) async {
    if (!_canManageTraining) return;

    final dateController = TextEditingController();
    final dayController = TextEditingController();
    final timeController = TextEditingController();
    final batchController = TextEditingController();
    final typeController = TextEditingController();
    final statusController = TextEditingController(text: AppStrings.upcoming);

    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    Future<void> pickDate(BuildContext dialogContext) async {
      final now = DateTime.now();

      final picked = await showDatePicker(
        context: dialogContext,
        initialDate: selectedDate ?? now,
        firstDate: DateTime(now.year - 2),
        lastDate: DateTime(now.year + 2),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (pickerContext, child) {
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

      if (picked != null) {
        selectedDate = picked;
        dateController.text = _dateKey(picked);
        dayController.text = _dayName(picked);
      }
    }

    Future<void> pickTime(BuildContext dialogContext) async {
      final picked = await showTimePicker(
        context: dialogContext,
        initialTime: selectedTime ?? TimeOfDay.now(),
        initialEntryMode: TimePickerEntryMode.dialOnly,
        builder: (pickerContext, child) {
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

      if (picked != null) {
        selectedTime = picked;

        if (dialogContext.mounted) {
          timeController.text = picked.format(dialogContext);
        }
      }
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card(isDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDark ? red.withOpacity(0.35) : maroon.withOpacity(0.25),
            ),
          ),
          title: Text(
            AppStrings.addTraining,
            style: TextStyle(
              fontFamily: ResponsiveText.fontFamily,
              color: _primaryText(isDark),
              fontWeight: _heavyWeight,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input(
                  isDark: isDark,
                  label: AppStrings.date,
                  controller: dateController,
                  readOnly: true,
                  icon: Icons.calendar_today_rounded,
                  onTap: () => pickDate(dialogContext),
                ),
                _input(
                  isDark: isDark,
                  label: AppStrings.day,
                  controller: dayController,
                  readOnly: true,
                  icon: Icons.event_rounded,
                ),
                _input(
                  isDark: isDark,
                  label: AppStrings.time,
                  controller: timeController,
                  readOnly: true,
                  icon: Icons.access_time_rounded,
                  onTap: () => pickTime(dialogContext),
                ),
                _input(
                  isDark: isDark,
                  label: AppStrings.batch,
                  controller: batchController,
                  hintText: AppStrings.exampleMorningBatch,
                ),
                _input(
                  isDark: isDark,
                  label: AppStrings.trainingType,
                  controller: typeController,
                  hintText: AppStrings.exampleBattingPractice,
                ),
                _input(
                  isDark: isDark,
                  label: AppStrings.status,
                  controller: statusController,
                  hintText: AppStrings.trainingStatusHint,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                AppStrings.cancel,
                style: TextStyle(
                  fontFamily: ResponsiveText.fontFamily,
                  color: isDark ? Colors.white70 : maroon,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? red : maroon,
                foregroundColor: isDark ? Colors.white : gold,
              ),
              onPressed: () async {
                final date = dateController.text.trim();
                final day = dayController.text.trim();
                final time = timeController.text.trim();
                final batch = batchController.text.trim();
                final type = typeController.text.trim();
                final status = statusController.text.trim().isEmpty
                    ? AppStrings.upcoming
                    : statusController.text.trim();

                if (date.isEmpty ||
                    day.isEmpty ||
                    time.isEmpty ||
                    batch.isEmpty ||
                    type.isEmpty ||
                    status.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.pleaseFillAllFields),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('training_schedules')
                      .add({
                    'date': date,
                    'day': day,
                    'time': time,
                    'batch': batch,
                    'type': type,
                    'status': status,
                    'createdBy': uid,
                    'createdByRole': role,
                    'createdAt': FieldValue.serverTimestamp(),
                    'updatedAt': FieldValue.serverTimestamp(),
                  });

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppStrings.trainingScheduleAdded),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text("${AppStrings.saveFailed}: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(
                AppStrings.save,
                style: TextStyle(
                  fontFamily: ResponsiveText.fontFamily,
                  fontWeight: _heavyWeight,
                ),
              ),
            ),
          ],
        );
      },
    );

    dateController.dispose();
    dayController.dispose();
    timeController.dispose();
    batchController.dispose();
    typeController.dispose();
    statusController.dispose();
  }

  Widget _input({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    IconData? icon,
    VoidCallback? onTap,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(
            color: _secondaryText(isDark).withOpacity(0.65),
            fontSize: ResponsiveText.bodySmall(context),
          ),
          labelStyle: TextStyle(color: _secondaryText(isDark)),
          suffixIcon: icon == null
              ? null
              : Icon(
                  icon,
                  color: isDark ? gold : maroon,
                ),
          filled: true,
          fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? red : maroon,
              width: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, bool isDark) {
    if (!_canManageTraining) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card(isDark),
        title: Text(
          AppStrings.deleteTraining,
          style: TextStyle(
            fontFamily: ResponsiveText.fontFamily,
            color: _primaryText(isDark),
            fontWeight: _heavyWeight,
          ),
        ),
        content: Text(
          AppStrings.deleteTrainingConfirm,
          style: TextStyle(
            fontFamily: ResponsiveText.fontFamily,
            color: _secondaryText(isDark),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                fontFamily: ResponsiveText.fontFamily,
                color: isDark ? Colors.white70 : maroon,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTraining(context, docId);
            },
            child: Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    final lower = type.toLowerCase();

    if (lower.contains("fitness")) return Icons.fitness_center_rounded;
    if (lower.contains("bat")) return Icons.sports_cricket_rounded;
    if (lower.contains("bowl")) return Icons.sports_baseball_rounded;
    if (lower.contains("field")) return Icons.sports_handball_rounded;

    return Icons.calendar_month_rounded;
  }

  Color _typeColor(String type) {
    final lower = type.toLowerCase();

    if (lower.contains("fitness")) return Colors.green;
    if (lower.contains("bat")) return Colors.orange;
    if (lower.contains("bowl")) return Colors.blueAccent;
    if (lower.contains("field")) return Colors.purpleAccent;

    return Colors.teal;
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();

    if (lower.contains("complete")) return Colors.green;
    if (lower.contains("cancel")) return Colors.redAccent;
    if (lower.contains("pending")) return Colors.orange;
    if (lower.contains("upcoming")) return Colors.blueAccent;

    return Colors.teal;
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
          floatingActionButton: _canManageTraining
              ? SafeArea(
                  child: FloatingActionButton.extended(
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                    onPressed: () => _showAddTrainingDialog(context, isDark),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      AppStrings.addTraining,
                      style: TextStyle(
                        fontFamily: ResponsiveText.fontFamily,
                        fontWeight: _heavyWeight,
                      ),
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
                : _hasNoAssignedBatch
                    ? Column(
                        children: [
                          _topHeader(context, isDark),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: _messageCard(
                                  isDark: isDark,
                                  icon: Icons.groups_rounded,
                                  title: role == 'Coach'
                                      ? AppStrings.noBatchAssigned
                                      : AppStrings.noBatchAssigned,
                                  message: role == 'Coach'
                                      ? AppStrings.askAdminAssignBatchSession
                                      : AppStrings.noScheduleBecauseNoBatch,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _trainingQuery().snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Column(
                              children: [
                                _topHeader(context, isDark),
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: _messageCard(
                                        isDark: isDark,
                                        icon: Icons.error_outline_rounded,
                                        title: AppStrings.unableLoadSchedule,
                                        message: snapshot.error.toString(),
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

                          final schedules =
                              _sortSchedules(snapshot.data?.docs ?? []);

                          int fitnessCount = 0;
                          int skillCount = 0;

                          for (final doc in schedules) {
                            final type =
                                _text(doc.data()['type']).toLowerCase();

                            if (type.contains('fitness')) {
                              fitnessCount++;
                            } else {
                              skillCount++;
                            }
                          }

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                _topHeader(context, isDark),
                                _heroBanner(
                                  isDark: isDark,
                                  total: schedules.length,
                                  fitnessCount: fitnessCount,
                                  skillCount: skillCount,
                                ),
                                const SizedBox(height: 18),
                                _sectionTitle(AppStrings.trainingSchedules, isDark),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: schedules.isEmpty
                                      ? _emptyCard(isDark)
                                      : Column(
                                          children: schedules.map((doc) {
                                            final data = doc.data();

                                            final day =
                                                _text(data['day']).isEmpty
                                                    ? AppStrings.noDay
                                                    : _text(data['day']);

                                            final date =
                                                _text(data['date']).isEmpty
                                                    ? AppStrings.noDate
                                                    : _text(data['date']);

                                            final time =
                                                _text(data['time']).isEmpty
                                                    ? AppStrings.noTime
                                                    : _text(data['time']);

                                            final batch =
                                                _text(data['batch']).isEmpty
                                                    ? AppStrings.noBatch
                                                    : _text(data['batch']);

                                            final type =
                                                _text(data['type']).isEmpty
                                                    ? AppStrings.training
                                                    : _text(data['type']);

                                            final status =
                                                _text(data['status']).isEmpty
                                                    ? AppStrings.upcoming
                                                    : _text(data['status']);

                                            return _trainingCard(
                                              isDark: isDark,
                                              day: _localizedDay(day),
                                              date: date,
                                              time: time,
                                              batch: batch,
                                              type: type,
                                              status: _localizedStatus(status),
                                              onDelete: () => _confirmDelete(
                                                context,
                                                doc.id,
                                                isDark,
                                              ),
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.trainingSchedule.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: ResponsiveText.fontFamily,
                    color: _primaryText(isDark),
                    fontSize: ResponsiveText.pageTitle(context),
                    fontWeight: _heavyWeight,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                Text(
                  _canManageTraining
                      ? AppStrings.manageAcademyTrainingSessions
                      : AppStrings.viewAssignedTrainingSessions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: ResponsiveText.fontFamily,
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
    required int fitnessCount,
    required int skillCount,
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
              Icons.fitness_center_rounded,
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
                    Icons.fitness_center_rounded,
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
                          "YGCA",
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            fontFamily: ResponsiveText.fontFamily,
                            color: gold,
                            fontSize: ResponsiveText.body(context),
                            fontWeight: _heavyWeight,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          AppStrings.training.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: ResponsiveText.fontFamily,
                            color: Colors.white,
                            fontSize: ResponsiveText.hero(context),
                            fontWeight: _heavyWeight,
                            height: 1,
                          ),
                        ),
                        Text(
                          AppStrings.center.toUpperCase(),
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            fontFamily: ResponsiveText.fontFamily,
                            color: gold,
                            fontSize: ResponsiveText.heroSubtitle(context),
                            fontWeight: _heavyWeight,
                            height: 1,
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
                            _heroChip("${AppStrings.schedulesLabel}: $total"),
                            _heroChip("${AppStrings.fitness}: $fitnessCount"),
                            _heroChip("${AppStrings.skills}: $skillCount"),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                return Row(
                  children: [
                    icon,
                    SizedBox(width: compact ? 10 : 14),
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
          fontFamily: ResponsiveText.fontFamily,
          color: gold,
          fontSize: ResponsiveText.small(context),
          fontWeight: _heavyWeight,
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
                softWrap: false,
                style: TextStyle(
                  fontFamily: ResponsiveText.fontFamily,
                  color: isDark ? gold : maroon,
                  fontSize: ResponsiveText.title(context),
                  fontWeight: _heavyWeight,
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

  Widget _trainingCard({
    required bool isDark,
    required String day,
    required String date,
    required String time,
    required String batch,
    required String type,
    required String status,
    required VoidCallback onDelete,
  }) {
    final color = _typeColor(type);
    final icon = _typeIcon(type);
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
                ? Colors.black.withOpacity(0.28)
                : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;

          final contentRow = Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: color,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$day • $date",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ResponsiveText.fontFamily,
                        color: _primaryText(isDark),
                        fontWeight: _heavyWeight,
                        fontSize: ResponsiveText.title(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$time • $batch",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ResponsiveText.fontFamily,
                        color: _secondaryText(isDark),
                        fontSize: ResponsiveText.bodySmall(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _typeChip(isDark: isDark, type: type, color: color),
                        _typeChip(
                          isDark: isDark,
                          type: status,
                          color: statusColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );

          if (compact && _canManageTraining) {
            return Column(
              children: [
                contentRow,
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: onDelete,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: contentRow),
              if (_canManageTraining)
                IconButton(
                  icon: const Icon(
                    Icons.delete_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: onDelete,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _typeChip({
    required bool isDark,
    required String type,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        type,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: ResponsiveText.fontFamily,
          color: color,
          fontWeight: _heavyWeight,
          fontSize: ResponsiveText.small(context),
        ),
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
            Icons.calendar_month_rounded,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.noScheduleAvailable,
            style: TextStyle(
              fontFamily: ResponsiveText.fontFamily,
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _canManageTraining
                ? AppStrings.clickAddTrainingCreateOne
                : AppStrings.noTrainingScheduleForBatch,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ResponsiveText.fontFamily,
              color: _secondaryText(isDark),
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
        mainAxisSize: MainAxisSize.min,
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
              fontFamily: ResponsiveText.fontFamily,
              color: _primaryText(isDark),
              fontWeight: _heavyWeight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ResponsiveText.fontFamily,
              color: _secondaryText(isDark),
              fontSize: ResponsiveText.bodySmall(context),
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
