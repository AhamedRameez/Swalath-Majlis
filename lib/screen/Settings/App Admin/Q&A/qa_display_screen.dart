// lib/screen/Settings/App Admin/qa_display_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qa_enter_screen.dart';
import 'qa_folder_screen.dart';

class QADisplayScreen extends StatefulWidget {
  const QADisplayScreen({super.key});

  @override
  State<QADisplayScreen> createState() => _QADisplayScreenState();
}

class _QADisplayScreenState extends State<QADisplayScreen> {
  static const Color primaryColor = Color(0xFF3D2A5B);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF5FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2E1065);
  static const Color textSecondary = Color(0xFF7E22CE);
  static const Color borderColor = Color(0xFFE0D5F5);
  static const Color deleteColor = Color(0xFFE57373);
  static const Color editColor = Color(0xFF4CAF50);
  static const Color moveColor = Color(0xFFFFA726);

  String? _selectedCategory;
  List<String> _categories = [];
  List<Map<String, dynamic>> _folders = [];
  bool _isLoadingFolders = true;

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
    _loadFolders();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_categories')
          .orderBy('name') // ✅ Changed from 'order' to 'name'
          .get();

      setState(() {
        _categories =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadFolders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_categories')
          .orderBy('name') // ✅ Changed from 'order' to 'name'
          .get();

      List<Map<String, dynamic>> foldersWithCounts = [];

      for (var doc in snapshot.docs) {
        final folderName = doc['name'] as String;
        final folderDocId = doc.id;

        final countSnapshot = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('qa_section')
            .where('category', isEqualTo: folderName)
            .count()
            .get();

        foldersWithCounts.add({
          'docId': folderDocId,
          'name': folderName,
          'count': countSnapshot.count ?? 0,
        });
      }

      // ✅ Sort by order field (client-side, fallback to name)
      foldersWithCounts.sort((a, b) {
        final aOrder = a['order'] ?? 999;
        final bOrder = b['order'] ?? 999;
        return (aOrder as num).compareTo(bOrder as num);
      });

      setState(() {
        _folders = foldersWithCounts;
        _isLoadingFolders = false;
      });
    } catch (e) {
      print('Error loading folders: $e');
      setState(() => _isLoadingFolders = false);
    }
  }

  // 🆕 Update folder order in Firestore
  Future<void> _updateFolderOrder(List<String> folderDocIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final categoriesRef = FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_categories');

      for (int i = 0; i < folderDocIds.length; i++) {
        batch.update(categoriesRef.doc(folderDocIds[i]), {
          'order': i,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _moveQAUp(String docId, int currentOrder) async {
    if (currentOrder <= 0) return;

    try {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_section')
          .doc(docId)
          .update({
        'order': currentOrder - 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _moveQADown(
      String docId, int currentOrder, int totalCount) async {
    if (currentOrder >= totalCount - 1) return;

    try {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_section')
          .doc(docId)
          .update({
        'order': currentOrder + 1,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteQA(String docId, String question) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Q&A',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$question"?',
          style: const TextStyle(fontSize: 14),
        ),
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
                    .collection('qa_section')
                    .doc(docId)
                    .delete();

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$question" deleted'),
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
          'Q&A Management',
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
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              _loadCategories();
              _loadFolders();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================== FOLDER SECTION (Reorderable) ====================
            if (_isLoadingFolders)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              )
            else if (_folders.isNotEmpty)
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _folders.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final folder = _folders.removeAt(oldIndex);
                    _folders.insert(newIndex, folder);

                    // Update order in Firestore
                    final folderDocIds =
                        _folders.map((f) => f['docId'] as String).toList();
                    _updateFolderOrder(folderDocIds);
                  });
                },
                buildDefaultDragHandles: true,
                itemBuilder: (context, index) {
                  final folder = _folders[index];

                  return Container(
                    key: ValueKey(folder['docId']),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder_rounded,
                          color: accentColor,
                          size: 26,
                        ),
                      ),
                      title: Text(
                        folder['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${folder['count']} Q&A',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${folder['count']}',
                          style: const TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => QAFolderScreen(
                              folderName: folder['name'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

            if (_folders.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                height: 1,
                color: borderColor,
              ),
              const SizedBox(height: 16),
            ],

            // ==================== UNCATEGORIZED Q&A ====================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('swalathmajlis')
                  .doc('iM6QRMlgUuWNbUdgQ0')
                  .collection('qa_section')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Center(
                      child: Text(
                        'No Q&A available',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  );
                }

                // Filter: Only uncategorized Q&A
                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final category = data['category'];
                  return category == null || category.toString().isEmpty;
                }).toList();

                // Sort by order field
                docs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aOrder = aData['order'] ?? 0;
                  final bOrder = bData['order'] ?? 0;
                  return (aOrder as num).compareTo(bOrder as num);
                });

                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: const Center(
                      child: Text(
                        'No uncategorized Q&A',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  );
                }

                return Column(
                  children: List.generate(docs.length, (index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final question = data['question'] ?? 'No question';
                    final answer = data['answer'] ?? '';
                    final order = data['order'] ?? index;

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
                          question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          answer,
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_upward_rounded,
                                color: index > 0
                                    ? moveColor
                                    : Colors.grey.withValues(alpha: 0.3),
                                size: 18,
                              ),
                              onPressed: index > 0
                                  ? () => _moveQAUp(docId, order)
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: 'Move Up',
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_downward_rounded,
                                color: index < docs.length - 1
                                    ? moveColor
                                    : Colors.grey.withValues(alpha: 0.3),
                                size: 18,
                              ),
                              onPressed: index < docs.length - 1
                                  ? () => _moveQADown(docId, order, docs.length)
                                  : null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              tooltip: 'Move Down',
                            ),
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: editColor),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QAEnterScreen(
                                      isEditMode: true,
                                      qaData: data,
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
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_rounded,
                                  color: deleteColor),
                              onPressed: () => _deleteQA(docId, question),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const QAEnterScreen(),
            ),
          );
          if (result == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Q&A added'),
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
