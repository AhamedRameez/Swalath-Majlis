// lib/screen/user/swalath_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'swalath_folder_screen.dart';
import 'swalath_details_screen.dart';

class SwalathScreen extends StatefulWidget {
  const SwalathScreen({super.key});

  @override
  State<SwalathScreen> createState() => _SwalathScreenState();
}

class _SwalathScreenState extends State<SwalathScreen> {
  List<String> categories = [];
  List<QueryDocumentSnapshot> allSwalaths = [];
  bool _isLoading = true;

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
      print('Loading Swalath data from Firestore...');

      // Load ALL swalaths (both categorized and uncategorized)
      final allSwalathsSnapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('swalath')
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${allSwalathsSnapshot.docs.length} total swalaths');

      // Get unique categories from swalaths (to show only categories that have swalaths)
      final Set<String> categoriesWithSwalaths = {};
      for (var swalath in allSwalathsSnapshot.docs) {
        final swalathData = swalath.data();
        if (swalathData.containsKey('category') &&
            swalathData['category'] != null &&
            swalathData['category'].toString().isNotEmpty) {
          categoriesWithSwalaths.add(swalathData['category'].toString());
        }
      }

      setState(() {
        allSwalaths = allSwalathsSnapshot.docs;
        categories = categoriesWithSwalaths.toList()..sort();
        _isLoading = false;
      });

      print('Categories with swalaths: $categories');
      print('Total swalaths to display: ${allSwalaths.length}');
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading swalaths: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCategoryCard(String category, int index, BuildContext context) {
    // Count swalaths in this category
    final categorySwalathsCount = allSwalaths.where((swalath) {
      final swalathData = swalath.data() as Map<String, dynamic>;
      return swalathData.containsKey('category') &&
          swalathData['category']?.toString() == category;
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
              builder: (_) => SwalathFolderScreen(folderName: category),
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
                        '$categorySwalathsCount ${categorySwalathsCount == 1 ? 'item' : 'items'}',
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

  Widget _buildSwalathCard(
    QueryDocumentSnapshot data,
    int index,
    BuildContext context,
  ) {
    final swalathData = data.data() as Map<String, dynamic>;
    final title = swalathData['title']?.toString() ?? 'Untitled Swalath';
    final hasDua =
        swalathData['dua'] != null && swalathData['dua'].toString().isNotEmpty;

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
                  SwalathDetailScreen(swalathData: swalathData, docId: data.id),
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
                      // Style badge REMOVED - only keep Dua badge if needed
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

  // Method to get uncategorized swalaths
  List<QueryDocumentSnapshot> _getUncategorizedSwalaths() {
    return allSwalaths.where((swalath) {
      final swalathData = swalath.data() as Map<String, dynamic>;
      return !swalathData.containsKey('category') ||
          swalathData['category'] == null ||
          swalathData['category'].toString().isEmpty;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uncategorizedSwalaths = _getUncategorizedSwalaths();
    final hasCategories = categories.isNotEmpty;
    final hasUncategorized = uncategorizedSwalaths.isNotEmpty;
    final hasAnyContent = hasCategories || hasUncategorized;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Swalath',
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
                    'Loading Swalaths...',
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
                    // Categories Section (Folders)
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

                    // Uncategorized Swalaths Section
                    if (hasUncategorized)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSwalathCard(
                              uncategorizedSwalaths[index],
                              index,
                              context,
                            ),
                          );
                        }, childCount: uncategorizedSwalaths.length),
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
                                'No swalath available',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add some swalath from the admin panel',
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
