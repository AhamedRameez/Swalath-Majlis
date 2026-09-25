// lib/screen/user_dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swalath_majlis_user/screen/Ramazan/Ramazan_screen.dart';
import 'package:swalath_majlis_user/screen/Swalath/swalath_screen.dart';
import 'Moulood/moulood_screen.dart';
import 'Settings/about_us_screen.dart';
import 'Thasbeeh/tasbeeh_screen.dart';
import 'Duas/duas_screen.dart';
import 'adhkar/adkar_screen.dart';
import 'announcement_screen.dart';
import 'najathul_view_screen.dart';
import 'imp surah/important_surah_screen.dart';
import 'prayer_times_screen.dart';
import 'Ayaths/ayaths_screen.dart';
import 'Quran/quran_select_screen.dart';
import 'salah/namaz_list_screen.dart';
import './Settings/SettingsScreen.dart';
import 'special day/special_day_dua_detail_screen.dart';
import 'thouba/thowba_screen.dart';
import 'hijri_calendar_screen.dart';
import 'user_send_message_admin_screen.dart';
import 'islamic studies/islamic_studies_screen.dart';
import 'Asmaul Husna/asmaul_husna_screen.dart';
import '../services/announcement_service.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  ThemeData get _modernTheme => ThemeData(
        useMaterial3: true,
        fontFamily: 'Poppins',
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 42, 172, 131),
          secondary: Color(0xFFD4AF37),
          surface: Colors.white,
          onSurface: Color(0xFF333333),
          onPrimary: Colors.white,
          onSecondary: Color.fromARGB(255, 197, 194, 194),
          surfaceContainerHighest: Color(0xFFE0E0E0),
          onSurfaceVariant: Color(0xFF666666),
          error: Color(0xFFE53935),
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Color(0xFF333333),
          ),
          titleSmall: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF333333),
          ),
          bodySmall: TextStyle(fontSize: 13, color: Color(0xFF666666)),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: const Color(0xFFFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _modernTheme,
      child: Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: SafeArea(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/images/dashboard.png'),
                    fit: BoxFit.cover,
                    opacity: 0.5,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF5F3EF).withValues(alpha: 0.92),
                      const Color(0xFFFAF9F6).withValues(alpha: 0.88),
                      const Color(0xFFF5F3EF).withValues(alpha: 0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // 🆕 TOP BAR - Icons on dashboard background (NO AppBar)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Settings Icon (Left) - Smaller Golden Circle
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(
                                    255, 54, 52, 52), // Gold color
                                width: 1.5,
                              ),
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.settings,
                                color: Color(0xFFD4AF37),
                                size: 16, // Smaller icon
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                          ),

                          // S.A.K Title (Center)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AboutUsScreen(),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFFD4AF37),
                                        Color(0xFFD4AF37)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: const Text(
                                      "S.A.K",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 40,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF333333),
                                          Color(0xFF333333)
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Notification Icon (Right)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(
                                    255, 54, 52, 52), // Gold color
                                width: 1.5,
                              ),
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications,
                                color: Color(0xFFD4AF37),
                                size: 16, // Smaller icon
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showNotificationSheet(context),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification trigger (UNCHANGED)
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('swalathmajlis')
                          .doc('iM6QRMlgUuWNbUdgQ0')
                          .collection('announcements')
                          .orderBy('createdAt', descending: true)
                          .limit(1)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          final latestDoc = snapshot.data!.docs.first;
                          final data = latestDoc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'New Announcement';
                          final message = data['message'] ?? '';
                          final announcementId = latestDoc.id;

                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            AnnouncementService().showAnnouncement(
                              id: announcementId,
                              title: title,
                              body: message,
                            );
                          });
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        child: Column(
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 20),
                            _buildLiveStreamsSection(context),
                            const SizedBox(height: 12),
                            _buildSection(
                              context,
                              "                                                          ",
                              [
                                _card(
                                  context,
                                  'Imp Surah',
                                  'assets/icon/menu/ayath.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ImportantSurahScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Salah',
                                  'assets/icon/menu/salah.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const NamazListScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Imp Ayath',
                                  'assets/icon/menu/ayath.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AyathsScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Moulood',
                                  'assets/icon/menu/kubba.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const MouloodScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Swalath Bait',
                                  'assets/icon/menu/moulood.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SwalathScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Aurad',
                                  'assets/icon/menu/kubba.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AdhkarScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Najathul Islam',
                                  'assets/icon/menu/majlisunnur.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => NajathulViewScreen(
                                          title: 'Najathul Islam',
                                          pdfPath: 'assets/pdfs/Majlis.pdf',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Prayer time',
                                  'assets/icon/menu/azan.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const PrayerTimeScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Majlisunnoor',
                                  'assets/icon/menu/majlisunnur.png',
                                  () {
                                    _showComingSoonSnackbar(
                                      context,
                                      'Majlisunnoor',
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Islamic Studies',
                                  'assets/icon/menu/studies.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const IslamicStudiesMenuScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Ramzan',
                                  'assets/icon/menu/ramazan.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const RamazanScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Thouba',
                                  'assets/icon/menu/thouba.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ThawbaScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Asmaul Husna',
                                  'assets/icon/menu/asmai.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AsmaulHusnaScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Calender',
                                  'assets/icon/menu/calender.png',
                                  () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const HijriCalendarScreen(),
                                      ),
                                    );
                                  },
                                ),
                                _card(
                                  context,
                                  'Hajj & Umrah',
                                  'assets/icon/menu/hajj.png',
                                  () {
                                    _showComingSoonSnackbar(
                                      context,
                                      'Hajj & Umrah',
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            height: 0.5,
                            width: double.infinity,
                            color: colorScheme.surfaceContainerHighest,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: _buildPinnedSection(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== PINNED SECTION (UNCHANGED) ====================
  Widget _buildPinnedSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _compactBottomCard(
            context,
            'Quran',
            'assets/icon/menu/quran.png',
            const Color(0xFF1B5E20),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuranSelectScreen()),
              );
            },
          ),
          _compactBottomCard(
            context,
            'Duas',
            'assets/icon/menu/dua.png',
            const Color(0xFF1B5E20),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DuasScreen()),
              );
            },
          ),
          _compactBottomCard(
            context,
            'Tasbeeh',
            'assets/icon/menu/counter.png',
            const Color(0xFF1B5E20),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasbeehScreen()),
              );
            },
          ),
          _compactBottomCard(
            context,
            'Message',
            'assets/icon/menu/message.png',
            const Color(0xFF1B5E20),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserSendMessageScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==================== COMPACT BOTTOM CARD (UNCHANGED) ====================
  Widget _compactBottomCard(
    BuildContext context,
    String title,
    String imagePath,
    Color color,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    imagePath,
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.image_not_supported, color: color, size: 16),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonSnackbar(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName - Coming Soon!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==================== NOTIFICATION SHEET (UNCHANGED) ====================
  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F6),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Latest Announcement",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnnouncementScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('swalathmajlis')
                      .doc('iM6QRMlgUuWNbUdgQ0')
                      .collection('announcements')
                      .orderBy('createdAt', descending: true)
                      .limit(1)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 40,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No announcements",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final latestDoc = snapshot.data!.docs.first;
                    final data = latestDoc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'New Announcement';
                    final message = data['message'] ?? '';
                    final timestamp = data['createdAt'] as Timestamp?;
                    final timeAgo = timestamp != null
                        ? _getTimeAgo(timestamp.toDate())
                        : '';
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.campaign_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      if (timeAgo.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          timeAgo,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // ==================== HEADER (UNCHANGED) ====================
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.surfaceContainerHighest,
            width: 0.8,
          ),
        ),
        child: SizedBox(
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  "Swalath Majlis",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/masjid.png',
                      width: 38,
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 🎯 LIVE STREAMS SECTION (UNCHANGED) ====================
  Widget _buildLiveStreamsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('live_stream_visibility')
          .snapshots(),
      builder: (context, visibilitySnapshot) {
        bool isThursdayVisible = true;
        bool isSpecialDayDuasVisible = true;

        if (visibilitySnapshot.hasData && visibilitySnapshot.data!.exists) {
          final data = visibilitySnapshot.data!.data() as Map<String, dynamic>?;
          isThursdayVisible = data?['isVisible'] ?? true;
          isSpecialDayDuasVisible = data?['isSpecialDayDuasVisible'] ?? true;
        }

        int visibleCardCount = 0;
        if (isThursdayVisible) visibleCardCount++;
        if (isSpecialDayDuasVisible) visibleCardCount++;
        visibleCardCount++;

        if (isThursdayVisible && !isSpecialDayDuasVisible) {
          return _ThursdayCardSlider(
            thursdayCard: _buildYouTubeLiveCard(context),
            quranCard: _build247QuranCard(context),
            screenWidth: screenWidth,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visibleCardCount > 1) ...[
              SizedBox(
                height: 140,
                child: AutoSlideListView(
                  screenWidth: screenWidth,
                  thursdayCard:
                      isThursdayVisible ? _buildYouTubeLiveCard(context) : null,
                  specialDayDuasCard: isSpecialDayDuasVisible
                      ? _buildSpecialDayDuasCard(context)
                      : null,
                  quranCard: _build247QuranCard(context),
                ),
              ),
            ] else if (isThursdayVisible) ...[
              SizedBox(height: 140, child: _buildYouTubeLiveCard(context)),
            ] else if (isSpecialDayDuasVisible) ...[
              SizedBox(height: 140, child: _buildSpecialDayDuasCard(context)),
            ] else ...[
              SizedBox(height: 140, child: _build247QuranCard(context)),
            ],
          ],
        );
      },
    );
  }

  // ==================== 🎥 YOUTUBE LIVE CARD (UNCHANGED) ====================
  Widget _buildYouTubeLiveCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('video_stream_settings')
          .snapshots(),
      builder: (context, snapshot) {
        String videoId = '4iKp91iLzwo';
        String title = 'Live Stream';
        bool isLive = true;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          videoId = data['videoId']?.toString() ?? videoId;
          title = data['title']?.toString() ?? title;
          isLive = data['isLive'] ?? true;
        }

        if (!isLive) {
          return Container(
            width: screenWidth - 32,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFC62828), Color(0xFFE53935)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'Stream Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          );
        }

        final controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            showLiveFullscreenButton: true,
            enableCaption: false,
            isLive: false,
          ),
        );

        return Container(
          key: ValueKey(videoId),
          width: screenWidth - 32,
          height: 140,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFC62828), Color(0xFFE53935)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: YoutubePlayer(
                    controller: controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.red,
                    progressColors: const ProgressBarColors(
                      playedColor: Colors.red,
                      handleColor: Colors.redAccent,
                    ),
                    bottomActions: const [
                      CurrentPosition(),
                      ProgressBar(isExpanded: true),
                      RemainingDuration(),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== SPECIAL DAY DUAS CARD (UNCHANGED) ====================
  Widget _buildSpecialDayDuasCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('special_day_duas')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        String heading = 'Special Day Duas';
        String activeDocId = '';
        Map<String, dynamic> activeData = {};

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc = snapshot.data!.docs.first;
          activeDocId = doc.id;
          activeData = doc.data() as Map<String, dynamic>;
          heading = activeData['heading'] ?? 'Special Day Dua';
        }

        return GestureDetector(
          onTap: () {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpecialDayDuaDetailScreen(
                    docId: activeDocId,
                    data: activeData,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No active Special Day Dua available'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Container(
            width: screenWidth - 32,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 10,
                  top: 10,
                  child: Icon(
                    Icons.event_available_rounded,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.event_available_rounded,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "SPECIAL DAY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              heading,
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Tap to read",
                              style: textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==================== QURAN CARD (UNCHANGED) ====================
  Widget _build247QuranCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('app_settings')
          .doc('quran_stream_settings')
          .snapshots(),
      builder: (context, settingsSnapshot) {
        const defaultTitle = '24/7 Quran Recitation';

        String streamTitle = defaultTitle;
        bool isEnabled = true;

        if (settingsSnapshot.hasData && settingsSnapshot.data!.exists) {
          final data = settingsSnapshot.data!.data() as Map<String, dynamic>?;
          streamTitle = data?['title'] ?? streamTitle;
          isEnabled = data?['isEnabled'] ?? true;
        }

        if (!isEnabled) {
          return const SizedBox.shrink();
        }

        return Container(
          width: screenWidth - 32,
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.9),
                colorScheme.secondary.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: _QuranAudioPlayer(streamUrl: '', streamTitle: streamTitle),
        );
      },
    );
  }

  // ==================== SECTION (UNCHANGED) ====================
  Widget _buildSection(BuildContext context, String title, List<Widget> cards) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
          children: cards,
        ),
      ],
    );
  }

  // ==================== CARD (UNCHANGED) ====================
  Widget _card(
    BuildContext context,
    String title,
    String imagePath,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.surfaceContainerHighest,
            width: 0.8,
          ),
        ),
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image_not_supported,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoLiveStreamSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('No live stream at the moment. Check back later.'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ==================== AUTO-SLIDE LIST VIEW (UNCHANGED) ====================
class AutoSlideListView extends StatefulWidget {
  final double screenWidth;
  final Widget? thursdayCard;
  final Widget? specialDayDuasCard;
  final Widget quranCard;

  const AutoSlideListView({
    super.key,
    required this.screenWidth,
    this.thursdayCard,
    this.specialDayDuasCard,
    required this.quranCard,
  });

  @override
  State<AutoSlideListView> createState() => _AutoSlideListViewState();
}

class _AutoSlideListViewState extends State<AutoSlideListView> {
  late ScrollController _scrollController;
  int _currentIndex = 0;
  bool _isAutoSliding = true;
  int _slideCount = 0;
  final int _maxSlides = 6;

  List<Widget> get _visibleCards {
    final List<Widget> cards = [];
    if (widget.thursdayCard != null) cards.add(widget.thursdayCard!);
    if (widget.specialDayDuasCard != null) {
      cards.add(widget.specialDayDuasCard!);
    }
    cards.add(widget.quranCard);
    return cards;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted || !_isAutoSliding || _slideCount >= _maxSlides) return;

      final screenWidth = widget.screenWidth;
      final cardWidth = screenWidth - 32;
      const gapWidth = 16.0;

      final visibleCount = _visibleCards.length;
      final nextIndex = (_currentIndex + 1) % visibleCount;

      double scrollPosition = 0;
      for (int i = 1; i <= nextIndex; i++) {
        scrollPosition += cardWidth + gapWidth;
      }

      _scrollController
          .animateTo(
        scrollPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      )
          .then((_) {
        setState(() {
          _currentIndex = nextIndex;
          _slideCount++;
        });

        if (_slideCount < _maxSlides) {
          _startAutoSlide();
        }
      });
    });
  }

  @override
  void dispose() {
    _isAutoSliding = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> cards = [];

    for (int i = 0; i < _visibleCards.length; i++) {
      cards.add(_visibleCards[i]);
      if (i < _visibleCards.length - 1) {
        cards.add(const SizedBox(width: 16));
      }
    }

    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      children: cards,
    );
  }
}

// ==================== THURSDAY CARD SLIDER (UNCHANGED) ====================
class _ThursdayCardSlider extends StatefulWidget {
  final Widget thursdayCard;
  final Widget quranCard;
  final double screenWidth;

  const _ThursdayCardSlider({
    required this.thursdayCard,
    required this.quranCard,
    required this.screenWidth,
  });

  @override
  State<_ThursdayCardSlider> createState() => _ThursdayCardSliderState();
}

class _ThursdayCardSliderState extends State<_ThursdayCardSlider> {
  late ScrollController _scrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  void _slideToCard(int index) {
    if (index < 0 || index > 1) return;

    final cardWidth = widget.screenWidth - 32;
    const gapWidth = 16.0;
    double scrollPosition = index == 0 ? 0 : cardWidth + gapWidth;

    _scrollController.animateTo(
      scrollPosition,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = widget.screenWidth - 32;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 140,
          child: ListView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              SizedBox(width: cardWidth, child: widget.thursdayCard),
              const SizedBox(width: 16),
              SizedBox(width: cardWidth, child: widget.quranCard),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _currentIndex > 0 ? () => _slideToCard(0) : null,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _currentIndex > 0
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: _currentIndex > 0 ? Colors.white : Colors.grey,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _currentIndex < 1 ? () => _slideToCard(1) : null,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _currentIndex < 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: _currentIndex < 1 ? Colors.white : Colors.grey,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ==================== QURAN AUDIO PLAYER (UNCHANGED) ====================
class _QuranAudioPlayer extends StatefulWidget {
  final String streamUrl;
  final String streamTitle;

  const _QuranAudioPlayer({required this.streamUrl, required this.streamTitle});

  @override
  State<_QuranAudioPlayer> createState() => _QuranAudioPlayerState();
}

class _QuranAudioPlayerState extends State<_QuranAudioPlayer>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlaying = false;
  bool _isStopped = true;
  String _errorMessage = '';
  String _currentStatus = '⏹️ Stopped';

  int _currentSurah = 1;
  final int _totalSurahs = 114;

  final List<Map<String, String>> _surahNames = [
    {'number': '1', 'arabic': 'الفاتحة', 'english': 'Al-Fatihah'},
    {'number': '2', 'arabic': 'البقرة', 'english': 'Al-Baqarah'},
    {'number': '3', 'arabic': 'آل عمران', 'english': 'Al-Imran'},
    {'number': '4', 'arabic': 'النساء', 'english': 'An-Nisa'},
    {'number': '5', 'arabic': 'المائدة', 'english': 'Al-Maidah'},
    {'number': '6', 'arabic': 'الأنعام', 'english': 'Al-An\'am'},
    {'number': '7', 'arabic': 'الأعراف', 'english': 'Al-A\'raf'},
    {'number': '8', 'arabic': 'الأنفال', 'english': 'Al-Anfal'},
    {'number': '9', 'arabic': 'التوبة', 'english': 'At-Tawbah'},
    {'number': '10', 'arabic': 'يونس', 'english': 'Yunus'},
    {'number': '11', 'arabic': 'هود', 'english': 'Hud'},
    {'number': '12', 'arabic': 'يوسف', 'english': 'Yusuf'},
    {'number': '13', 'arabic': 'الرعد', 'english': 'Ar-Ra\'d'},
    {'number': '14', 'arabic': 'إبراهيم', 'english': 'Ibrahim'},
    {'number': '15', 'arabic': 'الحجر', 'english': 'Al-Hijr'},
    {'number': '16', 'arabic': 'النحل', 'english': 'An-Nahl'},
    {'number': '17', 'arabic': 'الإسراء', 'english': 'Al-Isra'},
    {'number': '18', 'arabic': 'الكهف', 'english': 'Al-Kahf'},
    {'number': '19', 'arabic': 'مريم', 'english': 'Maryam'},
    {'number': '20', 'arabic': 'طه', 'english': 'Taha'},
    {'number': '21', 'arabic': 'الأنبياء', 'english': 'Al-Anbiya'},
    {'number': '22', 'arabic': 'الحج', 'english': 'Al-Hajj'},
    {'number': '23', 'arabic': 'المؤمنون', 'english': 'Al-Mu\'minun'},
    {'number': '24', 'arabic': 'النور', 'english': 'An-Nur'},
    {'number': '25', 'arabic': 'الفرقان', 'english': 'Al-Furqan'},
    {'number': '26', 'arabic': 'الشعراء', 'english': 'Ash-Shu\'ara'},
    {'number': '27', 'arabic': 'النمل', 'english': 'An-Naml'},
    {'number': '28', 'arabic': 'القصص', 'english': 'Al-Qasas'},
    {'number': '29', 'arabic': 'العنكبوت', 'english': 'Al-Ankabut'},
    {'number': '30', 'arabic': 'الروم', 'english': 'Ar-Rum'},
    {'number': '31', 'arabic': 'لقمان', 'english': 'Luqman'},
    {'number': '32', 'arabic': 'السجدة', 'english': 'As-Sajdah'},
    {'number': '33', 'arabic': 'الأحزاب', 'english': 'Al-Ahzab'},
    {'number': '34', 'arabic': 'سبأ', 'english': 'Saba'},
    {'number': '35', 'arabic': 'فاطر', 'english': 'Fatir'},
    {'number': '36', 'arabic': 'يس', 'english': 'Yasin'},
    {'number': '37', 'arabic': 'الصافات', 'english': 'As-Saffat'},
    {'number': '38', 'arabic': 'ص', 'english': 'Sad'},
    {'number': '39', 'arabic': 'الزمر', 'english': 'Az-Zumar'},
    {'number': '40', 'arabic': 'غافر', 'english': 'Ghafir'},
    {'number': '41', 'arabic': 'فصلت', 'english': 'Fussilat'},
    {'number': '42', 'arabic': 'الشورى', 'english': 'Ash-Shura'},
    {'number': '43', 'arabic': 'الزخرف', 'english': 'Az-Zukhruf'},
    {'number': '44', 'arabic': 'الدخان', 'english': 'Ad-Dukhan'},
    {'number': '45', 'arabic': 'الجاثية', 'english': 'Al-Jathiyah'},
    {'number': '46', 'arabic': 'الأحقاف', 'english': 'Al-Ahqaf'},
    {'number': '47', 'arabic': 'محمد', 'english': 'Muhammad'},
    {'number': '48', 'arabic': 'الفتح', 'english': 'Al-Fath'},
    {'number': '49', 'arabic': 'الحجرات', 'english': 'Al-Hujurat'},
    {'number': '50', 'arabic': 'ق', 'english': 'Qaf'},
    {'number': '51', 'arabic': 'الذاريات', 'english': 'Adh-Dhariyat'},
    {'number': '52', 'arabic': 'الطور', 'english': 'At-Tur'},
    {'number': '53', 'arabic': 'النجم', 'english': 'An-Najm'},
    {'number': '54', 'arabic': 'القمر', 'english': 'Al-Qamar'},
    {'number': '55', 'arabic': 'الرحمن', 'english': 'Ar-Rahman'},
    {'number': '56', 'arabic': 'الواقعة', 'english': 'Al-Waqi\'ah'},
    {'number': '57', 'arabic': 'الحديد', 'english': 'Al-Hadid'},
    {'number': '58', 'arabic': 'المجادلة', 'english': 'Al-Mujadilah'},
    {'number': '59', 'arabic': 'الحشر', 'english': 'Al-Hashr'},
    {'number': '60', 'arabic': 'الممتحنة', 'english': 'Al-Mumtahanah'},
    {'number': '61', 'arabic': 'الصف', 'english': 'As-Saff'},
    {'number': '62', 'arabic': 'الجمعة', 'english': 'Al-Jumu\'ah'},
    {'number': '63', 'arabic': 'المنافقون', 'english': 'Al-Munafiqun'},
    {'number': '64', 'arabic': 'التغابن', 'english': 'At-Taghabun'},
    {'number': '65', 'arabic': 'الطلاق', 'english': 'At-Talaq'},
    {'number': '66', 'arabic': 'التحريم', 'english': 'At-Tahrim'},
    {'number': '67', 'arabic': 'الملك', 'english': 'Al-Mulk'},
    {'number': '68', 'arabic': 'القلم', 'english': 'Al-Qalam'},
    {'number': '69', 'arabic': 'الحاقة', 'english': 'Al-Haqqah'},
    {'number': '70', 'arabic': 'المعارج', 'english': 'Al-Ma\'arij'},
    {'number': '71', 'arabic': 'نوح', 'english': 'Nuh'},
    {'number': '72', 'arabic': 'الجن', 'english': 'Al-Jinn'},
    {'number': '73', 'arabic': 'المزمل', 'english': 'Al-Muzzammil'},
    {'number': '74', 'arabic': 'المدثر', 'english': 'Al-Muddaththir'},
    {'number': '75', 'arabic': 'القيامة', 'english': 'Al-Qiyamah'},
    {'number': '76', 'arabic': 'الإنسان', 'english': 'Al-Insan'},
    {'number': '77', 'arabic': 'المرسلات', 'english': 'Al-Mursalat'},
    {'number': '78', 'arabic': 'النبأ', 'english': 'An-Naba'},
    {'number': '79', 'arabic': 'النازعات', 'english': 'An-Nazi\'at'},
    {'number': '80', 'arabic': 'عبس', 'english': 'Abasa'},
    {'number': '81', 'arabic': 'التكوير', 'english': 'At-Takwir'},
    {'number': '82', 'arabic': 'الانفطار', 'english': 'Al-Infitar'},
    {'number': '83', 'arabic': 'المطففين', 'english': 'Al-Mutaffifin'},
    {'number': '84', 'arabic': 'الانشقاق', 'english': 'Al-Inshiqaq'},
    {'number': '85', 'arabic': 'البروج', 'english': 'Al-Buruj'},
    {'number': '86', 'arabic': 'الطارق', 'english': 'At-Tariq'},
    {'number': '87', 'arabic': 'الأعلى', 'english': 'Al-A\'la'},
    {'number': '88', 'arabic': 'الغاشية', 'english': 'Al-Ghashiyah'},
    {'number': '89', 'arabic': 'الفجر', 'english': 'Al-Fajr'},
    {'number': '90', 'arabic': 'البلد', 'english': 'Al-Balad'},
    {'number': '91', 'arabic': 'الشمس', 'english': 'Ash-Shams'},
    {'number': '92', 'arabic': 'الليل', 'english': 'Al-Layl'},
    {'number': '93', 'arabic': 'الضحى', 'english': 'Ad-Duha'},
    {'number': '94', 'arabic': 'الشرح', 'english': 'Ash-Sharh'},
    {'number': '95', 'arabic': 'التين', 'english': 'At-Tin'},
    {'number': '96', 'arabic': 'العلق', 'english': 'Al-Alaq'},
    {'number': '97', 'arabic': 'القدر', 'english': 'Al-Qadr'},
    {'number': '98', 'arabic': 'البينة', 'english': 'Al-Bayyinah'},
    {'number': '99', 'arabic': 'الزلزلة', 'english': 'Az-Zalzalah'},
    {'number': '100', 'arabic': 'العاديات', 'english': 'Al-Adiyat'},
    {'number': '101', 'arabic': 'القارعة', 'english': 'Al-Qari\'ah'},
    {'number': '102', 'arabic': 'التكاثر', 'english': 'At-Takathur'},
    {'number': '103', 'arabic': 'العصر', 'english': 'Al-Asr'},
    {'number': '104', 'arabic': 'الهمزة', 'english': 'Al-Humazah'},
    {'number': '105', 'arabic': 'الفيل', 'english': 'Al-Fil'},
    {'number': '106', 'arabic': 'قريش', 'english': 'Quraysh'},
    {'number': '107', 'arabic': 'الماعون', 'english': 'Al-Ma\'un'},
    {'number': '108', 'arabic': 'الكوثر', 'english': 'Al-Kawthar'},
    {'number': '109', 'arabic': 'الكافرون', 'english': 'Al-Kafirun'},
    {'number': '110', 'arabic': 'النصر', 'english': 'An-Nasr'},
    {'number': '111', 'arabic': 'المسد', 'english': 'Al-Masad'},
    {'number': '112', 'arabic': 'الإخلاص', 'english': 'Al-Ikhlas'},
    {'number': '113', 'arabic': 'الفلق', 'english': 'Al-Falaq'},
    {'number': '114', 'arabic': 'الناس', 'english': 'An-Nas'},
  ];

  int _currentReciterIndex = 0;
  final List<Map<String, String>> _reciters = [
    {'name': 'Mishary Alafasy', 'baseUrl': 'https://server8.mp3quran.net/afs/'},
    {
      'name': 'Yasser Al-Dosari',
      'baseUrl': 'https://server11.mp3quran.net/yasser/',
    },
    {
      'name': 'Nasser Al-Qatami',
      'baseUrl': 'https://server6.mp3quran.net/qtm/',
    },
    {'name': 'Fares Abbad', 'baseUrl': 'https://server8.mp3quran.net/frs_a/'},
    {
      'name': 'Maher Al Muaiqly',
      'baseUrl': 'https://server12.mp3quran.net/maher/',
    },
    {
      'name': 'Mohamed Siddiq',
      'baseUrl': 'https://server10.mp3quran.net/minsh/',
    },
    {
      'name': 'Ibrahim Al-Akdar',
      'baseUrl': 'https://server6.mp3quran.net/akdr/',
    },
    {
      'name': 'Abu Bakr Al-Shatri',
      'baseUrl': 'https://server11.mp3quran.net/shatri/',
    },
    {
      'name': 'Saud Al-Shuraim',
      'baseUrl': 'https://server7.mp3quran.net/shur/',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      _audioPlayer = AudioPlayer();

      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            _isLoading = state.processingState == ProcessingState.loading;
          });

          if (state.processingState == ProcessingState.completed &&
              !_isStopped) {
            _playNextSurah();
          }
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (position.inSeconds > 0 && mounted) {
          if (_currentStatus != '▶️ Playing') {
            setState(() {
              _currentStatus = '▶️ Playing';
            });
          }
        }
      });

      _isLoading = false;
      _isStopped = true;
      _currentStatus = '⏹️ Stopped';
    } catch (e) {
      print('❌ Init error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize';
      });
    }
  }

  String _getCurrentUrl() {
    final surahNumber = _currentSurah.toString().padLeft(3, '0');
    final reciter = _reciters[_currentReciterIndex];
    return '${reciter['baseUrl']}$surahNumber.mp3';
  }

  Future<void> _playCurrentSurah() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _isStopped = false;
        _currentStatus = 'Loading Surah $_currentSurah...';
      });

      final url = _getCurrentUrl();
      final reciterName = _reciters[_currentReciterIndex]['name']!;

      print('🎯 Playing: $reciterName - Surah $_currentSurah');
      print('📡 URL: $url');

      await _audioPlayer.stop();
      await _audioPlayer.setUrl(url);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();

      print('✅ Now playing: Surah $_currentSurah');
    } catch (e) {
      print('❌ Play error: $e');
      _playNextSurah();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _playNextSurah() {
    if (_isStopped) return;

    if (_currentSurah < _totalSurahs) {
      setState(() {
        _currentSurah++;
      });
      _playCurrentSurah();
    } else {
      setState(() {
        _currentSurah = 1;
      });
      _playCurrentSurah();
    }
  }

  void _playPreviousSurah() {
    if (_isStopped) {
      if (_currentSurah > 1) {
        setState(() {
          _currentSurah--;
        });
      } else {
        setState(() {
          _currentSurah = _totalSurahs;
        });
      }
      return;
    }

    if (_currentSurah > 1) {
      setState(() {
        _currentSurah--;
      });
      _playCurrentSurah();
    } else {
      setState(() {
        _currentSurah = _totalSurahs;
      });
      _playCurrentSurah();
    }
  }

  void _switchReciter(int index) {
    if (index == _currentReciterIndex) return;

    setState(() {
      _currentReciterIndex = index;
    });

    if (!_isStopped) {
      _playCurrentSurah();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to ${_reciters[index]['name']}'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _jumpToSurah(int surahNumber) {
    if (surahNumber == _currentSurah) return;

    setState(() {
      _currentSurah = surahNumber;
    });

    if (!_isStopped) {
      _playCurrentSurah();
    }

    final surahName = _surahNames[surahNumber - 1]['arabic'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Jumped to Surah $surahNumber - $surahName'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _togglePlayStop() async {
    try {
      if (_isStopped) {
        setState(() {
          _isStopped = false;
        });
        await _playCurrentSurah();
      } else if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
          _currentStatus = '⏸️ Paused';
        });
      } else {
        await _audioPlayer.play();
        setState(() {
          _isPlaying = true;
          _currentStatus = '▶️ Playing';
        });
      }
    } catch (e) {
      print('❌ Play/Stop error: $e');
    }
  }

  Future<void> _fullStop() async {
    try {
      await _audioPlayer.stop();
      setState(() {
        _isStopped = true;
        _isPlaying = false;
        _currentStatus = '⏹️ Stopped';
      });
    } catch (e) {
      print('❌ Stop error: $e');
    }
  }

  Future<void> _start() async {
    try {
      setState(() {
        _isStopped = false;
      });
      await _playCurrentSurah();
    } catch (e) {
      print('❌ Start error: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isStopped
                        ? Icons.stop_circle_rounded
                        : (_isPlaying
                            ? Icons.play_circle_fill_rounded
                            : Icons.pause_circle_filled_rounded),
                    color: _isStopped
                        ? Colors.orange
                        : (_isPlaying ? Colors.green : Colors.white),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 160,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _reciters[_currentReciterIndex]['name'],
                            isDense: true,
                            icon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            dropdownColor: Colors.white,
                            items: _reciters.map((reciter) {
                              final isSelected = _currentReciterIndex ==
                                  _reciters.indexOf(reciter);
                              return DropdownMenuItem<String>(
                                value: reciter['name'],
                                child: Text(
                                  reciter['name']!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
                                        : const Color(0xFF333333),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              final index = _reciters.indexWhere(
                                (r) => r['name'] == value,
                              );
                              if (index != -1) {
                                _switchReciter(index);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _isStopped
                              ? Colors.orange
                              : (_isPlaying ? Colors.green : Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isStopped
                              ? 'STOP'
                              : (_isPlaying ? 'Playing' : 'Loading'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 135,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _currentSurah,
                      isDense: true,
                      icon: const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      dropdownColor: Colors.white,
                      items: _surahNames.map((surah) {
                        final surahNumber = int.parse(surah['number']!);
                        final arabicName = surah['arabic']!;
                        final isSelected = _currentSurah == surahNumber;
                        return DropdownMenuItem<int>(
                          value: surahNumber,
                          child: Row(
                            children: [
                              Text(
                                '${surah['number']}.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                arabicName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : const Color(0xFF1A472A),
                                  fontFamily: 'Amiri',
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _jumpToSurah(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_hasError) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconButton(
                    onPressed: _playPreviousSurah,
                    icon: const Icon(Icons.skip_previous, color: Colors.white),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _togglePlayStop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isStopped
                          ? Colors.red
                          : (_isPlaying ? Colors.green : Colors.red),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 40),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isStopped
                              ? Icons.play_arrow_rounded
                              : (_isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded),
                          size: 22,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isStopped
                              ? 'Start'
                              : (_isPlaying ? 'Pause' : 'Resume'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconButton(
                    onPressed: _playNextSurah,
                    icon: const Icon(Icons.skip_next, color: Colors.white),
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
