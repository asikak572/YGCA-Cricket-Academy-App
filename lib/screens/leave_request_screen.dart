import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_service.dart';
import 'widgets/ygca_app_bar.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  bool loadingUser = true;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;
      setState(() {
        userData = {};
        loadingUser = false;
      });
      return;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!mounted) return;

    if (!doc.exists) {
      setState(() {
        userData = {};
        loadingUser = false;
      });
      return;
    }

    setState(() {
      userData = {
        'uid': user.uid,
        'authEmail': user.email ?? '',
        ...doc.data()!,
      };
      loadingUser = false;
    });
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

  Query<Map<String, dynamic>> _leaveQuery() {
    final role = _text(userData['role']);
    final uid = _text(userData['uid']);

    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('leave_requests');

    if (role == 'Admin') {
      return query;
    }

    if (role == 'Student') {
      return query.where('studentId', isEqualTo: uid);
    }

    if (role == 'Parent') {
      final linkedChildrenIds = _stringList(userData['linkedChildrenIds']);

      if (linkedChildrenIds.isEmpty) {
        return query.where('parentId', isEqualTo: uid);
      }

      if (linkedChildrenIds.length == 1) {
        return query.where('studentId', isEqualTo: linkedChildrenIds.first);
      }

      return query.where(
        'studentId',
        whereIn: linkedChildrenIds.take(10).toList(),
      );
    }

    if (role == 'Coach') {
      final assignedBatches = _stringList(userData['assignedBatches']);

      final assignedBatch = _text(userData['assignedBatch']);
      final batch = _text(userData['batch']);

      if (assignedBatch.isNotEmpty && !assignedBatches.contains(assignedBatch)) {
        assignedBatches.add(assignedBatch);
      }

      if (batch.isNotEmpty && !assignedBatches.contains(batch)) {
        assignedBatches.add(batch);
      }

      if (assignedBatches.isEmpty) {
        return query.where('batch', isEqualTo: '__NO_ASSIGNED_BATCH__');
      }

      if (assignedBatches.length == 1) {
        return query.where('batch', isEqualTo: assignedBatches.first);
      }

      return query.where(
        'batch',
        whereIn: assignedBatches.take(10).toList(),
      );
    }

    return query.where('studentId', isEqualTo: '__NO_ACCESS__');
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _sortLeaveDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = docs.toList();

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

  String _autoMakeupBatch(String originalBatch) {
    final batch = originalBatch.trim();
    final lower = batch.toLowerCase();

    String day = '';

    if (batch.contains(':')) {
      day = batch.split(':').first.trim();
    }

    final prefix = day.isNotEmpty ? '$day: ' : '';

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
  }) async {
    final studentId = _text(leaveData['studentId']);

    final studentName = _text(
      _text(leaveData['studentName']).isNotEmpty
          ? leaveData['studentName']
          : leaveData['name'],
    );

    final originalBatch = _text(leaveData['batch']);

    final leaveDate = _text(
      _text(leaveData['date']).isNotEmpty
          ? leaveData['date']
          : leaveData['leaveDate'],
    );

    final reason = _text(leaveData['reason']);

    String parentUid = _text(
      _text(leaveData['parentId']).isNotEmpty
          ? leaveData['parentId']
          : leaveData['parentUid'],
    );

    if (studentId.isNotEmpty) {
      final studentData = await _getStudentDoc(studentId);

      if (studentData != null && parentUid.isEmpty) {
        parentUid = _text(studentData['parentUid']);
      }
    }

    final makeupBatch = _autoMakeupBatch(originalBatch);

    final makeupDocRef = FirebaseFirestore.instance
        .collection('makeup_sessions')
        .doc(leaveRequestId);

    await makeupDocRef.set({
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
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(leaveRequestId)
        .set({
      'makeupSessionCreated': true,
      'makeupSessionId': leaveRequestId,
      'makeupBatch': makeupBatch,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _updateStatus({
    required BuildContext context,
    required String docId,
    required String status,
    required Map<String, dynamic> leaveData,
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
        );
      }

      try {
        await NotificationService.leaveStatus(
          studentName: _text(
            _text(leaveData['studentName']).isNotEmpty
                ? leaveData['studentName']
                : leaveData['name'],
          ),
          status: status,
        );
      } catch (_) {}

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == "Approved"
                ? "Leave approved and makeup session created"
                : "Leave rejected",
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    }
  }

  Future<void> _deleteLeave(BuildContext context, String docId) async {
    await FirebaseFirestore.instance
        .collection('leave_requests')
        .doc(docId)
        .delete();

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave request deleted")),
    );
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
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
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
    return role == 'Student' || role == 'Parent';
  }

  bool _showMakeupInfo(Map<String, dynamic> data) {
    return _text(data['makeupBatch']).isNotEmpty ||
        data['makeupSessionCreated'] == true;
  }

 Future<void> _openLeaveForm() async {
  final submitted = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => LeaveFormScreen(userData: userData),
    ),
  );

  if (!mounted) return;

  if (submitted == true) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Leave request submitted")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final role = _text(userData['role']);

    return Scaffold(
      backgroundColor: bg,
      appBar: const YgcaAppBar(title: "Leave Requests"),
      body: loadingUser
          ? const Center(child: CircularProgressIndicator())
          : userData.isEmpty
              ? const Center(child: Text("User data not found"))
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _leaveQuery().snapshots(),
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

                    final requests = _sortLeaveDocs(snapshot.data?.docs ?? []);

                    if (requests.isEmpty) {
                      return const Center(child: Text("No leave requests found"));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final doc = requests[index];
                        final data = doc.data();

                        final name =
                            _text(data['name'] ?? data['studentName']);
                        final batch = _text(data['batch']);
                        final date = _text(
                          _text(data['date']).isNotEmpty
                              ? data['date']
                              : data['leaveDate'],
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
                                        name.isNotEmpty
                                            ? name[0].toUpperCase()
                                            : "?",
                                        style: TextStyle(
                                          color: gold,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                if (status == "Pending" &&
                                    _canApprove(role)) ...[
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
                ),
      floatingActionButton: _canCreate(role)
          ? FloatingActionButton.extended(
              backgroundColor: maroon,
              foregroundColor: gold,
              onPressed: _openLeaveForm,
              icon: const Icon(Icons.add),
              label: const Text("New Leave"),
            )
          : null,
    );
  }
}

class LeaveFormScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const LeaveFormScreen({
    super.key,
    required this.userData,
  });

  @override
  State<LeaveFormScreen> createState() => _LeaveFormScreenState();
}

class _LeaveFormScreenState extends State<LeaveFormScreen> {
  final Color maroon = const Color(0xFF7F0000);
  final Color gold = const Color(0xFFD4AF37);
  final Color bg = const Color(0xFFF8FAFC);
  final Color border = const Color(0xFFE2E8F0);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController leaveDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  bool loadingChildren = true;
  bool submitting = false;

  List<Map<String, dynamic>> linkedChildren = [];
  Map<String, dynamic>? selectedChild;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    nameController.dispose();
    batchController.dispose();
    leaveDateController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  String _lower(String value) {
    return value.trim().toLowerCase();
  }

  String get role => _text(widget.userData['role']);

  String get uid => _text(widget.userData['uid']);

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

  Future<void> _loadInitialData() async {
    final children = await _getLinkedChildren();

    if (!mounted) return;

    linkedChildren = children;

    if (role == 'Student') {
      final studentData =
          linkedChildren.isNotEmpty ? linkedChildren.first : widget.userData;

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
        selectedChild!['name'] ?? selectedChild!['studentName'],
      );

      batchController.text = _text(selectedChild!['batch']);
    }

    setState(() {
      loadingChildren = false;
    });
  }

  Future<List<Map<String, dynamic>>> _getLinkedChildren() async {
    if (role == 'Student') {
      final studentData = await _getStudentDoc(uid);

      if (studentData != null) {
        return [studentData];
      }

      return [
        {
          'studentId': uid,
          'name': _text(widget.userData['name']),
          'batch': _text(widget.userData['batch']),
          'parentUid': _text(widget.userData['parentUid']),
        }
      ];
    }

    if (role != 'Parent') return [];

    final children = <Map<String, dynamic>>[];
    final ids = <String>{};

    final linkedChildrenIds = widget.userData['linkedChildrenIds'];

    if (linkedChildrenIds is List) {
      for (final id in linkedChildrenIds) {
        final value = _text(id);
        if (value.isNotEmpty) ids.add(value);
      }
    }

    final childId = _text(widget.userData['childId']);
    if (childId.isNotEmpty) ids.add(childId);

    final studentId = _text(widget.userData['studentId']);
    if (studentId.isNotEmpty) ids.add(studentId);

    for (final id in ids) {
      final childData = await _getStudentDoc(id);

      if (childData != null) {
        children.add(childData);
      }
    }

    final parentEmail = _lower(
      _text(widget.userData['email']).isNotEmpty
          ? _text(widget.userData['email'])
          : _text(widget.userData['authEmail']),
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

  Future<void> _submitLeave() async {
    final name = nameController.text.trim();
    final batch = batchController.text.trim();
    final leaveDate = leaveDateController.text.trim();
    final reason = reasonController.text.trim();

    if (name.isEmpty || batch.isEmpty || leaveDate.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    String studentId = uid;
    String parentUid = '';

    if (role == 'Parent') {
      if (selectedChild == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select linked student")),
        );
        return;
      }

      studentId = _text(selectedChild!['studentId']);
      parentUid = uid;

      if (studentId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Student ID not found")),
        );
        return;
      }
    } else if (role == 'Student') {
      final studentData =
          linkedChildren.isNotEmpty ? linkedChildren.first : <String, dynamic>{};

      parentUid = _text(studentData['parentUid']);
    }

    setState(() {
      submitting = true;
    });

    try {
      await FirebaseFirestore.instance.collection('leave_requests').add({
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

      if (!mounted) return;

Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submit failed: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          submitting = false;
        });
      }
    }
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    int maxLines = 1,
    String? hint,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = role == 'Student' || role == 'Parent';

    return Scaffold(
      backgroundColor: bg,
      appBar: const YgcaAppBar(title: "New Leave Request"),
      body: loadingChildren
          ? const Center(child: CircularProgressIndicator())
          : !canSubmit
              ? const Center(
                  child: Text("You cannot create leave request"),
                )
              : role == 'Parent' && linkedChildren.isEmpty
                  ? const Center(
                      child: Text("No linked student found for this parent"),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBF2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: gold),
                            ),
                            child: Text(
                              "Submit your leave request. Admin/Coach will approve and makeup session will be created automatically.",
                              style: TextStyle(
                                color: maroon,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (role == 'Parent' && linkedChildren.length > 1)
                            DropdownButtonFormField<String>(
                              value: selectedChild == null
                                  ? null
                                  : _text(selectedChild!['studentId']),
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: "Select Student",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              items: linkedChildren.map((child) {
                                final id = _text(child['studentId']);
                                final name = _text(
                                  _text(child['name']).isNotEmpty
                                      ? child['name']
                                      : child['studentName'],
                                );
                                final batch = _text(child['batch']);

                                return DropdownMenuItem<String>(
                                  value: id,
                                  child: Text(
                                    "$name - $batch",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;

                                final child = linkedChildren.firstWhere(
                                  (item) => _text(item['studentId']) == value,
                                );

                                setState(() {
                                  selectedChild = child;
                                  nameController.text = _text(
                                    _text(child['name']).isNotEmpty
                                        ? child['name']
                                        : child['studentName'],
                                  );
                                  batchController.text = _text(child['batch']);
                                });
                              },
                            ),
                          if (role == 'Parent' && linkedChildren.length > 1)
                            const SizedBox(height: 12),
                          _field(
                            label: "Student Name",
                            controller: nameController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            label: "Batch",
                            controller: batchController,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          _field(
                            label: "Leave Date",
                            controller: leaveDateController,
                            hint: "Example: 22-06-2026",
                          ),
                          const SizedBox(height: 12),
                          _field(
                            label: "Reason",
                            controller: reasonController,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: maroon,
                                foregroundColor: gold,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: submitting ? null : _submitLeave,
                              icon: submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                              label: Text(
                                submitting ? "Submitting..." : "Submit Leave",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
