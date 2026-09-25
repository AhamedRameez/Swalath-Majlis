// lib/screen/qa_detail_screen.dart
import 'package:flutter/material.dart';

class QADetailScreen extends StatelessWidget {
  final Map<String, dynamic> qaData;
  final String docId;

  const QADetailScreen({
    super.key,
    required this.qaData,
    required this.docId,
  });

  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color qaColor = Color(0xFF9C27B0);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    final question = qaData['question'] ?? 'No question';
    final answer = qaData['answer'] ?? '';
    final category = qaData['category'];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 6,
        backgroundColor: qaColor,
        title: const Text(
          'Question & Answer',
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
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_rounded, size: 16, color: accentColor),
                    const SizedBox(width: 8),
                    Text(
                      category.toString(),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Question Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: qaColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: qaColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_rounded, color: qaColor, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Question',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: qaColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                      color: textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Decorative Divider
            Row(
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: qaColor.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 16,
                  color: qaColor.withValues(alpha: 0.5),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Answer Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dividerColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.chat_rounded, color: qaColor, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Answer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: qaColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      fontFamily: 'Poppins',
                      color: textSecondary,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Footer
            Center(
              child: Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      qaColor.withValues(alpha: 0.6),
                      accentColor.withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
