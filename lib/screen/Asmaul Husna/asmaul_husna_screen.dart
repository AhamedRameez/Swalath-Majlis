// lib/screen/user/asmaul_husna_screen.dart
import 'package:flutter/material.dart';
import 'asmaul_husna_name_screen.dart';
import 'asmaul_husna_tharjim_screen.dart';

class AsmaulHusnaScreen extends StatelessWidget {
  const AsmaulHusnaScreen({super.key});

  // 🎨 Using the same theme colors as UserDashboard
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate responsive sizes
    final horizontalPadding = screenWidth * 0.05; // 5% of screen width

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 6,
        backgroundColor: primaryColor,
        title: const Text(
          'Asmaul Husna',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF5F3EF), backgroundColor, Color(0xFFF5F3EF)],
            ),
          ),
          child: SingleChildScrollView(
            // ✅ Added scrolling
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    padding: EdgeInsets.all(horizontalPadding * 0.8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '99 Names of Allah',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Learn the beautiful names of Allah',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Section Title
                  const Text(
                    "Select Option",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // TWO CARDS - Using AspectRatio for proper sizing
                  AspectRatio(
                    aspectRatio: 2.2, // Controls height relative to width
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMenuCard(
                            context,
                            title: "Allah's Names",
                            subtitle: 'Read 99 names with dua',
                            icon: Icons.menu_book_rounded,
                            color: primaryColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AsmaulHusnaNameScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: _buildMenuCard(
                            context,
                            title: 'With Meaning',
                            subtitle: 'Names with translation',
                            icon: Icons.menu_book_rounded,
                            color: accentColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AsmaulHusnaTharjimScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add bottom padding to prevent overflow
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizes
    final iconSize =
        screenWidth * 0.07; // Slightly smaller - 7% of screen width
    final iconContainerSize = screenWidth * 0.14; // 14% of screen width
    final titleFontSize = screenWidth * 0.035; // 3.5% of screen width
    final subtitleFontSize = screenWidth * 0.028; // 2.8% of screen width

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity, // Takes full height of parent AspectRatio
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dividerColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(iconContainerSize * 0.25),
                ),
                child: Icon(icon, size: iconSize, color: color),
              ),
              SizedBox(height: screenWidth * 0.02), // Responsive spacing
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: titleFontSize,
                  fontFamily: 'Poppins',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),

              SizedBox(height: screenWidth * 0.01),

              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  fontSize: subtitleFontSize,
                  fontFamily: 'Poppins',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
