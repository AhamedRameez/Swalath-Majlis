// lib/screen/islamic_study_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'islamic_study_detail_screen.dart';
import 'study_folder_screen.dart';

class IslamicStudyListScreen extends StatefulWidget {
  final String category;
  final Color categoryColor;

  const IslamicStudyListScreen({
    super.key,
    required this.category,
    required this.categoryColor,
  });

  @override
  State<IslamicStudyListScreen> createState() => _IslamicStudyListScreenState();
}

class _IslamicStudyListScreenState extends State<IslamicStudyListScreen> {
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color folderColor = Color(0xFFD4AF37);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _folders = [];
  bool _isLoadingFolders = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('islamicstudy_folders')
          .where('category', isEqualTo: widget.category)
          .orderBy('name')
          .get();

      List<Map<String, dynamic>> foldersWithCounts = [];

      for (var doc in snapshot.docs) {
        final folderName = doc['name'] as String;

        final countSnapshot = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('islamicstudy')
            .where('category', isEqualTo: widget.category)
            .where('folder', isEqualTo: folderName)
            .count()
            .get();

        foldersWithCounts.add({
          'name': folderName,
          'count': countSnapshot.count ?? 0,
        });
      }

      setState(() {
        _folders = foldersWithCounts;
        _isLoadingFolders = false;
      });
    } catch (e) {
      print('Error loading folders: $e');
      setState(() {
        _isLoadingFolders = false;
      });
    }
  }

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              'Islamic Studies',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: widget.categoryColor,
        elevation: 0,
        centerTitle: false,
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
                hintText: 'Search by title...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: widget.categoryColor,
                ),
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
                  borderSide: BorderSide(color: widget.categoryColor, width: 2),
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
                  // ==================== FOLDER SECTION ====================
                  if (_searchQuery.isEmpty) ...[
                    if (_isLoadingFolders)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: folderColor,
                          ),
                        ),
                      )
                    else if (_folders.isNotEmpty)
                      ..._folders.map((folder) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: folderColor.withValues(alpha: 0.3),
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
                                color: folderColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.folder_rounded,
                                color: folderColor,
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
                              '${folder['count']} studies',
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
                                color: folderColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${folder['count']}',
                                style: const TextStyle(
                                  color: folderColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StudyFolderScreen(
                                    category: widget.category,
                                    folder: folder['name'],
                                    categoryColor: widget.categoryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    if (_folders.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 1,
                        color: dividerColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],

                  // ==================== UNFOLDERED STUDIES ====================
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('swalathmajlis')
                        .doc('iM6QRMlgUuWNbUdgQ0')
                        .collection('islamicstudy')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: widget.categoryColor,
                            ),
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
                              'No studies available',
                              style: TextStyle(color: textSecondary),
                            ),
                          ),
                        );
                      }

                      // Filter: Studies in this category WITHOUT folder
                      var docs = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docCategory = data['category']?.toString() ?? '';
                        final docFolder = data['folder']?.toString() ?? '';

                        return docCategory.toLowerCase() ==
                                widget.category.toLowerCase() &&
                            docFolder.isEmpty;
                      }).toList();

                      // Apply search filter
                      if (_searchQuery.isNotEmpty) {
                        docs = docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final title =
                              data['title']?.toString().toLowerCase() ?? '';
                          return title.contains(_searchQuery);
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
                                  ? 'No matching studies'
                                  : 'No studies',
                              style: const TextStyle(color: textSecondary),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: List.generate(docs.length, (index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final docId = doc.id;
                          final title = data['title'] ?? 'Untitled';
                          final content = data['content'] as List<dynamic>?;

                          // 🆕 Get first heading from content (if available)
                          String heading = '';
                          if (content != null && content.isNotEmpty) {
                            final firstHeading = content.firstWhere(
                              (c) => c['type'] == 'heading',
                              orElse: () => const {},
                            );
                            heading = firstHeading.isNotEmpty
                                ? firstHeading['text'] ?? ''
                                : '';
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: dividerColor),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.categoryColor
                                      .withValues(alpha: 0.05),
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
                                  color: widget.categoryColor
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: widget.categoryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              // 🆕 Full title (no ellipsis)
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  color: textPrimary,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              // 🆕 Below title: heading if available
                              subtitle: heading.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Container(
                                              width: 3,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: widget.categoryColor
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                heading,
                                                style: const TextStyle(
                                                  color: textSecondary,
                                                  fontSize: 13,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : null,
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: widget.categoryColor,
                                size: 16,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => IslamicStudyDetailScreen(
                                      studyData: data,
                                      docId: docId,
                                      categoryColor: widget.categoryColor,
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
