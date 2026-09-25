// lib/screen/admin/admin_swalath_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'swalath_enter_screen.dart';

class AdminSwalathListScreen extends StatefulWidget {
  const AdminSwalathListScreen({super.key});

  @override
  State<AdminSwalathListScreen> createState() => _AdminSwalathListScreenState();
}

class _AdminSwalathListScreenState extends State<AdminSwalathListScreen> {
  // Your app's beautiful color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color(0xFF1A472A);
  static const Color moveColor = Color(0xFFFFA726); // Orange for move buttons

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'swalathmajlis/iM6QRMlgUuWNbUdgQ0/swalath';
  final String _categoriesPath =
      'swalathmajlis/iM6QRMlgUuWNbUdgQ0/swalath_categories';

  // To track if we're in reorder mode
  bool _isReordering = false;

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Filter by category
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot =
          await _firestore.collection(_categoriesPath).orderBy('name').get();

      setState(() {
        _categories = [
          'All',
          ...snapshot.docs.map((doc) => doc['name'] as String)
        ];
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Move swalath up (decrease index)
  Future<void> _moveSwalathUp(
      List<QueryDocumentSnapshot> docs, int currentIndex) async {
    if (currentIndex == 0) return; // Already at top

    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('swalath');

    final currentDoc = docs[currentIndex];
    final previousDoc = docs[currentIndex - 1];

    final currentData = currentDoc.data() as Map<String, dynamic>;
    final previousData = previousDoc.data() as Map<String, dynamic>;

    // Swap order values or timestamps
    final currentTimestamp = currentData['createdAt'] ?? Timestamp.now();
    final previousTimestamp = previousData['createdAt'] ?? Timestamp.now();

    batch.update(collectionRef.doc(currentDoc.id), {
      'createdAt': previousTimestamp,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(collectionRef.doc(previousDoc.id), {
      'createdAt': currentTimestamp,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Swalath moved up successfully'),
            backgroundColor: moveColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error moving swalath: $e');
    }
  }

  // Move swalath down (increase index)
  Future<void> _moveSwalathDown(
      List<QueryDocumentSnapshot> docs, int currentIndex) async {
    if (currentIndex == docs.length - 1) return; // Already at bottom

    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('swalath');

    final currentDoc = docs[currentIndex];
    final nextDoc = docs[currentIndex + 1];

    final currentData = currentDoc.data() as Map<String, dynamic>;
    final nextData = nextDoc.data() as Map<String, dynamic>;

    // Swap order values or timestamps
    final currentTimestamp = currentData['createdAt'] ?? Timestamp.now();
    final nextTimestamp = nextData['createdAt'] ?? Timestamp.now();

    batch.update(collectionRef.doc(currentDoc.id), {
      'createdAt': nextTimestamp,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(collectionRef.doc(nextDoc.id), {
      'createdAt': currentTimestamp,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    try {
      await batch.commit();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Swalath moved down successfully'),
            backgroundColor: moveColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error moving swalath: $e');
    }
  }

  Future<void> _deleteSwalath(String docId, String title) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            const Text(
              'Delete Swalath',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$title"? This action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore
                    .collection(_collectionPath)
                    .doc(docId)
                    .delete();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white),
                          const SizedBox(width: 12),
                          Text('Swalath "$title" deleted successfully'),
                        ],
                      ),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting: $e'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _editSwalath(
      Map<String, dynamic> swalathData, String docId) async {
    // Navigate to edit screen with existing data
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SwalathEnterScreen(
          isEditMode: true,
          swalathData: swalathData,
          docId: docId,
        ),
      ),
    );

    // If edit was successful, refresh the list
    if (result == true && mounted) {
      setState(() {});
    }
  }

  String _getPreviewText(Map<String, dynamic> data) {
    if (data['style'] == 'verse') {
      final verses = data['verses'] as List<dynamic>? ?? [];
      if (verses.isNotEmpty) {
        final firstVerse = verses.first as Map<String, dynamic>;
        return firstVerse['arabic'] ?? '';
      }
      return '';
    } else {
      return data['arabic'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Manage Swalath',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        actions: [
          // Toggle Reorder Mode
          IconButton(
            icon: Icon(
              _isReordering ? Icons.sort_by_alpha : Icons.swap_vert_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isReordering = !_isReordering;
              });
            },
            tooltip: _isReordering ? 'Exit Reorder Mode' : 'Reorder Swalath',
          ),

          // Add new Swalath button
          IconButton(
            icon: const Icon(Icons.add_circle_rounded),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SwalathEnterScreen(),
                ),
              );
              if (result == true && mounted) {
                setState(() {});
                await _loadCategories(); // Reload categories if new one added
              }
            },
            tooltip: 'Add New Swalath',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search swalath...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon:
                          const Icon(Icons.search_rounded, color: primaryColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : primaryColor,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: primaryColor,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          checkmarkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? primaryColor
                                  : primaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Reorder mode indicator
                if (_isReordering) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: moveColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: moveColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swap_vert_rounded,
                            color: moveColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reorder mode: Use up/down arrows to change display order',
                            style: TextStyle(
                              color: moveColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Stats Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'All Swalath',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const Spacer(),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore.collection(_collectionPath).snapshots(),
                  builder: (context, snapshot) {
                    int count = snapshot.data?.docs.length ?? 0;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count total',
                        style: const TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List of Swalath
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection(_collectionPath)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded,
                            color: Colors.red[400], size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading data',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
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
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            size: 40,
                            color: primaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Swalath yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap + to add your first Swalath',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SwalathEnterScreen(),
                              ),
                            );
                            if (result == true && mounted) {
                              setState(() {});
                              await _loadCategories();
                            }
                          },
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Swalath'),
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
                  );
                }

                // Filter by search query and category
                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final category = data['category']?.toString() ?? '';

                  // Apply search filter
                  final matchesSearch =
                      _searchQuery.isEmpty || title.contains(_searchQuery);

                  // Apply category filter
                  final matchesCategory = _selectedCategory == 'All' ||
                      category == _selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try a different search term or category',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title'] ?? 'Untitled';
                    final description = data['description'] ?? '';
                    final style = data['style'] ?? 'normal';
                    final category = data['category'];
                    final hasDua = data['dua'] != null &&
                        data['dua'].toString().isNotEmpty;
                    final previewText = _getPreviewText(data);
                    final timestamp = data['createdAt'] as Timestamp?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Main content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with title and badges
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: style == 'verse'
                                              ? [
                                                  accentColor,
                                                  accentColor.withValues(alpha: 0.8)
                                                ]
                                              : [
                                                  primaryColor,
                                                  primaryColor.withValues(alpha: 0.8)
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          style == 'verse'
                                              ? Icons.format_quote_rounded
                                              : Icons.auto_stories_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'Poppins',
                                              color: textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              // Style badge
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: style == 'verse'
                                                      ? accentColor
                                                          .withValues(alpha: 0.1)
                                                      : Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  style == 'verse'
                                                      ? 'Verse Style'
                                                      : 'Normal',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: style == 'verse'
                                                        ? accentColor
                                                        : textSecondary,
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ),
                                              // Category badge
                                              if (category != null &&
                                                  category.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: primaryColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.folder_rounded,
                                                        size: 10,
                                                        color: primaryColor,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        category,
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: primaryColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily: 'Poppins',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // Dua badge
                                              if (hasDua)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'Has Dua',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.green.shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                if (description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.description_outlined,
                                          size: 14,
                                          color: textSecondary,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: textSecondary,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                // Preview of content
                                if (previewText.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: arabicTextColor.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: arabicTextColor.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      previewText,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Amiri',
                                        color: arabicTextColor,
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 12),

                                // Footer with timestamp
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 14,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      timestamp != null
                                          ? 'Added: ${_formatDate(timestamp.toDate())}'
                                          : 'Just now',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Action buttons
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              border: const Border(
                                top: BorderSide(
                                  color: dividerColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Reorder buttons (show when in reorder mode)
                                if (_isReordering)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Up Arrow
                                      if (index > 0)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () =>
                                                _moveSwalathUp(docs, index),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    moveColor.withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.arrow_upward_rounded,
                                                    size: 16,
                                                    color: moveColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Up',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: moveColor,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 8),

                                      // Down Arrow
                                      if (index < docs.length - 1)
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () =>
                                                _moveSwalathDown(docs, index),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    moveColor.withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .arrow_downward_rounded,
                                                    size: 16,
                                                    color: moveColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Down',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: moveColor,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),

                                // Edit button (show in both modes)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _editSwalath(data, doc.id),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.edit_rounded,
                                            size: 16,
                                            color: primaryColor,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Delete button (show in both modes)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _deleteSwalath(doc.id, title),
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_rounded,
                                            size: 16,
                                            color: Colors.red[400],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.red[400],
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
