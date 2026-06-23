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

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!doc.exists) return {};

    return {
      'uid': user.uid,
      'authEmail': user.email ?? '',
      ...doc.data()!,
    };
  }

  Future<Map<String, dynamic>?> _getStudentDoc(String studentId) async {
    final studentDoc = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();

    if (studentDoc.exists) {
      return {
        'studentId': studentId,
        ...studentDoc.data()!,
      };
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(studentId).get();

    if (userDoc.exists) {
      return {
        'studentId': studentId,
        ...userDoc.data()!,
      };
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> _getLinkedChildren(
    Map<String, dynamic> userData,
  ) async {
    final role = _text(userData['role']);
    final uid = _text(userData['uid']);

    if (role == 'Student') {
      final studentData = await _getStudentDoc(uid);

      if (studentData != null) {
        return [studentData];
      }

      return [
        {
          'studentId': uid,
          'name': _text(userData['name']),
          'batch': _text(userData['batch']),
          'parentUid': _text(userData['parentUid']),
        }
      ];
    }

    if (role != 'Parent') return [];

    final children = <Map<String, dynamic>>[];
    final ids = <String>{};

    final linkedChildrenIds = userData['linkedChildrenIds'];

    if (linkedChildrenIds is List) {
      for (final id in linkedChildrenIds) {
        final value = _text(id);
        if (value.isNotEmpty) ids.add(value);
      }
    }

    final childId = _text(userData['childId']);
    if (childId.isNotEmpty) ids.add(childId);

    final studentId = _text(userData['studentId']);
    if (studentId.isNotEmpty) ids.add(studentId);

    for (final id in ids) {
      final childData = await _getStudentDoc(id);

      if (childData != null) {
        children.add(childData);
      }
    }

    final parentEmail = _lower(
      _text(userData['email']).isNotEmpty
          ? _text(userData['email'])
          : _text(userData['authEmail']),
    );

    if (parentEmail.isNotEmpty) {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmailLower', isEqualTo: parentEmail)
          .get();

      for (final doc in studentSnapshot.docs) {
        children.add({
          'studentId': doc.id,
          ...doc.data(),
        });
      }
    }

    return _dedupeChildren(children);
  }

  List<Map<String, dynamic>> _dedupeChildren(List<Map<String, dynamic>> input) {
    final ids = <String>{};
    final result = <Map<String, dynamic>>[];

    for (final child in input) {
      final id = _text(child['studentId']);
      if (id.isNotEmpty && !ids.contains(id)) {
        ids.add(id);
        result.add(child);
      }
    }

    return result;
  }

  Map<String, dynamic>? _findChildByName(
    List<Map<String, dynamic>> children,
    String typedName,
  ) {
    final search = typedName.trim().toLowerCase();
    if (search.isEmpty) return null;

    for (final child in children) {
      final name = _text(child['name']).toLowerCase();
      final studentName = _text(child['studentName']).toLowerCase();

      if (name == search || studentName == search) {
        return child;
      }
    }

    for (final child in children) {
      final name = _text(child['name']).toLowerCase();
      final studentName = _text(child['studentName']).toLowerCase();

      if (name.startsWith(search) || studentName.startsWith(search)) {
        return child;
      }
    }

    return null;
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

  Query<Map<String, dynamic>> _leaveQuery(Map<String, dynamic> userData) {
    final role = _text(userData['role']);
    final uid = _text(userData['uid']);

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('leave_requests');

    if (role == 'Student') {
      query = query.where('studentId', isEqualTo: uid);
    } else if (role == 'Parent') {
      final linkedChildrenIds = _stringList(userData['linkedChildrenIds']);

      if (linkedChildrenIds.isNotEmpty) {
        query = query.where(
          'studentId',
          whereIn: linkedChildrenIds.take(10).toList(),
        );
      } else {
        query = query.where('parentId', isEqualTo: uid);
      }
    } else if (role == 'Coach') {
      final assignedBatches = _stringList(userData['assignedBatches']);

      final singleBatch = _text(userData['assignedBatch']).isNotEmpty
          ? _text(userData['assignedBatch'])
          : _text(userData['batch']);

      if (singleBatch.isNotEmpty && !assignedBatches.contains(singleBatch)) {
        assignedBatches.add(singleBatch);
      }

      if (assignedBatches.isNotEmpty) {
        query = query.where(
          'batch',
          whereIn: assignedBatches.take(10).toList(),
        );
      } else {
        query = query.where('batch', isEqualTo: '__NO_ASSIGNED_BATCH__');
      }
    }

    return query.orderBy('createdAt', descending: true);
  }

  String _autoMakeupBatch(String originalBatch) {
    final batch = originalBatch.trim();
    final lower = batch.toLowerCase();

    String day = '';
    if (batch.contains(':')) {
      day = batch.split(':').first.trim();
    }

    String prefix = day.isNotEmpty ? '$day: ' : '';

    if (lower.contains('morning') || lower.contains('am')) {
      return '${prefix}4:00 PM – 6:00 PM';
    }

    if (lower.contains('evening') || lower.contains('pm')) {
      return '${prefix}7:00 AM – 9:00 AM';
    }

    return '${prefix}Alternate Makeup Batch';
  }

  Future<void> _createMakeupSessionForLeave({
    required String leaveRequestId,
    required Map<String, dynamic> leaveData,
    required Map<String, dynamic> userData,
  }) async {
    final makeupCollection =
        FirebaseFirestore.instance.collection('makeup_sessions');

    final existing = await makeupCollection
        .where('leaveRequestId', isEqualTo: leaveRequestId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return;
    }

    final studentId = _text(leaveData['studentId']);
    final studentName = _text(
      _text(leaveData['studentName']).isNotEmpty
          ? leaveData['studentName']
          : leaveData['name'],
    );
    final originalBatch = _text(leaveData['batch']);
    final leaveDate = _text(
      _text(leaveData['date']).isNotEmpty ? leaveData['date'] : leaveData['leaveDate'],
    );
    final reason = _text(leaveData['reason']);

    String parentUid = _text(
      _text(leaveData['parentId']).isNotEmpty
          ? leaveData['parentId']
          : leaveData['parentUid'],
    );

    if (studentId.isNotEmpty) {
      final studentData = await _getStudentDoc(studentId);

      if (studentData != null) {
        if (parentUid.isEmpty) {
          parentUid = _text(studentData['parentUid']);
        }
      }
    }

    final makeupBatch = _autoMakeupBatch(originalBatch);

    final makeupDoc = await makeupCollection.add({
      'leaveRequestId': leaveRequestId,
      'studentId': studentId,
      'studentName': studentName,
      'parentUid': parentUid,
      'batch': originalBatch,
      'originalBatch': originalBatch,
      'makeupBatch': makeupBatch,
      'leaveDate': leaveDate,
      'cancelledDate': leaveDate,
      'reason': reason,
      'status': 'Pending',
      'createdFrom': 'Leave Request',
      'approvedBy': _text(userData['uid']),
      'approvedByRole': _text(userData['role']),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(leaveRequestId)
        .set({
      'makeupSessionCreated': true,
      'makeupSessionId': makeupDoc.id,
      'makeupBatch': makeupBatch,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required String docId,
    required String status,
    required Map<String, dynamic> leaveData,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(docId)
          .set({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (status == "Approved") {
        await _createMakeupSessionForLeave(
          leaveRequestId: docId,
          leaveData: leaveData,
          userData: userData,
        );
      }

      await NotificationService.leaveStatus(
        studentName: _text(
          _text(leaveData['studentName']).isNotEmpty
              ? leaveData['studentName']
              : leaveData['name'],
        ),
        status: status,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == "Approved"
                  ? "Leave approved and makeup session created"
                  : "Leave rejected",
            ),
          ),
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

  Future<void> _showLeaveForm(
    BuildContext context,
    Map<String, dynamic> userData,
  ) async {
    final role = _text(userData['role']);
    final uid = _text(userData['uid']);

    final linkedChildren = await _getLinkedChildren(userData);

    if (!context.mounted) return;

    if (role == 'Parent' && linkedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No linked student found for this parent"),
        ),
      );
      return;
    }

    Map<String, dynamic>? selectedChild;

    final nameController = TextEditingController();
    final batchController = TextEditingController();
    final leaveDateController = TextEditingController();
    final reasonController = TextEditingController();

    if (role == 'Student') {
      final studentData =
          linkedChildren.isNotEmpty ? linkedChildren.first : userData;
      nameController.text = _text(
        _text(studentData['name']).isNotEmpty
            ? studentData['name']
            : studentData['studentName'],
      );
      batchController.text = _text(studentData['batch']);
    }

    if (role == 'Parent' && linkedChildren.length == 1) {
      selectedChild = linkedChildren.first;
      nameController.text = _text(
        selectedChild['name'] ?? selectedChild['studentName'],
      );
      batchController.text = _text(selectedChild['batch']);
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text("New Leave Request"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (role == 'Parent' && linkedChildren.length > 1)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: gold.withOpacity(0.45)),
                        ),
                        child: Text(
                          "Linked Students: ${linkedChildren.map((child) {
                            return _text(child['name'] ?? child['studentName']);
                          }).where((name) => name.isNotEmpty).join(', ')}",
                          style: TextStyle(
                            color: maroon,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    TextField(
                      controller: nameController,
                      readOnly: role == 'Student',
                      decoration: const InputDecoration(
                        labelText: "Student Name",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (role != 'Parent') return;

                        final matchedChild =
                            _findChildByName(linkedChildren, value);

                        setDialogState(() {
                          selectedChild = matchedChild;

                          if (matchedChild != null) {
                            batchController.text = _text(matchedChild['batch']);
                          } else {
                            batchController.clear();
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: batchController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Batch",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: leaveDateController,
                      decoration: const InputDecoration(
                        labelText: "Leave Date",
                        hintText: "Example: 22-06-2026",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Reason",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: maroon,
                    foregroundColor: gold,
                  ),
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final batch = batchController.text.trim();
                    final leaveDate = leaveDateController.text.trim();
                    final reason = reasonController.text.trim();

                    if (name.isEmpty ||
                        batch.isEmpty ||
                        leaveDate.isEmpty ||
                        reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please fill all fields"),
                        ),
                      );
                      return;
                    }

                    String studentId = uid;
                    String parentUid = '';

                    if (role == 'Parent') {
                      selectedChild ??= _findChildByName(
                        linkedChildren,
                        name,
                      );

                      if (selectedChild == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please enter a valid linked student name",
                            ),
                          ),
                        );
                        return;
                      }

                      studentId = _text(selectedChild!['studentId']);
                      parentUid = uid;

                      if (studentId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Student ID not found"),
                          ),
                        );
                        return;
                      }
                    } else if (role == 'Student') {
                      final studentData =
                          linkedChildren.isNotEmpty ? linkedChildren.first : {};
                      parentUid = _text(studentData['parentUid']);
                    }

                    await FirebaseFirestore.instance
                        .collection('leave_requests')
                        .add({
                      'studentId': studentId,
                      'parentId': role == 'Parent' ? uid : '',
                      'parentUid': parentUid,
                      'name': name,
                      'studentName': name,
                      'batch': batch,
                      'date': leaveDate,
                      'leaveDate': leaveDate,
                      'reason': reason,
                      'status': 'Pending',
                      'requestedBy': role,
                      'makeupSessionCreated': false,
                      'createdAt': FieldValue.serverTimestamp(),
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Leave request submitted"),
                        ),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
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

  bool _showMakeupInfo(Map<String, dynamic> data) {
    return _text(data['makeupBatch']).isNotEmpty ||
        data['makeupSessionCreated'] == true;
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
          final role = _text(userData['role']);

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: _leaveQuery(userData).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
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

                  final name = _text(data['name'] ?? data['studentName']);
                  final batch = _text(data['batch']);
                  final date = _text(
                    _text(data['date']).isNotEmpty ? data['date'] : data['leaveDate'],
                  );
                  final reason = _text(data['reason']);
                  final status = _text(data['status']).isEmpty
                      ? 'Pending'
                      : _text(data['status']);
                  final requestedBy = _text(data['requestedBy']).isEmpty
                      ? 'Unknown'
                      : _text(data['requestedBy']);

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
                          if (_showMakeupInfo(data))
                            _row(
                              "Makeup Batch",
                              _text(data['makeupBatch']).isEmpty
                                  ? "Created"
                                  : _text(data['makeupBatch']),
                            ),
                          if (status == "Pending" && _canApprove(role)) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      await _updateStatus(
                                        context: context,
                                        docId: doc.id,
                                        status: "Rejected",
                                        leaveData: data,
                                        userData: userData,
                                      );
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
                                        context: context,
                                        docId: doc.id,
                                        status: "Approved",
                                        leaveData: data,
                                        userData: userData,
                                      );
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
      floatingActionButton: FloatingActionButton.extended(
  backgroundColor: maroon,
  foregroundColor: gold,
  onPressed: () async {
    final data = await _getUserData();

    if (!context.mounted) return;

    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User data not found")),
      );
      return;
    }

    final role = _text(data['role']);

    if (!_canCreate(role)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You cannot create leave request")),
      );
      return;
    }

    await _showLeaveForm(context, data);
  },
  icon: const Icon(Icons.add),
  label: const Text("New Leave"),
),
    );
  }
}
