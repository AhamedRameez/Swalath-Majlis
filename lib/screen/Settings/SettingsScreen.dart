// lib/screen/settings/settingsScreen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swalath_majlis_user/screen/Settings/about_app_screen.dart';
import 'package:swalath_majlis_user/screen/Settings/about_us_screen.dart';
import 'package:swalath_majlis_user/screen/Settings/privacy_policy_screen.dart';
import 'package:swalath_majlis_user/screen/Settings/help_support_screen.dart';
import 'App Admin/appAdmin_login_screen.dart';
import 'App Admin/appAdmin_dashboard.dart';
import '/services/app_admin_auth_service.dart';
// Add this import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 🎨 UPDATED: Your app theme colors
  static const Color primaryColor = Color.fromARGB(
    255,
    42,
    172,
    131,
  ); // Deep Teal Green
  static const Color accentColor = Color(0xFFD4AF37); // Warm Gold
  static const Color backgroundColor = Color(0xFFFAF9F6); // Warm White
  static const Color cardColor = Color(0xFFFFFFFF); // Pure White
  static const Color textPrimary = Color(0xFF333333); // Dark Gray
  static const Color textSecondary = Color(0xFF666666); // Medium Gray
  static const Color textTertiary = Color(0xFF888888); // Light Gray
  static const Color dividerColor = Color(0xFFE0E0E0); // Light Gray Divider

  // Settings variables
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _arabicFontEnabled = true;
  bool _hapticFeedback = true;
  bool _autoUpdatePrayerTimes = true;
  bool _isUpdatingLocation = false;
  double _arabicFontSize = 20.0;
  String _language = 'English';
  String _prayerCalculationMethod = 'Muslim World League';

  // Auto-update settings
  int _updateFrequency = 60; // minutes
  bool _updateOnAppStart = true;
  bool _updateOnLocationChange = true;
  String _lastLocationUpdate = 'Never';
  String _currentLocation = 'Unknown';

  // Add Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
    _getLastLocationUpdate();
  }

  /// 📥 Load saved settings from SharedPreferences
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _darkMode = prefs.getBool('darkMode') ?? false;
      _arabicFontEnabled = prefs.getBool('arabicFontEnabled') ?? true;
      _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
      _autoUpdatePrayerTimes = prefs.getBool('autoUpdatePrayerTimes') ?? true;
      _arabicFontSize = prefs.getDouble('arabicFontSize') ?? 20.0;
      _language = prefs.getString('language') ?? 'English';
      _prayerCalculationMethod =
          prefs.getString('prayerCalculationMethod') ?? 'Muslim World League';
      _updateFrequency = prefs.getInt('updateFrequency') ?? 60;
      _updateOnAppStart = prefs.getBool('updateOnAppStart') ?? true;
      _updateOnLocationChange = prefs.getBool('updateOnLocationChange') ?? true;
    });
  }

  /// 📍 Get last location update time
  Future<void> _getLastLocationUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('lastLocationUpdate');
    final savedLocation = prefs.getString('currentLocation');

    setState(() {
      _lastLocationUpdate = lastUpdate ?? 'Never';
      _currentLocation = savedLocation ?? 'Unknown';
    });
  }

  /// 📍 Update location manually
  Future<void> _updateLocationManually() async {
    setState(() {
      _isUpdatingLocation = true;
    });

    try {
      // Check location permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationDialog(
          'Location services are disabled. Please enable location.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationDialog('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationDialog('Location permissions are permanently denied.');
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      // Get location name (you can use a geocoding service here)
      String locationName =
          '${position.latitude.toStringAsFixed(4)}° N, ${position.longitude.toStringAsFixed(4)}° E';

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final formattedDate =
          '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      await prefs.setString('lastLocationUpdate', formattedDate);
      await prefs.setString('currentLocation', locationName);
      await prefs.setDouble('lastLatitude', position.latitude);
      await prefs.setDouble('lastLongitude', position.longitude);

      setState(() {
        _lastLocationUpdate = formattedDate;
        _currentLocation = locationName;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 12),
              Expanded(child: Text('Location updated successfully')),
            ],
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      _showLocationDialog('Error updating location: ${e.toString()}');
    } finally {
      setState(() {
        _isUpdatingLocation = false;
      });
    }
  }

  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Location Update',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 🔔 NEW: Update notification settings
  Future<void> _updateNotificationSettings(bool enabled) async {
    try {
      if (enabled) {
        // You can add permission check here if needed
        print('✅ Notifications enabled by user');

        // Optional: Send test notification to confirm
        // await AnnouncementService().showAnnouncement(
        //   id: 'settings_test',
        //   title: 'Notifications Enabled',
        //   body: 'You will now receive prayer time alerts',
        // );
      } else {
        print('🔕 Notifications disabled by user');
        // Note: We can't programmatically disable system notifications
        // This just saves the preference for the app to check
      }
    } catch (e) {
      print('Error updating notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSection('App Settings', [
              // 🔥 UPDATED: Working notification toggle
              _buildSettingItem(
                icon: Icons.notifications_active_rounded,
                title: 'Notifications',
                subtitle: 'Prayer time reminders and announcements',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: primaryColor,
                  onChanged: (value) async {
                    // Update UI
                    setState(() {
                      _notificationsEnabled = value;
                    });

                    // Save to SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('notificationsEnabled', value);

                    // Update notification settings
                    await _updateNotificationSettings(value);

                    // Show feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              value
                                  ? Icons.notifications_active_rounded
                                  : Icons.notifications_off_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                value
                                    ? 'Notifications Enabled'
                                    : 'Notifications Disabled',
                                style: const TextStyle(fontFamily: 'Poppins'),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: value
                            ? primaryColor
                            : Colors.grey[600],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.translate_rounded,
                title: 'Language',
                subtitle: 'App language',
                trailing: DropdownButton<String>(
                  value: _language,
                  underline: Container(),
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  items: ['English', 'Arabic', 'Malayalam'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _language = newValue!;
                    });
                  },
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // // Prayer Settings Section with Auto-Update
            // _buildSection('Prayer Settings', [
            //   // 🔄 AUTO-UPDATE PRAYER TIMES - Main Switch
            //   _buildSettingItem(
            //     icon: Icons.update_rounded,
            //     title: 'Auto Update Prayer Times',
            //     subtitle: 'Automatically refresh prayer times',
            //     trailing: Switch(
            //       value: _autoUpdatePrayerTimes,
            //       activeColor: primaryColor,
            //       onChanged: (value) {
            //         setState(() {
            //           _autoUpdatePrayerTimes = value;
            //         });
            //       },
            //     ),
            //   ),

            //   // Auto-update sub-settings (only visible when auto-update is enabled)
            //   if (_autoUpdatePrayerTimes) ...[
            //     _buildDivider(),

            //     // Update on App Start
            //     _buildSettingItem(
            //       icon: Icons.play_circle_rounded,
            //       title: 'Update on App Start',
            //       subtitle: 'Refresh when app opens',
            //       trailing: Switch(
            //         value: _updateOnAppStart,
            //         activeColor: primaryColor,
            //         onChanged: (value) {
            //           setState(() {
            //             _updateOnAppStart = value;
            //           });
            //         },
            //       ),
            //     ),
            //     _buildDivider(),

            //     // Update on Location Change
            //     _buildSettingItem(
            //       icon: Icons.location_on_rounded,
            //       title: 'Update on Location Change',
            //       subtitle: 'Refresh when location changes',
            //       trailing: Switch(
            //         value: _updateOnLocationChange,
            //         activeColor: primaryColor,
            //         onChanged: (value) {
            //           setState(() {
            //             _updateOnLocationChange = value;
            //           });
            //         },
            //       ),
            //     ),
            //   ],
            // ]),

            // const SizedBox(height: 24),
            const SizedBox(height: 24),

            // App Admin section Section
            StreamBuilder<DocumentSnapshot>(
              stream: _firestore
                  .collection('app_settings')
                  .doc('admin_section_visibility')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
                }

                final isVisible = snapshot.data?['isVisible'] ?? true;

                if (!isVisible) {
                  return const SizedBox();
                }

                return _buildSection('Admin Section', [
                  StreamBuilder<bool>(
                    stream: Stream.fromFuture(AppAdminAuthService.isLoggedIn()),
                    builder: (context, loginSnapshot) {
                      final isLoggedIn = loginSnapshot.data ?? false;

                      return _buildSettingItem(
                        icon: Icons.admin_panel_settings_rounded,
                        title: isLoggedIn ? 'App Admin Dashboard' : 'Admin',
                        subtitle: isLoggedIn
                            ? 'Manage live streams, feedback, and analytics'
                            : 'Limited content management',
                        trailing: isLoggedIn
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Logged In',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                              ),
                        onTap: () {
                          if (isLoggedIn) {
                            AppAdminAuthService.extendSession();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AppAdminDashboard(),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AppAdminLoginScreen(),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ]);
              },
            ),

            const SizedBox(height: 24),

            // Other Settings Section
            _buildSection('Other Settings', [
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
                subtitle: 'View our privacy policy',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                subtitle: 'Get help using the app',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                title: 'About Us',
                subtitle: 'About Company & Developer',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.info_outline_rounded,
                title: 'About App',
                subtitle: 'Version 1.0.3',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AboutAppScreen()),
                  );
                },
              ),
            ]),

            const SizedBox(height: 32),

            // Save & Reset Buttons
            // Row(
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         onPressed: () {
            //           _saveSettings();
            //           Navigator.pop(context);
            //         },
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: primaryColor,
            //           foregroundColor: Colors.white,
            //           padding: const EdgeInsets.symmetric(vertical: 16),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //         child: const Text(
            //           'Save Settings',
            //           style: TextStyle(
            //             fontFamily: 'Poppins',
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 12),
            //     OutlinedButton(
            //       onPressed: _resetSettings,
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: primaryColor,
            //         side: const BorderSide(color: primaryColor),
            //         padding: const EdgeInsets.symmetric(
            //           vertical: 16,
            //           horizontal: 20,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //       ),
            //       child: const Text(
            //         'Reset',
            //         style: TextStyle(
            //           fontFamily: 'Poppins',
            //           fontWeight: FontWeight.w600,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, thickness: 0.5, color: dividerColor),
    );
  }

  void _showCalculationMethodDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Calculation Method',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[
                  'Muslim World League',
                  'Egyptian',
                  'Karachi',
                  'Umm al-Qura',
                  'Dubai',
                ]
                .map(
                  (method) => RadioListTile<String>(
                    title: Text(
                      method,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                    value: method,
                    groupValue: _prayerCalculationMethod,
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _prayerCalculationMethod = value!;
                      });
                      Navigator.pop(context);
                    },
                  ),
                )
                ,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'About Swalath Majlis',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.3',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Swalath Majlis is a comprehensive Islamic app providing prayer times, Quranic content, duas, and more.',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: primaryColor),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// 💾 Save all settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('darkMode', _darkMode);
    await prefs.setBool('arabicFontEnabled', _arabicFontEnabled);
    await prefs.setBool('hapticFeedback', _hapticFeedback);
    await prefs.setBool('autoUpdatePrayerTimes', _autoUpdatePrayerTimes);
    await prefs.setDouble('arabicFontSize', _arabicFontSize);
    await prefs.setString('language', _language);
    await prefs.setString('prayerCalculationMethod', _prayerCalculationMethod);
    await prefs.setInt('updateFrequency', _updateFrequency);
    await prefs.setBool('updateOnAppStart', _updateOnAppStart);
    await prefs.setBool('updateOnLocationChange', _updateOnLocationChange);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Settings saved successfully')),
          ],
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reset Settings',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        content: const Text(
          'Are you sure you want to reset all settings to default?',
          style: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: textSecondary),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notificationsEnabled = true;
                _darkMode = false;
                _arabicFontEnabled = true;
                _hapticFeedback = true;
                _autoUpdatePrayerTimes = true;
                _arabicFontSize = 20.0;
                _language = 'English';
                _prayerCalculationMethod = 'Muslim World League';
                _updateFrequency = 60;
                _updateOnAppStart = true;
                _updateOnLocationChange = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(child: Text('Settings reset to default')),
                    ],
                  ),
                  backgroundColor: primaryColor,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
