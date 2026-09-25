// lib/screen/settings/app admin/studies/islamicstudy_details_screen.dart
import 'package:flutter/material.dart';

class IslamicStudyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> studyData;
  final String docId;

  const IslamicStudyDetailScreen({
    super.key,
    required this.studyData,
    required this.docId,
  });

  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color headingColor = Color(0xFFFFA726);
  static const Color folderColor = Color(0xFFD4AF37); // Gold for folder

  @override
  Widget build(BuildContext context) {
    final title = studyData['title'] ?? 'Untitled';
    final category = studyData['category'];
    final folder = studyData['folder']; // 🆕 Get folder
    final content = studyData['content'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Folder Badges
            Row(
              children: [
                // Category Badge
                if (category != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.toString(),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                // 🆕 Folder Badge (only if folder exists)
                if (folder != null && folder.toString().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: folderColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: folderColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_rounded,
                          size: 14,
                          color: folderColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          folder.toString(),
                          style: TextStyle(
                            color: folderColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            if (category != null || folder != null) const SizedBox(height: 16),

            // Content Blocks
            ...content.map((block) {
              final isHeading = block['type'] == 'heading';
              final text = block['text'] ?? '';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(isHeading ? 8 : 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHeading ? headingColor : borderColor,
                    width: isHeading ? 2 : 1,
                  ),
                ),
                child: isHeading
                    ? Row(
                        children: [
                          Container(
                            width: 4,
                            height: 24,
                            color: headingColor,
                            margin: const EdgeInsets.only(right: 12),
                          ),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        text,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: textSecondary,
                        ),
                      ),
              );
            }),

            if (content.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No content available',
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
