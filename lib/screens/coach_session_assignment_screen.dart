import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

class CoachSessionAssignmentScreen extends StatefulWidget {
  const CoachSessionAssignmentScreen({super.key});

  @override
  State<CoachSessionAssignmentScreen> createState() =>
      _CoachSessionAssignmentScreenState();
}

class _CoachSessionAssignmentScreenState
    extends State<CoachSessionAssignmentScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final List<String> academySessions = const [
    "Friday: 6:00 PM – 8:00 PM",
    "Saturday: 7:00 AM – 9:00 AM",
    "Saturday: 4:00 PM – 6:00 PM",
    "Saturday: 6:00 PM – 8:00 PM",
  ];

  late DateTime selectedWeekStart;
  bool isLoading = true;
  bool isSaving = false;

  final Map<String, String?> selectedCoachForSession = {};
  final Map<String, String> coachNameById = {};
  final Map<String, String> coachEmailById = {};
  final Map<String, String> coachSpecializationById = {};

  @override
  void initState() {
    super.initState();
    selectedWeekStart = _startOfWeek(DateTime.now());

    for (final session in academySessions) {
      selectedCoachForSession[session] = null;
    }

    _loadWeeklyAssignments();
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

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _weekRangeText() {
    final end = selectedWeekStart.add(const Duration(days: 6));
    return "${_formatDate(selectedWeekStart)} - ${_formatDate(end)}";
  }

  String _safeDocId(String value) {
    return value
        .replaceAll(':', '-')
        .replaceAll('/', '-')
        .replaceAll('–', '-')
        .replaceAll(' ', '_');
  }

  String _assignmentDocId(String session) {
    return "${_dateId(selectedWeekStart)}_${_safeDocId(session)}";
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

  bool _isCoachActive(Map<String, dynamic> data) {
    final role = data['role']?.toString().trim() ?? '';
    final approvalStatus =
        data['approvalStatus']?.toString().toLowerCase().trim() ?? '';
    final status = data['status']?.toString().toLowerCase().trim() ?? '';

    return role == 'Coach' &&
        (approvalStatus == 'approved' ||
            status == 'active' ||
            data['isApproved'] == true);
  }

  Future<void> _loadWeeklyAssignments() async {
    setState(() => isLoading = true);

    try {
      final weekId = _dateId(selectedWeekStart);

      final snapshot = await FirebaseFirestore.instance
          .collection('coach_session_assignments')
          .where('weekStartDate', isEqualTo: weekId)
          .get();

      for (final session in academySessions) {
        selectedCoachForSession[session] = null;
      }

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final session = data['session']?.toString() ?? '';
        final coachId = data['coachId']?.toString() ?? '';

        if (academySessions.contains(session) && coachId.isNotEmpty) {
          selectedCoachForSession[session] = coachId;
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Assignment loading failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _changeWeek(int days) async {
    setState(() {
      selectedWeekStart = selectedWeekStart.add(Duration(days: days));
    });

    await _loadWeeklyAssignments();
  }

  Future<void> _saveAssignments() async {
    setState(() => isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      final weekId = _dateId(selectedWeekStart);

      for (final session in academySessions) {
        final coachId = selectedCoachForSession[session];
        final docRef = firestore
            .collection('coach_session_assignments')
            .doc(_assignmentDocId(session));

        if (coachId == null || coachId.trim().isEmpty) {
          batch.set(
            docRef,
            {
              'weekStartDate': weekId,
              'weekEndDate': _dateId(
                selectedWeekStart.add(const Duration(days: 6)),
              ),
              'session': session,
              'batch': session,
              'coachId': '',
              'coachName': 'Not Assigned',
              'coachEmail': '',
              'coachSpecialization': '',
              'status': 'Unassigned',
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          batch.set(
            docRef,
            {
              'weekStartDate': weekId,
              'weekEndDate': _dateId(
                selectedWeekStart.add(const Duration(days: 6)),
              ),
              'session': session,
              'batch': session,
              'coachId': coachId,
              'coachName': coachNameById[coachId] ?? 'Coach',
              'coachEmail': coachEmailById[coachId] ?? '',
              'coachSpecialization':
                  coachSpecializationById[coachId] ?? 'Coach',
              'status': 'Active',
              'updatedAt': FieldValue.serverTimestamp(),
              'createdAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      }

      await batch.commit();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Weekly coach assignments saved successfully"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Save failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          body: SafeArea(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'Coach')
                  .snapshots(),
              builder: (context, coachSnapshot) {
                if (coachSnapshot.hasError) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      Expanded(
                        child: _messageCard(
                          isDark: isDark,
                          icon: Icons.error_outline_rounded,
                          title: "Firebase Error",
                          message: coachSnapshot.error.toString(),
                        ),
                      ),
                    ],
                  );
                }

                if (coachSnapshot.connectionState == ConnectionState.waiting ||
                    isLoading) {
                  return Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                final coaches = coachSnapshot.data?.docs.where((doc) {
                      final data = doc.data();
                      return _isCoachActive(data);
                    }).toList() ??
                    [];

                coachNameById.clear();
                coachEmailById.clear();
                coachSpecializationById.clear();

                for (final coach in coaches) {
                  final data = coach.data();

                  coachNameById[coach.id] =
                      data['name']?.toString().trim() ?? 'Coach';

                  coachEmailById[coach.id] =
                      data['email']?.toString().trim() ?? '';

                  coachSpecializationById[coach.id] =
                      data['specialization']?.toString().trim() ?? 'Coach';
                }

                return Column(
                  children: [
                    _topHeader(context, isDark),
                    _weekSelector(isDark),
                    Expanded(
                      child: coaches.isEmpty
                          ? _messageCard(
                              isDark: isDark,
                              icon: Icons.sports_cricket_rounded,
                              title: "No Active Coach Users Found",
                              message:
                                  "Coach must register first. Then Admin can approve and assign weekly sessions.",
                            )
                          : ListView(
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              children: [
                                _infoBanner(isDark),
                                const SizedBox(height: 14),
                                ...academySessions.map((session) {
                                  return _sessionAssignmentCard(
                                    isDark: isDark,
                                    session: session,
                                    coaches: coaches,
                                  );
                                }),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          bottomNavigationBar: _saveButton(isDark),
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
                  "WEEKLY ASSIGNMENT",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  "Assign coaches to weekly sessions",
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

  Widget _weekSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.black,
                  darkMaroon,
                  red.withOpacity(0.35),
                ]
              : [
                  maroon,
                  red.withOpacity(0.75),
                  darkMaroon,
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? red.withOpacity(0.35) : gold.withOpacity(0.8),
        ),
      ),
      child: Row(
        children: [
          _weekButton(
            icon: Icons.chevron_left_rounded,
            onTap: isSaving ? null : () => _changeWeek(-7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                const Text(
                  "Selected Week",
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weekRangeText(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _weekButton(
            icon: Icons.chevron_right_rounded,
            onTap: isSaving ? null : () => _changeWeek(7),
          ),
        ],
      ),
    );
  }

  Widget _weekButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
          border: Border.all(color: gold.withOpacity(0.45)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  Widget _infoBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? red.withOpacity(0.25) : gold.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: isDark ? gold : maroon,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Assign registered coach users for each weekly session. Coach login will show only these sessions.",
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionAssignmentCard({
    required bool isDark,
    required String session,
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> coaches,
  }) {
    final rawSelectedCoachId = selectedCoachForSession[session];

    final selectedCoachId =
        coaches.any((coach) => coach.id == rawSelectedCoachId)
            ? rawSelectedCoachId
            : null;

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
                ? red.withOpacity(0.08)
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
                radius: 21,
                backgroundColor: red.withOpacity(0.15),
                child: Icon(
                  Icons.sports_cricket_rounded,
                  color: isDark ? gold : maroon,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  session,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedCoachId,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
            style: TextStyle(
              color: _primaryText(isDark),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: "Assign Coach",
              labelStyle: TextStyle(color: _secondaryText(isDark)),
              prefixIcon: Icon(
                Icons.person_rounded,
                color: isDark ? gold : maroon,
              ),
              filled: true,
              fillColor: isDark ? const Color(0xFF0B0B0B) : Colors.white,
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
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text("Not Assigned"),
              ),
              ...coaches.map((coach) {
                final data = coach.data();
                final name = data['name']?.toString() ?? 'Coach';
                final specialization =
                    data['specialization']?.toString() ?? 'Coach';

                return DropdownMenuItem<String>(
                  value: coach.id,
                  child: Text(
                    "$name • $specialization",
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: isSaving
                ? null
                : (value) {
                    setState(() {
                      if (value == null || value.isEmpty) {
                        selectedCoachForSession[session] = null;
                      } else {
                        selectedCoachForSession[session] = value;
                      }
                    });
                  },
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _card(isDark),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border(isDark)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDark ? gold : maroon,
                size: 46,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText(isDark),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton(bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        decoration: BoxDecoration(
          color: _bg(isDark),
          border: Border(
            top: BorderSide(color: _border(isDark)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
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
            onPressed: isSaving ? null : _saveAssignments,
            icon: isSaving
                ? const SizedBox()
                : const Icon(Icons.save_alt_rounded, size: 22),
            label: isSaving
                ? CircularProgressIndicator(
                    color: isDark ? Colors.white : gold,
                    strokeWidth: 2,
                  )
                : const Text(
                    "SAVE WEEKLY ASSIGNMENT",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}