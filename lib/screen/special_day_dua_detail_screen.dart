// lib/screen/user/special_day_dua_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpecialDayDuaDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const SpecialDayDuaDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<SpecialDayDuaDetailScreen> createState() =>
      _SpecialDayDuaDetailScreenState();
}

class _SpecialDayDuaDetailScreenState extends State<SpecialDayDuaDetailScreen> {
  // Theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color arabicTextColor = Color(0xFF1A472A);

  @override
  Widget build(BuildContext context) {
    final heading = widget.data['heading'] ?? '';
    final title = widget.data['title'] ?? '';
    final paragraph = widget.data['paragraph'] ?? '';
    final imageUrl = widget.data['imageUrl'] ?? '';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          heading.isNotEmpty ? heading : 'Special Day Dua',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image at the top
            if (imageUrl.isNotEmpty)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_rounded,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // White Card Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Card
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        heading,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle (if exists)
                  if (title.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Paragraph Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: arabicTextColor.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: arabicTextColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      paragraph,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        fontFamily: 'Poppins',
                        color: textPrimary,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withValues(alpha: 0.6),
                                accentColor.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'اللهم تقبل منا',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Amiri',
                            color: textTertiary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
