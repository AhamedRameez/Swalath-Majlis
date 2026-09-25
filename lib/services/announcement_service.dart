// lib/services/announcement_service.dart
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class AnnouncementService {
  static final AnnouncementService _instance = AnnouncementService._internal();
  factory AnnouncementService() => _instance;
  AnnouncementService._internal();

  // Reference to the same notification plugin used in prayer times
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Keep track of shown announcements to prevent duplicates
  final Set<String> _shownAnnouncements = {};

  // Initialize (call this in main.dart)
  void init(FlutterLocalNotificationsPlugin notifications) {
    tz.initializeTimeZones();
    // Use the same instance from prayer times
  }

  // Show announcement notification immediately
  Future<void> showAnnouncement({
    required String id,
    required String title,
    required String body,
  }) async {
    // Prevent duplicate notifications for same announcement
    if (_shownAnnouncements.contains(id)) {
      print('⏭️ Announcement $id already shown, skipping');
      return;
    }

    try {
      // REUSE the same channel as prayer notifications
      const androidDetails = AndroidNotificationDetails(
        'prayer_channel', // EXACT same channel as prayer times
        'Prayer Notifications',
        channelDescription: 'Prayer times and announcements',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        color: Color(0xFF2AAC83),
        ledColor: Color(0xFF2AAC83),
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: 'Announcement',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      // Show notification immediately
      await _notifications.show(
        id.hashCode, // Use announcement ID as unique notification ID
        '📢 $title',
        body,
        notificationDetails,
      );

      // Mark as shown
      _shownAnnouncements.add(id);

      print('✅ Announcement notification shown: $title');
    } catch (e) {
      print('❌ Error showing announcement: $e');
    }
  }

  // Clear history (optional - call when needed)
  void clearHistory() {
    _shownAnnouncements.clear();
  }
}
