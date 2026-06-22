import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/ygca_app_bar.dart';
import 'attendance_calendar_screen.dart';
import 'attendance_history_screen.dart';

class ParentAttendanceModuleScreen extends StatelessWidget {
  const ParentAttendanceModuleScreen({super.key});

  String _text(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  Future<Map<String, dynamic>?> _getStudentById(String studentId) async {
    final doc = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .get();

    if (!doc.exists) return null;

    return {
      'studentId': doc.id,
      ...doc.data()!,
    };
  }

  Future<List<Map<String, dynamic>>> _getLinkedChildren() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final parentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!parentDoc.exists) return [];

    final parentData = parentDoc.data() ?? {};
    final parentEmail = _text(parentData['email']).isNotEmpty
        ? _text(parentData['email'])
        : _text(user.email);

    final children = <Map<String, dynamic>>[];
    final ids = <String>{};

    final linkedChildrenIds = parentData['linkedChildrenIds'];

    if (linkedChildrenIds is List) {
      for (final id in linkedChildrenIds) {
        final value = _text(id);
        if (value.isNotEmpty) {
          ids.add(value);
        }
      }
    }

    final childId = _text(parentData['childId']);
    if (childId.isNotEmpty) ids.add(childId);

    final studentId = _text(parentData['studentId']);
    if (studentId.isNotEmpty) ids.add(studentId);

    for (final id in ids) {
      final student = await _getStudentById(id);
      if (student != null) {
        children.add(student);
      }
    }

    // Fallback auto-link check using parentEmail
    if (children.isEmpty && parentEmail.isNotEmpty) {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('parentEmail', isEqualTo: parentEmail)
          .get();

      for (final doc in studentSnapshot.docs) {
        children.add({
          'studentId': doc.id,
          ...doc.data(),
        });
      }
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: const YgcaAppBar(title: "Attendance Module"),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getLinkedChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final children = snapshot.data ?? [];

          if (children.isEmpty) {
            return const Center(
              child: Text("No linked student found for this parent"),
            );
          }

          final firstChild = children.first;

          final firstStudentId = _text(firstChild['studentId']);
          final allowedStudentIds = children
              .map((child) => _text(child['studentId']))
              .where((id) => id.isNotEmpty)
              .toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: [
                _moduleCard(
                  context,
                  Icons.calendar_month,
                  "Attendance Calendar",
                  Colors.orange,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceCalendarScreen(
                          studentId: firstStudentId,
                          name: _text(firstChild['name']),
                          batch: _text(firstChild['batch']),
                          rollNo: _text(firstChild['rollNo']),
                          attendance: _text(firstChild['attendance']).isEmpty
                              ? '0%'
                              : _text(firstChild['attendance']),
                        ),
                      ),
                    );
                  },
                ),
                _moduleCard(
                  context,
                  Icons.history,
                  "Attendance History",
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceHistoryScreen(
                          allowedStudentIds: allowedStudentIds,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}