// lib/screens/admin_duas_display_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'duas_enter_screen.dart';

class AdminDuasDisplayScreen extends StatefulWidget {
  const AdminDuasDisplayScreen({super.key});

  @override
  State<AdminDuasDisplayScreen> createState() => _AdminDuasDisplayScreenState();
}

class _AdminDuasDisplayScreenState extends State<AdminDuasDisplayScreen> {
  // 🌈 Color scheme matching Admin Dashboard
  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textTertiary = Colors.grey;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color deleteColor = Color(0xFFE53935);
  static const Color editColor = Color(0xFF4CAF50);

  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  bool _showCategoryFilter = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('categories')
          .orderBy('name')
          .get();

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

  Future<void> _deleteDua(String docId, String heading) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dua'),
        content: Text('Are you sure you want to delete "$heading"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: deleteColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('duas')
          .doc(docId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$heading" deleted successfully'),
            backgroundColor: deleteColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editDua(Map<String, dynamic> duaData, String docId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuasEnterScreen(
          isEditMode: true,
          duaData: duaData,
          docId: docId,
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dua updated successfully'),
          backgroundColor: editColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          'Manage Duas',
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
          // Filter toggle button
          IconButton(
            icon: Icon(
              _showCategoryFilter ? Icons.filter_list_off : Icons.filter_list,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showCategoryFilter = !_showCategoryFilter;
              });
            },
            tooltip: 'Toggle Category Filter',
          ),
          // Add new dua button
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DuasEnterScreen(),
                ),
              );
              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Dua added successfully'),
                    backgroundColor: primaryColor,
                  ),
                );
              }
            },
            tooltip: 'Add New Dua',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE9EEFF),
              Color(0xFFF4F7FF),
              Color(0xFFE8EDFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Category Filter (conditionally shown)
            if (_showCategoryFilter) ...[
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(
                              category == 'All'
                                  ? Icons.list_rounded
                                  : Icons.folder_rounded,
                              color: primaryColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                  ),
                ),
              ),
            ],

            // Duas List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _selectedCategory == 'All'
                    ? FirebaseFirestore.instance
                        .collection('swalathmajlis')
                        .doc('iM6QRMlgUuWNbUdgQ0')
                        .collection('duas')
                        .orderBy('createdAt', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('swalathmajlis')
                        .doc('iM6QRMlgUuWNbUdgQ0')
                        .collection('duas')
                        .where('category', isEqualTo: _selectedCategory)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 3,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[400],
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading duas',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
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
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: primaryColor.withValues(alpha: 0.5),
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _selectedCategory == 'All'
                                ? 'No Duas Available'
                                : 'No Duas in "$_selectedCategory"',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedCategory == 'All'
                                ? 'Tap the + button to add a new dua'
                                : 'Try selecting a different category',
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

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final heading = data['heading'] ?? 'Untitled';
                      final category = data['category'];
                      final arabic = data['arabic'] ?? '';
                      final english = data['english'] ?? '';
                      final malayalam = data['malayalam'] ?? '';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ExpansionTile(
                          tilePadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          childrenPadding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            heading,
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          subtitle: category != null
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.folder_rounded,
                                      size: 14,
                                      color: textTertiary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        color: textTertiary,
                                        fontSize: 12,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit Button
                              IconButton(
                                icon: Icon(
                                  Icons.edit_rounded,
                                  color: editColor,
                                  size: 22,
                                ),
                                onPressed: () => _editDua(data, doc.id),
                                tooltip: 'Edit',
                              ),
                              // Delete Button
                              IconButton(
                                icon: Icon(
                                  Icons.delete_rounded,
                                  color: deleteColor,
                                  size: 22,
                                ),
                                onPressed: () => _deleteDua(doc.id, heading),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                          children: [
                            Divider(color: borderColor, thickness: 1),
                            const SizedBox(height: 12),

                            // Arabic Text
                            if (arabic.isNotEmpty) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  arabic,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Amiri',
                                    color: Color(0xFF1A472A),
                                    height: 1.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],

                            // English Meaning
                            if (english.isNotEmpty) ...[
                              _buildDetailSection(
                                'English Meaning',
                                english,
                                Icons.translate_rounded,
                              ),
                              const SizedBox(height: 8),
                            ],

                            // Malayalam Meaning
                            if (malayalam.isNotEmpty) ...[
                              _buildDetailSection(
                                'Malayalam Meaning',
                                malayalam,
                                Icons.translate_rounded,
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildDetailSection(String label, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: primaryColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontFamily: 'Poppins',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
