// lib/screen/user/special_day_dua_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Counter variables
  int _counter = 0;
  bool _showCounter = false;

  // Draggable counter position
  Offset _counterPosition = const Offset(0, 0);
  bool _isDragging = false;
  bool _isPositionInitialized = false;

  // Gallery variables
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  void _incrementCounter() => setState(() => _counter++);
  void _resetCounter() => setState(() => _counter = 0);

  void _toggleCounter() {
    setState(() {
      _showCounter = !_showCounter;
      if (_showCounter && !_isPositionInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            setState(() {
              _counterPosition = Offset(
                (screenWidth - 200) / 2,
                screenHeight / 2 - 50,
              );
              _isPositionInitialized = true;
            });
          }
        });
      }
    });
  }

  // Show fullscreen image gallery with zoom AND COUNTER
  void _showImageGallery(List<String> imageUrls, int initialIndex) {
    // Counter state for gallery
    int galleryCounter = _counter;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatefulBuilder(
          builder: (context, setGalleryState) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                foregroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    // Update main counter when closing
                    setState(() {
                      _counter = galleryCounter;
                    });
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  '${initialIndex + 1} / ${imageUrls.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                actions: [
                  // Counter display in AppBar
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          color: Colors.white,
                          onPressed: () {
                            setGalleryState(() {
                              galleryCounter = 0;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$galleryCounter',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add, size: 18),
                          color: Colors.white,
                          onPressed: () {
                            setGalleryState(() {
                              galleryCounter++;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  PhotoViewGallery.builder(
                    itemCount: imageUrls.length,
                    builder: (context, index) {
                      return PhotoViewGalleryPageOptions(
                        imageProvider: CachedNetworkImageProvider(
                          imageUrls[index],
                        ),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3,
                        heroAttributes: PhotoViewHeroAttributes(
                          tag: imageUrls[index],
                        ),
                      );
                    },
                    pageController: PageController(initialPage: initialIndex),
                    onPageChanged: (index) {
                      if (mounted) {
                        setGalleryState(() {
                          _currentImageIndex = index;
                        });
                      }
                    },
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),

                  // Floating counter at bottom of gallery
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Reset button
                            GestureDetector(
                              onTap: () {
                                setGalleryState(() {
                                  galleryCounter = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Counter number
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '$galleryCounter',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Plus button
                            GestureDetector(
                              onTap: () {
                                setGalleryState(() {
                                  galleryCounter++;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Image counter badge
                  Positioned(
                    top: 60,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImageIndex + 1} / ${imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ).then((_) {
      // Refresh main counter when gallery closes (in case it was updated)
      setState(() {});
    });
  }

  // Draggable Counter Widget
  Widget _buildWhiteTransparentCounterWidget({required bool isDragging}) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: isDragging
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: isDragging
                  ? primaryColor.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: isDragging ? 15 : 8,
              offset: Offset(0, isDragging ? 5 : 2),
              spreadRadius: isDragging ? 2 : 0,
            ),
          ],
          border: Border.all(
            color: isDragging
                ? primaryColor.withValues(alpha: 0.8)
                : primaryColor.withValues(alpha: 0.4),
            width: isDragging ? 2 : 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // RETRY/REFRESH button
              GestureDetector(
                onTap: _resetCounter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Counter number
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    shadows: [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Plus button
              GestureDetector(
                onTap: _incrementCounter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: primaryColor,
                    size: 22,
                    weight: 800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = widget.data['heading'] ?? '';
    final title = widget.data['title'] ?? '';
    final paragraph = widget.data['paragraph'] ?? '';

    // Support both single image (old data) and multiple images (new data)
    List<String> imageUrls = [];

    // Check if data has imageUrls (array) or single imageUrl
    if (widget.data.containsKey('imageUrls') &&
        widget.data['imageUrls'] is List) {
      imageUrls = List<String>.from(widget.data['imageUrls']);
    } else if (widget.data.containsKey('imageUrl') &&
        widget.data['imageUrl'].toString().isNotEmpty) {
      imageUrls = [widget.data['imageUrl']];
    }

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
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // 🔥 FULL SCREEN GALLERY - Same as gallery screen
                if (imageUrls.isNotEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // Main Gallery - Using PhotoViewGallery for consistency
                        PhotoViewGallery.builder(
                          scrollPhysics: const BouncingScrollPhysics(),
                          builder: (context, index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: CachedNetworkImageProvider(
                                imageUrls[index],
                              ),
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 3,
                              heroAttributes: PhotoViewHeroAttributes(
                                tag: imageUrls[index],
                              ),
                            );
                          },
                          itemCount: imageUrls.length,
                          pageController: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        ),

                        // Image Counter Badge (if multiple images)
                        if (imageUrls.length > 1)
                          Positioned(
                            top: 50,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentImageIndex + 1} / ${imageUrls.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                        // Left Arrow (prev)
                        if (imageUrls.length > 1)
                          Positioned(
                            left: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (_currentImageIndex > 0) {
                                    _pageController.previousPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Right Arrow (next)
                        if (imageUrls.length > 1)
                          Positioned(
                            right: 8,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: GestureDetector(
                                onTap: () {
                                  if (_currentImageIndex <
                                      imageUrls.length - 1) {
                                    _pageController.nextPage(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Zoom Hint
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.zoom_in_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Tap to zoom',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // White Card Container - TEXT BELOW IMAGE
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
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
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.2),
                            ),
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

                      // Thumbnail Indicators (if multiple images)
                      if (imageUrls.length > 1)
                        Column(
                          children: [
                            const Divider(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(imageUrls.length, (
                                index,
                              ) {
                                final isActive = _currentImageIndex == index;
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.animateToPage(
                                      index,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                    );
                                  },
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isActive
                                          ? primaryColor
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),

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

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Counter Toggle Button (Bottom-Left)
          Positioned(
            left: 20,
            bottom: 20,
            child: Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.2),
              child: InkWell(
                onTap: _toggleCounter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dividerColor.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _showCounter
                        ? Icons.close_rounded
                        : Icons.calculate_rounded,
                    color: _showCounter ? textTertiary : primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Draggable Counter
          if (_showCounter && _isPositionInitialized)
            Positioned(
              left: _counterPosition.dx,
              top: _counterPosition.dy,
              child: Draggable(
                feedback: _buildWhiteTransparentCounterWidget(isDragging: true),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                onDraggableCanceled: (velocity, offset) {
                  setState(() {
                    _isDragging = false;
                    _counterPosition = offset;
                  });
                },
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _counterPosition += details.delta;
                      _counterPosition = Offset(
                        _counterPosition.dx.clamp(
                          0,
                          MediaQuery.of(context).size.width - 200,
                        ),
                        _counterPosition.dy.clamp(
                          0,
                          MediaQuery.of(context).size.height - 100,
                        ),
                      );
                    });
                  },
                  child: _buildWhiteTransparentCounterWidget(isDragging: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
