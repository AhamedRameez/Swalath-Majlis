// lib/screen/qa_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qa_detail_screen.dart';
import 'qa_folder_screen.dart';

class QAListScreen extends StatefulWidget {
  const QAListScreen({super.key});

  @override
  State<QAListScreen> createState() => _QAListScreenState();
}

class _QAListScreenState extends State<QAListScreen> {
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color qaColor = Color(0xFF9C27B0);

  List<Map<String, dynamic>> _categories = [];
  bool _isLoadingCategories = true;

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
          .collection('qa_categories')
          .orderBy('name')
          .get();

      List<Map<String, dynamic>> categoriesWithCounts = [];

      for (var doc in snapshot.docs) {
        final categoryName = doc['name'] as String;

        final countSnapshot = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('qa_section')
            .where('category', isEqualTo: categoryName)
            .count()
            .get();

        categoriesWithCounts.add({
          'name': categoryName,
          'count': countSnapshot.count ?? 0,
          'order': doc['order'] ?? 999, // 🆕 Get order field
        });
      }

      // 🆕 Sort by order field (client-side)
      categoriesWithCounts.sort((a, b) {
        return (a['order'] as num).compareTo(b['order'] as num);
      });

      setState(() {
        _categories = categoriesWithCounts;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 6,
        backgroundColor: qaColor,
        title: const Text(
          'Question & Answer',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
                hintText: 'Search questions...',
                prefixIcon: Icon(Icons.search_rounded, color: qaColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: qaColor, width: 2),
                ),
                filled: true,
                fillColor: backgroundColor,
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================== CATEGORY FOLDERS ====================
                  if (_searchQuery.isEmpty) ...[
                    if (_isLoadingCategories)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: qaColor),
                        ),
                      )
                    else if (_categories.isNotEmpty)
                      ..._categories.map((category) {
                        return Container(
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
                              category['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '${category['count']} Q&A',
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
                                '${category['count']}',
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
                                    category: category['name'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // Divider
                    if (_categories.isNotEmpty)
                      Container(
                        height: 1,
                        color: dividerColor,
                      ),
                    if (_categories.isNotEmpty) const SizedBox(height: 16),
                  ],

                  // ==================== UNCATEGORIZED Q&A ====================
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('swalathmajlis')
                        .doc('iM6QRMlgUuWNbUdgQ0')
                        .collection('qa_section')
                        .snapshots(), // ✅ Removed orderBy
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: qaColor),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: dividerColor),
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

                      // ✅ Sort by order field (client-side)
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aOrder = aData['order'] ?? 999;
                        final bOrder = bData['order'] ?? 999;
                        return (aOrder as num).compareTo(bOrder as num);
                      });

                      // Apply search filter
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final question =
                              data['question']?.toString().toLowerCase() ?? '';
                          return question.contains(_searchQuery);
                        }).toList();
                      }

                      if (docs.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: dividerColor),
                          ),
                          child: Center(
                            child: Text(
                              _searchQuery.isNotEmpty
                                  ? 'No matching Q&A'
                                  : 'No Q&A available',
                              style: const TextStyle(color: textSecondary),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: List.generate(docs.length, (index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final question = data['question'] ?? 'No question';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: qaColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: qaColor.withValues(alpha: 0.05),
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
                                  color: qaColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: qaColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                question,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  color: textPrimary,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: qaColor,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QADetailScreen(
                                      qaData: data,
                                      docId: doc.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
