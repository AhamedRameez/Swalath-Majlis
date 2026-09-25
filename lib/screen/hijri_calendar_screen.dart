// lib/screen/hijri_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(
    255,
    42,
    172,
    131,
  ); // Deep Teal Green
  static const Color accentColor = Color(0xFFD4AF37); // Warm Gold
  static const Color backgroundColor = Color(0xFFFAF9F6); // Warm White
  static const Color textPrimary = Color(0xFF333333); // Dark Gray
  static const Color textSecondary = Color(0xFF666666); // Medium Gray
  static const Color textTertiary = Color(0xFF888888); // Light Gray
  static const Color cardColor = Color(0xFFFFFFFF); // Pure White
  static const Color dividerColor = Color(0xFFE0E0E0); // Light Gray Divider

  DateTime _currentDate = DateTime.now();
  late HijriCalendar _currentHijri;

  // Month names
  final List<String> _gregorianMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final List<String> _hijriMonths = [
    'Muḥarram',
    'Ṣafar',
    'Rabīʿ I',
    'Rabīʿ II',
    'Jumādā I',
    'Jumādā II',
    'Rajab',
    'Shaʿbān',
    'Ramaḍān',
    'Shawwāl',
    'Dhū al-Qaʿdah',
    'Dhū al-Ḥijjah',
  ];

  @override
  void initState() {
    super.initState();
    _currentHijri = HijriCalendar.fromDate(_currentDate);
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      _currentHijri = HijriCalendar.fromDate(_currentDate);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      _currentHijri = HijriCalendar.fromDate(_currentDate);
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _currentHijri = HijriCalendar.fromDate(_currentDate);
    });
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstWeekday(int year, int month) {
    return DateTime(year, month, 1).weekday;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Hijri Calendar',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.8,
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
            icon: const Icon(Icons.today_rounded),
            onPressed: _goToToday,
            tooltip: 'Today',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: Column(
        children: [
          /// 📆 MONTH HEADER
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Navigation arrows
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    // Main Hijri month display
                    Column(
                      children: [
                        Text(
                          '${_hijriMonths[_currentHijri.hMonth - 1]} ${_currentHijri.hYear}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Gregorian month in small text below
                        Text(
                          '${_gregorianMonths[_currentDate.month - 1]} ${_currentDate.year}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 📅 WEEKDAY HEADERS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Mon',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Tue',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Wed',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Thu',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Fri',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Sat',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  'Sun',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            color: dividerColor,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),

          /// 📆 CALENDAR GRID
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCalendarGrid(),
            ),
          ),

          /// ℹ️ TODAY'S DATE SUMMARY
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dividerColor.withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            _currentHijri.toFormat("dd MMMM yyyy"),
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              DateFormat('dd MMM yyyy').format(DateTime.now()),
                              style: const TextStyle(
                                color: accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_currentDate.year, _currentDate.month);
    final firstWeekday = _getFirstWeekday(
      _currentDate.year,
      _currentDate.month,
    );

    // Adjust for Monday as first day (1 = Monday, 7 = Sunday)
    final startOffset = firstWeekday - 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 0.9,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 42, // 6 rows × 7 days
      itemBuilder: (context, index) {
        final day = index - startOffset + 1;

        if (day < 1 || day > daysInMonth) {
          return const SizedBox.shrink(); // Empty cells
        }

        final date = DateTime(_currentDate.year, _currentDate.month, day);
        final hijriDate = HijriCalendar.fromDate(date);
        final isToday = _isToday(date);
        final isFriday = date.weekday == 5; // Friday

        return Container(
          decoration: BoxDecoration(
            color: isToday
                ? primaryColor.withValues(alpha: 0.1)
                : isFriday
                ? accentColor.withValues(alpha: 0.05)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: isToday ? Border.all(color: primaryColor, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hijri day (main number)
              Text(
                hijriDate.hDay.toString(),
                style: TextStyle(
                  color: isToday
                      ? primaryColor
                      : isFriday
                      ? accentColor
                      : textPrimary,
                  fontSize: 18,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              // Gregorian day (small below)
              Text(
                day.toString(),
                style: TextStyle(
                  color: isToday ? primaryColor.withValues(alpha: 0.7) : textTertiary,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
