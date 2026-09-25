// lib/screen/user/salah_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import constants

class SalahDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const SalahDetailScreen({super.key, required this.docId, required this.data});

  @override
  State<SalahDetailScreen> createState() => _SalahDetailScreenState();
}

class _SalahDetailScreenState extends State<SalahDetailScreen> {
  // 🎨 Color Theme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color(0xFF1A472A);

  // // 🖼️ Get the image path based on Salah name
  // String get _imagePath {
  //   final name = widget.data['name'] ?? '';

  //   // Check if this Salah has a specific image
  //   if (SalahConstants.salahImages.containsKey(name)) {
  //     return SalahConstants.salahImages[name]!;
  //   }

  //   // Return default image if no specific image found
  //   return SalahConstants.defaultImage;
  // }

  // Language specific styling
  final Map<String, TextStyle> _languageStyles = {
    'Arabic': const TextStyle(
      fontFamily: 'Amiri',
      fontSize: 20,
      height: 1.8,
      color: arabicTextColor,
    ),
    'Malayalam': const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      height: 1.6,
      color: textPrimary,
    ),
    'English': const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      height: 1.6,
      color: textPrimary,
    ),
  };

  final Map<String, Color> _languageColors = {
    'Malayalam': primaryColor,
    'Arabic': arabicTextColor,
    'English': Colors.blue,
  };

  final Map<String, IconData> _languageIcons = {
    'Malayalam': Icons.translate,
    'Arabic': Icons.translate_rounded,
    'English': Icons.language,
  };

  final Map<String, TextAlign> _languageAlign = {
    'Arabic': TextAlign.right,
    'Malayalam': TextAlign.left,
    'English': TextAlign.left,
  };

  final Map<String, TextDirection> _languageDirection = {
    'Arabic': TextDirection.rtl,
    'Malayalam': TextDirection.ltr,
    'English': TextDirection.ltr,
  };

  @override
  Widget build(BuildContext context) {
    final name = widget.data['name'] ?? 'Salah Guide';
    final description = widget.data['description'] ?? '';
    final englishName = widget.data['englishName'] ?? '';
    final List textBlocks = widget.data['textBlocks'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            if (englishName.isNotEmpty)
              Text(
                englishName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('salahs')
            .doc(widget.docId)
            .snapshots(),
        builder: (context, snapshot) {
          // Use live data if available, otherwise use passed data
          Map<String, dynamic> currentData;
          if (snapshot.hasData && snapshot.data!.exists) {
            currentData = snapshot.data!.data() as Map<String, dynamic>;
          } else {
            currentData = widget.data;
          }

          final List currentTextBlocks = currentData['textBlocks'] ?? [];
          final currentName = currentData['name'] ?? 'Salah Guide';
          final currentEnglishName = currentData['englishName'] ?? '';
          final currentDescription = currentData['description'] ?? '';

          // Get image path for this Salah
          // final imagePath = _getImagePathForName(currentName);

          if (currentTextBlocks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No prayer text available',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Container(
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
                children: [
                  // 🖼️ IMAGE SECTION - DISPLAY FROM ASSETS
                  // Container(
                  //   width: double.infinity,
                  //   height: 180,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(16),
                  //     image: DecorationImage(
                  //       image: AssetImage(imagePath),
                  //       fit: BoxFit.cover,
                  //     ),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withValues(alpha: 0.1),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(16),
                  //       gradient: LinearGradient(
                  //         begin: Alignment.bottomCenter,
                  //         end: Alignment.topCenter,
                  //         colors: [
                  //           Colors.black.withValues(alpha: 0.5),
                  //           Colors.transparent,
                  //         ],
                  //       ),
                  //     ),
                  //     child: Align(
                  //       alignment: Alignment.bottomLeft,
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(16),
                  //         child: Column(
                  //           mainAxisSize: MainAxisSize.min,
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           children: [
                  //             Text(
                  //               currentName,
                  //               style: const TextStyle(
                  //                 color: Colors.white,
                  //                 fontFamily: 'Amiri',
                  //                 fontSize: 24,
                  //                 fontWeight: FontWeight.bold,
                  //               ),
                  //               textDirection: TextDirection.rtl,
                  //             ),
                  //             if (currentEnglishName.isNotEmpty)
                  //               Text(
                  //                 currentEnglishName,
                  //                 style: TextStyle(
                  //                   color: Colors.white.withOpacity(0.9),
                  //                   fontFamily: 'Poppins',
                  //                   fontSize: 14,
                  //                   fontWeight: FontWeight.w500,
                  //                 ),
                  //               ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  // const SizedBox(height: 20),

                  // Title Card - Arabic Name
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
                        currentName,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Amiri',
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description (below main heading)
                  if (currentDescription.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        currentDescription,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Text Blocks (Arabic, Malayalam, English)
                  ...currentTextBlocks.map((block) {
                    final language = block['language'] ?? 'English';
                    final text = block['text'] ?? '';
                    if (text.isEmpty) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (_languageColors[language] ?? primaryColor)
                            .withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (_languageColors[language] ?? primaryColor)
                              .withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Language Label
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (_languageColors[language] ??
                                          primaryColor)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _languageIcons[language] ??
                                          Icons.translate,
                                      size: 12,
                                      color: _languageColors[language] ??
                                          primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      language,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _languageColors[language] ??
                                            primaryColor,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Text Content
                          Text(
                            text,
                            style: _languageStyles[language] ??
                                const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  height: 1.6,
                                ),
                            textAlign:
                                _languageAlign[language] ?? TextAlign.left,
                            textDirection: _languageDirection[language] ??
                                TextDirection.ltr,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

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
          );
        },
      ),
    );
  }

  // // Helper method to get image path
  // String _getImagePathForName(String name) {
  //   // Check if this Salah has a specific image
  //   if (SalahConstants.salahImages.containsKey(name)) {
  //     return SalahConstants.salahImages[name]!;
  //   }
  //   // Return default image if no specific image found
  //   return SalahConstants.defaultImage;
  // }
}
