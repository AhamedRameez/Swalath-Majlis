// lib/screens/ramzan_category_duas_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ramzan_dua_detail_screen.dart';

class RamzanCategoryDuasScreen extends StatefulWidget {
  final String category;

  const RamzanCategoryDuasScreen({super.key, required this.category});

  @override
  State<RamzanCategoryDuasScreen> createState() =>
      _RamzanCategoryDuasScreenState();
}

class _RamzanCategoryDuasScreenState extends State<RamzanCategoryDuasScreen> {
  List<QueryDocumentSnapshot> categoryDuas = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

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
  }

  Future<void> _loadCategoryDuas() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      print('🔍 Loading duas for category: "${widget.category}"');

      // 🔴 FIXED: Use Stream for real-time updates, but for initial load use get()
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('Ramzan_duas')
          .where('category', isEqualTo: widget.category)
          .orderBy('createdAt', descending: true)
          .get();

      print('✅ Found ${snapshot.docs.length} duas with exact category match');

      if (snapshot.docs.isEmpty) {
        // If no exact match, try case-insensitive search as fallback
        print('⚠️ No exact match. Trying case-insensitive search...');

        final allDuasSnapshot = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('Ramzan_duas')
            .orderBy('createdAt', descending: true)
            .get();

        final filteredDuas = allDuasSnapshot.docs.where((dua) {
          final duaData = dua.data();
          if (duaData.containsKey('category') && duaData['category'] != null) {
            final duaCategory = duaData['category'].toString().trim();
            // Case-insensitive comparison
            return duaCategory.toLowerCase() == widget.category.toLowerCase();
          }
          return false;
        }).toList();

        print(
          '✅ Found ${filteredDuas.length} duas with case-insensitive match',
        );

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

      // If still no duas found, show appropriate message
      if (categoryDuas.isEmpty) {
        print('ℹ️ No duas found for category: "${widget.category}"');
      }
    } catch (e) {
      print('❌ Error loading category duas: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildDuaCard(
    QueryDocumentSnapshot data,
    int index,
    BuildContext context,
  ) {
    final duaData = data.data() as Map<String, dynamic>;
    final heading = duaData['heading']?.toString() ?? 'Untitled Dua';

    // Check if Arabic content exists
    final hasArabic =
        duaData.containsKey('arabic') &&
        duaData['arabic'] != null &&
        duaData['arabic'].toString().isNotEmpty;

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
                      // Heading
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

                      // Category badge and Arabic indicator
                      const Row(
                        children: [
                          // // Category badge
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //     horizontal: 10,
                          //     vertical: 4,
                          //   ),
                          //   decoration: BoxDecoration(
                          //     color: primaryColor.withOpacity(0.08),
                          //     borderRadius: BorderRadius.circular(20),
                          //     border: Border.all(
                          //       color: primaryColor.withOpacity(0.2),
                          //       width: 1,
                          //     ),
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       Icon(
                          //         Icons.folder_open_rounded,
                          //         size: 12,
                          //         color: primaryColor.withOpacity(0.7),
                          //       ),
                          //       const SizedBox(width: 4),
                          //       Text(
                          //         widget.category,
                          //         style: const TextStyle(
                          //           color: primaryColor,
                          //           fontSize: 11,
                          //           fontWeight: FontWeight.w500,
                          //           fontFamily: 'Poppins',
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // const SizedBox(width: 8),

                          // Arabic indicator
                          // if (hasArabic)
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 8,
                          //       vertical: 4,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: accentColor.withOpacity(0.08),
                          //       borderRadius: BorderRadius.circular(20),
                          //       border: Border.all(
                          //         color: accentColor.withOpacity(0.2),
                          //         width: 1,
                          //       ),
                          //     ),
                          // child: Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Icon(
                          //       Icons.translate_rounded,
                          //       size: 10,
                          //       color: accentColor.withOpacity(0.7),
                          //     ),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       'العربية',
                          //       style: TextStyle(
                          //         color: accentColor,
                          //         fontSize: 9,
                          //         fontWeight: FontWeight.w500,
                          //         fontFamily: 'Poppins',
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // ),
                        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadCategoryDuas,
            tooltip: 'Refresh',
          ),
        ],
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
          : _hasError
          ? _buildErrorWidget()
          : categoryDuas.isEmpty
          ? _buildEmptyWidget()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RefreshIndicator(
                color: primaryColor,
                backgroundColor: backgroundColor,
                onRefresh: _loadCategoryDuas,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: categoryDuas.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _buildDuaCard(categoryDuas[index], index, context);
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.folder_open_rounded,
                color: primaryColor.withValues(alpha: 0.6),
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Duas Found',
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The category "${widget.category}" has no duas yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 16,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later or explore other categories.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textTertiary,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text(
                'Go Back',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: Colors.red[400],
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something Went Wrong',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load duas for this category.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadCategoryDuas,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Try Again',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
