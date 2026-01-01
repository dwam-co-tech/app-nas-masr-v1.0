import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handler for background messages
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background Message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
}

class FCMService {
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

      // Get FCM token
      String? token = await _messaging.getToken();
      if (token != null) {
        print('🔑 FCM Token: $token');
        // إرسال الـ Token للـ Backend
        await _sendTokenToBackend(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        print('🔄 FCM Token Refreshed: $newToken');
        // تحديث الـ Token في الـ Backend
        _sendTokenToBackend(newToken);
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

    await _localNotifications.show(
      message.hashCode, // notification ID
      message.notification?.title ?? 'إشعار جديد',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );

    print('✅ Local notification displayed');
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
      // لا نريد إيقاف التطبيق إذا فشل إرسال الـ Token
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
}
