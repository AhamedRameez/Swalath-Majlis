// lib/screen/user/namaz_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'namaz_detail_screen.dart';
import '../../utils/salah_constants.dart';

class NamazListScreen extends StatefulWidget {
  const NamazListScreen({super.key});

  @override
  State<NamazListScreen> createState() => _NamazListScreenState();
}

class _NamazListScreenState extends State<NamazListScreen> {
  // ==================== COLOR SCHEME ====================
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // ==================== SEARCH ====================
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Namaz Guides',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              _showSearchDialog(context);
            },
            tooltip: 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('swalathmajlis')
                  .doc('iM6QRMlgUuWNbUdgQ0')
                  .collection('salahs')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red[400],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading Namaz guides',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mosque_rounded,
                          color: textTertiary,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Namaz Guides Available',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Check back later for updates',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter data based on search query
                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = data['name']?.toString().toLowerCase() ?? '';
                  final englishName =
                      data['englishName']?.toString().toLowerCase() ?? '';
                  final description =
                      data['description']?.toString().toLowerCase() ?? '';
                  final query = _searchQuery.toLowerCase();
                  return name.contains(query) ||
                      englishName.contains(query) ||
                      description.contains(query);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: textTertiary,
                          size: 56,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No results found',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching with different keywords',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredDocs.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      final name = data['name']?.toString() ?? 'Unnamed Namaz';
                      final englishName = data['englishName']?.toString() ?? '';
                      final description = data['description']?.toString() ?? '';
                      final textBlocks =
                          data['textBlocks'] as List<dynamic>? ?? [];

                      // 🖼️ USE LIST IMAGE if available, otherwise fallback to first detail image
                      String listImagePath = data['listImagePath'] ?? '';
                      if (listImagePath.isEmpty) {
                        final detailPaths =
                            data['detailImagePaths'] as List<dynamic>? ?? [];
                        if (detailPaths.isNotEmpty) {
                          listImagePath = detailPaths.first.toString();
                        } else {
                          // Fallback to old format
                          final oldPaths =
                              data['imagePaths'] as List<dynamic>? ?? [];
                          if (oldPaths.isNotEmpty) {
                            listImagePath = oldPaths.first.toString();
                          } else {
                            listImagePath = SalahConstants.defaultListImage;
                          }
                        }
                      }

                      return _buildNamazCard(
                        context: context,
                        docId: doc.id,
                        name: name,
                        englishName: englishName,
                        description: description,
                        listImagePath: listImagePath,
                        textBlockCount: textBlocks.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NamazDetailScreen(
                                docId: doc.id,
                                data: data,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SEARCH BAR ====================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search Namaz guides...',
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: Colors.grey[600]),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
        ),
      ),
    );
  }

  // ==================== SEARCH DIALOG ====================
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Search Namaz',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Type to search...',
              prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                });
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  // ==================== BUILD NAMAZ CARD ====================
  Widget _buildNamazCard({
    required BuildContext context,
    required String docId,
    required String name,
    required String englishName,
    required String description,
    required String listImagePath,
    required int textBlockCount,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: dividerColor.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🖼️ LIST IMAGE (separate from detail images)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Image.asset(
                    listImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: primaryColor.withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.mosque_rounded,
                        color: primaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Arabic Name
                    Text(
                      name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Amiri',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.rtl,
                    ),
                    // English Name
                    if (englishName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        englishName,
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    // Description
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Arrow Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
