// lib/screen/prayer_times_screen.dart
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'default_prayer_time_screen.dart';

class PrayerTimeScreen extends StatefulWidget {
  const PrayerTimeScreen({super.key});

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  PrayerTimes? prayerTimes;
  Position? position;
  bool _isLoading = true;
  String? _errorMessage;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Alarm offset options
  final List<int> _alarmOffsets = [-30, -20, -15, -10, -5, 0, 5];
  final Map<String, int> _selectedOffsets = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  // Track which alarms are set
  final Map<String, bool> _alarmsSet = {
    'Fajr': false,
    'Dhuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  @override
  void initState() {
    super.initState();
    _initNotification();
    _loadPrayerTimes();
  }

  /// 🔔 Notification init
  Future<void> _initNotification() async {
    try {
      tz.initializeTimeZones();
      await _requestNotificationPermission();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: android);
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );

      debugPrint('✅ Notifications initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// 🔐 Request notification permission
  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  /// 🔍 Check location permission
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage =
            'Location services are disabled. Please enable location.';
        _isLoading = false;
      });
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied.';
          _isLoading = false;
        });
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage = 'Location permissions permanently denied.';
        _isLoading = false;
      });
      return false;
    }

    return true;
  }

  /// 📍 Load prayer times
  Future<void> _loadPrayerTimes() async {
    try {
      bool hasPermission = await _checkLocationPermission();
      if (!hasPermission) return;

      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      ).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to get location. Please try again.';
          _isLoading = false;
        });
        return null;
      });

      if (position == null) {
        setState(() {
          _errorMessage = 'Unable to get current location.';
          _isLoading = false;
        });
        return;
      }

      final coordinates = Coordinates(position!.latitude, position!.longitude);
      final params = CalculationMethod.muslim_world_league.getParameters();
      params.madhab = Madhab.shafi;
      prayerTimes = PrayerTimes.today(coordinates, params);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error calculating prayer times.';
        _isLoading = false;
      });
    }
  }

  /// 🔄 Retry loading prayer times
  Future<void> _retryLoadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await _loadPrayerTimes();
  }

  /// 🔔 Set alarm
  Future<void> _setAlarm(String prayerName) async {
    try {
      if (prayerTimes == null) return;

      if (!await Permission.notification.isGranted) {
        await _requestNotificationPermission();
      }

      DateTime prayerTime;
      switch (prayerName) {
        case 'Fajr':
          prayerTime = prayerTimes!.fajr;
          break;
        case 'Dhuhr':
          prayerTime = prayerTimes!.dhuhr;
          break;
        case 'Asr':
          prayerTime = prayerTimes!.asr;
          break;
        case 'Maghrib':
          prayerTime = prayerTimes!.maghrib;
          break;
        case 'Isha':
          prayerTime = prayerTimes!.isha;
          break;
        default:
          return;
      }

      await _notifications.cancel(prayerName.hashCode);

      final offset = _selectedOffsets[prayerName] ?? 0;
      final alarmTime = prayerTime.add(Duration(minutes: offset));
      final now = DateTime.now();

      DateTime scheduleTime;
      if (alarmTime.isBefore(now)) {
        scheduleTime = alarmTime.add(const Duration(days: 1));
      } else {
        scheduleTime = alarmTime;
      }

      await _scheduleNotification(prayerName, scheduleTime, offset);

      setState(() {
        _alarmsSet[prayerName] = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    offset == 0
                        ? '🔔 Alarm set for $prayerName prayer'
                        : '🔔 Alarm set ${offset.abs()} min ${offset > 0 ? 'after' : 'before'} $prayerName',
                  ),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error setting alarm: $e');
      if (mounted) {
        String errorMsg = e.toString();
        if (errorMsg.length > 50) errorMsg = '${errorMsg.substring(0, 50)}...';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set alarm: $errorMsg'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// 🛠️ Schedule notification - FIXED with androidScheduleMode
  Future<void> _scheduleNotification(
    String name,
    DateTime scheduleTime,
    int offset,
  ) async {
    final offsetText = offset == 0
        ? ''
        : offset > 0
            ? ' (+$offset min)'
            : ' (${offset.abs()} min before)';

    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Notifications',
      channelDescription: 'Reminders for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      enableLights: true,
      color: Color(0xFF2AAC83),
      ledColor: Color(0xFF2AAC83),
      ledOnMs: 1000,
      ledOffMs: 500,
      playSound: true,
      ticker: 'Prayer Time Alert',
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    final tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);

    // 🔥 FIXED: Added androidScheduleMode parameter
    await _notifications.zonedSchedule(
      name.hashCode,
      '🕌 Time for $name Prayer',
      'It\'s time for $name prayer$offsetText',
      tzScheduleTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: name,
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // 🔥 ADD THIS
    );
  }

  /// 🗑️ Cancel alarm
  Future<void> _cancelAlarm(String prayerName) async {
    await _notifications.cancel(prayerName.hashCode);
    setState(() {
      _alarmsSet[prayerName] = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⏰ Alarm cancelled for $prayerName'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildPrayerCard(String name, DateTime time, int index) {
    final formattedTime = DateFormat.jm().format(time.toLocal());
    final offset = _selectedOffsets[name] ?? 0;
    final alarmTime = time.add(Duration(minutes: offset));
    final alarmFormattedTime = DateFormat.jm().format(alarmTime.toLocal());
    final isAlarmSet = _alarmsSet[name] ?? false;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAlarmSet
                ? accentColor.withValues(alpha: 0.5)
                : dividerColor.withValues(alpha: 0.8),
            width: isAlarmSet ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Prayer number badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isAlarmSet
                      ? accentColor.withValues(alpha: 0.15)
                      : accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isAlarmSet
                        ? accentColor.withValues(alpha: 0.5)
                        : accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isAlarmSet ? accentColor : accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prayer name
                    Row(
                      children: [
                        Icon(
                          Icons.mosque_rounded,
                          size: 16,
                          color: isAlarmSet ? accentColor : primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          name,
                          style: TextStyle(
                            color: isAlarmSet ? accentColor : textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        if (isAlarmSet) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Alarm On',
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Prayer time with offset info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Original prayer time
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Alarm offset info
                        if (offset != 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                offset > 0
                                    ? Icons.notifications_active_outlined
                                    : Icons.notifications_active_rounded,
                                size: 12,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Alarm: $alarmFormattedTime',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Alarm button with dropdown
              PopupMenuButton<int>(
                tooltip: isAlarmSet ? 'Alarm is set' : 'Set alarm for $name',
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isAlarmSet
                        ? accentColor.withValues(alpha: 0.15)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isAlarmSet
                          ? accentColor.withValues(alpha: 0.3)
                          : Colors.blue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    isAlarmSet
                        ? Icons.alarm_on_rounded
                        : Icons.alarm_add_rounded,
                    size: 18,
                    color: isAlarmSet ? accentColor : Colors.blue,
                  ),
                ),
                onSelected: (value) {
                  if (value == -999) {
                    _cancelAlarm(name);
                  } else {
                    setState(() {
                      _selectedOffsets[name] = value;
                    });
                    _setAlarm(name);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: -30,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text('30 min before'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: -20,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text('20 min before'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: -15,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text('15 min before'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: -10,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text('10 min before'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: -5,
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.blue,
                        ),
                        SizedBox(width: 8),
                        Text('5 min before'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.notifications_rounded, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('At prayer time'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 5,
                    child: Row(
                      children: [
                        Icon(Icons.notifications_outlined, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('5 min after'),
                      ],
                    ),
                  ),
                  if (isAlarmSet) ...[
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: -999,
                      child: Row(
                        children: [
                          Icon(Icons.alarm_off_rounded, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Cancel Alarm',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Loading states...
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primaryColor, strokeWidth: 3),
              SizedBox(height: 20),
              Text(
                'Calculating Prayer Times...',
                style: TextStyle(color: textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_rounded,
                  color: Colors.red[400],
                  size: 40,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Location Required',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retryLoadPrayerTimes,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (prayerTimes == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.orange[400],
                  size: 40,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Calculation Error',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unable to calculate prayer times',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSecondary),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _retryLoadPrayerTimes,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final prayers = {
      'Fajr': prayerTimes!.fajr,
      'Dhuhr': prayerTimes!.dhuhr,
      'Asr': prayerTimes!.asr,
      'Maghrib': prayerTimes!.maghrib,
      'Isha': prayerTimes!.isha,
    };

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Location Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              children: [
                // Location info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '📍 Your Location',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${position!.latitude.toStringAsFixed(4)}° N, ${position!.longitude.toStringAsFixed(4)}° E',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Informative message with DIRECT navigation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'This is an estimated prayer time based on your current location.',
                              style: TextStyle(
                                color: const Color.fromARGB(
                                  255,
                                  0,
                                  0,
                                  0,
                                ).withValues(alpha: 0.9),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Direct navigation
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DefaultPrayerTimeScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 14,
                                color: accentColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Exact prayer time via city click here',
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 10,
                                color: accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Prayer List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: prayers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = prayers.entries.toList()[index];
                  return _buildPrayerCard(entry.key, entry.value, index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Prayer Times',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded),
          onPressed: _retryLoadPrayerTimes,
          tooltip: 'Refresh',
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    );
  }
}
