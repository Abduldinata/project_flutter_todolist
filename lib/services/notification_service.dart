import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  final GetStorage _storage = GetStorage();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Request permissions automatically on first initialization
    await requestPermissions();

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return false;
  }

  Future<void> scheduleTaskNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (!areNotificationsEnabled()) return;

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            channelDescription: 'Notifications for task reminders',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint('Scheduled notification for task $id at $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!areNotificationsEnabled()) return;

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  bool areNotificationsEnabled() {
    return _storage.read('notifications_enabled') ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storage.write('notifications_enabled', enabled);
    if (!enabled) {
      await cancelAllNotifications();
    }
  }
}
