import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Local (on-device) notifications only — this is what makes daily reminders
/// work with zero network access (spec §11, §32). Firebase Cloud Messaging
/// can later be layered on top for remote pushes without changing this API.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int learningReminderId = 1001;
  static const int reviewReminderId = 1002;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Schedules the single daily learning reminder ("Your Quran Word Lesson").
  /// Only one per day by default, per spec §11.
  Future<void> scheduleLearningReminder({
    required String hhmm,
    required int wordsWaiting,
  }) async {
    await _scheduleDaily(
      id: learningReminderId,
      hhmm: hhmm,
      title: 'Your Quran Word Lesson',
      body: '$wordsWaiting Quranic words are waiting for you today.',
    );
  }

  Future<void> scheduleReviewReminder({
    required String hhmm,
    required int wordsDue,
  }) async {
    await _scheduleDaily(
      id: reviewReminderId,
      hhmm: hhmm,
      title: 'Time to Review',
      body: 'You have $wordsDue Quranic words ready for revision.',
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _scheduleDaily({
    required int id,
    required String hhmm,
    required String title,
    required String body,
  }) async {
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts.first) ?? 20;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daily Reminders',
      channelDescription: 'Learning and review reminders',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
