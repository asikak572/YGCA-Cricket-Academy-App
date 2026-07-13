import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/language/app_strings.dart';

class CancelSessionScreen extends StatefulWidget {
  const CancelSessionScreen({super.key});

  @override
  State<CancelSessionScreen> createState() => _CancelSessionScreenState();
}

class _CancelSessionScreenState extends State<CancelSessionScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  bool submitting = false;
  bool loadingUser = true;

  String uid = '';
  String role = '';
  String userBatch = '';

  List<String> linkedChildrenIds = [];
  List<String> linkedChildBatches = [];

  String cancelType = 'Batch';
  String? selectedBatch;
  String? selectedStudentId;
  String? selectedStudentName;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  Color _bg(bool isDark) => isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  Color _card(bool isDark) => isDark ? const Color(0xFF111111) : Colors.white;
  Color _border(bool isDark) => isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  Color _primaryText(bool isDark) => isDark ? Colors.white : const Color(0xFF111827);
  Color _secondaryText(bool isDark) => isDark ? Colors.white60 : const Color(0xFF64748B);

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
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

  bool get _canManage => role == 'Admin' || role == 'Coach';

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    uid = user.uid;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final data = userDoc.data() ?? {};
    final loadedRole = _text(data['role']);

    final children = <String>{};
    final childBatches = <String>{};

    for (final id in _stringList(data['linkedChildrenIds'])) {
      children.add(id);
    }

    final directChildId = _text(data['childId']);
    if (directChildId.isNotEmpty) children.add(directChildId);

    final directStudentId = _text(data['studentId']);
    if (directStudentId.isNotEmpty) children.add(directStudentId);

    if (loadedRole == 'Parent') {
      final parentEmail = _lower(
        _text(data['email']).isNotEmpty
            ? _text(data['email'])
            : user.email ?? '',
      );

      if (parentEmail.isNotEmpty) {
        final byLower = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmailLower', isEqualTo: parentEmail)
            .get();

        for (final doc in byLower.docs) {
          children.add(doc.id);
          final batch = _text(doc.data()['batch']);
          if (batch.isNotEmpty) childBatches.add(batch);
        }

        final byEmail = await FirebaseFirestore.instance
            .collection('students')
            .where('parentEmail', isEqualTo: parentEmail)
            .get();

        for (final doc in byEmail.docs) {
          children.add(doc.id);
          final batch = _text(doc.data()['batch']);
          if (batch.isNotEmpty) childBatches.add(batch);
        }
      }

      final byUid = await FirebaseFirestore.instance
          .collection('students')
          .where('parentUid', isEqualTo: uid)
          .get();

      for (final doc in byUid.docs) {
        children.add(doc.id);
        final batch = _text(doc.data()['batch']);
        if (batch.isNotEmpty) childBatches.add(batch);
      }

      for (final childId in children) {
        final childDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(childId)
            .get();

        if (childDoc.exists) {
          final batch = _text(childDoc.data()?['batch']);
          if (batch.isNotEmpty) childBatches.add(batch);
        }
      }
    }

    if (!mounted) return;

    setState(() {
      role = loadedRole;
      userBatch = _text(data['batch']).isNotEmpty
          ? _text(data['batch'])
          : _text(data['assignedBatch']);
      linkedChildrenIds = children.toList();
      linkedChildBatches = childBatches.toList();
      loadingUser = false;
    });
  }

  bool _canViewCancelledSession(Map<String, dynamic> data) {
    if (role == 'Admin' || role == 'Coach') return true;

    final cancelTypeValue = _text(data['cancelType']);
    final studentId = _text(data['studentId']);
    final batch = _text(data['batch']);

    if (role == 'Student') {
      if (cancelTypeValue == 'Student') {
        return studentId == uid;
      }

      return batch.isNotEmpty && batch == userBatch;
    }

    if (role == 'Parent') {
      if (cancelTypeValue == 'Student') {
        return linkedChildrenIds.contains(studentId);
      }

      return batch.isNotEmpty && linkedChildBatches.contains(batch);
    }

    return false;
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _cancelSession(BuildContext context) async {
    final batch = selectedBatch ?? '';
    final date = dateController.text.trim();
    final time = timeController.text.trim();
    final reason = reasonController.text.trim();

    if (batch.isEmpty || date.isEmpty || time.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pleaseFillAllFields),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (cancelType == 'Student' &&
        ((selectedStudentId ?? '').isEmpty || (selectedStudentName ?? '').isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.pleaseSelectStudent),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => submitting = true);

    try {
      final isIndividual = cancelType == 'Student';

      final notificationMessage = isIndividual
          ? '${selectedStudentName ?? 'Student'} session on $date at $time has been cancelled. Reason: $reason. Makeup session will be scheduled soon.'
          : '$batch session on $date at $time has been cancelled. Reason: $reason. Makeup session will be scheduled soon.';

      final cancelledDoc =
          await FirebaseFirestore.instance.collection('cancelled_sessions').add({
        'cancelType': cancelType,
        'batch': batch,
        'date': date,
        'cancelledDate': date,
        'time': time,
        'cancelledTime': time,
        'reason': reason,
        'studentId': isIndividual ? selectedStudentId : '',
        'studentName': isIndividual ? selectedStudentName : '',
        'makeup': 'Not scheduled',
        'status': 'Cancelled',
        'makeupStatus': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('makeup_sessions').add({
        'cancelledSessionId': cancelledDoc.id,
        'cancelType': cancelType,
        'batch': batch,
        'originalBatch': batch,
        'studentId': isIndividual ? selectedStudentId : '',
        'studentName': isIndividual ? selectedStudentName : '',
        'cancelledDate': date,
        'cancelledTime': time,
        'reason': reason,
        'makeupDate': '',
        'makeupTime': '',
        'makeupBatch': '',
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': isIndividual ? 'Student Session Cancelled' : 'Batch Session Cancelled',
        'message': notificationMessage,
        'targetRole': isIndividual ? 'Student' : 'Student',
        'targetUserId': isIndividual ? selectedStudentId : '',
        'batch': batch,
        'type': 'session_cancelled',
        'status': 'Unread',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': isIndividual ? 'Student Session Cancelled' : 'Batch Session Cancelled',
        'message': notificationMessage,
        'targetRole': 'Parent',
        'targetStudentId': isIndividual ? selectedStudentId : '',
        'batch': batch,
        'type': 'session_cancelled',
        'status': 'Unread',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.sessionCancelledMakeupCreated),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedBatch = null;
        selectedStudentId = null;
        selectedStudentName = null;
        cancelType = 'Batch';
      });

      dateController.clear();
      timeController.clear();
      reasonController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${AppStrings.cancelSessionFailed}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
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
    dateController.text = _dateKey(picked);
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

  Stream<List<String>> _batchStream() {
    return FirebaseFirestore.instance.collection('students').snapshots().map(
      (snapshot) {
        final batches = <String>{};

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final batch = _text(data['batch']).isNotEmpty
              ? _text(data['batch'])
              : _text(data['batchName']);

          if (batch.isNotEmpty) batches.add(batch);
        }

        final list = batches.toList();
        list.sort();
        return list;
      },
    );
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _studentStream() {
    if ((selectedBatch ?? '').isEmpty) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('students')
        .where('batch', isEqualTo: selectedBatch)
        .snapshots()
        .map((snapshot) => snapshot.docs);
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
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cancelled_sessions')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.error_outline_rounded,
                          title: AppStrings.somethingWentWrong,
                          message: snapshot.error.toString(),
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

                final sessions = (snapshot.data?.docs ?? []).where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _canViewCancelledSession(data);
                }).toList();

                int makeupPending = 0;
                final Set<String> batches = {};

                for (final doc in sessions) {
                  final data = doc.data() as Map<String, dynamic>;
                  final makeup = data['makeup']?.toString() ?? 'Not scheduled';
                  final batch = data['batch']?.toString() ?? '';

                  if (makeup == 'Not scheduled') makeupPending++;
                  if (batch.isNotEmpty) batches.add(batch);
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _topHeader(context, isDark),
                      _heroBanner(
                        isDark: isDark,
                        total: sessions.length,
                        makeupPending: makeupPending,
                        batches: batches.length,
                      ),
                      if (_canManage) ...[
                        const SizedBox(height: 18),
                        _sectionTitle(AppStrings.cancelSessionForm, isDark),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _warningBox(isDark),
                              const SizedBox(height: 14),
                              _cancelTypeSelector(isDark),
                              const SizedBox(height: 10),
                              _batchDropdown(isDark),
                              if (cancelType == 'Student') ...[
                                const SizedBox(height: 10),
                                _studentDropdown(isDark),
                              ],
                              const SizedBox(height: 10),
                              _inputBox(
                                isDark: isDark,
                                label: AppStrings.sessionDate,
                                controller: dateController,
                                icon: Icons.calendar_month_rounded,
                                readOnly: true,
                                onTap: _pickDate,
                              ),
                              _inputBox(
                                isDark: isDark,
                                label: AppStrings.sessionTime,
                                controller: timeController,
                                icon: Icons.access_time_rounded,
                                readOnly: true,
                                onTap: _pickTime,
                              ),
                              _inputBox(
                                isDark: isDark,
                                label: AppStrings.reason,
                                controller: reasonController,
                                icon: Icons.warning_amber_rounded,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
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
                                  onPressed: submitting
                                      ? null
                                      : () => _cancelSession(context),
                                  icon: submitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.notifications_active_rounded),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      submitting
                                          ? AppStrings.creating
                                          : cancelType == 'Student'
                                              ? AppStrings.cancelStudentCreateMakeup
                                              : AppStrings.cancelBatchCreateMakeup,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ] else
                        const SizedBox(height: 18),
                      _sectionTitle(AppStrings.recentlyCancelled, isDark),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: sessions.isEmpty
                            ? _emptyCard(isDark)
                            : Column(
                                children: sessions.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;

                                  return _cancelledCard(
                                    isDark: isDark,
                                    cancelType: data['cancelType']?.toString() ?? 'Batch',
                                    studentName: data['studentName']?.toString() ?? '',
                                    batch: data['batch']?.toString() ?? '',
                                    date: data['date']?.toString() ??
                                        data['cancelledDate']?.toString() ??
                                        '',
                                    time: data['time']?.toString() ??
                                        data['cancelledTime']?.toString() ??
                                        '',
                                    reason: data['reason']?.toString() ?? '',
                                    makeup: data['makeup']?.toString() ??
                                        'Not scheduled',
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

  Widget _cancelTypeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Expanded(child: _typeButton(isDark, 'Batch', Icons.groups_rounded)),
          const SizedBox(width: 8),
          Expanded(child: _typeButton(isDark, 'Student', Icons.person_rounded)),
        ],
      ),
    );
  }

  Widget _typeButton(bool isDark, String type, IconData icon) {
    final selected = cancelType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () {
        setState(() {
          cancelType = type;
          selectedStudentId = null;
          selectedStudentName = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? red : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : _secondaryText(isDark), size: 18),
            const SizedBox(width: 6),
            Text(
              type == 'Batch' ? AppStrings.fullBatch : AppStrings.individual,
              style: TextStyle(
                color: selected ? Colors.white : _primaryText(isDark),
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _batchDropdown(bool isDark) {
    return StreamBuilder<List<String>>(
      stream: _batchStream(),
      builder: (context, snapshot) {
        final batches = snapshot.data ?? [];

        return DropdownButtonFormField<String>(
          value: selectedBatch,
          isExpanded: true,
          dropdownColor: _card(isDark),
          iconEnabledColor: isDark ? gold : maroon,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w800,
          ),
          decoration: _dropdownDecoration(
            isDark: isDark,
            label: AppStrings.selectBatch,
            icon: Icons.groups_rounded,
          ),
          items: batches.map((batch) {
            return DropdownMenuItem<String>(
              value: batch,
              child: Text(
                batch,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedBatch = value;
              selectedStudentId = null;
              selectedStudentName = null;
            });
          },
        );
      },
    );
  }

  Widget _studentDropdown(bool isDark) {
    if ((selectedBatch ?? '').isEmpty) {
      return _disabledBox(
        isDark: isDark,
        label: AppStrings.selectStudent,
        text: AppStrings.selectBatchFirst,
        icon: Icons.person_rounded,
      );
    }

    return StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
      stream: _studentStream(),
      builder: (context, snapshot) {
        final students = snapshot.data ?? [];

        return DropdownButtonFormField<String>(
          value: selectedStudentId,
          isExpanded: true,
          dropdownColor: _card(isDark),
          iconEnabledColor: isDark ? gold : maroon,
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w800,
          ),
          decoration: _dropdownDecoration(
            isDark: isDark,
            label: AppStrings.selectStudent,
            icon: Icons.person_rounded,
          ),
          items: students.map((doc) {
            final data = doc.data();
            final name = _text(data['name']).isEmpty ? AppStrings.unnamedStudent : _text(data['name']);

            return DropdownMenuItem<String>(
              value: doc.id,
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            final doc = students.firstWhere((student) => student.id == value);
            final data = doc.data();

            setState(() {
              selectedStudentId = value;
              selectedStudentName =
                  _text(data['name']).isEmpty ? AppStrings.unnamedStudent : _text(data['name']);
            });
          },
        );
      },
    );
  }

  InputDecoration _dropdownDecoration({
    required bool isDark,
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _secondaryText(isDark)),
      prefixIcon: Icon(icon, color: isDark ? gold : maroon),
      filled: true,
      fillColor: _card(isDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: _border(isDark)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: _border(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: isDark ? red : maroon),
      ),
    );
  }

  Widget _disabledBox({
    required bool isDark,
    required String label,
    required String text,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 17),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _border(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? gold : maroon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
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
                    AppStrings.cancelSession.toUpperCase(),
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
                  AppStrings.batchOrIndividualControl,
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
              color: isDark ? red.withOpacity(0.12) : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: isDark ? Colors.white : maroon, size: 21),
      ),
    );
  }

  Widget _heroBanner({
    required bool isDark,
    required int total,
    required int makeupPending,
    required int batches,
  }) {
    return Container(
      height: 220,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? red.withOpacity(0.55) : gold.withOpacity(0.9)),
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
            child: Image.asset('assets/images/home_hero_bg.png', fit: BoxFit.cover),
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
              Icons.event_busy_rounded,
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
                    Icons.event_busy_rounded,
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
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          AppStrings.session.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          AppStrings.control.toUpperCase(),
                          textAlign: compact ? TextAlign.center : TextAlign.left,
                          style: TextStyle(
                            color: gold,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
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
                            _heroChip("${AppStrings.cancelled}: $total"),
                            _heroChip("${AppStrings.batches}: $batches"),
                            _heroChip("${AppStrings.makeup}: $makeupPending"),
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
        style: const TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _warningBox(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.red.withOpacity(0.10) : const Color(0xFFFEF2F2),
        border: Border.all(
          color: isDark
              ? Colors.redAccent.withOpacity(0.35)
              : const Color(0xFFFECACA),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.cancelSessionWarning,
              style: TextStyle(
                fontSize: 12,
                height: 1.35,
                color: isDark ? Colors.red.shade200 : Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBox({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _secondaryText(isDark)),
          prefixIcon: Icon(icon, color: isDark ? gold : maroon),
          filled: true,
          fillColor: _card(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: _border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: isDark ? red : maroon),
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
                  fontSize: 17,
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

  Widget _cancelledCard({
    required bool isDark,
    required String cancelType,
    required String studentName,
    required String batch,
    required String date,
    required String time,
    required String reason,
    required String makeup,
  }) {
    final needsMakeup = makeup == "Not scheduled";
    final isStudent = cancelType == 'Student';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(color: isDark ? red.withOpacity(0.25) : _border(isDark)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.28) : Colors.black.withOpacity(0.045),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.red.withOpacity(0.12),
            child: Icon(
              isStudent ? Icons.person_off_rounded : Icons.event_busy_rounded,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStudent
                      ? (studentName.isEmpty ? AppStrings.individualStudent : studentName)
                      : (batch.isEmpty ? AppStrings.unknownBatch : batch),
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
                  isStudent ? "${AppStrings.individual} • $batch" : AppStrings.fullBatch,
                  style: TextStyle(
                    color: isDark ? gold : maroon,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time.isEmpty ? date : "$date • $time",
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _detailChip(
                  isDark: isDark,
                  icon: Icons.warning_amber_rounded,
                  text: reason,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 6),
                _detailChip(
                  isDark: isDark,
                  icon: Icons.event_repeat_rounded,
                  text: makeup,
                  color: needsMakeup ? Colors.orange : Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailChip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text.isEmpty ? AppStrings.notAdded : text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
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
          Icon(Icons.event_busy_rounded, size: 40, color: _secondaryText(isDark)),
          const SizedBox(height: 10),
          Text(
            AppStrings.noCancelledSessionsFound,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.cancelledSessionsAppearHere,
            style: TextStyle(color: _secondaryText(isDark)),
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