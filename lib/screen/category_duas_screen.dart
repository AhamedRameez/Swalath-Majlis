// lib/screen/category_duas_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Duas/dua_detail_screen.dart';

class CategoryDuasScreen extends StatefulWidget {
  final String category;

  const CategoryDuasScreen({super.key, required this.category});

  @override
  State<CategoryDuasScreen> createState() => _CategoryDuasScreenState();
}

class _CategoryDuasScreenState extends State<CategoryDuasScreen> {
  List<QueryDocumentSnapshot> categoryDuas = [];
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
    _loadCategoryDuas();
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

  Future<void> _loadCategoryDuas() async {
    try {
      print('Loading duas for category: "${widget.category}"');

      // First, let's check what categories actually exist in the duas
      final allDuas = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('duas')
          .get();

      print('Total duas in database: ${allDuas.docs.length}');

      // Find all unique categories from actual duas
      final Set<String> actualCategories = {};
      for (var dua in allDuas.docs) {
        final duaData = dua.data();
        if (duaData.containsKey('category') &&
            duaData['category'] != null &&
            duaData['category'].toString().isNotEmpty) {
          actualCategories.add(duaData['category'].toString());
        }
      }

      print('Actual categories found in duas: $actualCategories');
      print('Looking for: "${widget.category}"');
      print('Exact match? ${actualCategories.contains(widget.category)}');

      // Try to find duas with this category
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('duas')
          .where('category', isEqualTo: widget.category)
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${snapshot.docs.length} duas with exact category match');

      // If no exact match, try case-insensitive search
      if (snapshot.docs.isEmpty) {
        print(
          'No exact match found. Trying to find case-insensitive matches...',
        );

        // Get all duas and filter locally
        final allDuasSnapshot = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('duas')
            .orderBy('createdAt', descending: true)
            .get();

        final filteredDuas = allDuasSnapshot.docs.where((dua) {
          final duaData = dua.data();
          if (duaData.containsKey('category') &&
              duaData['category'] != null &&
              duaData['category'].toString().isNotEmpty) {
            final duaCategory = duaData['category'].toString().trim();
            return duaCategory.toLowerCase() == widget.category.toLowerCase();
          }
          return false;
        }).toList();

        print('Found ${filteredDuas.length} duas with case-insensitive match');

        setState(() {
          categoryDuas = filteredDuas;
          _isLoading = false;
        });
      } else {
        setState(() {
          categoryDuas = snapshot.docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading category duas: $e');
      setState(() => _isLoading = false);
    }
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
            MaterialPageRoute(builder: (_) => DuaDetailScreen(data: duaData)),
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
                      const SizedBox(height: 8),
                      // Category badge (commented out as in original)
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

  @override
  Widget build(BuildContext context) {
    final filteredDuas = _filterDuas(categoryDuas);
    final hasSearchResults = _searchQuery.isNotEmpty && filteredDuas.isNotEmpty;

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
                  hintText: 'Search in ${widget.category}...',
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
            : Text(
                widget.category,
                style: const TextStyle(
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
          // 🔥 NEW: Search toggle button
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close_rounded : Icons.search_rounded,
            ),
            onPressed: _toggleSearch,
            tooltip: _isSearching ? 'Close search' : 'Search in this category',
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
          : categoryDuas.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No Duas in "${widget.category}"',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This category exists but has no duas yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: backgroundColor,
                onRefresh: _loadCategoryDuas,
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
                                  'Found ${filteredDuas.length} ${filteredDuas.length == 1 ? 'dua' : 'duas'}',
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
                                  'No duas match "$_searchQuery" in this category',
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

                    // Duas list (filtered)
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDuaCard(
                            filteredDuas[index],
                            index,
                            context,
                          ),
                        );
                      }, childCount: filteredDuas.length),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
