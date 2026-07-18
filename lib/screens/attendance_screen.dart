import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';
import '../core/responsive/responsive_helper.dart';
import '../core/responsive/responsive_padding.dart';
import '../core/responsive/responsive_spacing.dart';
import '../core/responsive/responsive_radius.dart';
import '../core/responsive/responsive_text.dart';

import 'notification_service.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;
  bool isSaving = false;

  String uid = '';
  String role = '';
  String selectedBatch = '';

  final Map<String, bool> attendanceStatus = {};

  final List<String> allBatches = const [
    "Friday: 6:00 PM – 8:00 PM",
    "Saturday: 7:00 AM – 9:00 AM",
    "Saturday: 4:00 PM – 6:00 PM",
    "Saturday: 6:00 PM – 8:00 PM",
  ];

  List<String> availableBatches = [];

  @override
  void initState() {
    super.initState();
    _loadUserAccess();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day - (date.weekday - 1),
    );
  }

  String _dateId(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _currentWeekId() {
    return _dateId(_startOfWeek(DateTime.now()));
  }

  Future<List<String>> _loadCoachWeeklySessions(String coachUid) async {
    final weekId = _currentWeekId();

    final snapshot = await FirebaseFirestore.instance
        .collection('coach_session_assignments')
        .where('weekStartDate', isEqualTo: weekId)
        .get();

    final sessions = <String>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final coachId = data['coachId']?.toString().trim() ?? '';
      final status = data['status']?.toString().toLowerCase().trim() ?? '';
      final session = data['session']?.toString().trim() ?? '';

      if (coachId == coachUid &&
          status == 'active' &&
          session.isNotEmpty &&
          !sessions.contains(session)) {
        sessions.add(session);
      }
    }

    return sessions;
  }

  Future<void> _loadUserAccess() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        loadingUser = false;
        availableBatches = [];
        selectedBatch = '';
      });
      return;
    }

    uid = user.uid;

    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists || userDoc.data() == null) {
        if (!mounted) return;
        setState(() {
          loadingUser = false;
          availableBatches = [];
          selectedBatch = '';
        });
        return;
      }

      final data = userDoc.data() ?? {};
      final loadedRole = _text(data['role']);

      List<String> batchesToShow = [];

      if (loadedRole == 'Admin') {
        batchesToShow = List<String>.from(allBatches);
      } else if (loadedRole == 'Coach') {
        batchesToShow = await _loadCoachWeeklySessions(uid);
      } else {
        batchesToShow = [];
      }

      if (!mounted) return;

      setState(() {
        role = loadedRole;
        availableBatches = batchesToShow;
        selectedBatch = batchesToShow.isNotEmpty ? batchesToShow.first : '';
        attendanceStatus.clear();
        loadingUser = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingUser = false;
        availableBatches = [];
        selectedBatch = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("User access loading failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
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

  String _safeDocId(String value) {
    return value
        .replaceAll(':', '-')
        .replaceAll('/', '-')
        .replaceAll('–', '-')
        .replaceAll(' ', '_');
  }

  Future<void> saveAttendance(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> students,
  ) async {
    if (selectedBatch.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No assigned session found"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No students found in this session")),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final today = DateTime.now();
      final dateId =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final firestore = FirebaseFirestore.instance;
      final batchWrite = firestore.batch();
      final batchKey = _safeDocId(selectedBatch);

      for (final student in students) {
        final data = student.data();
        final studentName = data['name']?.toString() ?? 'No Name';
        final isPresent = attendanceStatus[student.id] ?? true;

        final attendanceDoc = firestore
            .collection('attendance')
            .doc("${student.id}_${dateId}_$batchKey");

        batchWrite.set(attendanceDoc, {
          'studentId': student.id,
          'studentName': studentName,
          'batch': selectedBatch,
          'session': selectedBatch,
          'weekStartDate': _currentWeekId(),
          'date': dateId,
          'status': isPresent ? 'Present' : 'Absent',
          'present': isPresent,
          'markedBy': uid,
          'markedByRole': role,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final oldPresent =
            int.tryParse(data['presentCount']?.toString() ?? '0') ?? 0;
        final oldTotal =
            int.tryParse(data['totalAttendanceCount']?.toString() ?? '0') ?? 0;

        final newPresent = oldPresent + (isPresent ? 1 : 0);
        final newTotal = oldTotal + 1;
        final percentage =
            newTotal == 0 ? 0 : ((newPresent / newTotal) * 100).round();

        batchWrite.update(
          firestore.collection('students').doc(student.id),
          {
            'presentCount': newPresent,
            'totalAttendanceCount': newTotal,
            'attendance': "$percentage%",
            'lastAttendanceDate': dateId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );

        if (!isPresent) {
          await NotificationService.attendanceAlert(
            studentName: studentName,
            studentId: student.id,
            batch: selectedBatch,
          );
        }
      }

      await batchWrite.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Attendance saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving attendance: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _studentsStream() {
    return FirebaseFirestore.instance
        .collection('students')
        .where('batch', isEqualTo: selectedBatch)
        .snapshots();
  }

  Future<void> _refreshCoachSessions() async {
    if (role != 'Coach') return;

    setState(() => loadingUser = true);
    await _loadUserAccess();
  }

  bool get _isTamil {
    final language = ThemeController.language.value.trim().toLowerCase();
    return language == 'tamil' ||
        language == 'தமிழ்' ||
        language == 'ta' ||
        language == 'ta_in';
  }

  String _localized(String english, String tamil) {
    return _isTamil ? tamil : english;
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveHelper.maxContentWidth(context),
                    ),
                    child: loadingUser
                        ? Column(
                            children: [
                              _topHeader(context, isDark),
                              const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ],
                          )
                        : availableBatches.isEmpty
                            ? Column(
                                children: [
                                  _topHeader(context, isDark),
                                  Expanded(
                                    child: _noAccessState(isDark),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _topHeader(context, isDark),
                                  _batchSelector(isDark),
                                  Expanded(
                                    child: StreamBuilder<
                                        QuerySnapshot<Map<String, dynamic>>>(
                                      stream: _studentsStream(),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Center(
                                            child: Padding(
                                              padding: EdgeInsets.all(
                                                ResponsiveSpacing.medium(
                                                  context,
                                                ),
                                              ),
                                              child: Text(
                                                "Error loading students:\n${snapshot.error}",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        final students = snapshot.data?.docs ?? [];

                                        if (students.isEmpty) {
                                          return _emptyState(isDark);
                                        }

                                        int presentCount = 0;
                                        int absentCount = 0;

                                        for (final student in students) {
                                          attendanceStatus.putIfAbsent(
                                            student.id,
                                            () => true,
                                          );

                                          if (attendanceStatus[student.id] ==
                                              true) {
                                            presentCount++;
                                          } else {
                                            absentCount++;
                                          }
                                        }

                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    ResponsivePadding.horizontal(
                                                  context,
                                                ),
                                              ),
                                              child: _summaryCardsRow(
                                                isDark: isDark,
                                                total: students.length,
                                                present: presentCount,
                                                absent: absentCount,
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  ResponsiveSpacing.medium(
                                                context,
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      ResponsivePadding
                                                          .horizontal(context),
                                                ),
                                                itemCount: students.length,
                                                itemBuilder: (context, index) {
                                                  final student =
                                                      students[index];
                                                  final data = student.data();

                                                  final name = data['name']
                                                          ?.toString() ??
                                                      'No Name';
                                                  final attendance =
                                                      data['attendance']
                                                              ?.toString() ??
                                                          '0%';
                                                  final rollNo = data['rollNo']
                                                          ?.toString() ??
                                                      '#YGCA';
                                                  final isPresent =
                                                      attendanceStatus[
                                                              student.id] ??
                                                          true;

                                                  final initials = name
                                                      .split(" ")
                                                      .where(
                                                        (e) => e.isNotEmpty,
                                                      )
                                                      .map((e) => e[0])
                                                      .take(2)
                                                      .join()
                                                      .toUpperCase();

                                                  return _studentAttendanceCard(
                                                    isDark: isDark,
                                                    studentId: student.id,
                                                    name: name,
                                                    rollNo: rollNo,
                                                    attendance: attendance,
                                                    initials: initials,
                                                    isPresent: isPresent,
                                                  );
                                                },
                                              ),
                                            ),
                                            _saveButton(isDark, students),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context) - 2,
        12,
        ResponsivePadding.horizontal(context) - 2,
        10,
      ),
      padding: EdgeInsets.all(ResponsiveSpacing.medium(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.55),
                ]
              : [
                  maroon,
                  red.withOpacity(0.78),
                  darkMaroon,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveRadius.large(context)),
        border: Border.all(
          color: isDark ? red.withOpacity(0.40) : gold.withOpacity(0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? red.withOpacity(0.18) : maroon.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _circleHeaderButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: ResponsiveHelper.isMobile(context) ? 48 : 56,
            height: ResponsiveHelper.isMobile(context) ? 48 : 56,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localized("MARK ATTENDANCE", "வருகையை பதிவு செய்"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: gold,
                    fontSize: ResponsiveText.body(context),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _localized("Weekly assigned session attendance", "வாரத்திற்கு ஒதுக்கப்பட்ட பயிற்சி அமர்வு வருகை"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
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

              return _circleHeaderButton(
                icon: dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: ThemeController.toggleTheme,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final size = ResponsiveHelper.isMobile(context) ? 42.0 : 46.0;

    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: ResponsiveHelper.isMobile(context) ? 21 : 23,
        ),
      ),
    );
  }

  Widget _batchSelector(bool isDark) {
    final isCoach = role == 'Coach';

    return Container(
      margin: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        0,
        ResponsivePadding.horizontal(context),
        ResponsiveSpacing.medium(context),
      ),
      padding: EdgeInsets.all(ResponsiveSpacing.medium(context)),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
        border: Border.all(
          color: isDark ? red.withOpacity(0.28) : gold.withOpacity(0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: ResponsiveHelper.isMobile(context) ? 17 : 20,
                backgroundColor: red.withOpacity(0.16),
                child: Icon(
                  Icons.groups_rounded,
                  color: isDark ? gold : maroon,
                  size: ResponsiveHelper.isMobile(context) ? 18 : 21,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  isCoach
                      ? _localized("Current Week Assigned Session", "இந்த வாரம் ஒதுக்கப்பட்ட அமர்வு")
                      : _localized("Select Training Session", "பயிற்சி அமர்வைத் தேர்வு செய்க"),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: ResponsiveText.body(context),
                  ),
                ),
              ),
              if (isCoach)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: isSaving ? null : _refreshCoachSessions,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _localized("Refresh", "புதுப்பி"),
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (availableBatches.length == 1)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B0B0B) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _border(isDark)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sports_cricket_rounded,
                    color: isDark ? gold : maroon,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      selectedBatch,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontSize: ResponsiveText.small(context) + 1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (isCoach)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _localized("Assigned", "ஒதுக்கப்பட்டது"),
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            DropdownButtonFormField<String>(
              value: selectedBatch,
              dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
              isExpanded: true,
              style: TextStyle(
                color: _primaryText(isDark),
                fontSize: ResponsiveText.small(context) + 1,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
                prefixIcon: Icon(
                  Icons.sports_cricket_rounded,
                  color: isDark ? gold : maroon,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
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
              items: availableBatches.map((batch) {
                return DropdownMenuItem(
                  value: batch,
                  child: Text(
                    batch,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: isSaving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        selectedBatch = value;
                        attendanceStatus.clear();
                      });
                    },
            ),
        ],
      ),
    );
  }

  Widget _noAccessState(bool isDark) {
    final title = role == 'Coach' ? _localized("No Session Assigned", "அமர்வு ஒதுக்கப்படவில்லை") : _localized("No Access", "அணுகல் இல்லை");
    final message = role == 'Coach'
        ? _localized("Admin has not assigned any session to this coach for the current week.", "இந்த வாரத்திற்கு நிர்வாகி இந்த பயிற்சியாளருக்கு எந்த அமர்வையும் ஒதுக்கவில்லை.")
        : _localized("Only Admin and assigned Coach can mark attendance.", "நிர்வாகி மற்றும் ஒதுக்கப்பட்ட பயிற்சியாளர் மட்டுமே வருகையை பதிவு செய்யலாம்.");

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: ResponsivePadding.screen(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveSpacing.large(context)),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(ResponsiveRadius.large(context)),
            border: Border.all(color: _border(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: isDark ? gold : maroon,
                size: ResponsiveHelper.isMobile(context) ? 48 : 60,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: ResponsiveText.heading(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: ResponsiveText.small(context),
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: ResponsivePadding.screen(context),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(ResponsiveSpacing.large(context)),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(ResponsiveRadius.large(context)),
            border: Border.all(color: _border(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.groups_2_outlined,
                color: isDark ? gold : maroon,
                size: ResponsiveHelper.isMobile(context) ? 48 : 60,
              ),
              const SizedBox(height: 12),
              Text(
                _localized("No students found", "மாணவர்கள் எவரும் இல்லை"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: ResponsiveText.heading(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                selectedBatch,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: ResponsiveText.small(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCardsRow({
    required bool isDark,
    required int total,
    required int present,
    required int absent,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;

        if (compact) {
          return Column(
            children: [
              _summaryCard(
                isDark: isDark,
                title: _localized("Students", "மாணவர்கள்"),
                value: total.toString(),
                icon: Icons.groups_rounded,
                color: Colors.blueAccent,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      isDark: isDark,
                      title: _localized("Present", "வருகை"),
                      value: present.toString(),
                      icon: Icons.check_circle_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _summaryCard(
                      isDark: isDark,
                      title: _localized("Absent", "வரவில்லை"),
                      value: absent.toString(),
                      icon: Icons.cancel_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                isDark: isDark,
                title: _localized("Students", "மாணவர்கள்"),
                value: total.toString(),
                icon: Icons.groups_rounded,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                isDark: isDark,
                title: _localized("Present", "வருகை"),
                value: present.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                isDark: isDark,
                title: _localized("Absent", "வரவில்லை"),
                value: absent.toString(),
                icon: Icons.cancel_rounded,
                color: Colors.redAccent,
              ),
            ),
          ],
        );
      },
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
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.isMobile(context) ? 13 : 16,
        horizontal: 8,
      ),
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
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.6),
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
          width: ResponsiveHelper.isMobile(context) ? 90 : 120,
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: ResponsiveHelper.isMobile(context) ? 25 : 30,
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: ResponsiveText.heading(context),
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: ResponsiveText.small(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentAttendanceCard({
    required bool isDark,
    required String studentId,
    required String name,
    required String rollNo,
    required String attendance,
    required String initials,
    required bool isPresent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(ResponsiveSpacing.small(context) + 4),
      decoration: BoxDecoration(
        color: _card(isDark),
        border: Border.all(
          color: isPresent
              ? Colors.green.withOpacity(isDark ? 0.35 : 0.25)
              : Colors.red.withOpacity(isDark ? 0.40 : 0.28),
        ),
        borderRadius: BorderRadius.circular(ResponsiveRadius.medium(context)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.30)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 350;

          final studentInfo = Row(
            children: [
              CircleAvatar(
                radius: compact ? 23 : 25,
                backgroundColor: isPresent ? Colors.green : Colors.redAccent,
                child: Text(
                  initials.isNotEmpty ? initials : "?",
                  style: const TextStyle(
                    color: Colors.white,
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
                        fontSize: ResponsiveText.body(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$rollNo • ${_localized("Current", "தற்போது")}: $attendance",
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
            ],
          );

          final statusSwitch = Row(
            mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment:
                compact ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isPresent
                      ? Colors.green.withOpacity(0.14)
                      : Colors.red.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPresent ? _localized("Present", "வருகை") : _localized("Absent", "வரவில்லை"),
                  style: TextStyle(
                    color: isPresent ? Colors.green : Colors.redAccent,
                    fontSize: ResponsiveText.small(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Transform.scale(
                scale: compact ? 0.78 : 0.82,
                child: Switch(
                  activeThumbColor: Colors.green,
                  inactiveThumbColor: Colors.redAccent,
                  activeTrackColor: Colors.green.withOpacity(0.35),
                  inactiveTrackColor: Colors.red.withOpacity(0.22),
                  value: isPresent,
                  onChanged: isSaving
                      ? null
                      : (value) {
                          setState(() {
                            attendanceStatus[studentId] = value;
                          });
                        },
                ),
              ),
            ],
          );

          if (compact) {
            return Column(
              children: [
                studentInfo,
                const SizedBox(height: 8),
                statusSwitch,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: studentInfo),
              const SizedBox(width: 8),
              statusSwitch,
            ],
          );
        },
      ),
    );
  }

  Widget _saveButton(
    bool isDark,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> students,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ResponsivePadding.horizontal(context),
        10,
        ResponsivePadding.horizontal(context),
        16,
      ),
      decoration: BoxDecoration(
        color: _bg(isDark),
        border: Border(
          top: BorderSide(color: _border(isDark)),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SizedBox(
            width: double.infinity,
            height: ResponsiveHelper.isMobile(context) ? 54 : 58,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? red : maroon,
                foregroundColor: isDark ? Colors.white : gold,
                elevation: 8,
                shadowColor: red.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: isSaving ? null : () => saveAttendance(students),
              icon: isSaving
                  ? const SizedBox()
                  : const Icon(Icons.save_alt_rounded, size: 22),
              label: isSaving
                  ? CircularProgressIndicator(
                      color: isDark ? Colors.white : gold,
                      strokeWidth: 2,
                    )
                  : Text(
                      _localized("SAVE ATTENDANCE", "வருகையை சேமி"),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
