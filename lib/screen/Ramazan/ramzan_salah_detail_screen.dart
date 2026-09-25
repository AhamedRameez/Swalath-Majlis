// lib/screen/user/salah_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RamzanSalahDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const RamzanSalahDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<RamzanSalahDetailScreen> createState() =>
      _RamzanSalahDetailScreenState();
}

class _RamzanSalahDetailScreenState extends State<RamzanSalahDetailScreen> {
  // 🎨 Color Theme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardColor = Color(0xFFFFFFFF);

  // Language specific styling
  final Map<String, TextStyle> _languageStyles = {
    'Arabic': const TextStyle(
      fontFamily: 'Amiri',
      fontSize: 20,
      height: 1.8,
      color: Color(0xFF333333),
    ),
    'Malayalam': const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      height: 1.6,
      color: Color(0xFF333333),
    ),
    'English': const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      height: 1.6,
      color: Color(0xFF333333),
    ),
  };

  final Map<String, Color> _languageColors = {
    'Malayalam': primaryColor,
    'Arabic': accentColor,
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
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            if (description.isNotEmpty)
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            .collection('ramzan_salahs')
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: currentTextBlocks.length,
            itemBuilder: (context, index) {
              final block = currentTextBlocks[index];
              final language = block['language'] ?? 'English';
              final text = block['text'] ?? '';

              if (text.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (_languageColors[language] ?? primaryColor)
                        .withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Language header
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 16,
                    //     vertical: 12,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: (_languageColors[language] ?? primaryColor)
                    //         .withOpacity(0.05),
                    //     borderRadius: const BorderRadius.only(
                    //       topLeft: Radius.circular(16),
                    //       topRight: Radius.circular(16),
                    //     ),
                    //     border: Border(
                    //       bottom: BorderSide(
                    //         color: (_languageColors[language] ?? primaryColor)
                    //             .withOpacity(0.2),
                    //       ),
                    //     ),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         padding: const EdgeInsets.all(6),
                    //         decoration: BoxDecoration(
                    //           color: (_languageColors[language] ?? primaryColor)
                    //               .withOpacity(0.1),
                    //           borderRadius: BorderRadius.circular(6),
                    //         ),
                    //         child: Icon(
                    //           _languageIcons[language] ?? Icons.translate,
                    //           size: 14,
                    //           color: _languageColors[language] ?? primaryColor,
                    //         ),
                    //       ),
                    //       const SizedBox(width: 10),
                    //       Text(
                    //         language == 'Malayalam'
                    //             ? 'മലയാളം'
                    //             : language == 'Arabic'
                    //             ? 'العربية'
                    //             : 'English',
                    //         style: TextStyle(
                    //           color: _languageColors[language] ?? primaryColor,
                    //           fontSize: 13,
                    //           fontWeight: FontWeight.w600,
                    //           fontFamily: 'Poppins',
                    //         ),
                    //       ),
                    //       if (language == 'Arabic') ...[
                    //         const Spacer(),
                    //         Container(
                    //           padding: const EdgeInsets.symmetric(
                    //             horizontal: 8,
                    //             vertical: 2,
                    //           ),
                    //           decoration: BoxDecoration(
                    //             color: accentColor.withOpacity(0.1),
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //           child: const Text(
                    //             'RTL',
                    //             style: TextStyle(
                    //               fontSize: 10,
                    //               color: accentColor,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ],
                    //   ),
                    // ),

                    // Text content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        text,
                        style:
                            _languageStyles[language] ??
                            const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              height: 1.6,
                            ),
                        textAlign: _languageAlign[language] ?? TextAlign.left,
                        textDirection:
                            _languageDirection[language] ?? TextDirection.ltr,
                      ),
                    ),

                    // Step indicator for long content
                    if (currentTextBlocks.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (_languageColors[language] ?? primaryColor)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1} of ${currentTextBlocks.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      _languageColors[language] ?? primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
