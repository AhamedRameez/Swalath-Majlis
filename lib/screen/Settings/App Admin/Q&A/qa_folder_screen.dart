// lib/screen/Settings/App Admin/qa_folder_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'qa_enter_screen.dart';

class QAFolderScreen extends StatefulWidget {
  final String folderName;

  const QAFolderScreen({
    super.key,
    required this.folderName,
  });

  @override
  State<QAFolderScreen> createState() => _QAFolderScreenState();
}

class _QAFolderScreenState extends State<QAFolderScreen> {
  static const Color primaryColor = Color(0xFF3D2A5B);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF5FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2E1065);
  static const Color textSecondary = Color(0xFF7E22CE);
  static const Color borderColor = Color(0xFFE0D5F5);
  static const Color deleteColor = Color(0xFFE57373);
  static const Color editColor = Color(0xFF4CAF50);

  // 🆕 Update order in Firestore after drag
  Future<void> _updateOrder(List<String> docIds) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final qaRef = FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_section');

      for (int i = 0; i < docIds.length; i++) {
        batch.update(qaRef.doc(docIds[i]), {
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
        backgroundColor: accentColor,
        title: Text(
          widget.folderName,
          style: const TextStyle(
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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('qa_section')
            .where('category', isEqualTo: widget.folderName)
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
                  Icon(
                    Icons.folder_open_rounded,
                    color: accentColor.withValues(alpha: 0.3),
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Q&A in ${widget.folderName}',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          // Sort by order field
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aOrder = aData['order'] ?? 0;
            final bOrder = bData['order'] ?? 0;
            return (aOrder as num).compareTo(bOrder as num);
          });

          // 🆕 Use ReorderableListView
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final doc = docs.removeAt(oldIndex);
                docs.insert(newIndex, doc);

                // Update order in Firestore
                final docIds = docs.map((d) => d.id).toList();
                _updateOrder(docIds);
              });
            },
            buildDefaultDragHandles: true, // ✅ Enable drag handles
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;
              final question = data['question'] ?? 'No question';
              final answer = data['answer'] ?? '';

              return Container(
                key: ValueKey(docId), // ✅ Required for ReorderableListView
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
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: accentColor,
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
                      // Edit
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
                      // Delete
                      IconButton(
                        icon: Icon(Icons.delete_rounded, color: deleteColor),
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
            },
          );
        },
      ),
    );
  }
}
