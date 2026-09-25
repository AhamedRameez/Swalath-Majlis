// lib/screen/user/moulood_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'moulood_folder_screen.dart';
import 'moulood_detail_screen.dart';
import 'default Moulood/manqoos_moulood_screen.dart';
import 'default Moulood/muhyuddeen_moulood_screen.dart'; // 🔥 ADD THIS IMPORT
import 'default Moulood/rifaai_moulood_screen.dart'; // 🔥 ADD THIS IMPORT

class MouloodScreen extends StatefulWidget {
  const MouloodScreen({super.key});

  @override
  State<MouloodScreen> createState() => _MouloodScreenState();
}

class _MouloodScreenState extends State<MouloodScreen> {
  List<String> categories = [];
  List<QueryDocumentSnapshot> allMouloods = [];
  bool _isLoading = true;

  // 🔥 UPDATED: Static moulood data (appears as direct items, NOT in folders)
  final List<Map<String, dynamic>> _staticMouloods = [
    {
      'title': 'Manqoos Moulood',
      'description':
          'The blessed Manqoos Moulood celebrating the birth of Prophet Muhammad ﷺ with beautiful poetry and prose.',
      'isStatic': true,
      'isSpecialScreen': true,
    },
    {
      'title': 'Muhyuddeen Moulood',
      'description':
          'The blessed Moulood of Muhyuddeen Abdul Qadir Jilani (RA) celebrating the life and spiritual legacy of the great saint.',
      'isStatic': true,
      'isSpecialScreen': true,
    },
    {
      'title': 'Rifaai Moulood',
      'description':
          'The blessed Moulood of Sultan al-Arifeen Sayyidi Ahmad al-Kabir al-Rifaai (RA).',
      'isStatic': true,
      'isSpecialScreen': true,
    },
    // Add more static mouloods here in the future
  ];

  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      print('Loading Moulood data from Firestore...');

      // Load ALL mouloods (both categorized and uncategorized)
      final allMouloodsSnapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('mouloods')
          .orderBy('createdAt', descending: true)
          .get();

      print(
        'Found ${allMouloodsSnapshot.docs.length} total mouloods from Firestore',
      );

      // Get unique categories from Firestore mouloods only
      final Set<String> categoriesWithMouloods = {};
      for (var moulood in allMouloodsSnapshot.docs) {
        final mouloodData = moulood.data();
        if (mouloodData.containsKey('category') &&
            mouloodData['category'] != null &&
            mouloodData['category'].toString().isNotEmpty) {
          categoriesWithMouloods.add(mouloodData['category'].toString());
        }
      }

      setState(() {
        allMouloods = allMouloodsSnapshot.docs;
        categories = categoriesWithMouloods.toList()..sort();
        _isLoading = false;
      });

      print('Categories with mouloods: $categories');
      print('Total mouloods to display: ${allMouloods.length} (Firestore)');
      print('Static mouloods: ${_staticMouloods.length}');
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading mouloods: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCategoryCard(String category, int index, BuildContext context) {
    // Count mouloods in this category (only from Firestore)
    final categoryMouloodsCount = allMouloods.where((moulood) {
      final mouloodData = moulood.data() as Map<String, dynamic>;
      return mouloodData.containsKey('category') &&
          mouloodData['category']?.toString() == category;
    }).length;

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
              builder: (_) => MouloodFolderScreen(folderName: category),
            ),
          );
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
                        '$categoryMouloodsCount ${categoryMouloodsCount == 1 ? 'item' : 'items'}',
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

  Widget _buildMouloodCard(
    QueryDocumentSnapshot data,
    int index,
    BuildContext context,
  ) {
    final mouloodData = data.data() as Map<String, dynamic>;
    final title = mouloodData['title']?.toString() ?? 'Untitled Moulood';
    final hasDua =
        mouloodData['dua'] != null && mouloodData['dua'].toString().isNotEmpty;

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
              builder: (_) =>
                  MouloodDetailScreen(mouloodData: mouloodData, docId: data.id),
            ),
          );
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                      if (hasDua) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Dua',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 UPDATED: Method to build static moulood card (supports multiple special screens)
  Widget _buildStaticMouloodCard(
    Map<String, dynamic> moulood,
    int index,
    BuildContext context,
  ) {
    final title = moulood['title'] ?? 'Untitled';
    final isSpecialScreen = moulood['isSpecialScreen'] ?? false;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          if (isSpecialScreen) {
            if (title == 'Manqoos Moulood') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManqoosMouloodScreen()),
              );
            } else if (title == 'Muhyuddeen Moulood') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MuhyuddeenMouloodScreen(),
                ),
              );
            } else if (title == 'Rifaai Moulood') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RifaaiMouloodScreen()),
              );
            }
          }
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            fontSize: 10,
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to get uncategorized mouloods from Firestore
  List<QueryDocumentSnapshot> _getUncategorizedMouloods() {
    return allMouloods.where((moulood) {
      final mouloodData = moulood.data() as Map<String, dynamic>;
      return !mouloodData.containsKey('category') ||
          mouloodData['category'] == null ||
          mouloodData['category'].toString().isEmpty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uncategorizedMouloods = _getUncategorizedMouloods();
    final hasCategories = categories.isNotEmpty;
    final hasUncategorized = uncategorizedMouloods.isNotEmpty;
    final hasStaticMouloods = _staticMouloods.isNotEmpty;
    final hasAnyContent =
        hasCategories || hasUncategorized || hasStaticMouloods;

    // Calculate total items for numbering (Firestore + Static)
    final totalFirestoreCount = uncategorizedMouloods.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Moulood',
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
        actionsIconTheme: const IconThemeData(color: Colors.white),
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
                    'Loading Moulood...',
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
                    // Categories Section (Folders) - ONLY from Firestore
                    if (hasCategories)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 12,
                              top: index == 0 ? 0 : 0,
                            ),
                            child: _buildCategoryCard(
                              categories[index],
                              index,
                              context,
                            ),
                          );
                        }, childCount: categories.length),
                      ),

                    // 🔥 Static Mouloods Section - WITHOUT HEADING
                    if (hasStaticMouloods)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildStaticMouloodCard(
                              _staticMouloods[index],
                              index,
                              context,
                            ),
                          );
                        }, childCount: _staticMouloods.length),
                      ),

                    // 🔥 ADD: Spacer between sections only if both exist
                    if (hasStaticMouloods && hasUncategorized)
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),

                    // Uncategorized Mouloods Section (Firestore) - WITHOUT HEADING
                    if (hasUncategorized)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMouloodCard(
                              uncategorizedMouloods[index],
                              totalFirestoreCount + index,
                              context,
                            ),
                          );
                        }, childCount: uncategorizedMouloods.length),
                      ),

                    // Empty State
                    if (!hasAnyContent)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(top: 40),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: dividerColor.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.auto_stories_rounded,
                                color: textTertiary,
                                size: 40,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No moulood available',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add some moulood from the admin panel',
                                style: TextStyle(
                                  color: textTertiary,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Add some padding at the bottom
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
    );
  }
}
