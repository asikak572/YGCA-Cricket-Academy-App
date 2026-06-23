import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MakeupSessionScreen extends StatefulWidget {
  const MakeupSessionScreen({super.key});

  @override
  State<MakeupSessionScreen> createState() => _MakeupSessionScreenState();
}

class _MakeupSessionScreenState extends State<MakeupSessionScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color darkMaroon = const Color(0xFF3B0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFFAFAFA);
  final Color border = const Color(0xFFE2E8F0);

  bool isLoadingUser = true;
  String uid = '';
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

  Future<void> _loadCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        isLoadingUser = false;
      });
      return;
    }

    uid = user.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!mounted) return;

    if (!userDoc.exists) {
      setState(() {
        isLoadingUser = false;
      });
      return;
    }

    final data = userDoc.data() ?? {};

    final batches = <String>[];
    final rawBatches = data['assignedBatches'];

    if (rawBatches is List) {
      for (final batch in rawBatches) {
        final value = _text(batch);
        if (value.isNotEmpty) {
          batches.add(value);
        }
      }
    }

    final childIds = <String>[];
    final rawChildren = data['linkedChildrenIds'];

    if (rawChildren is List) {
      for (final childId in rawChildren) {
        final value = _text(childId);
        if (value.isNotEmpty) {
          childIds.add(value);
        }
      }
    }

    setState(() {
      role = _text(data['role']);
      assignedBatches = batches;
      linkedChildrenIds = childIds;
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

      return collection.where(
        'batch',
        whereIn: assignedBatches.take(10).toList(),
      );
    }

    if (role == 'Parent') {
      return collection.where('parentUid', isEqualTo: uid);
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
      final aData = a.data();
      final bData = b.data();

      final aTime = aData['createdAt'];
      final bTime = bData['createdAt'];

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
    final dateController = TextEditingController();
    final timeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Schedule Makeup Session"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input("Makeup Date", dateController),
            _input("Makeup Time", timeController),
          ],
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
              final date = dateController.text.trim();
              final time = timeController.text.trim();

              if (date.isEmpty || time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill date and time")),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('makeup_sessions')
                    .doc(docId)
                    .set({
                  'makeupDate': date,
                  'makeupTime': time,
                  'status': 'Scheduled',
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                await FirebaseFirestore.instance.collection('notifications').add({
                  'title': 'Makeup Session Scheduled',
                  'message': 'Makeup session scheduled on $date at $time',
                  'targetRole': 'All',
                  'type': 'Announcement',
                  'createdBy': uid,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Makeup session scheduled")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Schedule failed: $e")),
                  );
                }
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    dateController.dispose();
    timeController.dispose();
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
          const SnackBar(content: Text("Makeup session marked as completed")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Update failed: $e")),
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
          const SnackBar(content: Text("Makeup session deleted")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete failed: $e")),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Makeup Session"),
        content: const Text("Are you sure you want to delete this session?"),
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
              await _deleteSession(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  Color _statusColor(String status) {
    if (status == "Completed") return Colors.blue;
    if (status == "Pending") return Colors.orange;
    return Colors.green;
  }

  IconData _statusIcon(String status) {
    if (status == "Completed") return Icons.check_circle;
    if (status == "Pending") return Icons.pending_actions;
    return Icons.calendar_month;
  }

  bool get _canManage {
    return role == 'Admin' || role == 'Coach';
  }

  bool get _canDelete {
    return role == 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _makeupQuery().snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _errorView(context, snapshot.error.toString());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = _sortSessions(snapshot.data?.docs ?? []);

          int scheduled = 0;
          int completed = 0;
          int pending = 0;

          for (final doc in sessions) {
            final data = doc.data();
            final status = data['status']?.toString() ?? 'Pending';

            if (status == "Completed") {
              completed++;
            } else if (status == "Pending") {
              pending++;
            } else {
              scheduled++;
            }
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _topHeader(context),
                _heroBanner(
                  total: sessions.length,
                  scheduled: scheduled,
                  completed: completed,
                  pending: pending,
                ),
                const SizedBox(height: 18),
                _sectionTitle("MAKEUP OVERVIEW"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                    children: [
                      _statCard(
                        Icons.event_repeat,
                        "TOTAL",
                        sessions.length.toString(),
                        "Sessions",
                        Colors.blue,
                      ),
                      _statCard(
                        Icons.calendar_month,
                        "SCHEDULED",
                        scheduled.toString(),
                        "Planned",
                        Colors.green,
                      ),
                      _statCard(
                        Icons.pending_actions,
                        "PENDING",
                        pending.toString(),
                        "Waiting",
                        Colors.orange,
                      ),
                      _statCard(
                        Icons.check_circle,
                        "COMPLETED",
                        completed.toString(),
                        "Done",
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoBanner(),
                ),
                const SizedBox(height: 18),
                _sectionTitle("MAKEUP SESSION LIST"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: sessions.isEmpty
                      ? _emptyCard()
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
                                ? 'Pending'
                                : _text(data['status']);

                            return _makeupCard(
                              context: context,
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
                              status: status,
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
    );
  }

  Widget _errorView(BuildContext context, String error) {
    return Column(
      children: [
        _topHeader(context),
        Expanded(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 10),
                  const Text(
                    "Unable to load makeup sessions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
          Image.asset('assets/images/ygca_logo.jpg', width: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "MAKEUP SESSIONS",
              style: TextStyle(
                color: gold,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.event_repeat, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _heroBanner({
    required int total,
    required int scheduled,
    required int completed,
    required int pending,
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
                  child: Icon(Icons.event_repeat, color: maroon, size: 42),
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
                        "MAKEUP",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        "SESSIONS",
                        style: TextStyle(
                          color: gold,
                          fontSize: 25,
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
                          _heroChip("Scheduled: $scheduled"),
                          _heroChip("Pending: $pending"),
                          _heroChip("Completed: $completed"),
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

  Widget _statCard(
    IconData icon,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Makeup sessions are created from approved leave requests or cancelled sessions. Coaches can schedule and complete makeup sessions for their assigned batches.",
              style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _makeupCard({
    required BuildContext context,
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
        ? "Not scheduled"
        : makeupTime.isEmpty
            ? makeupDate
            : "$makeupDate • $makeupTime";

    final titleText = studentName.isNotEmpty
        ? studentName
        : batch.isNotEmpty
            ? batch
            : "Makeup Session";

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
      child: Column(
        children: [
          Row(
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
              _statusChip(status, statusColor),
            ],
          ),
          const SizedBox(height: 14),
          if (studentName.isNotEmpty) _detailRow("Student", studentName),
          _detailRow("Original Batch", originalBatch),
          if (makeupBatch.isNotEmpty) _detailRow("Makeup Batch", makeupBatch),
          _detailRow("Leave / Cancelled Date", cancelledDate),
          if (cancelledTime.isNotEmpty) _detailRow("Time", cancelledTime),
          _detailRow("Reason", reason),
          _detailRow("Makeup Date", makeupText),
          if (_canManage) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (isPending)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: maroon,
                        foregroundColor: gold,
                      ),
                      onPressed: () => _scheduleMakeup(context, docId),
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text("Schedule"),
                    ),
                  )
                else if (canComplete)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _markCompleted(context, docId),
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text("Complete"),
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      "Completed",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (_canDelete) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(context, docId),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value.isEmpty ? "Not added" : value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
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
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: const Column(
        children: [
          Icon(Icons.event_repeat, size: 40, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Makeup Sessions Found",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            "Approved leave requests will automatically create makeup sessions.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
