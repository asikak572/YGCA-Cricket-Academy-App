import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';

class MatchScheduleScreen extends StatefulWidget {
  const MatchScheduleScreen({super.key});

  @override
  State<MatchScheduleScreen> createState() => _MatchScheduleScreenState();
}

class _MatchScheduleScreenState extends State<MatchScheduleScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  bool loadingUser = true;
  String uid = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  String _text(dynamic value) => value == null ? '' : value.toString().trim();

  bool get _canManage => role == 'Admin';

  Color _bg(bool isDark) => isDark ? const Color(0xFF070707) : const Color(0xFFFAFAFA);
  Color _card(bool isDark) => isDark ? const Color(0xFF111111) : Colors.white;
  Color _border(bool isDark) => isDark ? const Color(0xFF3A1515) : const Color(0xFFE2E8F0);
  Color _primaryText(bool isDark) => isDark ? Colors.white : const Color(0xFF111827);
  Color _secondaryText(bool isDark) => isDark ? Colors.white60 : const Color(0xFF64748B);

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => loadingUser = false);
      return;
    }

    uid = user.uid;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    role = _text(doc.data()?['role']);

    if (mounted) setState(() => loadingUser = false);
  }

  String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  String _formatDate(dynamic value) {
    final date = _parseDate(value);
    if (date == null) return _text(value);

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Color _statusColor(String status) {
    final lower = status.toLowerCase();
    if (lower.contains("completed")) return Colors.green;
    if (lower.contains("cancelled")) return Colors.redAccent;
    return Colors.orange;
  }

  IconData _statusIcon(String status) {
    final lower = status.toLowerCase();
    if (lower.contains("completed")) return Icons.verified_rounded;
    if (lower.contains("cancelled")) return Icons.cancel_rounded;
    return Icons.schedule_rounded;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortMatches(
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

  Future<void> _deleteMatch(String docId) async {
    if (!_canManage) return;

    try {
      await FirebaseFirestore.instance.collection('matches').doc(docId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Match deleted"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Delete failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddMatchDialog(BuildContext context, bool isDark) async {
    if (!_canManage) return;

    final titleController = TextEditingController();
    final opponentController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final venueController = TextEditingController();
    final batchController = TextEditingController();
    final statusController = TextEditingController(text: "Upcoming");

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
              dialogBackgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
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
              dialogBackgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
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
            "Add Match",
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input(
                  isDark: isDark,
                  label: "Match Title",
                  controller: titleController,
                  hintText: "Example: Friendly Match",
                ),
                _input(
                  isDark: isDark,
                  label: "Opponent",
                  controller: opponentController,
                  hintText: "Example: ABC Academy",
                ),
                _input(
                  isDark: isDark,
                  label: "Date",
                  controller: dateController,
                  readOnly: true,
                  icon: Icons.calendar_today_rounded,
                  onTap: () => pickDate(dialogContext),
                ),
                _input(
                  isDark: isDark,
                  label: "Time",
                  controller: timeController,
                  readOnly: true,
                  icon: Icons.access_time_rounded,
                  onTap: () => pickTime(dialogContext),
                ),
                _input(
                  isDark: isDark,
                  label: "Venue",
                  controller: venueController,
                  hintText: "Example: YGCA Ground",
                ),
                _input(
                  isDark: isDark,
                  label: "Batch",
                  controller: batchController,
                  hintText: "Example: Morning Batch",
                ),
                _input(
                  isDark: isDark,
                  label: "Status",
                  controller: statusController,
                  hintText: "Upcoming / Completed / Cancelled",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                "Cancel",
                style: TextStyle(
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
                final title = titleController.text.trim();
                final opponent = opponentController.text.trim();
                final date = dateController.text.trim();
                final time = timeController.text.trim();
                final venue = venueController.text.trim();
                final batch = batchController.text.trim();
                final status = statusController.text.trim().isEmpty
                    ? "Upcoming"
                    : statusController.text.trim();

                if (title.isEmpty ||
                    opponent.isEmpty ||
                    date.isEmpty ||
                    time.isEmpty ||
                    venue.isEmpty ||
                    batch.isEmpty ||
                    status.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill all fields"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance.collection('matches').add({
                    'title': title,
                    'opponent': opponent,
                    'date': date,
                    'time': time,
                    'venue': venue,
                    'batch': batch,
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
                      const SnackBar(
                        content: Text("Match added"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(
                        content: Text("Save failed: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    opponentController.dispose();
    dateController.dispose();
    timeController.dispose();
    venueController.dispose();
    batchController.dispose();
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
          color: _primaryText(isDark),
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(
            color: _secondaryText(isDark).withOpacity(0.65),
            fontSize: 12,
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
    if (!_canManage) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card(isDark),
        title: Text(
          "Delete Match",
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this match?",
          style: TextStyle(color: _secondaryText(isDark)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: isDark ? Colors.white70 : maroon),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteMatch(docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          floatingActionButton: _canManage
              ? SafeArea(
                  child: FloatingActionButton.extended(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                  onPressed: () => _showAddMatchDialog(context, isDark),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    "Add Match",
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
                    stream: FirebaseFirestore.instance
                        .collection('matches')
                        .snapshots(),
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
                                    "Error: ${snapshot.error}",
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

                      final matches = _sortMatches(snapshot.data?.docs ?? []);

                      int upcoming = 0;
                      int completed = 0;
                      int cancelled = 0;

                      for (final doc in matches) {
                        final data = doc.data();
                        final status = _text(data['status']).isEmpty
                            ? 'Upcoming'
                            : _text(data['status']);

                        final lower = status.toLowerCase();

                        if (lower.contains("completed")) {
                          completed++;
                        } else if (lower.contains("cancelled")) {
                          cancelled++;
                        } else {
                          upcoming++;
                        }
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroBanner(
                              isDark: isDark,
                              total: matches.length,
                              upcoming: upcoming,
                              completed: completed,
                              cancelled: cancelled,
                            ),
                            const SizedBox(height: 18),
                            _sectionTitle("MATCH SCHEDULES", isDark),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: matches.isEmpty
                                  ? _emptyCard(isDark)
                                  : Column(
                                      children: matches.map((doc) {
                                        final data = doc.data();

                                        return _matchCard(
                                          isDark: isDark,
                                          title: _text(data['title']).isEmpty
                                              ? 'No Title'
                                              : _text(data['title']),
                                          opponent: _text(data['opponent']),
                                          date: _formatDate(data['date']),
                                          time: _text(data['time']),
                                          venue: _text(data['venue']),
                                          status: _text(data['status']).isEmpty
                                              ? 'Upcoming'
                                              : _text(data['status']),
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
                  "MATCH SCHEDULE",
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
                  _canManage
                      ? "Manage academy match updates"
                      : "View academy match updates",
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
                icon:
                    dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
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
    required int upcoming,
    required int completed,
    required int cancelled,
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
              Icons.sports_cricket_rounded,
              color: Colors.white.withOpacity(0.08),
              size: 150,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.sports_cricket_rounded,
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
                          const Text(
                            "YGCA",
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const Text(
                            "MATCH",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const Text(
                            "CENTER",
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
                              _heroChip("Total: $total"),
                              _heroChip("Upcoming: $upcoming"),
                              _heroChip("Completed: $completed"),
                              _heroChip("Cancelled: $cancelled"),
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
        style: const TextStyle(
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
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                maxLines: 1,
                softWrap: false,
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

  Widget _matchCard({
    required bool isDark,
    required String title,
    required String opponent,
    required String date,
    required String time,
    required String venue,
    required String status,
    required VoidCallback onDelete,
  }) {
    final color = _statusColor(status);
    final icon = _statusIcon(status);
    final dateTime = [date, time].where((item) => item.isNotEmpty).join(' • ');

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
            radius: 26,
            backgroundColor: color.withOpacity(0.18),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText(isDark),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                if (opponent.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "vs $opponent",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (dateTime.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    dateTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? gold : maroon,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
                if (venue.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    venue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _secondaryText(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _statusChip(status, color),
              ],
            ),
          ),
          if (_canManage)
            IconButton(
              icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
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
          Icon(Icons.sports_cricket_rounded, size: 38, color: _secondaryText(isDark)),
          const SizedBox(height: 10),
          Text(
            "No matches scheduled",
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _canManage ? "Click Add Match to create one" : "Match updates will appear here",
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
