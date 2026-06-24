import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/theme_controller.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  String role = '';
  String uid = '';
  String email = '';
  bool isUserLoaded = false;

  List<String> linkedChildrenIds = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
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

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() => isUserLoaded = true);
      return;
    }

    uid = user.uid;
    email = _lower(user.email ?? '');

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      if (!mounted) return;
      setState(() => isUserLoaded = true);
      return;
    }

    final data = userDoc.data() ?? {};
    final loadedRole = _text(data['role']);
    final loadedEmail = _lower(
      _text(data['email']).isNotEmpty ? _text(data['email']) : email,
    );

    final ids = <String>{};

    final linked = data['linkedChildrenIds'];
    if (linked is List) {
      for (final id in linked) {
        final value = _text(id);
        if (value.isNotEmpty) ids.add(value);
      }
    }

    final childId = _text(data['childId']);
    if (childId.isNotEmpty) ids.add(childId);

    final studentId = _text(data['studentId']);
    if (studentId.isNotEmpty) ids.add(studentId);

    if (loadedRole == 'Parent' && loadedEmail.isNotEmpty) {
      final byParentEmailLower = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmailLower', isEqualTo: loadedEmail)
          .get();

      for (final doc in byParentEmailLower.docs) {
        ids.add(doc.id);
      }

      final byParentEmail = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmail', isEqualTo: loadedEmail)
          .get();

      for (final doc in byParentEmail.docs) {
        ids.add(doc.id);
      }

      final byParentUid = await FirebaseFirestore.instance
          .collection('students')
          .where('parentUid', isEqualTo: uid)
          .get();

      for (final doc in byParentUid.docs) {
        ids.add(doc.id);
      }
    }

    if (!mounted) return;

    setState(() {
      role = loadedRole;
      email = loadedEmail;
      linkedChildrenIds = ids.toList();
      isUserLoaded = true;
    });
  }

  Query<Map<String, dynamic>> _notificationQuery() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true);
  }

  bool _canShowNotification(Map<String, dynamic> data) {
    final targetRole =
        _text(data['targetRole']).isEmpty ? 'All' : _text(data['targetRole']);

    final studentId = _text(data['studentId']);
    final type = _text(data['type']).isEmpty ? 'General' : _text(data['type']);

    final targetEmail = _lower(_text(data['targetEmail']));
    final parentEmail = _lower(_text(data['parentEmail']));

    if (role == 'Admin') return true;

    if (role == 'Coach') {
      return targetRole == 'All' || targetRole == 'Coach';
    }

    if (role == 'Student') {
      if (targetRole == 'All') return true;

      if (targetRole == 'Student') {
        if (studentId.isEmpty) return true;
        return studentId == uid;
      }

      return false;
    }

    if (role == 'Parent') {
      if (targetRole == 'All') return true;

      if (targetRole == 'Parent' &&
          (type == 'General' || type == 'Announcement')) {
        return true;
      }

      if (targetEmail.isNotEmpty && targetEmail == email) return true;
      if (parentEmail.isNotEmpty && parentEmail == email) return true;

      if (studentId.isNotEmpty && linkedChildrenIds.contains(studentId)) {
        return true;
      }

      return false;
    }

    return targetRole == 'All';
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "No date";

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
      return "No date";
    }
  }

  Future<void> _deleteNotification(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Notification deleted"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
        title: Text(
          "Delete Notification",
          style: TextStyle(
            color: _primaryText(isDark),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          "Are you sure you want to delete this notification?",
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
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNotification(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _addNotificationDialog(
    BuildContext context,
    bool isDark,
  ) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    String selectedTarget = "All";

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF111111) : Colors.white,
              title: Text(
                "Add Notification",
                style: TextStyle(
                  color: _primaryText(isDark),
                  fontWeight: FontWeight.w900,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedTarget,
                      dropdownColor:
                          isDark ? const Color(0xFF111111) : Colors.white,
                      style: TextStyle(
                        color: _primaryText(isDark),
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        labelText: "Send To",
                        labelStyle: TextStyle(color: _secondaryText(isDark)),
                        border: const OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: _border(isDark)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: isDark ? red : maroon),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: "All", child: Text("All")),
                        DropdownMenuItem(value: "Admin", child: Text("Admin")),
                        DropdownMenuItem(value: "Coach", child: Text("Coach")),
                        DropdownMenuItem(value: "Parent", child: Text("Parent")),
                        DropdownMenuItem(
                          value: "Student",
                          child: Text("Student"),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => selectedTarget = value);
                      },
                    ),
                    const SizedBox(height: 10),
                    _field(
                      isDark: isDark,
                      label: "Title",
                      controller: titleController,
                    ),
                    _field(
                      isDark: isDark,
                      label: "Message",
                      controller: messageController,
                      maxLines: 3,
                    ),
                  ],
                ),
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
                    backgroundColor: isDark ? red : maroon,
                    foregroundColor: isDark ? Colors.white : gold,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        messageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill title and message"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    await FirebaseFirestore.instance
                        .collection('notifications')
                        .add({
                      'title': titleController.text.trim(),
                      'message': messageController.text.trim(),
                      'targetRole': selectedTarget,
                      'type': 'Announcement',
                      'createdBy': uid,
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Notification added"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    messageController.dispose();
  }

  Widget _field({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
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

  Color _targetColor(String targetRole) {
    switch (targetRole) {
      case "Admin":
        return Colors.redAccent;
      case "Coach":
        return Colors.blueAccent;
      case "Parent":
        return Colors.orange;
      case "Student":
        return Colors.green;
      default:
        return Colors.purpleAccent;
    }
  }

  IconData _targetIcon(String targetRole) {
    switch (targetRole) {
      case "Admin":
        return Icons.admin_panel_settings_rounded;
      case "Coach":
        return Icons.sports_cricket_rounded;
      case "Parent":
        return Icons.family_restroom_rounded;
      case "Student":
        return Icons.school_rounded;
      default:
        return Icons.groups_rounded;
    }
  }

  int _todayCount(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    final now = DateTime.now();
    int count = 0;

    for (final doc in docs) {
      final timestamp = doc.data()['createdAt'];

      if (timestamp is Timestamp) {
        final date = timestamp.toDate();

        if (date.year == now.year &&
            date.month == now.month &&
            date.day == now.day) {
          count++;
        }
      }
    }

    return count;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: _bg(isDark),
          floatingActionButton: role == 'Admin'
              ? FloatingActionButton.extended(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                  onPressed: () => _addNotificationDialog(context, isDark),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    "Add Notification",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                )
              : null,
          body: SafeArea(
            child: !isUserLoaded
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _notificationQuery().snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: [
                            _topHeader(context, isDark),
                            Expanded(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
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

                      final notifications = snapshot.data?.docs ?? [];

                      final filteredNotifications = notifications.where((doc) {
                        return _canShowNotification(doc.data());
                      }).toList();

                      final todayCount = _todayCount(filteredNotifications);

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            _topHeader(context, isDark),
                            _heroBanner(
                              isDark: isDark,
                              total: filteredNotifications.length,
                              today: todayCount,
                            ),
                            const SizedBox(height: 14),
                            _sectionTitle("NOTIFICATION LIST", isDark),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: filteredNotifications.isEmpty
                                  ? _emptyCard(isDark)
                                  : Column(
                                      children:
                                          filteredNotifications.map((doc) {
                                        final data = doc.data();

                                        final title =
                                            _text(data['title']).isEmpty
                                                ? 'No Title'
                                                : _text(data['title']);

                                        final message =
                                            _text(data['message']).isEmpty
                                                ? 'No Message'
                                                : _text(data['message']);

                                        final targetRole =
                                            _text(data['targetRole']).isEmpty
                                                ? 'All'
                                                : _text(data['targetRole']);

                                        final time =
                                            _formatDate(data['createdAt']);

                                        return _notificationCard(
                                          isDark: isDark,
                                          title: title,
                                          message: message,
                                          targetRole: targetRole,
                                          time: time,
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
                  "NOTIFICATIONS",
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
                  "Academy updates center",
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
    required int total,
    required int today,
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
              Icons.notifications_active_rounded,
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
                    Icons.notifications_active_rounded,
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
                            "ACADEMY",
                            style: TextStyle(
                              color: gold,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const Text(
                            "UPDATES",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          Text(
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
                              _heroChip("Today: $today"),
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
      constraints: const BoxConstraints(maxWidth: 150),
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
            Icons.notifications_none_rounded,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            "No notifications found",
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "No updates available for your account",
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _notificationCard({
    required bool isDark,
    required String title,
    required String message,
    required String targetRole,
    required String time,
    required VoidCallback onDelete,
  }) {
    final color = _targetColor(targetRole);
    final icon = _targetIcon(targetRole);

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 20),
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
                const SizedBox(height: 5),
                Text(
                  message,
                  softWrap: true,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _roleChip(targetRole, color),
                    _timeChip(time, isDark),
                  ],
                ),
              ],
            ),
          ),
          if (role == 'Admin')
            IconButton(
              icon: const Icon(
                Icons.delete_rounded,
                color: Colors.redAccent,
                size: 21,
              ),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }

  Widget _roleChip(String role, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _timeChip(String time, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: _secondaryText(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}