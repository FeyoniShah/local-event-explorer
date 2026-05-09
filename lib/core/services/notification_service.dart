// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../features/events/data/event_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Initialize ─────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  // ── Request permission ─────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return android ?? ios ?? false;
  }

  // ── Schedule notifications for ONE event ───────────────────────────────
  Future<void> scheduleEventNotifications(EventModel event) async {
    final now = DateTime.now();
    final eventTime = event.dateTime;
    final diff = eventTime.difference(now);

    // Cancel any existing notifications for this event first
    await cancelEventNotifications(event.id);

    // ── If event is MORE than 24hrs away → schedule 24hr reminder ─────
    if (diff.inHours >= 24) {
      final notifyAt = eventTime.subtract(const Duration(hours: 24));
      if (notifyAt.isAfter(now)) {
        await _scheduleNotification(
          id: _idFrom(event.id, '24h'),
          title: '📅 Tomorrow: ${event.title}',
          body:
              '${event.title} is happening tomorrow at ${event.venue}! Don\'t forget 🎉',
          scheduledTime: notifyAt,
        );
      }
    }

    // ── If event is within same day (< 24hrs) → schedule 1hr reminder ──
    if (diff.inHours < 24 && diff.inHours >= 1) {
      final notifyAt = eventTime.subtract(const Duration(hours: 1));
      if (notifyAt.isAfter(now)) {
        await _scheduleNotification(
          id: _idFrom(event.id, '1h'),
          title: '⏰ Starting soon: ${event.title}',
          body:
              '${event.title} starts in 1 hour at ${event.venue}! Get ready 🚀',
          scheduledTime: notifyAt,
        );
      }
    }

    // ── If MORE than 24hrs away → ALSO schedule 1hr reminder ───────────
    if (diff.inHours >= 24) {
      final notifyAt1h = eventTime.subtract(const Duration(hours: 1));
      if (notifyAt1h.isAfter(now)) {
        await _scheduleNotification(
          id: _idFrom(event.id, '1h'),
          title: '⏰ Starting soon: ${event.title}',
          body:
              '${event.title} starts in 1 hour at ${event.venue}! Get ready 🚀',
          scheduledTime: notifyAt1h,
        );
      }
    }
  }

  // ── Schedule notifications for ALL RSVP'd events ──────────────────────
  Future<int> scheduleAllRsvpNotifications(
      List<EventModel> rsvpdEvents) async {
    int scheduled = 0;
    final now = DateTime.now();

    for (final event in rsvpdEvents) {
      // Only schedule for future events
      if (event.dateTime.isAfter(now)) {
        await scheduleEventNotifications(event);
        scheduled++;
      }
    }
    return scheduled;
  }

  // ── Cancel notifications for a specific event ──────────────────────────
  Future<void> cancelEventNotifications(String eventId) async {
    await _plugin.cancel(_idFrom(eventId, '24h'));
    await _plugin.cancel(_idFrom(eventId, '1h'));
  }

  // ── Cancel ALL notifications ───────────────────────────────────────────
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // ── Show immediate notification (for bell tap feedback) ────────────────
  Future<void> showImmediate({
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Notifications for your RSVP\'d events',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          channelDescription: 'Notifications for your RSVP\'d events',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Converts event id string + suffix to a stable int id for the plugin
  int _idFrom(String eventId, String suffix) {
    return '${eventId}_$suffix'.hashCode.abs() % 100000;
  }
}

// ── Global instance ────────────────────────────────────────────────────────
final notificationService = NotificationService();