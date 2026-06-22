import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

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

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    uid = user.uid;
    email = user.email ?? '';

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      if (!mounted) return;
      setState(() {
        isUserLoaded = true;
      });
      return;
    }

    final data = userDoc.data() ?? {};
    final loadedRole = _text(data['role']);
    final loadedEmail =
        _text(data['email']).isNotEmpty ? _text(data['email']) : email;

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

    // Fallback auto-link support: find student docs by parentEmail
    if (loadedRole == 'Parent' && loadedEmail.isNotEmpty) {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmail', isEqualTo: loadedEmail)
          .get();

      for (final doc in studentSnapshot.docs) {
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

  Query _notificationQuery() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .orderBy('createdAt', descending: true);
  }

  bool _canShowNotification(Map<String, dynamic> data) {
    final targetRole = _text(data['targetRole']).isEmpty
        ? 'All'
        : _text(data['targetRole']);

    final studentId = _text(data['studentId']);
    final type = _text(data['type']).isEmpty ? 'General' : _text(data['type']);
    final targetEmail = _text(data['targetEmail']);
    final parentEmail = _text(data['parentEmail']);

    if (role == 'Admin') return true;

    if (role == 'Coach') {
      return targetRole == 'All' || targetRole == 'Coach';
    }

    if (role == 'Student') {
      if (targetRole == 'All' || targetRole == 'Student') {
        if (studentId.isEmpty) return true;
        return studentId == uid;
      }
      return false;
    }

    if (role == 'Parent') {
      // Admin announcements / academy announcements
      if (targetRole == 'All') return true;

      if (targetRole == 'Parent' &&
          (type == 'General' || type == 'Announcement')) {
        return true;
      }

      // Parent-specific by email
      if (targetEmail.isNotEmpty && targetEmail == email) return true;
      if (parentEmail.isNotEmpty && parentEmail == email) return true;

      // Child-specific notification
      if (studentId.isNotEmpty && linkedChildrenIds.contains(studentId)) {
        return true;
      }

      return false;
    }

    return targetRole == 'All';
  }

  Future<void> _addNotificationDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    String selectedTarget = "All";

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Notification"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedTarget,
                      decoration: const InputDecoration(
                        labelText: "Send To",
                        border: OutlineInputBorder(),
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
                        setDialogState(() {
                          selectedTarget = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _field("Title", titleController),
                    _field("Message", messageController, maxLines: 3),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                  ),
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty ||
                        messageController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill title and message"),
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
                        const SnackBar(content: Text("Notification added")),
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

  static Widget _field(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "No date";

    try {
      final date = (timestamp as Timestamp).toDate();
      return "${date.day}/${date.month}/${date.year}";
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
        const SnackBar(content: Text("Notification deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Notification"),
        content: const Text(
          "Are you sure you want to delete this notification?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
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

  Color _targetColor(String role) {
    switch (role) {
      case "Admin":
        return Colors.red;
      case "Coach":
        return Colors.blue;
      case "Parent":
        return Colors.orange;
      case "Student":
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  IconData _targetIcon(String role) {
    switch (role) {
      case "Admin":
        return Icons.admin_panel_settings;
      case "Coach":
        return Icons.sports;
      case "Parent":
        return Icons.family_restroom;
      case "Student":
        return Icons.school;
      default:
        return Icons.groups;
    }
  }

  int _todayCount(List<QueryDocumentSnapshot> notifications) {
    final now = DateTime.now();
    int count = 0;

    for (final doc in notifications) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['createdAt'];

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
    if (!isUserLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];

          final filteredNotifications = notifications.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _canShowNotification(data);
          }).toList();

          final todayCount = _todayCount(filteredNotifications);

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: filteredNotifications.length,
                  today: todayCount,
                ),
                const SizedBox(height: 18),
                _sectionTitle("NOTIFICATION LIST"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: filteredNotifications.isEmpty
                      ? _emptyCard()
                      : Column(
                          children: filteredNotifications.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;

                            final title =
                                data['title']?.toString() ?? 'No Title';
                            final message =
                                data['message']?.toString() ?? 'No Message';
                            final targetRole =
                                data['targetRole']?.toString() ?? 'All';
                            final time = _formatDate(data['createdAt']);

                            return _notificationCard(
                              title: title,
                              message: message,
                              targetRole: targetRole,
                              time: time,
                              onDelete: () => _confirmDelete(context, doc.id),
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
      floatingActionButton: role == 'Admin'
          ? FloatingActionButton.extended(
              backgroundColor: maroon,
              foregroundColor: gold,
              onPressed: () => _addNotificationDialog(context),
              icon: const Icon(Icons.add),
              label: const Text("Add Notification"),
            )
          : null,
    );
  }

  Widget _topHeader(BuildContext context) {
    return Container(
      color: maroon,
      padding: const EdgeInsets.fromLTRB(16, 45, 16, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          Image.asset(
            'assets/images/ygca_logo.jpg',
            width: 58,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "NOTIFICATIONS",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int today,
  }) {
    return Container(
      height: 230,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border.all(color: gold, width: 1),
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
                  colors: [
                    darkMaroon.withOpacity(0.96),
                    maroon.withOpacity(0.70),
                    Colors.black.withOpacity(0.38),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.notifications_active,
                    color: maroon,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ACADEMY",
                        style: TextStyle(
                          color: gold,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "UPDATES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "CENTER",
                        style: TextStyle(
                          color: gold,
                          fontSize: 26,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withOpacity(0.7)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: gold,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: maroon,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 42, height: 2, color: gold),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.notifications_none, size: 38, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No notifications found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("No updates available for your account"),
        ],
      ),
    );
  }

  Widget _notificationCard({
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
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  softWrap: true,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _roleChip(targetRole, color),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (role == 'Admin')
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 21),
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
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}