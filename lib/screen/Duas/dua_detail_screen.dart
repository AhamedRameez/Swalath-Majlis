// lib/screen/dua_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; // Add this import
import '../category_duas_screen.dart';

class DuaDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const DuaDetailScreen({super.key, required this.data});

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

  // Helper method to safely access document fields
  String _getFieldSafe(String fieldName, String defaultValue) {
    try {
      if (data[fieldName] != null) {
        final value = data[fieldName];
        return value?.toString() ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // 🔥 NEW: Professional share function (copied from RamzanDuaDetailScreen)
  Future<void> _shareDua(BuildContext context) async {
    final heading = _getFieldSafe('heading', 'Untitled Dua');
    final arabic = _getFieldSafe('arabic', '');
    final malayalam = _getFieldSafe('malayalam', '');
    final english = _getFieldSafe('english', '');
    final category = _getFieldSafe('category', '');

    final StringBuffer shareText = StringBuffer();

    // Clean, professional header
    shareText.writeln('🕌 $heading');
    shareText.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━');
    shareText.writeln('📂 $category');
    shareText.writeln();

    // Arabic section
    if (arabic.isNotEmpty) {
      shareText.writeln('📖 *Arabic*');
      shareText.writeln(arabic);
      shareText.writeln();
    }

    // English section
    if (english.isNotEmpty) {
      shareText.writeln('📖 *English*');
      shareText.writeln(english);
      shareText.writeln();
    }

    // Malayalam section
    if (malayalam.isNotEmpty) {
      shareText.writeln('📖 *Malayalam*');
      shareText.writeln(malayalam);
      shareText.writeln();
    }

    shareText.writeln('');
    shareText.writeln('       📲  DOWNLOAD OUR APP  📲       ');
    shareText.writeln('         ═════════════════════        ');
    shareText.writeln();

    shareText.writeln('— Shared from Swalath Majlis App');
    shareText.writeln('🔗 *Click here to download:*');
    shareText.writeln(
      '📱 https://play.google.com/store/apps/details?id=com.saktechnosolution.swalathmajlis',
    );

    try {
      await Share.share(shareText.toString(), subject: heading);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✨ Shared successfully! Jazakallah! ✨',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error if sharing fails
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Could not share. Please try again.',
                    style: TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildMeaningCard(String title, String content, IconData icon) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card header with icon and title
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(icon, color: accentColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Divider
              Container(height: 1, color: dividerColor.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              // Content text
              Text(
                content,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // SAFELY access document fields
    final heading = _getFieldSafe('heading', 'Untitled Dua');
    final arabic = _getFieldSafe('arabic', '');
    final english = _getFieldSafe('english', '');
    final malayalam = _getFieldSafe('malayalam', '');
    final description = _getFieldSafe('description', '');
    final author = _getFieldSafe('author', '');
    final category = _getFieldSafe('category', '');

    // 🔥 FIX: Check if ANY content exists (arabic OR malayalam OR english)
    final hasAnyContent =
        arabic.isNotEmpty || malayalam.isNotEmpty || english.isNotEmpty;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          heading,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        // 🔥 NEW: Add share button in app bar
        actions: [
          // Share button with tooltip
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share this dua',
            onPressed: hasAnyContent
                ? () => _shareDua(context)
                : null, // Disable if no content
          ),
        ],
      ),
      body: !hasAnyContent
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Content Not Available',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The dua content could not be loaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge at the top
                    if (category.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CategoryDuasScreen(category: category),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.category_rounded,
                                color: primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 🔥 FIX: Show Arabic section ONLY if it has content
                    if (arabic.isNotEmpty) ...[
                      Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 0.5,
                        shadowColor: Colors.black.withValues(alpha: 0.05),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: dividerColor.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Decorative header with accent color
                                Container(
                                  width: 60,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: const EdgeInsets.only(
                                    bottom: 20,
                                    top: 8,
                                  ),
                                ),
                                // Arabic text
                                Text(
                                  arabic,
                                  textAlign:
                                      TextAlign.right, // Changed from center
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize:
                                        22, // Slightly reduced for better fit
                                    height: 1.8,
                                    fontFamily: 'Scheherazade',
                                    color: textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Decorative footer
                                Container(
                                  width: 60,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  margin: const EdgeInsets.only(
                                    top: 20,
                                    bottom: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // English Meaning Card
                    if (english.isNotEmpty) ...[
                      _buildMeaningCard(
                        'English Meaning',
                        english,
                        Icons.language_rounded,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Malayalam Meaning Card
                    if (malayalam.isNotEmpty) ...[
                      _buildMeaningCard(
                        'Malayalam Meaning',
                        malayalam,
                        Icons.translate_rounded,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Description Section (if available)
                    if (description.isNotEmpty) ...[
                      Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        elevation: 0.5,
                        shadowColor: Colors.black.withValues(alpha: 0.05),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: dividerColor.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Description header
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color:
                                            primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                              alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.description_rounded,
                                        color: primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Explanation',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Divider
                                Container(
                                  height: 1,
                                  color: dividerColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 16),
                                // Description text
                                Text(
                                  description,
                                  style: const TextStyle(
                                    color: textSecondary,
                                    fontSize: 15,
                                    height: 1.6,
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Author & Category Section
                    if (author.isNotEmpty)
                      Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 0.3,
                        shadowColor: Colors.black.withValues(alpha: 0.03),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: dividerColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.person_outline_rounded,
                                  color: textTertiary,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Author: $author',
                                    style: const TextStyle(
                                      color: textTertiary,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'Poppins',
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Add bottom padding for better scrolling
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
