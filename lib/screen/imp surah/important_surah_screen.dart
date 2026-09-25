//lib/screen/important_surah_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'important_surah_detail_screen.dart';

class ImportantSurahScreen extends StatelessWidget {
  const ImportantSurahScreen({super.key});

  // Same color scheme from AyathsScreen
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Important Surahs',
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
        actionsIconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('important_surah')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Surahs...',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Connection Error',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load surahs. Please check your connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Add retry logic if needed
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Try Again',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Surahs Available',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'New surahs will appear here once they are added.',
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
            );
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final data = docs[index];

                // SAFELY access document fields with null checks
                final title = _getFieldSafe(data, 'title', 'Untitled Surah');

                return _buildSurahCard(
                  index: index,
                  data: data,
                  title: title,
                  context: context,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSurahCard({
    required int index,
    required QueryDocumentSnapshot data,
    required String title,
    required BuildContext context,
  }) {
    // SAFELY get optional fields
    final reference = _getFieldSafe(data, 'reference', '');
    // Get subtitle from Firestore
    final subtitle = _getFieldSafe(data, 'subtitle', '');

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImportantSurahDetailScreen(
                title: data['title'],
                subtitle: subtitle, // Fetch from Firestore
                arabic: data['arabic'],
                description: _getFieldSafe(data, 'description', ''),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withValues(alpha: 0.08),
        highlightColor: primaryColor.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge with accent gold
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with primary color
                      Text(
                        title,
                        style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.4,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Reference if available
                      if (reference.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.bookmark_outline_rounded,
                              size: 12,
                              color: textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              reference,
                              style: const TextStyle(
                                color: textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chevron with accent color
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to safely access document fields
  String _getFieldSafe(
    QueryDocumentSnapshot doc,
    String fieldName,
    String defaultValue,
  ) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey(fieldName)) {
        final value = data[fieldName];
        return value?.toString() ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}
