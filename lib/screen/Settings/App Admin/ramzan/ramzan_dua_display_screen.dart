//lib/screens/ramzan_dua_display_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Ramzan_dua_enter_screen.dart';

class RamzanDuaDisplayScreen extends StatefulWidget {
  const RamzanDuaDisplayScreen({super.key});

  @override
  State<RamzanDuaDisplayScreen> createState() => _RamzanDuaDisplayScreenState();
}

class _RamzanDuaDisplayScreenState extends State<RamzanDuaDisplayScreen> {
  // 🌈 Color scheme matching Admin Dashboard
  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color deleteColor = Color(0xFFE57373);
  static const Color editColor = Color(0xFF4CAF50);
  static const Color moveColor = Color(0xFFFFA726); // Orange for move buttons

  String? _selectedCategory;
  List<String> _categories = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // To track if we're in reorder mode
  bool _isReordering = false;

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
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('ramzancategories')
          .orderBy('name')
          .get();

      setState(() {
        _categories =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _deleteDua(String docId, String heading) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dua'),
        content: Text('Are you sure you want to delete "$heading"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('swalathmajlis')
                    .doc('iM6QRMlgUuWNbUdgQ0')
                    .collection('Ramzan_duas')
                    .doc(docId)
                    .delete();

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$heading" deleted successfully'),
                      backgroundColor: deleteColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: deleteColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Move dua up (decrease index)
  Future<void> _moveDuaUp(
      List<QueryDocumentSnapshot> docs, int currentIndex) async {
    if (currentIndex == 0) return; // Already at top

    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('Ramzan_duas');

    final currentDoc = docs[currentIndex];
    final previousDoc = docs[currentIndex - 1];

    final currentData = currentDoc.data() as Map<String, dynamic>;
    final previousData = previousDoc.data() as Map<String, dynamic>;

    // Swap order values or timestamps
    // If you have a specific 'order' field, use that. Otherwise, swap createdAt timestamps
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
            content: const Text('Dua moved up successfully'),
            backgroundColor: moveColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error moving dua: $e');
    }
  }

  // Move dua down (increase index)
  Future<void> _moveDuaDown(
      List<QueryDocumentSnapshot> docs, int currentIndex) async {
    if (currentIndex == docs.length - 1) return; // Already at bottom

    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('Ramzan_duas');

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
            content: const Text('Dua moved down successfully'),
            backgroundColor: moveColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      print('Error moving dua: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryColor,
        title: const Text(
          'Ramadan Duas Management',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
            tooltip: _isReordering ? 'Exit Reorder Mode' : 'Reorder Duas',
          ),

          // Filter by category
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedCategory = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('All Duas'),
                ),
                const PopupMenuDivider(),
              ];

              items.addAll(
                _categories.map(
                  (category) => PopupMenuItem<String>(
                    value: category,
                    child: Text(category),
                  ),
                ),
              );

              return items;
            },
          ),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              setState(() {}); // Refresh the stream
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search duas by heading...',
                    prefixIcon: Icon(Icons.search_rounded, color: primaryColor),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 2),
                    ),
                    filled: true,
                    fillColor: backgroundColor,
                  ),
                ),

                // Filter Chip Row
                if (_selectedCategory != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.filter_alt_rounded,
                            color: primaryColor, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Category: $_selectedCategory',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = null;
                            });
                          },
                          child: Icon(Icons.close_rounded,
                              color: primaryColor, size: 16),
                        ),
                      ],
                    ),
                  ),
                ],

                // Reorder mode indicator
                if (_isReordering) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: moveColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: moveColor.withOpacity(0.3)),
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

          // Duas List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('swalathmajlis')
                  .doc('iM6QRMlgUuWNbUdgQ0')
                  .collection('Ramzan_duas')
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
                        Icon(Icons.error_outline, color: Colors.red, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading duas',
                          style: TextStyle(color: textPrimary, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(snapshot.error.toString()),
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
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: primaryColor.withOpacity(0.5),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Ramadan Duas Found',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap the + button to add your first Ramadan dua',
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

                // Filter and search logic
                var docs = snapshot.data!.docs.toList();

                // Apply category filter
                if (_selectedCategory != null) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['category'] == _selectedCategory;
                  }).toList();
                }

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final heading =
                        data['heading']?.toString().toLowerCase() ?? '';
                    return heading.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded,
                            color: textSecondary, size: 60),
                        const SizedBox(height: 16),
                        Text(
                          'No matching duas found',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    // Handle reorder if you want drag-and-drop
                    // This is kept minimal since we use buttons
                  },
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final heading = data['heading'] ?? 'Untitled';
                    final category = data['category'];
                    final hasArabic = data['arabic'] != null &&
                        data['arabic'].toString().isNotEmpty;

                    return Container(
                      key: ValueKey(docId),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          heading,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            if (category != null &&
                                category.toString().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category.toString(),
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (hasArabic)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'العربية',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                const Spacer(),
                                Text(
                                  'ID: ${docId.substring(0, 6)}...',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Up Arrow (only show in reorder mode and not at top)
                            if (_isReordering && index > 0)
                              IconButton(
                                icon: Icon(Icons.arrow_upward_rounded,
                                    color: moveColor, size: 20),
                                onPressed: () => _moveDuaUp(docs, index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),

                            // Down Arrow (only show in reorder mode and not at bottom)
                            if (_isReordering && index < docs.length - 1)
                              IconButton(
                                icon: Icon(Icons.arrow_downward_rounded,
                                    color: moveColor, size: 20),
                                onPressed: () => _moveDuaDown(docs, index),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),

                            // Spacing between move buttons and edit/delete
                            if (_isReordering) const SizedBox(width: 4),

                            // Edit Button (always show)
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: editColor),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RamzanDuasEnterScreen(
                                      isEditMode: true,
                                      duaData: data,
                                      docId: docId,
                                    ),
                                  ),
                                );

                                if (result == true && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('"$heading" updated'),
                                      backgroundColor: editColor,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),

                            // Delete Button (always show)
                            IconButton(
                              icon: Icon(Icons.delete_rounded,
                                  color: deleteColor),
                              onPressed: () => _deleteDua(docId, heading),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ➕ Add FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RamzanDuasEnterScreen(),
            ),
          );

          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('New Ramadan dua added'),
                backgroundColor: primaryColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}
