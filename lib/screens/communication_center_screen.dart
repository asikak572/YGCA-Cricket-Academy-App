import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/theme_controller.dart';

class CommunicationCenterScreen extends StatefulWidget {
  const CommunicationCenterScreen({super.key});

  @override
  State<CommunicationCenterScreen> createState() =>
      _CommunicationCenterScreenState();
}

class _CommunicationCenterScreenState extends State<CommunicationCenterScreen> {
  static const Color red = Color(0xFFE50914);
  static const Color maroon = Color(0xFF7F0000);
  static const Color darkMaroon = Color(0xFF3B0000);
  static const Color gold = Color(0xFFD4AF37);

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  bool loadingUser = true;
  bool isSending = false;

  String uid = '';
  String role = '';
  String email = '';

  String selectedType = "Academy Announcement";
  String selectedTarget = "All";
  String selectedBatch = "All";

  final List<String> messageTypes = [
    "Academy Announcement",
    "Match Schedule",
    "Practice Cancelled",
    "Tournament Update",
    "Camp Registration",
    "Custom Message",
  ];

  final List<String> targetOptions = [
    "All",
    "Students",
    "Parents",
    "Coaches",
    "Batch Wise",
  ];

  final List<String> batchOptions = [
    "All",
    "U-14",
    "U-15",
    "U-16",
    "Senior batch",
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
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

  bool get _canSendCommunication {
    return role == 'Admin' || role == 'Coach';
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

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!userDoc.exists || userDoc.data() == null) {
      if (!mounted) return;
      setState(() => loadingUser = false);
      return;
    }

    final data = userDoc.data() ?? {};

    if (!mounted) return;

    setState(() {
      role = _text(data['role']);
      loadingUser = false;
    });
  }

  String _targetRole() {
    if (selectedTarget == "Students") return "Student";
    if (selectedTarget == "Parents") return "Parent";
    if (selectedTarget == "Coaches") return "Coach";
    if (selectedTarget == "Batch Wise") return "Student";
    return "All";
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "No Date";

    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        final year = date.year.toString();

        return "$day/$month/$year";
      }

      if (timestamp is DateTime) {
        final day = timestamp.day.toString().padLeft(2, '0');
        final month = timestamp.month.toString().padLeft(2, '0');
        final year = timestamp.year.toString();

        return "$day/$month/$year";
      }

      return timestamp.toString();
    } catch (_) {
      return "No Date";
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortLogs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final logs = docs.toList();

    logs.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime is Timestamp && bTime is Timestamp) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    return logs;
  }

  Future<void> _sendCommunication() async {
    if (!_canSendCommunication) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You do not have access to send communication"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final title = titleController.text.trim();
    final message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill title and message"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      final targetRole = _targetRole();
      final targetBatch = selectedTarget == "Batch Wise" ? selectedBatch : "All";

      await FirebaseFirestore.instance.collection('communication_logs').add({
        'title': title,
        'message': message,
        'type': selectedType,
        'target': selectedTarget,
        'targetRole': targetRole,
        'batch': targetBatch,
        'targetBatch': targetBatch,
        'sentBy': uid,
        'sentByEmail': email,
        'sentByRole': role,
        'status': 'Pending API Integration',
        'channels': ['In-App', 'SMS', 'WhatsApp'],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'title': title,
        'message': message,
        'type': selectedType,
        'targetRole': targetRole,
        'target': selectedTarget,
        'batch': targetBatch,
        'targetBatch': targetBatch,
        'createdBy': uid,
        'createdByEmail': email,
        'createdByRole': role,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (!mounted) return;

      titleController.clear();
      messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Communication saved. SMS/WhatsApp API will be connected later.",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => isSending = false);
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
            child: loadingUser
                ? Column(
                    children: [
                      _topHeader(context, isDark),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        _topHeader(context, isDark),
                        _heroCard(isDark),
                        const SizedBox(height: 18),
                        if (_canSendCommunication) _formCard(isDark),
                        if (!_canSendCommunication) _accessCard(isDark),
                        const SizedBox(height: 16),
                        _infoCard(isDark),
                        const SizedBox(height: 18),
                        _sectionTitle("RECENT COMMUNICATIONS", isDark),
                        _recentLogs(isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
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
                  "COMMUNICATION",
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
                  _canSendCommunication
                      ? "Send academy alerts and updates"
                      : "View academy communication status",
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

  Widget _heroCard(bool isDark) {
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
              Icons.campaign_rounded,
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
                    Icons.campaign_rounded,
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
                          const Text(
                            "COMMUNICATION",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
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
                              _heroChip("In-App"),
                              _heroChip("SMS Later"),
                              _heroChip("WhatsApp Later"),
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

  Widget _formCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
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
            _dropdown(
              isDark: isDark,
              label: "Message Type",
              value: selectedType,
              items: messageTypes,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedType = value);
              },
            ),
            const SizedBox(height: 10),
            _dropdown(
              isDark: isDark,
              label: "Target Audience",
              value: selectedTarget,
              items: targetOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedTarget = value);
              },
            ),
            if (selectedTarget == "Batch Wise") ...[
              const SizedBox(height: 10),
              _dropdown(
                isDark: isDark,
                label: "Select Batch",
                value: selectedBatch,
                items: batchOptions,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedBatch = value);
                },
              ),
            ],
            const SizedBox(height: 10),
            _inputField(
              isDark: isDark,
              label: "Title",
              controller: titleController,
            ),
            const SizedBox(height: 10),
            _inputField(
              isDark: isDark,
              label: "Message",
              controller: messageController,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? red : maroon,
                  foregroundColor: isDark ? Colors.white : gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isSending ? null : _sendCommunication,
                icon: isSending
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
                  isSending ? "SENDING..." : "SEND COMMUNICATION",
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accessCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
              Icons.lock_outline_rounded,
              size: 40,
              color: _secondaryText(isDark),
            ),
            const SizedBox(height: 10),
            Text(
              "View Only Access",
              style: TextStyle(
                color: _primaryText(isDark),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Only Admin and Coach can send academy communication.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1304) : const Color(0xFFFFFBEB),
          border: Border.all(
            color: isDark ? gold.withOpacity(0.45) : const Color(0xFFFDE68A),
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Currently this saves communication logs and creates in-app notifications. Real SMS/WhatsApp API integration will be connected later.",
                style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF78350F),
                  fontSize: 12,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recentLogs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('communication_logs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _emptyCard(
              isDark,
              "Unable to load logs",
              snapshot.error.toString(),
              Icons.error_outline_rounded,
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final logs = _sortLogs(snapshot.data?.docs ?? []).take(10).toList();

          if (logs.isEmpty) {
            return _emptyCard(
              isDark,
              "No communication logs found",
              "Sent messages will appear here",
              Icons.campaign_outlined,
            );
          }

          return Column(
            children: logs.map((doc) {
              final data = doc.data();

              final title = _text(data['title']).isEmpty
                  ? 'Untitled Communication'
                  : _text(data['title']);

              final message = _text(data['message']);
              final target = _text(data['target']).isEmpty
                  ? _text(data['targetRole'])
                  : _text(data['target']);
              final type = _text(data['type']);
              final status = _text(data['status']).isEmpty
                  ? 'Saved'
                  : _text(data['status']);
              final date = _formatDate(data['createdAt']);

              return _logCard(
                isDark: isDark,
                title: title,
                message: message,
                target: target,
                type: type,
                status: status,
                date: date,
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _logCard({
    required bool isDark,
    required String title,
    required String message,
    required String target,
    required String type,
    required String status,
    required String date,
  }) {
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
            radius: 25,
            backgroundColor: maroon,
            child: const Icon(
              Icons.campaign_rounded,
              color: gold,
              size: 22,
            ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText(isDark),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                      isDark: isDark,
                      icon: Icons.category_rounded,
                      text: type.isEmpty ? "Message" : type,
                      color: Colors.blueAccent,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.group_rounded,
                      text: target.isEmpty ? "All" : target,
                      color: Colors.green,
                    ),
                    _chip(
                      isDark: isDark,
                      icon: Icons.schedule_rounded,
                      text: date,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _statusChip(status),
        ],
      ),
    );
  }

  Widget _dropdown({
    required bool isDark,
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: isDark ? const Color(0xFF111111) : Colors.white,
      style: TextStyle(
        color: _primaryText(isDark),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _secondaryText(isDark)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: _border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? red : maroon),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _inputField({
    required bool isDark,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(
        color: _primaryText(isDark),
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _secondaryText(isDark)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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

  Widget _chip({
    required bool isDark,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.13 : 0.10),
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
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
      ),
      child: Text(
        status,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _emptyCard(
    bool isDark,
    String title,
    String subtitle,
    IconData icon,
  ) {
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
            icon,
            size: 38,
            color: _secondaryText(isDark),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText(isDark),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText(isDark)),
          ),
        ],
      ),
    );
  }
}
