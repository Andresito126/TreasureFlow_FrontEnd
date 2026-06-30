import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:treasureflow/core/notifications/domain/entities/notification_payload.dart';
import 'package:treasureflow/core/router/app_router.dart';

/// Top-level handler required by FCM for background/terminated messages.
/// Cannot be a class method.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _channelId = 'treasureflow_channel';
  static const _channelName = 'TreasureFlow Notifications';
  static const _channelDesc = 'Notificaciones de TreasureFlow';

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  int _notificationId = 0;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    await _requestPermissions();
    await _setupLocalNotifications();
    _listenForeground();
    _listenBackgroundTap();
    await _handleTerminatedTap();
  }

  // ── Permissions ──────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false, // We show our own local notification in foreground
      badge: true,
      sound: false,
    );
  }

  // ── Local notifications setup ─────────────────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create the Android notification channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
          ),
        );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;

    try {
      final data = json.decode(raw) as Map<String, dynamic>;
      final payload = NotificationPayload.fromMap(data);
      _navigate(payload.screenRoute);
    } catch (_) {}
  }

  // ── FCM handlers ──────────────────────────────────────────────────────────

  /// App is open — FCM delivers silently, we show a local notification.
  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.data.isEmpty) return;
      final payload = NotificationPayload.fromMap(message.data);
      _showLocalNotification(payload);
    });
  }

  /// App was in the background and the user tapped the notification.
  void _listenBackgroundTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isEmpty) return;
      final payload = NotificationPayload.fromMap(message.data);
      _navigate(payload.screenRoute);
    });
  }

  /// App was terminated and the user tapped the notification to open it.
  Future<void> _handleTerminatedTap() async {
    final message = await _messaging.getInitialMessage();
    if (message == null || message.data.isEmpty) return;

    final payload = NotificationPayload.fromMap(message.data);
    if (payload.screenRoute.isEmpty) return;

    // Defer navigation until after the first frame so the router is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate(payload.screenRoute);
    });
  }

  // ── Show notification ────────────────────────────────────────────────────

  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final id = _notificationId++ % 10000;

    await _localNotifications.show(
      id,
      payload.title,
      payload.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: json.encode(payload.toMap()),
    );
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _navigate(String route) {
    if (route.isEmpty) return;
    appRouter.go(route);
  }

  // ── Utilities ────────────────────────────────────────────────────────────

  /// Returns the FCM device token to send to your backend.
  Future<String?> getToken() => _messaging.getToken();

  /// Subscribe to a topic (optional, for broadcast notifications).
  Future<void> subscribeToTopic(String topic) =>
      _messaging.subscribeToTopic(topic);
}
