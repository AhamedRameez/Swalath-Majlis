//lib/screen/islamic_study_detail_screen.dart
import 'package:flutter/material.dart';

class IslamicStudyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> studyData;
  final String docId;
  final Color categoryColor;

  const IslamicStudyDetailScreen({
    super.key,
    required this.studyData,
    required this.docId,
    required this.categoryColor,
  });

  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color headingColor = Color(0xFFFFA726);

  @override
  Widget build(BuildContext context) {
    final title = studyData['title'] ?? 'Untitled';
    final category = studyData['category'];
    final content = studyData['content'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: categoryColor,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            if (category != null)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_rounded, size: 16, color: categoryColor),
                    const SizedBox(width: 8),
                    Text(
                      category.toString(),
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Main Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                fontFamily: 'Poppins',
                height: 1.3,
              ),
            ),

            const SizedBox(height: 24),

            // Decorative divider
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 24),

            // Content Blocks
            ...content.map((block) {
              final isHeading = block['type'] == 'heading';
              final text = block['text'] ?? '';

              if (text.isEmpty) return const SizedBox.shrink();

              if (isHeading) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 28,
                        decoration: BoxDecoration(
                          color: headingColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            fontFamily: 'Poppins',
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dividerColor),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColor.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: textSecondary,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.justify,
                  ),
                );
              }
            }),

            if (content.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.note_rounded,
                        size: 60,
                        color: textSecondary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No content available',
                        style: TextStyle(color: textSecondary, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom padding
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
