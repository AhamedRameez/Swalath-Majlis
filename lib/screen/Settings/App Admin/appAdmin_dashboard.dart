import 'package:flutter/material.dart';
import '../../user_dashboard.dart';
import 'Q&A/qa_display_screen.dart';
import 'duas/admin_duas_display_screen.dart';
import 'live_special_hide.dart';
import '/services/app_admin_auth_service.dart';
import 'app_admin_quran_edit_screen.dart';
import 'manage_special_day_screen.dart';
import 'namaz_list_screen.dart';
import 'prayer_time_screen.dart';
import 'ramzan/ramzan_dua_display_screen.dart';
import 'ramzan/ramzan_salah_display_screen.dart';
import 'send_announcement_screen.dart';
import 'studies/islamicstudy_display_screen.dart';
import 'swalath/swalath_list_screen.dart';
import 'user_messages_screen.dart';
import 'youtube_video_add_screen.dart';

class AppAdminDashboard extends StatefulWidget {
  const AppAdminDashboard({super.key});

  @override
  State<AppAdminDashboard> createState() => _AppAdminDashboardState();
}

class _AppAdminDashboardState extends State<AppAdminDashboard> {
  // 🎨 Royal Purple & Gold Theme
  static const Color _primaryColor = Color(0xFF3D2A5B);
  static const Color _accentColor = Color(0xFFD4AF37);
  static const Color _backgroundColor = Color(0xFFFAF5FF);
  static const Color _cardColor = Color(0xFFFFFFFF);
  static const Color _textPrimary = Color(0xFF2E1065);
  static const Color _textSecondary = Color(0xFF7E22CE);

  bool _isLoading = true;
  String _adminName = 'App Admin';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    final name = await AppAdminAuthService.getAdminName();
    setState(() {
      _adminName = name ?? 'App Admin';
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout from App Admin dashboard?',
          style: TextStyle(fontSize: 14, color: _textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: _textSecondary),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await AppAdminAuthService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const UserDashboard()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _returnToUserDashboard() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const UserDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'App Admin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded, color: Colors.white),
            onPressed: _returnToUserDashboard,
            tooltip: 'User App',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
      ),
      body: _isLoading ? _buildLoadingState() : _buildDashboardContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          SizedBox(height: 20),
          Text(
            'Loading dashboard...',
            style: TextStyle(fontSize: 14, color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeHeader(),
              const SizedBox(height: 20),
              _buildSectionHeader('Quick Actions', Icons.bolt_rounded),
              const SizedBox(height: 12),
            ]),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0,
            ),
            delegate: SliverChildListDelegate([
              // Row 1 - Core Features
              _buildCompactMenuCard(
                title: 'Announce',
                icon: Icons.campaign_rounded,
                color: const Color(0xFFE53935),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendAnnouncementScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Special Day',
                icon: Icons.handshake_rounded,
                color: const Color(0xFF4CAF50),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageSpecialDayScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Q&A',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF2196F3),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QADisplayScreen()),
                ),
              ),
              // // Row 2
              _buildCompactMenuCard(
                title: 'Quran Edit',
                icon: Icons.image_rounded,
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AppAdminQuranEditScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Prayer',
                icon: Icons.access_time_rounded,
                color: _accentColor,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPrayerTimeScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Salah',
                icon: Icons.message_rounded,
                color: const Color(0xFF9C27B0),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NamazListScreen(),
                  ),
                ),
              ),

              _buildCompactMenuCard(
                title: 'Studies',
                icon: Icons.library_books_rounded,
                color: const Color(0xFF795548),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const IslamicStudyDisplayScreen()),
                ),
              ),

              // Row 4
              _buildCompactMenuCard(
                title: 'Duas',
                icon: Icons.home_work_rounded,
                color: const Color(0xFF607D8B),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AdminDuasDisplayScreen()),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Swalath',
                icon: Icons.link_rounded,
                color: const Color(0xFF3F51B5),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminSwalathListScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Ramazan Dua',
                icon: Icons.star_rounded,
                color: const Color(0xFFFF9800),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RamzanDuaDisplayScreen(),
                  ),
                ),
              ),
              // Row 5
              _buildCompactMenuCard(
                title: 'Ramazan Salah',
                icon: Icons.king_bed_rounded,
                color: const Color(0xFF8BC34A),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RamzanSalahDisplayScreen(),
                  ),
                ),
              ),
              // Row 3
              _buildCompactMenuCard(
                title: 'Live ',
                icon: Icons.edit_note_rounded,
                color: const Color(0xFF00BCD4),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LiveStreamVisibilityScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'LIVE Video',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFE91E63),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const YoutubeVideoAddScreen(),
                  ),
                ),
              ),
              _buildCompactMenuCard(
                title: 'Message',
                icon: Icons.message_rounded,
                color: const Color.fromARGB(255, 92, 105, 255),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserMessagesScreen(),
                  ),
                ),
              ),
              // _buildCompactMenuCard(
              //   title: 'Studies',
              //   icon: Icons.school_rounded,
              //   color: const Color(0xFF009688),
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => const StudiesManageScreen(),
              //     ),
              //   ),
              // ),
              // _buildCompactMenuCard(
              //   title: 'Location',
              //   icon: Icons.location_on_rounded,
              //   color: const Color(0xFFFF5722),
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => const LocationManageScreen(),
              //     ),
              //   ),
              // ),
              // // Row 6 - Last item centered
              // _buildCompactMenuCard(
              //   title: 'More Entry',
              //   icon: Icons.auto_stories_rounded,
              //   color: _primaryColor,
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const MoreManageScreen()),
              //   ),
              // ),
              // _buildCompactMenuCard(
              //   title: 'Adhkar',
              //   icon: Icons.edit_note_rounded,
              //   color: const Color.fromARGB(255, 80, 235, 106),
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (_) => const AdhkarManageScreen()),
              //   ),
              // ),
              // // _buildCompactMenuCard(
              // //   title: 'Events',
              // //   icon: Icons.auto_stories_rounded,
              // //   color: _primaryColor,
              // //   onTap: () => Navigator.push(
              // //     context,
              // //     MaterialPageRoute(builder: (_) => const EventManageScreen()),
              // //   ),
              // // ),
              // _buildCompactMenuCard(
              //   title: 'Jammiyath',
              //   icon: Icons.image_rounded,
              //   color: _primaryColor,
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => const JammiyathManageScreen(),
              //     ),
              //   ),
              // ),
              // // _buildCompactMenuCard(
              // //   title: 'Prayer Time',
              // //   icon: Icons.auto_stories_rounded,
              // //   color: _primaryColor,
              // //   onTap: () => Navigator.push(
              // //     context,
              // //     MaterialPageRoute(
              // //       builder: (_) => const AdminPrayerTimeScreen(),
              // //     ),
              // //   ),
              // // ),
              // _buildCompactMenuCard(
              //   title: 'Password Reset',
              //   icon: Icons.lock_reset_rounded,
              //   color: _primaryColor,
              //   onTap: () => Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => const AppAdminPasswordChangeScreen(),
              //     ),
              //   ),
              // ),
            ]),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _primaryColor.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 26,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _adminName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _accentColor.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_rounded, size: 14, color: _accentColor),
                SizedBox(width: 4),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _accentColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _accentColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: _primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildCompactMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: const Color(0xFFF3E8FF), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      color.withValues(alpha: 0.08)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: color.withValues(alpha: 0.3), width: 1),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  fontFamily: 'Poppins',
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
