import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static Future<void> createNotification({
    required String title,
    required String message,
    required String targetRole,
    String? studentId,
    String? parentId,
    String? batch,
    String type = 'General',
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'targetRole': targetRole,
      'studentId': studentId ?? '',
      'parentId': parentId ?? '',
      'batch': batch ?? '',
      'type': type,
      'createdBy': currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('communication_logs').add({
      'title': title,
      'message': message,
      'targetRole': targetRole,
      'studentId': studentId ?? '',
      'parentId': parentId ?? '',
      'batch': batch ?? '',
      'type': type,
      'channels': ['In-App'],
      'status': 'In-App Sent',
      'smsStatus': 'Not Connected',
      'whatsappStatus': 'Not Connected',
      'createdBy': currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> attendanceAlert({
    required String studentName,
    required String studentId,
    required String batch,
  }) async {
    await createNotification(
      title: 'Attendance Alert',
      message:
          '$studentName was marked absent today. Please contact the academy if needed.',
      targetRole: 'Parent',
      studentId: studentId,
      batch: batch,
      type: 'Attendance',
    );
  }

  static Future<void> feeReminder({
    required String studentName,
    required String studentId,
    required int pendingAmount,
  }) async {
    await createNotification(
      title: 'Fee Reminder',
      message:
          'Pending fee for $studentName is ₹$pendingAmount. Please complete the payment.',
      targetRole: 'Parent',
      studentId: studentId,
      type: 'Fee',
    );
  }

  static Future<void> leaveStatus({
    required String studentName,
    required String status,
  }) async {
    await createNotification(
      title: 'Leave $status',
      message: 'Leave request for $studentName has been $status.',
      targetRole: 'Parent',
      type: 'Leave',
    );
  }

  static Future<void> performanceUpdate({
    required String studentName,
    required String studentId,
    required String batch,
  }) async {
    await createNotification(
      title: 'Performance Update',
      message:
          'New performance report added for $studentName. Please check the app for details.',
      targetRole: 'Parent',
      studentId: studentId,
      batch: batch,
      type: 'Performance',
    );
  }
}