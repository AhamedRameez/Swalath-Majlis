// lib/screen/study_folder_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'islamic_study_detail_screen.dart';

class StudyFolderScreen extends StatefulWidget {
  final String category;
  final String folder;
  final Color categoryColor;

  const StudyFolderScreen({
    super.key,
    required this.category,
    required this.folder,
    required this.categoryColor,
  });

  @override
  State<StudyFolderScreen> createState() => _StudyFolderScreenState();
}

class _StudyFolderScreenState extends State<StudyFolderScreen> {
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color folderColor = Color(0xFFD4AF37);

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
              widget.folder,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              widget.category,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: folderColor,
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
                hintText: 'Search in ${widget.folder}...',
                prefixIcon: Icon(Icons.search_rounded, color: folderColor),
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
                  borderSide: BorderSide(color: folderColor, width: 2),
                ),
                filled: true,
                fillColor: backgroundColor,
              ),
            ),
          ),

          // Studies in this folder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('swalathmajlis')
                  .doc('iM6QRMlgUuWNbUdgQ0')
                  .collection('islamicstudy')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: folderColor),
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
                            color: folderColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.folder_open_rounded,
                            color: folderColor.withValues(alpha: 0.5),
                            size: 50,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No studies in ${widget.folder}',
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Filter: Studies in this category AND folder
                var docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final docCategory = data['category']?.toString() ?? '';
                  final docFolder = data['folder']?.toString() ?? '';

                  return docCategory.toLowerCase() ==
                          widget.category.toLowerCase() &&
                      docFolder.toLowerCase() == widget.folder.toLowerCase();
                }).toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = data['title']?.toString().toLowerCase() ?? '';
                    return title.contains(_searchQuery);
                  }).toList();
                }

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: textSecondary,
                          size: 60,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No matching studies',
                          style: TextStyle(color: textPrimary, fontSize: 16),
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
                    final content = data['content'] as List<dynamic>?;

                    String preview = '';
                    if (content != null && content.isNotEmpty) {
                      final firstParagraph = content.firstWhere(
                        (c) => c['type'] == 'paragraph',
                        orElse: () => content.first,
                      );
                      preview = firstParagraph['text'] ?? '';
                      if (preview.length > 100) {
                        preview = '${preview.substring(0, 100)}...';
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: folderColor.withValues(alpha: 0.05),
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
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: folderColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: preview.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    preview,
                                    style: const TextStyle(
                                      color: textSecondary,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )
                            : null,
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: folderColor,
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
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
