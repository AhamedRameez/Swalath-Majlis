// lib/screen/dua_select_screen.dart (UPDATED)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/dua_cache_service.dart';
import '../../models/dua_cache_model.dart';
import '../Duas/dua_select_category_screen.dart'; // New file for category duas

class DuaSelectScreen extends StatefulWidget {
  const DuaSelectScreen({super.key});

  @override
  State<DuaSelectScreen> createState() => _DuaSelectScreenState();
}

class _DuaSelectScreenState extends State<DuaSelectScreen> {
  // Your specified color scheme
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

  bool _isLoading = true;
  bool _isOnline = true;

  // Categories and duas data
  List<String> categories = [];
  List<DuaCache> allDuas = [];
  List<DuaCache> uncategorizedDuas = [];

  @override
  void initState() {
    super.initState();
    _loadDuas();
  }

  Future<void> _loadDuas() async {
    setState(() => _isLoading = true);

    try {
      // Try to fetch from Firebase first (online)
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('duas')
          .orderBy('createdAt', descending: true)
          .get(const GetOptions(source: Source.serverAndCache));

      // Update cache with fresh data
      await DuaCacheService.fetchAndCacheFromFirebase();
      _isOnline = true;
    } catch (e) {
      // If offline, use cached data
      _isOnline = false;
      print('⚠️ Offline mode: $e');
    }

    // Load all duas from cache
    allDuas = DuaCacheService.getAllCachedDuas();

    // Extract unique categories from duas
    _extractCategoriesAndUncategorized();

    setState(() => _isLoading = false);
  }

  void _extractCategoriesAndUncategorized() {
    final Set<String> categoriesWithDuas = {};
    final List<DuaCache> uncategorized = [];

    for (var dua in allDuas) {
      if (dua.category != null && dua.category!.isNotEmpty) {
        categoriesWithDuas.add(dua.category!);
      } else {
        uncategorized.add(dua);
      }
    }

    setState(() {
      categories = categoriesWithDuas.toList()..sort();
      uncategorizedDuas = uncategorized;
    });
  }

  Future<void> _refreshDuas() async {
    await _loadDuas();
  }

  // Method to count duas in a category
  int _getCategoryDuaCount(String category) {
    return allDuas.where((dua) => dua.category == category).length;
  }

  Widget _buildCategoryCard({
    required String category,
    required int index,
    required BuildContext context,
  }) {
    final duaCount = _getCategoryDuaCount(category);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          // Navigate to category duas screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DuaSelectCategoryScreen(
                category: category,
                isOnline: _isOnline,
              ),
            ),
          ).then((selectedDua) {
            // If a dua was selected, return it to tasbeeh screen
            if (selectedDua != null) {
              Navigator.pop(context, selectedDua);
            }
          });
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
              children: [
                // Folder icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.folder_rounded,
                    color: primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Category info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$duaCount ${duaCount == 1 ? 'dua' : 'duas'}',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: primaryColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUncategorizedDuaCard({
    required int index,
    required DuaCache dua,
    required BuildContext context,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, {
            'heading': dua.heading,
            'arabic': dua.arabic,
            'english': dua.english,
            'malayalam': dua.malayalam,
          });
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
                // Dua info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading and offline indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dua.heading,
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
                          ),
                          if (!_isOnline) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Offline',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Arabic preview
                      if (dua.arabic.isNotEmpty)
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            dua.arabic,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontFamily: 'Amiri',
                              color: textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Uncategorized badge
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: textTertiary.withOpacity(0.1),
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //       color: textTertiary.withOpacity(0.2),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Icons.folder_open_rounded,
                      //         size: 12,
                      //         color: textTertiary,
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         'Uncategorized',
                      //         style: TextStyle(
                      //           color: textTertiary,
                      //           fontSize: 11,
                      //           fontWeight: FontWeight.w500,
                      //           fontFamily: 'Poppins',
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Selection icon
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 22,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasCategories = categories.isNotEmpty;
    final hasUncategorized = uncategorizedDuas.isNotEmpty;
    final hasAnyContent = hasCategories || hasUncategorized;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'Select Dua',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
            if (!_isOnline) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _isLoading ? null : _refreshDuas,
            tooltip: 'Refresh Duas',
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _isOnline ? 'Loading Duas...' : 'Loading cached Duas...',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            )
          : !hasAnyContent
          ? Center(
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
                        Icons.handshake_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isOnline ? 'No Duas Available' : 'No Cached Duas',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isOnline
                          ? 'Duas will appear here once they are added.'
                          : 'Go online to download duas first.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    if (!_isOnline) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _refreshDuas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry Connection'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Categories Section
                  if (hasCategories)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4, bottom: 8),
                        child: Text(
                          'Categories',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),

                  if (hasCategories)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: 12,
                            top: index == 0 ? 0 : 0,
                          ),
                          child: _buildCategoryCard(
                            category: categories[index],
                            index: index,
                            context: context,
                          ),
                        );
                      }, childCount: categories.length),
                    ),

                  // Uncategorized Duas Section
                  // if (hasUncategorized)
                  //   SliverToBoxAdapter(
                  //     child: Padding(
                  //       padding: EdgeInsets.only(
                  //         bottom: 8,
                  //         top: hasCategories ? 16 : 4,
                  //       ),
                  //       child: Text(
                  //         'Uncategorized Duas',
                  //         style: TextStyle(
                  //           color: textPrimary,
                  //           fontSize: 18,
                  //           fontWeight: FontWeight.w600,
                  //           fontFamily: 'Poppins',
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  if (hasUncategorized)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUncategorizedDuaCard(
                            index: index,
                            dua: uncategorizedDuas[index],
                            context: context,
                          ),
                        );
                      }, childCount: uncategorizedDuas.length),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
    );
  }
}
