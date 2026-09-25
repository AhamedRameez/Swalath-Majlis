// lib/screen/quran_select_screen.dart
import 'package:flutter/material.dart';
import 'quran_screen.dart';
import 'quran_view.dart';

class QuranSelectScreen extends StatelessWidget {
  const QuranSelectScreen({super.key});

  // Your app theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  // 🔥 NEW: tharjeem color
  static const Color tharjeemColor = Color(0xFF1A472A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select Quran',
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 32,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose Quran Mode',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Option 1: PDF Quran
            _buildOption(
              icon: Icons.picture_as_pdf_rounded,
              title: 'PDF Quran',
              subtitle: 'Page-by-page viewing like a physical Mushaf',
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const QuranViewScreen(
                            title: 'Special Quran',
                            pdfPath: 'assets/pdfs/quran.pdf',
                          )),
                );
              },
            ),

            const SizedBox(height: 12),

            // Option 2: Default Quran
            // 🔥 UPDATED: subtitle now mentions Tharjeem + added badges
            _buildOption(
              icon: Icons.menu_book_rounded,
              title: 'Default Quran',
              subtitle:
                  'Adjustable font, bookmarks, surah navigation & Tharjeem (meaning)',
              color: primaryColor,
              // 🔥 NEW: feature tags
              tags: const [
                _FeatureTag(
                  icon: Icons.translate_rounded,
                  label: 'Tharjeem',
                  color: tharjeemColor,
                ),
                _FeatureTag(
                  icon: Icons.bookmark_rounded,
                  label: 'Bookmarks',
                  color: accentColor,
                ),
                _FeatureTag(
                  icon: Icons.text_fields_rounded,
                  label: 'Font Size',
                  color: primaryColor,
                ),
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuranScreen()),
                );
              },
            ),

            const SizedBox(height: 30),

            // Info note
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: textSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can switch between modes anytime',
                      style: TextStyle(
                        fontSize: 11,
                        color: textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 UPDATED: added optional `tags` parameter
  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    List<_FeatureTag>? tags, // 🔥 NEW: optional tags
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: textSecondary,
                      ),
                    ),
                    // 🔥 NEW: feature tags row (only if tags provided)
                    if (tags != null && tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            tags.map((tag) => _buildFeatureTag(tag)).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 NEW: build a single feature tag chip
  Widget _buildFeatureTag(_FeatureTag tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tag.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tag.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tag.icon, size: 10, color: tag.color),
          const SizedBox(width: 4),
          Text(
            tag.label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: tag.color,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// 🔥 NEW: small model for feature tags
class _FeatureTag {
  final IconData icon;
  final String label;
  final Color color;
  const _FeatureTag({
    required this.icon,
    required this.label,
    required this.color,
  });
}
