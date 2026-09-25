// lib/screen/user/namaz_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class NamazDetailScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const NamazDetailScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<NamazDetailScreen> createState() => _NamazDetailScreenState();
}

class _NamazDetailScreenState extends State<NamazDetailScreen> {
  // ==================== COLOR SCHEME ====================
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color(0xFF1A472A);

  // ==================== LANGUAGE STYLES ====================
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

  // ==================== STATE ====================
  bool _isLoading = true;
  Map<String, dynamic>? _currentData;
  int _currentImageIndex = 0;
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    _currentData = widget.data;
    _isLoading = false;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    final name = _currentData?['name']?.toString() ?? 'Namaz Guide';
    final englishName = _currentData?['englishName']?.toString() ?? '';
    final description = _currentData?['description']?.toString() ?? '';
    final imagePaths = (_currentData?['imagePaths'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    final textBlocks = _currentData?['textBlocks'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black87,
                Colors.transparent,
              ],
            ),
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
          // Use live data if available
          if (snapshot.hasData && snapshot.data!.exists) {
            _currentData = snapshot.data!.data() as Map<String, dynamic>;
          }

          final currentName =
              _currentData?['name']?.toString() ?? 'Namaz Guide';
          final currentEnglishName =
              _currentData?['englishName']?.toString() ?? '';
          final currentDescription =
              _currentData?['description']?.toString() ?? '';
          final currentImagePaths =
              (_currentData?['imagePaths'] as List<dynamic>? ?? [])
                  .map((e) => e.toString())
                  .toList();
          final currentTextBlocks =
              _currentData?['textBlocks'] as List<dynamic>? ?? [];

          if (currentTextBlocks.isEmpty && currentImagePaths.isEmpty) {
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
                    'No content available',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ SWIPEABLE FULL SCREEN IMAGE WITH ZOOM (80% height)
                if (currentImagePaths.isNotEmpty) ...[
                  _buildSwipeableImageGallery(context, currentImagePaths),
                ],

                // Content Container (overlapping the image)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        // BoxShadow(
                        //   color: Colors.black.withValues(alpha: 0.05),
                        //   blurRadius: 15,
                        //   offset: const Offset(0, 5),
                        // ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Section
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
                            child: Column(
                              children: [
                                Text(
                                  currentName,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Amiri',
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                if (currentEnglishName.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    currentEnglishName,
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Description
                        if (currentDescription.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.2),
                              ),
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

                        // Text Blocks
                        if (currentTextBlocks.isNotEmpty) ...[
                          // const Text(
                          //   'Prayer Text',
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     fontWeight: FontWeight.w600,
                          //     fontFamily: 'Poppins',
                          //     color: textPrimary,
                          //   ),
                          // ),
                          const SizedBox(height: 16),
                          ...currentTextBlocks.map((block) {
                            final language =
                                block['language']?.toString() ?? 'English';
                            final text = block['text']?.toString() ?? '';
                            if (text.isEmpty) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    (_languageColors[language] ?? primaryColor)
                                        .withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (_languageColors[language] ??
                                          primaryColor)
                                      .withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Language Label
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
                                    textAlign: _languageAlign[language] ??
                                        TextAlign.left,
                                    textDirection:
                                        _languageDirection[language] ??
                                            TextDirection.ltr,
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],

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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== SWIPEABLE IMAGE GALLERY WITH ZOOM ====================
  Widget _buildSwipeableImageGallery(
      BuildContext context, List<String> imagePaths) {
    // 🔥 IMAGE HEIGHT SET TO 80% OF SCREEN
    final double imageHeight = MediaQuery.of(context).size.height * 0.80;

    return Stack(
      children: [
        // 🔥 PHOTO VIEW GALLERY - Swipeable with Pinch Zoom
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: PhotoViewGallery.builder(
            itemCount: imagePaths.length,
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: AssetImage(imagePaths[index]),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 4,
                heroAttributes: PhotoViewHeroAttributes(
                  tag: 'namaz_image_$index',
                ),
                // Allow zooming on the image
                initialScale: PhotoViewComputedScale.contained,
              );
            },
          ),
        ),
        // Gradient overlay for better text visibility at bottom
        // Positioned(
        //   bottom: 0,
        //   left: 0,
        //   right: 0,
        //   child: Container(
        //     height: 100,
        //     decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //         begin: Alignment.topCenter,
        //         end: Alignment.bottomCenter,
        //         colors: [
        //           Colors.transparent,
        //           Colors.black.withValues(alpha: 0.7),
        //           Colors.black.withValues(alpha: 0.9),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        // Image title/name overlay at bottom
        // Positioned(
        //   bottom: 30,
        //   left: 20,
        //   right: 20,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         _currentData?['name']?.toString() ?? '',
        //         style: const TextStyle(
        //           color: Colors.white,
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //           fontFamily: 'Amiri',
        //         ),
        //         textDirection: TextDirection.rtl,
        //       ),
        //       const SizedBox(height: 4),
        //       if (_currentData?['englishName']?.toString() != null &&
        //           _currentData!['englishName'].toString().isNotEmpty)
        //         Text(
        //           _currentData!['englishName'].toString(),
        //           style: const TextStyle(
        //             color: Colors.white70,
        //             fontSize: 16,
        //             fontFamily: 'Poppins',
        //             fontWeight: FontWeight.w500,
        //           ),
        //         ),
        //       const SizedBox(height: 8),
        //       // Image counter with zoom indicator
        //       Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: [
        //           Container(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 12,
        //               vertical: 4,
        //             ),
        //             decoration: BoxDecoration(
        //               color: Colors.black.withValues(alpha: 0.5),
        //               borderRadius: BorderRadius.circular(20),
        //             ),
        //             child: Row(
        //               mainAxisSize: MainAxisSize.min,
        //               children: [
        //                 const Icon(
        //                   Icons.swipe_rounded,
        //                   color: Colors.white,
        //                   size: 16,
        //                 ),
        //                 const SizedBox(width: 6),
        //                 Text(
        //                   '${_currentImageIndex + 1} / ${imagePaths.length}  •  Pinch to zoom',
        //                   style: const TextStyle(
        //                     color: Colors.white,
        //                     fontSize: 12,
        //                     fontFamily: 'Poppins',
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        // Image counter at top left
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swipe_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_currentImageIndex + 1} / ${imagePaths.length} ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
        // // Page indicator dots (if multiple images)
        // if (imagePaths.length > 1)
        //   Positioned(
        //     top: MediaQuery.of(context).padding.top + 60,
        //     right: 16,
        //     child: Container(
        //       padding: const EdgeInsets.symmetric(
        //         horizontal: 10,
        //         vertical: 4,
        //       ),
        //       decoration: BoxDecoration(
        //         color: Colors.black.withValues(alpha: 0.5),
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: Row(
        //         mainAxisSize: MainAxisSize.min,
        //         children: List.generate(
        //           imagePaths.length,
        //           (index) => Container(
        //             width: 8,
        //             height: 8,
        //             margin: const EdgeInsets.symmetric(horizontal: 3),
        //             decoration: BoxDecoration(
        //               shape: BoxShape.circle,
        //               color: _currentImageIndex == index
        //                   ? Colors.white
        //                   : Colors.white.withOpacity(0.3),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
      ],
    );
  }
}
