// lib/screens/prayer/default_prayer_time_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DefaultPrayerTimeScreen extends StatefulWidget {
  const DefaultPrayerTimeScreen({super.key});

  @override
  State<DefaultPrayerTimeScreen> createState() =>
      _DefaultPrayerTimeScreenState();
}

class _DefaultPrayerTimeScreenState extends State<DefaultPrayerTimeScreen> {
  // 🎨 Your exact theme colors from prayer_screen.dart
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  String? _selectedCity;
  List<String> _cities = [];

  // Date selection
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  /// Load cities from Firestore with Kasaragod first
  Future<void> _loadCities() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('prayer_times')
          .get();

      final cities = snapshot.docs
          .map((doc) => doc['city'].toString())
          .toSet()
          .toList();

      // Sort alphabetically first
      cities.sort();

      // 🔥 Move Kasaragod to the front if it exists
      if (cities.contains('Kasaragod')) {
        cities.remove('Kasaragod');
        cities.insert(0, 'Kasaragod');
      }

      setState(() {
        _cities = cities;
        if (cities.isNotEmpty) {
          _selectedCity = cities.first; // This will be Kasaragod
        }
      });

      print('✅ Loaded ${cities.length} cities with Kasaragod first');
      print('📋 City order: $cities');
    } catch (e) {
      print('❌ Error loading cities: $e');
    }
  }

  /// Date picker
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryColor,
              secondary: accentColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Prayer Times",
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        actions: [
          // Calendar icon on right
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: _selectDate,
            tooltip: 'Select Date',
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
          const SizedBox(height: 16),

          // Date Display in Center
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _dateFormat.format(_selectedDate),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // City Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  hint: const Text(
                    "Select City",
                    style: TextStyle(color: textSecondary),
                  ),
                  icon: const Icon(
                    Icons.arrow_drop_down_rounded,
                    color: primaryColor,
                  ),
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(
                        city,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Prayer Time List
          Expanded(
            child: _selectedCity == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_city_rounded,
                          size: 60,
                          color: textTertiary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Select a city",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('swalathmajlis')
                        .doc('iM6QRMlgUuWNbUdgQ0')
                        .collection('prayer_times')
                        .where('city', isEqualTo: _selectedCity)
                        .where(
                          'date',
                          isGreaterThanOrEqualTo: Timestamp.fromDate(
                            DateTime.utc(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day,
                            ),
                          ),
                        )
                        .where(
                          'date',
                          isLessThan: Timestamp.fromDate(
                            DateTime.utc(
                              _selectedDate.year,
                              _selectedDate.month,
                              _selectedDate.day + 1,
                            ),
                          ),
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        print('❌ Error: ${snapshot.error}');
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 60,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Error loading data",
                                style: TextStyle(color: textSecondary),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 60,
                                color: textTertiary.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "No prayer times for this date",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Select another date",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final data =
                          snapshot.data!.docs.first.data()
                              as Map<String, dynamic>;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          final prayers = [
                            {
                              'name': 'Fajr',
                              'time': data['fajr'] ?? '--:--',
                              'icon': Icons.wb_sunny_rounded,
                            },
                            {
                              'name': 'Sunrise',
                              'time': data['sunrise'] ?? '--:--',
                              'icon': Icons.wb_twilight_rounded,
                            },
                            {
                              'name': 'Dhuhr',
                              'time': data['dhuhr'] ?? '--:--',
                              'icon': Icons.wb_sunny_rounded,
                            },
                            {
                              'name': 'Asr',
                              'time': data['asr'] ?? '--:--',
                              'icon': Icons.cloud_rounded,
                            },
                            {
                              'name': 'Maghrib',
                              'time': data['maghrib'] ?? '--:--',
                              'icon': Icons.nights_stay_rounded,
                            },
                            {
                              'name': 'Isha',
                              'time': data['isha'] ?? '--:--',
                              'icon': Icons.nightlight_round,
                            },
                          ];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: _buildPrayerCard(
                              prayers[index]['name']!,
                              prayers[index]['time']!,
                              prayers[index]['icon']!,
                              index,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Prayer card with time on RIGHT side (matching prayer_screen.dart)
  Widget _buildPrayerCard(String name, String time, IconData icon, int index) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
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
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Prayer name with icon (expanded to push time to right)
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              // Time on RIGHT side (exactly like prayer_screen.dart)
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
                      time,
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
            ],
          ),
        ),
      ),
    );
  }
}
