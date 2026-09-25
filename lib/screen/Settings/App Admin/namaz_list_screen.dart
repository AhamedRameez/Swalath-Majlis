// lib/screen/admin/namaz_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'namaz_edit_screen.dart';
import 'namaz_enter_screen.dart';

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
  static const Color deleteColor = Color(0xFFE53935);

  bool _isDeleting = false;

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
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NamazEnterScreen(),
                ),
              ).then((result) {
                if (result == true && mounted) {
                  setState(() {});
                }
              });
            },
            tooltip: 'Add Namaz Guide',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                    'Tap the + button to add your first Namaz guide',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NamazEnterScreen(),
                        ),
                      ).then((result) {
                        if (result == true && mounted) {
                          setState(() {});
                        }
                      });
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Namaz Guide'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
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

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;

                final name = data['name']?.toString() ?? 'Unnamed Namaz';
                final englishName = data['englishName']?.toString() ?? '';
                final description = data['description']?.toString() ?? '';
                final imagePaths = data['imagePaths'] as List<dynamic>? ?? [];
                final textBlocks = data['textBlocks'] as List<dynamic>? ?? [];
                final createdAt = data['createdAt'] as Timestamp?;

                return _buildNamazCard(
                  context: context,
                  docId: doc.id,
                  name: name,
                  englishName: englishName,
                  description: description,
                  imagePaths: imagePaths.map((e) => e.toString()).toList(),
                  textBlockCount: textBlocks.length,
                  imageCount: imagePaths.length,
                  createdAt: createdAt,
                  onTap: () {
                    _navigateToEditScreen(context, doc.id, data);
                  },
                  onEdit: () {
                    _navigateToEditScreen(context, doc.id, data);
                  },
                  onDelete: () {
                    _confirmDelete(context, doc.id, name);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ==================== BUILD NAMAZ CARD ====================
  Widget _buildNamazCard({
    required BuildContext context,
    required String docId,
    required String name,
    required String englishName,
    required String description,
    required List<String> imagePaths,
    required int textBlockCount,
    required int imageCount,
    required Timestamp? createdAt,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
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
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 🖼️ Image Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: imagePaths.isNotEmpty
                      ? Image.asset(
                          imagePaths.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 30,
                            ),
                          ),
                        )
                      : Container(
                          color: primaryColor.withValues(alpha: 0.1),
                          child: const Icon(
                            Icons.mosque_rounded,
                            color: primaryColor,
                            size: 30,
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
                    // Stats
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Image count
                        if (imagePaths.isNotEmpty) ...[
                          Icon(
                            Icons.image_rounded,
                            size: 14,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$imageCount',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        // Paragraph count
                        Icon(
                          Icons.text_fields_rounded,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$textBlockCount paragraphs',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        // Created date
                        if (createdAt != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            _formatDate(createdAt.toDate()),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  IconButton(
                    icon: Icon(
                      Icons.edit_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                    splashRadius: 20,
                  ),
                  // Delete Button
                  IconButton(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: deleteColor,
                      size: 22,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== NAVIGATE TO EDIT SCREEN ====================
  void _navigateToEditScreen(
      BuildContext context, String docId, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NamazEditScreen(
          docId: docId,
          data: data,
        ),
      ),
    ).then((result) {
      if (result == true && mounted) {
        setState(() {});
      }
    });
  }

  // ==================== DELETE CONFIRMATION ====================
  void _confirmDelete(BuildContext context, String docId, String name) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_rounded, color: deleteColor),
              const SizedBox(width: 8),
              const Text(
                'Delete Namaz',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you want to delete this Namaz guide?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: primaryColor,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteNamaz(context, docId, name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: deleteColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== DELETE NAMAZ ====================
  Future<void> _deleteNamaz(
      BuildContext context, String docId, String name) async {
    setState(() => _isDeleting = true);

    try {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('salahs')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('"$name" deleted successfully')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() => _isDeleting = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Error deleting: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        setState(() => _isDeleting = false);
      }
    }
  }

  // ==================== HELPER: FORMAT DATE ====================
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
