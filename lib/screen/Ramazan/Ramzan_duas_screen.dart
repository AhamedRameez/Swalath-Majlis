// lib/screens/ramzan_duas_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ramzan_dua_category_screen.dart';
import 'ramzan_dua_detail_screen.dart';

class RamzanDuasScreen extends StatefulWidget {
  const RamzanDuasScreen({super.key});

  @override
  State<RamzanDuasScreen> createState() => _RamzanDuasScreenState();
}

class _RamzanDuasScreenState extends State<RamzanDuasScreen> {
  List<String> categories = [];
  List<QueryDocumentSnapshot> allDuas = [];
  bool _isLoading = true;

  // 🔥 NEW: Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

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

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase().trim();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _clearSearch();
      }
    });
  }

  // 🔥 NEW: Filter categories based on search query
  List<String> _filterCategories(List<String> cats) {
    if (_searchQuery.isEmpty) {
      return cats;
    }

    return cats.where((cat) {
      return cat.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  // 🔥 NEW: Filter duas based on search query
  List<QueryDocumentSnapshot> _filterDuas(List<QueryDocumentSnapshot> docs) {
    if (_searchQuery.isEmpty) {
      return docs;
    }

    return docs.where((doc) {
      final duaData = doc.data() as Map<String, dynamic>;
      final heading = duaData['heading']?.toString().toLowerCase() ?? '';
      final arabic = duaData['arabic']?.toString().toLowerCase() ?? '';
      final malayalam = duaData['malayalam']?.toString().toLowerCase() ?? '';
      final english = duaData['english']?.toString().toLowerCase() ?? '';

      return heading.contains(_searchQuery) ||
          arabic.contains(_searchQuery) ||
          malayalam.contains(_searchQuery) ||
          english.contains(_searchQuery);
    }).toList();
  }

  Future<void> _loadData() async {
    try {
      print('Loading Ramadan data from Firestore...');

      // Load from Ramzan_duas collection
      final allDuasSnapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('Ramzan_duas')
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${allDuasSnapshot.docs.length} total Ramadan duas');

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

      print('Categories with duas: $categories');
      print('Total Ramadan duas to display: ${allDuas.length}');
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);

      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading Ramadan duas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildCategoryCard(String category, int index, BuildContext context) {
    // Count duas in this category
    final categoryDuasCount = allDuas.where((dua) {
      final duaData = dua.data() as Map<String, dynamic>;
      return duaData.containsKey('category') &&
          duaData['category']?.toString() == category;
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
              builder: (_) => RamzanCategoryDuasScreen(category: category),
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
                // Folder icon with Ramadan theme
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
                    Icons.mosque_rounded,
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
                        '$categoryDuasCount ${categoryDuasCount == 1 ? 'dua' : 'duas'}',
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

  Widget _buildDuaCard(
    QueryDocumentSnapshot data,
    int index,
    BuildContext context,
  ) {
    final duaData = data.data() as Map<String, dynamic>;
    final heading = duaData['heading']?.toString() ?? 'Untitled Dua';

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
              builder: (_) => RamzanDuaDetailScreen(data: duaData),
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
                      // Optional: Show category if available
                      if (duaData.containsKey('category') &&
                          duaData['category'] != null &&
                          duaData['category'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              duaData['category'].toString(),
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
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

  // Method to get uncategorized duas
  List<QueryDocumentSnapshot> _getUncategorizedDuas() {
    return allDuas.where((dua) {
      final duaData = dua.data() as Map<String, dynamic>;
      return !duaData.containsKey('category') ||
          duaData['category'] == null ||
          duaData['category'].toString().isEmpty;
    }).toList();
  }

  // Method to get categorized duas
  List<QueryDocumentSnapshot> _getCategorizedDuas(String category) {
    return allDuas.where((dua) {
      final duaData = dua.data() as Map<String, dynamic>;
      return duaData.containsKey('category') &&
          duaData['category']?.toString() == category;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Apply search filtering
    final filteredCategories = _filterCategories(categories);
    final filteredUncategorized = _filterDuas(_getUncategorizedDuas());

    final hasCategories = filteredCategories.isNotEmpty;
    final hasUncategorized = filteredUncategorized.isNotEmpty;
    final hasAnyContent = hasCategories || hasUncategorized;
    final hasSearchResults =
        _searchQuery.isNotEmpty &&
        (filteredCategories.isNotEmpty || filteredUncategorized.isNotEmpty);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Search Ramadan duas or categories...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, color: Colors.white),
                    onPressed: _clearSearch,
                  ),
                ),
              )
            : const Text(
                'Ramadan Duas',
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
        actions: [
          // 🔥 REPLACED: Refresh icon with search icon
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search',
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
                    'Loading Ramadan Duas...',
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
                    // 🔥 NEW: Search results count (when searching)
                    if (_searchQuery.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                size: 16,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Found ${filteredCategories.length} categories & ${filteredUncategorized.length} duas',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 🔥 NEW: No search results message
                    if (_searchQuery.isNotEmpty && !hasSearchResults)
                      SliverToBoxAdapter(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(top: 20),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_rounded,
                                  size: 80,
                                  color: textTertiary.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No results found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'No categories or duas match "$_searchQuery"',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _clearSearch,
                                  icon: const Icon(Icons.clear_rounded),
                                  label: const Text('Clear Search'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Categories Section (filtered)
                    if (hasCategories)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: 12,
                              top: index == 0 ? 0 : 0,
                            ),
                            child: _buildCategoryCard(
                              filteredCategories[index],
                              index,
                              context,
                            ),
                          );
                        }, childCount: filteredCategories.length),
                      ),

                    // Uncategorized Duas Section (filtered)
                    if (hasUncategorized)
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildDuaCard(
                              filteredUncategorized[index],
                              index,
                              context,
                            ),
                          );
                        }, childCount: filteredUncategorized.length),
                      ),

                    // Empty State (when no content and no search)
                    if (!hasAnyContent && _searchQuery.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          margin: const EdgeInsets.only(top: 60),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: dividerColor.withValues(alpha: 0.8),
                              width: 1,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.file_copy,
                                color: textTertiary,
                                size: 60,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Ramadan Duas Available',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add some duas from the admin panel',
                                style: TextStyle(
                                  color: textTertiary,
                                  fontSize: 14,
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
