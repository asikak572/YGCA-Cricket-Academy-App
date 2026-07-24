import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmService {
  FcmService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'ygca_notifications',
    'YGCA Notifications',
    description: 'Notifications from Young Gen Cricket Academy',
    importance: Importance.high,
  );

  static GlobalKey<NavigatorState>? _navigatorKey;

  static StreamSubscription<User?>? _authSubscription;
  static StreamSubscription<String>? _tokenSubscription;
  static StreamSubscription<RemoteMessage>? _messageSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;

  static bool _initialized = false;

  static Future<void> initialize({
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    if (_initialized) return;

    _initialized = true;
    _navigatorKey = navigatorKey;

    await _initializeLocalNotifications();
    await _requestNotificationPermission();
    await _configureForegroundNotifications();
    await _configureMessageListeners();
    await _configureTokenRegistration();
    await _handleInitialNotification();
  }

  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        _openNotificationScreen();
      },
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  static Future<void> _requestNotificationPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await _savePermissionStatus(settings.authorizationStatus);
  }

  static Future<void> _savePermissionStatus(
    AuthorizationStatus status,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'notificationPermission': status.name,
        'notificationPermissionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Notification setup must not crash login if rules need updating.
    }
  }

  static Future<void> _configureForegroundNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static Future<void> _configureMessageListeners() async {
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();

    _messageSubscription =
        FirebaseMessaging.onMessage.listen((message) async {
      await _showForegroundNotification(message);
    });

    _openedSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _openNotificationScreen();
    });
  }

  static Future<void> _configureTokenRegistration() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();

    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user == null) return;

      await saveCurrentToken();
    });

    _tokenSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });

    if (FirebaseAuth.instance.currentUser != null) {
      await saveCurrentToken();
    }
  }

  static Future<void> saveCurrentToken() async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.trim().isEmpty) return;

      await _saveToken(token);
    } catch (_) {
      // Firebase can retry token generation on a later launch or refresh.
    }
  }

  static Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || token.trim().isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokens': FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Prevent a Firestore permission error from breaking the app.
    }
  }

  static Future<void> _showForegroundNotification(
    RemoteMessage message,
  ) async {
    final notification = message.notification;

    final title = notification?.title ??
        message.data['title']?.toString() ??
        'YGCA Notification';

    final body = notification?.body ??
        message.data['message']?.toString() ??
        message.data['body']?.toString() ??
        '';

    if (body.trim().isEmpty) return;

    final notificationId =
        (message.messageId ?? DateTime.now().millisecondsSinceEpoch).hashCode &
            0x7fffffff;

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: '/notifications',
    );
  }

  static Future<void> _handleInitialNotification() async {
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openNotificationScreen();
    });
  }

  static void _openNotificationScreen() {
    final navigator = _navigatorKey?.currentState;

    if (navigator == null) {
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        _navigatorKey?.currentState?.pushNamed('/notifications');
      });
      return;
    }

    navigator.pushNamed('/notifications');
  }

  static Future<String?> getCurrentToken() {
    return _messaging.getToken();
  }

  static Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _messageSubscription?.cancel();
    await _openedSubscription?.cancel();

    _initialized = false;
  }
}
