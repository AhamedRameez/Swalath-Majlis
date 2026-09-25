// lib/screen/user/salahs_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'ramzan_salah_detail_screen.dart';

class RamzanSalahsScreen extends StatelessWidget {
  const RamzanSalahsScreen({super.key});

  // Your color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Safe data access helper
  static String _getString(Map<String, dynamic> data, String key) {
    return data[key]?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Salah Guide',
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
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
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
            .collection('ramzan_salahs')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
                backgroundColor: primaryColor.withValues(alpha: 0.1),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red[400],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading salahs',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mosque_rounded, color: textTertiary, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'No Salahs Available',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for updates',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final dataMap = doc.data() as Map<String, dynamic>;

                return _buildSalahCard(
                  context: context,
                  name: _getString(dataMap, 'name'),
                  description: _getString(dataMap, 'description'),
                  textBlocks: dataMap['textBlocks'] ?? [], // Pass text blocks
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RamzanSalahDetailScreen(
                            docId: doc.id, data: dataMap),
                      ),
                    );
                  },
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSalahCard({
    required BuildContext context,
    required String name,
    required String description,
    required List textBlocks,
    required VoidCallback onTap,
    required int index,
  }) {
    // Get language icons for preview
    final languageIcons = {
      'Malayalam': Icons.translate,
      'Arabic': Icons.translate_rounded,
      'English': Icons.language,
    };

    final languageColors = {
      'Malayalam': primaryColor,
      'Arabic': accentColor,
      'English': Colors.blue,
    };

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: dividerColor.withValues(alpha: 0.8), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Number badge with gradient
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, Color.fromARGB(255, 35, 150, 115)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Salah Name
                      Text(
                        name.isNotEmpty ? name : 'Unnamed Salah',
                        style: const TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // // Language indicators (preview of available languages)
                      // if (textBlocks.isNotEmpty)
                      //   Wrap(
                      //     spacing: 6,
                      //     runSpacing: 4,
                      //     children:
                      //         // Get unique languages in the text blocks
                      //         textBlocks
                      //             .map((block) => block['language'] as String)
                      //             .toSet()
                      //             .map((language) {
                      //               return Container(
                      //                 padding: const EdgeInsets.symmetric(
                      //                   horizontal: 8,
                      //                   vertical: 3,
                      //                 ),
                      //                 decoration: BoxDecoration(
                      //                   color:
                      //                       (languageColors[language] ??
                      //                               primaryColor)
                      //                           .withOpacity(0.1),
                      //                   borderRadius: BorderRadius.circular(12),
                      //                   border: Border.all(
                      //                     color:
                      //                         (languageColors[language] ??
                      //                                 primaryColor)
                      //                             .withOpacity(0.3),
                      //                     width: 1,
                      //                   ),
                      //                 ),
                      //                 child: Row(
                      //                   mainAxisSize: MainAxisSize.min,
                      //                   children: [
                      //                     Icon(
                      //                       languageIcons[language] ??
                      //                           Icons.translate,
                      //                       size: 11,
                      //                       color:
                      //                           languageColors[language] ??
                      //                           primaryColor,
                      //                     ),
                      //                     const SizedBox(width: 4),
                      //                     Text(
                      //                       language == 'Malayalam'
                      //                           ? 'മലയാളം'
                      //                           : language == 'Arabic'
                      //                           ? 'العربية'
                      //                           : 'English',
                      //                       style: TextStyle(
                      //                         color:
                      //                             languageColors[language] ??
                      //                             primaryColor,
                      //                         fontSize: 10,
                      //                         fontWeight: FontWeight.w500,
                      //                         fontFamily: 'Poppins',
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               );
                      //             })
                      //             .toList(),
                      //   ),

                      // // Description (if available)
                      // if (description.isNotEmpty) ...[
                      //   const SizedBox(height: 8),
                      //   Text(
                      //     description,
                      //     style: TextStyle(
                      //       color: textSecondary,
                      //       fontSize: 13,
                      //       fontFamily: 'Poppins',
                      //       height: 1.4,
                      //     ),
                      //     maxLines: 2,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Chevron icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: dividerColor, width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
