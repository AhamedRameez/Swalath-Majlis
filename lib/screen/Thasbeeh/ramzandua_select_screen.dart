import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ramzandua_select_category_screen.dart';

class RamzanDuaSelectScreen extends StatefulWidget {
  const RamzanDuaSelectScreen({super.key});

  @override
  State<RamzanDuaSelectScreen> createState() => _RamzanDuaSelectScreenState();
}

class _RamzanDuaSelectScreenState extends State<RamzanDuaSelectScreen> {
  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  List<String> categories = [];
  List<QueryDocumentSnapshot> allDuas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      print('📖 Loading duas for selection...');

      final allDuasSnapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('Ramzan_duas')
          .orderBy('createdAt', descending: true)
          .get();

      print('✅ Found ${allDuasSnapshot.docs.length} duas');

      // Get unique categories from duas
      final Set<String> categoriesWithDuas = {};
      for (var dua in allDuasSnapshot.docs) {
        final duaData = dua.data();
        if (duaData.containsKey('category') &&
            duaData['category'] != null &&
            duaData['category'].toString().isNotEmpty) {
          categoriesWithDuas.add(duaData['category'].toString());
        }
      }

      setState(() {
        allDuas = allDuasSnapshot.docs;
        categories = categoriesWithDuas.toList()..sort();
        _isLoading = false;
      });

      print('📂 Categories found: $categories');
    } catch (e) {
      print('❌ Error loading duas: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading duas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Method to get uncategorized duas
  List<QueryDocumentSnapshot> _getUncategorizedDuas() {
    return allDuas.where((dua) {
      final duaData = dua.data() as Map<String, dynamic>;
      return !duaData.containsKey('category') ||
          duaData['category'] == null ||
          duaData['category'].toString().isEmpty;
    }).toList();
  }

  // Method to count duas in a category
  int _getCategoryDuaCount(String category) {
    return allDuas.where((dua) {
      final duaData = dua.data() as Map<String, dynamic>;
      return duaData.containsKey('category') &&
          duaData['category']?.toString() == category;
    }).length;
  }

  Widget _buildCategoryCard(String category, int index) {
    final duaCount = _getCategoryDuaCount(category);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RamzanDuaSelectCategoryScreen(category: category),
            ),
          ).then((selectedDua) {
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

  Widget _buildUncategorizedDuaCard(QueryDocumentSnapshot data, int index) {
    final duaData = data.data() as Map<String, dynamic>;
    final heading = duaData['heading']?.toString() ?? 'Untitled Dua';
    final arabic = duaData['arabic']?.toString() ?? '';

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, {
            'heading': heading,
            'arabic': arabic,
            'english': duaData['english']?.toString() ?? '',
            'malayalam': duaData['malayalam']?.toString() ?? '',
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
                // Number badge
                // Container(
                //   width: 36,
                //   height: 36,
                //   decoration: BoxDecoration(
                //     color: accentColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(8),
                //     border: Border.all(
                //       color: accentColor.withOpacity(0.3),
                //       width: 1.5,
                //     ),
                //   ),
                //   child: Center(
                //     child: Text(
                //       '${index + 1}',
                //       style: TextStyle(
                //         color: accentColor,
                //         fontWeight: FontWeight.w700,
                //         fontSize: 14,
                //         fontFamily: 'Poppins',
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
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
                      if (arabic.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            arabic,
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
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: textTertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: textTertiary.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        // child: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     Icon(
                        //       Icons.folder_open_rounded,
                        //       size: 12,
                        //       color: textTertiary,
                        //     ),
                        //     const SizedBox(width: 4),
                        //     Text(
                        //       'Uncategorized',
                        //       style: TextStyle(
                        //         color: textTertiary,
                        //         fontSize: 11,
                        //         fontWeight: FontWeight.w500,
                        //         fontFamily: 'Poppins',
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
    final uncategorizedDuas = _getUncategorizedDuas();
    final hasCategories = categories.isNotEmpty;
    final hasUncategorized = uncategorizedDuas.isNotEmpty;
    final hasAnyContent = hasCategories || hasUncategorized;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select Ramadan Dua',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh',
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
                  const Text(
                    'Loading Duas...',
                    style: TextStyle(
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
                        Icons.menu_book_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Duas Available',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Duas will appear here once they are added.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: primaryColor,
              backgroundColor: backgroundColor,
              onRefresh: _loadData,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Categories Section
                    if (hasCategories)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.category_rounded,
                                size: 20,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Categories',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${categories.length}',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
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
                            child: _buildCategoryCard(categories[index], index),
                          );
                        }, childCount: categories.length),
                      ),

                    // Uncategorized Duas Section
                    // if (hasUncategorized)
                    //   SliverToBoxAdapter(
                    //     child: Padding(
                    //       padding: EdgeInsets.only(
                    //         bottom: 12,
                    //         top: hasCategories ? 24 : 4,
                    // ),
                    // child: Row(
                    //   children: [
                    //     Icon(
                    //       Icons.list_alt_rounded,
                    //       size: 20,
                    //       color: accentColor,
                    //     ),
                    //     const SizedBox(width: 8),
                    //     Text(
                    //       'Uncategorized Duas',
                    //       style: TextStyle(
                    //         color: textPrimary,
                    //         fontSize: 18,
                    //         fontWeight: FontWeight.w600,
                    //         fontFamily: 'Poppins',
                    //       ),
                    //     ),
                    //     const Spacer(),
                    //     Container(
                    //       padding: const EdgeInsets.symmetric(
                    //         horizontal: 10,
                    //         vertical: 4,
                    //       ),
                    //       decoration: BoxDecoration(
                    //         color: accentColor.withOpacity(0.1),
                    //         borderRadius: BorderRadius.circular(20),
                    //       ),
                    //       child: Text(
                    //         '${uncategorizedDuas.length}',
                    //         style: TextStyle(
                    //           color: accentColor,
                    //           fontWeight: FontWeight.w600,
                    //           fontSize: 13,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    //   ),
                    // ),
                    if (hasUncategorized)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildUncategorizedDuaCard(
                              uncategorizedDuas[index],
                              index,
                            ),
                          );
                        }, childCount: uncategorizedDuas.length),
                      ),

                    // Bottom padding
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
    );
  }
}
