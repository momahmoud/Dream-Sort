import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static const int _dailyReminderId = 1001;
  static const String _channelId = 'daily_reward';
  static const String _channelName = 'Daily Reward';
  static const String _channelDesc =
      'Reminds you when your daily reward is ready';

  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  /// Schedules a single "daily bonus ready" notification at [scheduledTime].
  /// Pass localized [title] and [body] from the call site that has BuildContext.
  /// Cancels any previously scheduled daily reminder first.
  static Future<void> scheduleDailyReminder(
    DateTime scheduledTime, {
    required String title,
    required String body,
  }) async {
    try {
      await _plugin.cancel(_dailyReminderId);

      final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

      await _plugin.zonedSchedule(
        _dailyReminderId,
        title,
        body,
        tzScheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService: failed to schedule reminder: $e');
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
