import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

/// Handles data-only messages in the background. No UI work is allowed here.
/// Notification payloads are displayed by Android automatically in background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('FCM background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title ?? message.data['title']}');
  debugPrint('Body: ${message.notification?.body ?? message.data['body']}');
}

/// Firebase Cloud Messaging setup for the Android version of LearnSpace.
/// - Requests permission
/// - Gets the device's FCM token
/// - Receives foreground notifications and shows a local notification
/// - Handles notification taps by logging title/body (navigation can be added)
class NotificationService {
  NotificationService._();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'learnspace_high_importance',
    'LearnSpace Notifications',
    description: 'Course updates and important LearnSpace messages',
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    _initialized = true;

    // Needed to display an Android system notification while the app is open.
    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Foreground notification tapped: ${response.payload}');
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    final messaging = FirebaseMessaging.instance;

    // Request permission (shows Android's permission dialog on Android 13+).
    final permission = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Notification permission: ${permission.authorizationStatus}');

    // A token identifies this app installation/device, not the user's account.
    // Don't hardcode it: it can change, so listen for refresh events too.
    try {
      final token = await messaging.getToken();
      debugPrint('FCM TOKEN: $token');
    } catch (error) {
      debugPrint('Could not get FCM token: $error');
    }

    messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM TOKEN REFRESHED: $token');
    });

    // Android does NOT automatically show foreground FCM notifications.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final notification = message.notification;
      final title = notification?.title ??
          message.data['title'] ??
          message.data['name'] ??
          'LearnSpace';
      final body = notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          '';

      debugPrint('FCM foreground message: ${message.messageId}');
      debugPrint('Title: $title');
      debugPrint('Body: $body');

      // A data-only message with no visible content should not show a blank alert.
      if (notification == null &&
          !message.data.containsKey('title') &&
          !message.data.containsKey('name') &&
          !message.data.containsKey('body') &&
          !message.data.containsKey('message')) {
        return;
      }

      try {
        await _local.show(
          id: DateTime.now().microsecondsSinceEpoch.remainder(2147483647),
          title: title,
          body: body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'learnspace_high_importance',
              'LearnSpace Notifications',
              channelDescription: 'Course updates and important LearnSpace messages',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: message.data.toString(),
        );
      } catch (error) {
        debugPrint('Could not show foreground notification: $error');
      }
    });

    // System notification pressed when app was in the background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // System notification pressed when app was completely closed.
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Foreground local notification pressed while the app was terminated.
    final launch = await _local.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      debugPrint('Opened from local notification: '
          '${launch?.notificationResponse?.payload}');
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM notification tapped');
    debugPrint('Title: ${message.notification?.title ?? message.data['title']}');
    debugPrint('Body: ${message.notification?.body ?? message.data['body']}');
    debugPrint('Extra data: ${message.data}');
    // TODO: Navigate to a course/details screen if message.data contains a route.
  }
}
