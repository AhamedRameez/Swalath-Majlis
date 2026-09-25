// lib/screen/setting/app admin/studies/islamicstudy_display_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'islamicstudy_enter_screen.dart';
import 'islamicstudy_detail_screen.dart';

class IslamicStudyDisplayScreen extends StatefulWidget {
  const IslamicStudyDisplayScreen({super.key});

  @override
  State<IslamicStudyDisplayScreen> createState() =>
      _IslamicStudyDisplayScreenState();
}

class _IslamicStudyDisplayScreenState extends State<IslamicStudyDisplayScreen> {
  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color deleteColor = Color(0xFFE57373);
  static const Color editColor = Color(0xFF4CAF50);
  static const Color headingColor = Color(0xFFFFA726);
  static const Color folderColor = Color(0xFFD4AF37); // Gold for folder

  String? _selectedCategory;
  List<String> _categories = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('islamicstudy_categories')
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

  Future<void> _deleteStudy(String docId, String title) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Study'),
        content: Text('Are you sure you want to delete "$title"?'),
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
                    .collection('islamicstudy')
                    .doc(docId)
                    .delete();

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$title" deleted'),
                      backgroundColor: deleteColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryColor,
        title: const Text(
          'Islamic Studies',
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
                  child: Text('All Studies'),
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: cardColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by title...',
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
          ),

          // Studies List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('swalathmajlis')
                  .doc('iM6QRMlgUuWNbUdgQ0')
                  .collection('islamicstudy')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_rounded,
                            color: primaryColor.withValues(alpha: 0.3), size: 80),
                        const SizedBox(height: 16),
                        Text(
                          'No Islamic Studies Found',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first study',
                          style: TextStyle(color: textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                var docs = snapshot.data!.docs;

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
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    return title.contains(_searchQuery);
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
                          'No matching studies',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
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
                    final docId = doc.id;
                    final title = data['title'] ?? 'Untitled';
                    final category = data['category'];
                    final folder = data['folder']; // 🆕 Get folder
                    final content = data['content'] as List<dynamic>?;
                    final contentPreview = content != null && content.isNotEmpty
                        ? content.firstWhere(
                            (c) => c['type'] == 'paragraph',
                            orElse: () => content.first,
                          )['text']
                        : 'No content';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            // 🆕 Category and Folder badges in a Row
                            Row(
                              children: [
                                // Category Badge
                                if (category != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      category.toString(),
                                      style: TextStyle(
                                        color: accentColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                // 🆕 Folder Badge
                                if (folder != null &&
                                    folder.toString().isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: folderColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.folder_rounded,
                                          size: 10,
                                          color: folderColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          folder.toString(),
                                          style: TextStyle(
                                            color: folderColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contentPreview.toString(),
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: editColor),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IslamicStudyEnterScreen(
                                      isEditMode: true,
                                      studyData: data,
                                      docId: docId,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Updated'),
                                      backgroundColor: editColor,
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_rounded,
                                  color: deleteColor),
                              onPressed: () => _deleteStudy(docId, title),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IslamicStudyDetailScreen(
                                studyData: data,
                                docId: docId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const IslamicStudyEnterScreen(),
            ),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Study added'),
                backgroundColor: primaryColor,
              ),
            );
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
