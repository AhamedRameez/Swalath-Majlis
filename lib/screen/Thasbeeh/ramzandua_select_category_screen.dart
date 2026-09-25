import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RamzanDuaSelectCategoryScreen extends StatefulWidget {
  final String category;

  const RamzanDuaSelectCategoryScreen({super.key, required this.category});

  @override
  State<RamzanDuaSelectCategoryScreen> createState() =>
      _RamzanDuaSelectCategoryScreenState();
}

class _RamzanDuaSelectCategoryScreenState
    extends State<RamzanDuaSelectCategoryScreen> {
  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  List<QueryDocumentSnapshot> categoryDuas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategoryDuas();
  }

  Future<void> _loadCategoryDuas() async {
    setState(() => _isLoading = true);

    try {
      print('🔍 Loading duas for category: "${widget.category}"');

      // First try exact match
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('Ramzan_duas')
          .where('category', isEqualTo: widget.category)
          .orderBy('createdAt', descending: true)
          .get();

      print('✅ Found ${snapshot.docs.length} duas with exact category match');

      if (snapshot.docs.isEmpty) {
        // Try case-insensitive search as fallback
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
    } catch (e) {
      print('❌ Error loading category duas: $e');
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDuaCard(QueryDocumentSnapshot data, int index) {
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
                      if (arabic.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        // Arabic preview
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            arabic,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontFamily: 'Scheherazade',
                              color: textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open_rounded,
                              size: 12,
                              color: primaryColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.category,
                              style: const TextStyle(
                                color: primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${categoryDuas.length} ${categoryDuas.length == 1 ? 'dua' : 'duas'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
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
            onPressed: _loadCategoryDuas,
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
          : categoryDuas.isEmpty
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
                        Icons.folder_open_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Duas Found',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
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
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: primaryColor,
              backgroundColor: backgroundColor,
              onRefresh: _loadCategoryDuas,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: categoryDuas.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    return _buildDuaCard(categoryDuas[index], index);
                  },
                ),
              ),
            ),
    );
  }
}
