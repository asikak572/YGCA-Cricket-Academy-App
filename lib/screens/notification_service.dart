import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '/services/cloudflare_push_service.dart';

class NotificationService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

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

    final notificationReference =
        await _firestore.collection('notifications').add({
      'title': title,
      'message': message,
      'targetRole': targetRole,
      'studentId': studentId ?? '',
      'parentId': parentId ?? '',
      'batch': batch ?? '',
      'type': type,
      'createdBy': currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    final logReference =
        await _firestore.collection('communication_logs').add({
      'title': title,
      'message': message,
      'targetRole': targetRole,
      'studentId': studentId ?? '',
      'parentId': parentId ?? '',
      'batch': batch ?? '',
      'type': type,
      'channels': ['In-App', 'Push'],
      'status': 'In-App Saved',
      'pushStatus': 'Pending',
      'smsStatus': 'Not Connected',
      'whatsappStatus': 'Not Connected',
      'createdBy': currentUser?.uid ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      final tokens = await _findRecipientTokens(
        targetRole: targetRole,
        studentId: studentId,
        parentId: parentId,
        batch: batch,
      );

      if (tokens.isEmpty) {
        await _updatePushResult(
          notificationId: notificationReference.id,
          logId: logReference.id,
          status: 'No Recipient Token',
          sentCount: 0,
        );
        return;
      }

      var sentCount = 0;
      final failures = <String>[];

      for (final token in tokens) {
        try {
          await CloudflarePushService.sendToToken(
            token: token,
            title: title,
            message: message,
            data: {
              'notificationId': notificationReference.id,
              'type': type,
              'targetRole': targetRole,
              'studentId': studentId ?? '',
              'parentId': parentId ?? '',
              'batch': batch ?? '',
            },
          );
          sentCount++;
        } catch (error) {
          failures.add(error.toString());
          debugPrint('Push notification failed: $error');
        }
      }

      final pushStatus = sentCount == tokens.length
          ? 'Push Sent'
          : sentCount > 0
              ? 'Partially Sent'
              : 'Push Failed';

      await _updatePushResult(
        notificationId: notificationReference.id,
        logId: logReference.id,
        status: pushStatus,
        sentCount: sentCount,
        attemptedCount: tokens.length,
        error: failures.isEmpty ? null : failures.first,
      );
    } catch (error) {
      debugPrint('Unable to process push notification: $error');

      await _updatePushResult(
        notificationId: notificationReference.id,
        logId: logReference.id,
        status: 'Push Failed',
        sentCount: 0,
        error: error.toString(),
      );
    }
  }

  static Future<Set<String>> _findRecipientTokens({
    required String targetRole,
    String? studentId,
    String? parentId,
    String? batch,
  }) async {
    final tokens = <String>{};
    final processedUserIds = <String>{};
    final cleanRole = targetRole.trim();
    final cleanStudentId = studentId?.trim() ?? '';
    final cleanParentId = parentId?.trim() ?? '';

    Future<void> addUserDocument(
      DocumentSnapshot<Map<String, dynamic>> document,
    ) async {
      if (!document.exists || processedUserIds.contains(document.id)) {
        return;
      }

      processedUserIds.add(document.id);
      _addTokensFromData(tokens, document.data());
    }

    Future<void> addUserById(String userId) async {
      if (userId.isEmpty || processedUserIds.contains(userId)) return;

      final document =
          await _firestore.collection('users').doc(userId).get();
      await addUserDocument(document);
    }

    Future<void> addUsersFromQuery(
      Query<Map<String, dynamic>> query,
    ) async {
      final snapshot = await query.get();

      for (final document in snapshot.docs) {
        await addUserDocument(document);
      }
    }

    if (cleanParentId.isNotEmpty) {
      await addUserById(cleanParentId);
    }

    if (cleanStudentId.isNotEmpty) {
      final studentDocument = await _firestore
          .collection('students')
          .doc(cleanStudentId)
          .get();
      final studentData = studentDocument.data() ?? {};

      if (cleanRole == 'Student') {
        final studentUid = _firstText([
          studentData['uid'],
          studentData['studentId'],
          cleanStudentId,
        ]);

        await addUserById(studentUid);
      }

      if (cleanRole == 'Parent') {
        final linkedParentId = _firstText([
          cleanParentId,
          studentData['parentUid'],
          studentData['parentId'],
        ]);

        if (linkedParentId.isNotEmpty) {
          await addUserById(linkedParentId);
        }

        await addUsersFromQuery(
          _firestore
              .collection('users')
              .where('role', isEqualTo: 'Parent')
              .where(
                'linkedChildrenIds',
                arrayContains: cleanStudentId,
              ),
        );

        await addUsersFromQuery(
          _firestore
              .collection('users')
              .where('role', isEqualTo: 'Parent')
              .where('studentId', isEqualTo: cleanStudentId),
        );

        final parentEmail = _firstText([
          studentData['parentEmail'],
          studentData['parentEmailLower'],
        ]).toLowerCase();

        if (parentEmail.isNotEmpty) {
          await addUsersFromQuery(
            _firestore
                .collection('users')
                .where('role', isEqualTo: 'Parent')
                .where('emailLower', isEqualTo: parentEmail),
          );
        }
      }
    }

    if (tokens.isEmpty && cleanRole.isNotEmpty) {
      final roleSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: cleanRole)
          .get();

      for (final document in roleSnapshot.docs) {
        if (_matchesBatch(document.data(), batch)) {
          await addUserDocument(document);
        }
      }
    }

    return tokens;
  }

  static void _addTokensFromData(
    Set<String> tokens,
    Map<String, dynamic>? data,
  ) {
    if (data == null) return;

    final singleToken = data['fcmToken']?.toString().trim() ?? '';

    if (singleToken.isNotEmpty) {
      tokens.add(singleToken);
    }

    final tokenList = data['fcmTokens'];

    if (tokenList is Iterable) {
      for (final value in tokenList) {
        final token = value?.toString().trim() ?? '';
        if (token.isNotEmpty) tokens.add(token);
      }
    }
  }

  static bool _matchesBatch(
    Map<String, dynamic> data,
    String? requestedBatch,
  ) {
    final cleanBatch = requestedBatch?.trim() ?? '';

    if (cleanBatch.isEmpty || cleanBatch == 'All') {
      return true;
    }

    final userBatch = data['batch']?.toString().trim() ?? '';
    if (userBatch == cleanBatch) return true;

    final assignedBatches = data['assignedBatches'];
    if (assignedBatches is Iterable) {
      return assignedBatches.any(
        (value) => value?.toString().trim() == cleanBatch,
      );
    }

    return false;
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }

    return '';
  }

  static Future<void> _updatePushResult({
    required String notificationId,
    required String logId,
    required String status,
    required int sentCount,
    int? attemptedCount,
    String? error,
  }) async {
    final result = <String, dynamic>{
      'pushStatus': status,
      'pushSentCount': sentCount,
      'pushAttemptedCount': attemptedCount ?? sentCount,
      'pushUpdatedAt': FieldValue.serverTimestamp(),
    };

    if (error != null && error.isNotEmpty) {
      result['pushError'] = error;
    } else {
      result['pushError'] = FieldValue.delete();
    }

    await Future.wait([
      _firestore
          .collection('notifications')
          .doc(notificationId)
          .update(result),
      _firestore
          .collection('communication_logs')
          .doc(logId)
          .update({
        ...result,
        'status': status,
      }),
    ]);
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
    String? studentId,
    String? parentId,
  }) async {
    await createNotification(
      title: 'Leave $status',
      message: 'Leave request for $studentName has been $status.',
      targetRole: 'Parent',
      studentId: studentId,
      parentId: parentId,
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
