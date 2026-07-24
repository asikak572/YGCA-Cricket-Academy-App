import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class CloudflarePushService {
  static const String _workerUrl =
      'https://ygca-notification-service.ahmedasik572.workers.dev/send';

  static Future<void> sendToToken({
    required String token,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in');
    }

    final cleanToken = token.trim();

    if (cleanToken.isEmpty) {
      throw Exception('Recipient FCM token is empty');
    }

    final idToken = await currentUser.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to obtain Firebase authentication token');
    }

    final response = await http.post(
      Uri.parse(_workerUrl),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': cleanToken,
        'title': title.trim(),
        'body': message.trim(),
        'data': _normaliseData(data),
      }),
    );

    _ensureSuccessful(response);
  }

  static Future<void> sendToTopic({
    required String topic,
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User is not logged in');
    }

    final cleanTopic = topic.trim();

    if (cleanTopic.isEmpty) {
      throw Exception('Notification topic is empty');
    }

    final idToken = await currentUser.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Unable to obtain Firebase authentication token');
    }

    final response = await http.post(
      Uri.parse(_workerUrl),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': cleanTopic,
        'title': title.trim(),
        'body': message.trim(),
        'data': _normaliseData(data),
      }),
    );

    _ensureSuccessful(response);
  }

  static Map<String, String> _normaliseData(
    Map<String, dynamic>? data,
  ) {
    final result = <String, String>{};

    data?.forEach((key, value) {
      if (value != null) {
        result[key] = value.toString();
      }
    });

    return result;
  }

  static void _ensureSuccessful(http.Response response) {
    final responseData = _decodeResponse(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error =
          responseData['error']?.toString() ?? 'Push notification failed';
      throw Exception(error);
    }
  }

  static Map<String, dynamic> _decodeResponse(String body) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // A non-JSON error response is handled by the status-code check.
    }

    return {};
  }
}
