import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _maybeShowBackgroundLocalNotification(
    RemoteMessage message) async {
  // If Firebase already handled the notification (notification object exists), don't show it again
  if (message.notification != null) return;

  // Only show local notification if there's data but NO notification object
  // This prevents duplicate notifications
  final title = (message.data['title'] ?? message.data['notification_title'])
          ?.toString() ??
      '';
  final body =
      (message.data['body'] ?? message.data['notification_body'])?.toString() ??
          '';
  if (title.isEmpty && body.isEmpty) return;

  final localNotifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await localNotifications.initialize(settings);

  final androidImplementation =
      localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  if (androidImplementation != null) {
    const channel = AndroidNotificationChannel(
      'fcm_default_channel',
      'FCM Notifications',
      description: 'Firebase Cloud Messaging notifications',
      importance: Importance.high,
    );
    await androidImplementation.createNotificationChannel(channel);
  }

  const androidDetails = AndroidNotificationDetails(
    'fcm_default_channel',
    'FCM Notifications',
    channelDescription: 'Firebase Cloud Messaging notifications',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );
  const details = NotificationDetails(android: androidDetails);

  await localNotifications.show(
    message.hashCode,
    title.isEmpty ? 'إشعار جديد' : title,
    body,
    details,
    payload: message.data.toString(),
  );
}

/// Handler for background messages
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  DartPluginRegistrant.ensureInitialized();
  await Firebase.initializeApp();
  await _maybeShowBackgroundLocalNotification(message);
  print('📩 Background Message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

class FCMService {
  static const String _lastSyncAtKey = 'fcm_last_sync_at';
  static const String _lastSyncErrorKey = 'fcm_last_sync_error';
  static const String _lastSyncedTokenKey = 'fcm_last_synced_token';
  static const String _pendingTokenKey = 'pending_fcm_token';
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM and request notification permissions
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      await requestNotificationPermission();

      // Get FCM token (but DON'T send it yet - wait for login)
      String? token = await _messaging.getToken();
      if (token != null) {
        print('🔑 FCM Token: $token');
        // Save token locally only (don't send to backend until authenticated)
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_pendingTokenKey, token);
          print('💾 FCM Token saved locally, will sync after login');
        } catch (_) {}
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM Token Refreshed: $newToken');

        // Check if user is authenticated before sending
        try {
          final prefs = await SharedPreferences.getInstance();
          final authToken = prefs.getString('auth_token');

          if (authToken != null && authToken.isNotEmpty) {
            // User is authenticated - send immediately
            print('✅ User authenticated, sending FCM token to backend');
            await _sendTokenToBackendOrStore(newToken);
          } else {
            // User not authenticated - store locally only
            print('💾 User not authenticated, storing FCM token locally');
            await prefs.setString(_pendingTokenKey, newToken);
          }
        } catch (_) {
          // Fallback to storing locally if any error
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_pendingTokenKey, newToken);
          } catch (_) {}
        }
      });

      // Setup message handlers
      _setupMessageHandlers();

      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      print('✅ FCM Service Initialized Successfully');
    } catch (e) {
      print('❌ Error initializing FCM: $e');
    }
  }

  Future<void> syncTokenWithBackend() async {
    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(_pendingTokenKey);
    } catch (_) {}
    token ??= await _messaging.getToken();
    if (token == null || token.isEmpty) return;
    await _sendTokenToBackendOrStore(token);
  }

  /// Request notification permission from user
  Future<void> requestNotificationPermission() async {
    try {
      // Request permission using Firebase Messaging
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      switch (settings.authorizationStatus) {
        case AuthorizationStatus.authorized:
          print('✅ User granted notification permission');
          break;
        case AuthorizationStatus.provisional:
          print('⚠️ User granted provisional notification permission');
          break;
        case AuthorizationStatus.denied:
          print('❌ User denied notification permission');
          break;
        case AuthorizationStatus.notDetermined:
          print('⚠️ Notification permission not determined');
          break;
      }

      // For Android 13+ (API level 33+), also use permission_handler
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (status.isGranted) {
          print('✅ Android notification permission granted');
        } else {
          print('❌ Android notification permission denied');
        }
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
    }
  }

  /// Setup handlers for different message states
  void _setupMessageHandlers() {
    // Handle foreground messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground Message Received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // عرض الإشعار محلياً في حالة Foreground
      _showLocalNotification(message);
    });

    // Handle when user taps on notification (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification Tapped (App in Background)');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      // TODO: التوجيه للصفحة المناسبة بناءً على البيانات
      // مثال: if (message.data['type'] == 'chat') { navigateToChatScreen(); }
    });

    // Check if app was opened from a terminated state
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App Opened from Notification (Terminated State)');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');

        // TODO: التوجيه للصفحة المناسبة بناءً على البيانات
      }
    });
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // عند الضغط على الإشعار
        print('🔔 Notification Tapped: ${response.payload}');
        // TODO: التوجيه للصفحة المناسبة
      },
    );

    // Create the channel on Android
    final androidImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'fcm_default_channel', // id
        'FCM Notifications', // title
        description: 'Firebase Cloud Messaging notifications', // description
        importance: Importance.high,
      );
      await androidImplementation.createNotificationChannel(channel);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fcm_default_channel', // channel ID
      'FCM Notifications', // channel name
      channelDescription: 'Firebase Cloud Messaging notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Get title and body from notification object
    final title = message.notification?.title ?? 'إشعار جديد';
    final body = message.notification?.body ?? '';

    await _localNotifications.show(
      message.hashCode, // notification ID
      title,
      body,
      details,
      payload: message.data.toString(),
    );

    print('✅ Local notification displayed');
    print('   Title: $title');
    print('   Body: $body');
  }

  Future<void> _sendTokenToBackendOrStore(String token) async {
    try {
      await _sendTokenToBackend(token);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_pendingTokenKey);
        await prefs.remove(_lastSyncErrorKey);
        await prefs.setString(_lastSyncedTokenKey, token);
        await prefs.setString(_lastSyncAtKey, DateTime.now().toIso8601String());
      } catch (_) {}
    } catch (e) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_pendingTokenKey, token);
        await prefs.setString(_lastSyncErrorKey, e.toString());
        await prefs.setString(_lastSyncAtKey, DateTime.now().toIso8601String());
      } catch (_) {}
      rethrow;
    }
  }

  static Future<Map<String, String?>> getDebugStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'pendingToken': prefs.getString(_pendingTokenKey),
        'lastSyncedToken': prefs.getString(_lastSyncedTokenKey),
        'lastSyncAt': prefs.getString(_lastSyncAtKey),
        'lastSyncError': prefs.getString(_lastSyncErrorKey),
      };
    } catch (_) {
      return {
        'pendingToken': null,
        'lastSyncedToken': null,
        'lastSyncAt': null,
        'lastSyncError': null,
      };
    }
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToBackend(String token) async {
    try {
      await ApiService().post(
        '/api/fcm-token',
        data: {
          'fcm_token': token,
          'device_type': 'android',
        },
      );
      print('✅ FCM Token sent to backend successfully');
    } catch (e) {
      print('❌ Error sending FCM token to backend: $e');
      rethrow;
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  /// Delete FCM token (useful for logout)
  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    print('🗑️ FCM Token Deleted');
  }

  Future<void> clearLocalSyncState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingTokenKey);
      await prefs.remove(_lastSyncedTokenKey);
      await prefs.remove(_lastSyncAtKey);
      await prefs.remove(_lastSyncErrorKey);
    } catch (_) {}
  }

  Future<String?> resetToken({bool syncIfPossible = true}) async {
    await deleteToken();
    await clearLocalSyncState();
    final token = await _messaging.getToken();
    if (!syncIfPossible) return token;
    if (token == null || token.isEmpty) return token;
    await _sendTokenToBackendOrStore(token);
    return token;
  }
}
