import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

import 'widgets/ygca_app_bar.dart';

class LeaveRequestScreen extends StatelessWidget {
  const LeaveRequestScreen({super.key});

  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return {};

    return {
      'uid': user.uid,
      ...doc.data()!,
    };
  }

  Query<Map<String, dynamic>> _leaveQuery(Map<String, dynamic> userData) {
    final role = userData['role']?.toString() ?? '';
    final uid = userData['uid']?.toString() ?? '';

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('leave_requests');

    if (role == 'Student') {
      query = query.where('studentId', isEqualTo: uid);
    } else if (role == 'Parent') {
      final linkedChildrenIds = userData['linkedChildrenIds'];

      if (linkedChildrenIds is List && linkedChildrenIds.isNotEmpty) {
        query = query.where(
          'studentId',
          whereIn: linkedChildrenIds.take(10).toList(),
        );
      } else {
        query = query.where('parentId', isEqualTo: uid);
      }
    } else if (role == 'Coach') {
      final batch = userData['assignedBatch']?.toString().isNotEmpty == true
          ? userData['assignedBatch'].toString()
          : userData['batch']?.toString() ?? '';

      if (batch.isNotEmpty) {
        query = query.where('batch', isEqualTo: batch);
      }
    }

    return query.orderBy('createdAt', descending: true);
  }

  Future<void> _updateStatus(
    String docId,
    String status,
    String name,
  ) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await NotificationService.leaveStatus(
  studentName: name,
  status: status,
);
  }

  Future<void> _deleteLeave(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request deleted")),
      );
    }
  }

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Leave Request"),
        content: const Text(
          "Are you sure you want to delete this leave request?",
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
              await _deleteLeave(context, docId);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showLeaveForm(
  BuildContext context,
  Map<String, dynamic> userData,
) {
  final role = userData['role']?.toString() ?? '';
  final uid = userData['uid']?.toString() ?? '';

  String name = userData['name']?.toString() ?? '';
  String batch = userData['batch']?.toString() ??
      userData['childBatch']?.toString() ??
      '';
  String leaveDate = '';
  String reason = '';

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text("New Leave Request"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(
                "Student Name",
                initialValue: name,
                onChanged: (value) => name = value,
              ),
              _input(
                "Batch",
                initialValue: batch,
                onChanged: (value) => batch = value,
              ),
              _input(
                "Leave Date",
                onChanged: (value) => leaveDate = value,
              ),
              _input(
                "Reason",
                maxLines: 3,
                onChanged: (value) => reason = value,
              ),
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
              if (name.trim().isEmpty ||
                  batch.trim().isEmpty ||
                  leaveDate.trim().isEmpty ||
                  reason.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

              String studentId = uid;

              if (role == 'Parent') {
                final linkedChildrenIds = userData['linkedChildrenIds'];

                if (linkedChildrenIds is List && linkedChildrenIds.isNotEmpty) {
                  studentId = linkedChildrenIds.first.toString();
                } else if (userData['childId'] != null) {
                  studentId = userData['childId'].toString();
                }
              }

              await FirebaseFirestore.instance
                  .collection('leave_requests')
                  .add({
                'studentId': studentId,
                'parentId': role == 'Parent' ? uid : '',
                'name': name.trim(),
                'batch': batch.trim(),
                'date': leaveDate.trim(),
                'reason': reason.trim(),
                'status': 'Pending',
                'requestedBy': role,
                'createdAt': FieldValue.serverTimestamp(),
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Leave request submitted")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      );
    },
  );
}

Widget _input(
  String label, {
  String initialValue = '',
  required Function(String) onChanged,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    ),
  );
}

  Color _getStatusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Rejected") return Colors.red;
    return Colors.orange;
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  bool _canApprove(String role) {
    return role == 'Admin' || role == 'Coach';
  }

  bool _canDelete(String role) {
    return role == 'Admin';
  }

  bool _canCreate(String role) {
    return role == 'Student' || role == 'Parent' || role == 'Admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: const YgcaAppBar(title: "Leave Requests"),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
            return const Center(child: Text("User data not found"));
          }

          final userData = userSnapshot.data!;
          final role = userData['role']?.toString() ?? '';

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _leaveQuery(userData).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final requests = snapshot.data?.docs ?? [];

              if (requests.isEmpty) {
                return const Center(child: Text("No leave requests found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final doc = requests[index];
                  final data = doc.data();

                  final name = data['name']?.toString() ?? '';
                  final batch = data['batch']?.toString() ?? '';
                  final date = data['date']?.toString() ?? '';
                  final reason = data['reason']?.toString() ?? '';
                  final status = data['status']?.toString() ?? 'Pending';
                  final requestedBy =
                      data['requestedBy']?.toString() ?? 'Unknown';

                  final statusColor = _getStatusColor(status);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: maroon,
                                child: Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : "?",
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      batch,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _statusChip(status, statusColor),
                              if (_canDelete(role))
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _confirmDelete(context, doc.id),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _row("Leave Date", date),
                          _row("Reason", reason),
                          _row("Requested By", requestedBy),
                          if (status == "Pending" && _canApprove(role)) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await _updateStatus(
                                        doc.id,
                                        "Rejected",
                                        name,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text("Leave rejected"),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.close),
                                    label: const Text("Reject"),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: maroon,
                                      foregroundColor: gold,
                                    ),
                                    onPressed: () async {
                                      await _updateStatus(
                                        doc.id,
                                        "Approved",
                                        name,
                                      );

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text("Leave approved"),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.check),
                                    label: const Text("Approve"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          final role = snapshot.data!['role']?.toString() ?? '';

          if (!_canCreate(role)) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            backgroundColor: maroon,
            foregroundColor: gold,
            onPressed: () => _showLeaveForm(context, snapshot.data!),
            icon: const Icon(Icons.add),
            label: const Text("New Leave"),
          );
        },
      ),
    );
  }
}