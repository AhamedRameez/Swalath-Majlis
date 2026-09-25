// lib/screen/Settings/App Admin/studies/islamicstudy_enter_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IslamicStudyEnterScreen extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? studyData;
  final String? docId;

  const IslamicStudyEnterScreen({
    super.key,
    this.isEditMode = false,
    this.studyData,
    this.docId,
  });

  @override
  State<IslamicStudyEnterScreen> createState() =>
      _IslamicStudyEnterScreenState();
}

class _IslamicStudyEnterScreenState extends State<IslamicStudyEnterScreen> {
  // Main title controller
  final _titleController = TextEditingController();

  // List of content blocks (each can be heading or paragraph)
  final List<Map<String, dynamic>> _contentBlocks = [];

  // Category (MANDATORY)
  String _selectedCategory = '';
  List<String> _existingCategories = [];
  bool _isLoading = false;
  bool _isNewCategory = false;
  final _categoryController = TextEditingController();

  // Folder (OPTIONAL - inside category)
  String _selectedFolder = '';
  List<String> _existingFolders = [];
  bool _useFolder = false;
  bool _isNewFolder = false;
  final _folderController = TextEditingController();

  // Default categories
  final List<String> _defaultCategories = ['Fiqh', 'Thajweed', 'Thareeq'];

  // 🌈 Color scheme
  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textTertiary = Colors.grey;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color editColor = Color(0xFF4CAF50);
  static const Color headingColor = Color(0xFFFFA726);
  static const Color paragraphColor = Color(0xFF2196F3);
  static const Color moveColor = Color(0xFFFFA726);
  static const Color deleteColor = Color(0xFFE57373);
  static const Color folderColor = Color(0xFFD4AF37); // Gold

  // Category colors
  final List<Color> _categoryColors = [
    const Color(0xFF3E63DD),
    const Color(0xFFFFA726),
    const Color(0xFF4CAF50),
    const Color(0xFFE91E63),
    const Color(0xFF9C27B0),
    const Color(0xFFFF5722),
    const Color(0xFF607D8B),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();

    if (widget.isEditMode && widget.studyData != null) {
      _loadExistingData();
    } else {
      _addContentBlock();
    }
  }

  void _loadExistingData() {
    final data = widget.studyData!;

    _titleController.text = data['title'] ?? '';

    // Load content blocks
    if (data.containsKey('content') && data['content'] != null) {
      final content = data['content'] as List<dynamic>;
      _contentBlocks.clear();
      for (var block in content) {
        _contentBlocks.add({
          'type': block['type'] ?? 'paragraph',
          'text': block['text'] ?? '',
          'controller': TextEditingController(text: block['text'] ?? ''),
        });
      }
    }

    // Load category
    if (data.containsKey('category') &&
        data['category'] != null &&
        data['category'].toString().isNotEmpty) {
      _selectedCategory = data['category'].toString();
      _loadFoldersForCategory(_selectedCategory);
    }

    // Load folder if exists
    if (data.containsKey('folder') &&
        data['folder'] != null &&
        data['folder'].toString().isNotEmpty) {
      _useFolder = true;
      _selectedFolder = data['folder'].toString();
    }
  }

  void _addContentBlock({String type = 'paragraph'}) {
    setState(() {
      _contentBlocks.add({
        'type': type,
        'text': '',
        'controller': TextEditingController(),
      });
    });
  }

  void _removeContentBlock(int index) {
    setState(() {
      _contentBlocks[index]['controller']?.dispose();
      _contentBlocks.removeAt(index);
    });
  }

  void _moveBlockUp(int index) {
    if (index > 0) {
      setState(() {
        final block = _contentBlocks.removeAt(index);
        _contentBlocks.insert(index - 1, block);
      });
    }
  }

  void _moveBlockDown(int index) {
    if (index < _contentBlocks.length - 1) {
      setState(() {
        final block = _contentBlocks.removeAt(index);
        _contentBlocks.insert(index + 1, block);
      });
    }
  }

  void _changeBlockType(int index, String newType) {
    setState(() {
      _contentBlocks[index]['type'] = newType;
    });
  }

  Future<void> _loadExistingCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('islamicstudy_categories')
          .orderBy('name')
          .get();

      if (snapshot.docs.isEmpty) {
        await _createDefaultCategories();
        setState(() {
          _existingCategories = List.from(_defaultCategories);
        });
      } else {
        setState(() {
          _existingCategories =
              snapshot.docs.map((doc) => doc['name'] as String).toList();
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _existingCategories = List.from(_defaultCategories);
      });
    }
  }

  Future<void> _createDefaultCategories() async {
    final batch = FirebaseFirestore.instance.batch();
    final categoriesRef = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('islamicstudy_categories');

    for (var category in _defaultCategories) {
      final docRef =
          categoriesRef.doc(category.toLowerCase().replaceAll(' ', '_'));
      batch.set(docRef, {
        'name': category,
        'createdAt': FieldValue.serverTimestamp(),
        'isDefault': true,
      });
    }

    try {
      await batch.commit();
    } catch (e) {
      print('Error creating default categories: $e');
    }
  }

  // Load folders for selected category
  Future<void> _loadFoldersForCategory(String category) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('islamicstudy_folders')
          .where('category', isEqualTo: category)
          .orderBy('name')
          .get();

      setState(() {
        _existingFolders =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error loading folders: $e');
      setState(() {
        _existingFolders = [];
      });
    }
  }

  Color _getCategoryColor(String category) {
    final index = _existingCategories.indexOf(category);
    if (index != -1) {
      return _categoryColors[index % _categoryColors.length];
    }
    return primaryColor;
  }

  Future<void> _saveStudy() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a title');
      return;
    }

    // Category is MANDATORY
    if (_selectedCategory.isEmpty && !_isNewCategory) {
      _showErrorSnackBar('Please select a category');
      return;
    }

    if (_isNewCategory && _categoryController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a category name');
      return;
    }

    bool hasContent = _contentBlocks
        .any((block) => block['controller'].text.trim().isNotEmpty);

    if (!hasContent) {
      _showErrorSnackBar('Please add at least one content block');
      return;
    }

    // Validate folder if using folder
    if (_useFolder) {
      if (_isNewFolder && _folderController.text.trim().isEmpty) {
        _showErrorSnackBar('Please enter a folder name');
        return;
      } else if (!_isNewFolder && _selectedFolder.isEmpty) {
        _showErrorSnackBar('Please select a folder');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final studiesRef = FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('islamicstudy');

      final List<Map<String, String>> contentData = [];
      for (var block in _contentBlocks) {
        final text = block['controller'].text.trim();
        if (text.isNotEmpty) {
          contentData.add({
            'type': block['type'],
            'text': text,
          });
        }
      }

      Map<String, dynamic> studyData = {
        'title': _titleController.text.trim(),
        'content': contentData,
      };

      if (widget.isEditMode) {
        studyData['updatedAt'] = FieldValue.serverTimestamp();
      } else {
        studyData['createdAt'] = FieldValue.serverTimestamp();
      }

      // Save category (MANDATORY)
      String finalCategory = '';
      if (_isNewCategory && _categoryController.text.trim().isNotEmpty) {
        finalCategory = _categoryController.text.trim();

        if (!_existingCategories.contains(finalCategory)) {
          await FirebaseFirestore.instance
              .collection('swalathmajlis')
              .doc('iM6QRMlgUuWNbUdgQ0')
              .collection('islamicstudy_categories')
              .doc(finalCategory.toLowerCase().replaceAll(' ', '_'))
              .set({
            'name': finalCategory,
            'createdAt': FieldValue.serverTimestamp(),
            'isDefault': false,
          });

          _existingCategories.add(finalCategory);
        }
      } else if (_selectedCategory.isNotEmpty) {
        finalCategory = _selectedCategory;
      }

      if (finalCategory.isNotEmpty) {
        studyData['category'] = finalCategory;
      }

      // Save folder (OPTIONAL)
      if (_useFolder) {
        if (_isNewFolder && _folderController.text.trim().isNotEmpty) {
          final newFolder = _folderController.text.trim();

          await FirebaseFirestore.instance
              .collection('swalathmajlis')
              .doc('iM6QRMlgUuWNbUdgQ0')
              .collection('islamicstudy_folders')
              .doc(
                  '${finalCategory.toLowerCase().replaceAll(' ', '_')}_${newFolder.toLowerCase().replaceAll(' ', '_')}')
              .set({
            'name': newFolder,
            'category': finalCategory,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // ✅ Add to local list immediately
          if (!_existingFolders.contains(newFolder)) {
            _existingFolders.add(newFolder);
          }

          studyData['folder'] = newFolder;
        } else if (_selectedFolder.isNotEmpty) {
          studyData['folder'] = _selectedFolder;
        }
      }

      if (widget.isEditMode && widget.docId != null) {
        await studiesRef.doc(widget.docId).update(studyData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Islamic Study updated successfully'),
              backgroundColor: editColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        Navigator.pop(context, true);
      } else {
        await studiesRef.add(studyData);

        _clearForm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Islamic Study added successfully'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (!widget.isEditMode) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    for (var block in _contentBlocks) {
      block['controller']?.dispose();
    }
    _contentBlocks.clear();
    _addContentBlock();

    _categoryController.clear();
    _folderController.clear();

    setState(() {
      _selectedCategory = '';
      _isNewCategory = false;
      _selectedFolder = '';
      _isNewFolder = false;
      _useFolder = false;
      _existingFolders = [];
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildContentBlock(int index) {
    final block = _contentBlocks[index];
    final isHeading = block['type'] == 'heading';
    final blockColor = isHeading ? headingColor : paragraphColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: blockColor.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: blockColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: blockColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isHeading ? Icons.title_rounded : Icons.notes_rounded,
                        size: 14,
                        color: blockColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHeading ? 'Heading' : 'Paragraph',
                        style: TextStyle(
                          color: blockColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(Icons.swap_vert_rounded,
                      color: textSecondary, size: 18),
                  onSelected: (value) => _changeBlockType(index, value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'heading',
                      child: Row(
                        children: [
                          Icon(Icons.title_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Heading'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'paragraph',
                      child: Row(
                        children: [
                          Icon(Icons.notes_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Paragraph'),
                        ],
                      ),
                    ),
                  ],
                ),
                if (index > 0)
                  IconButton(
                    icon: Icon(Icons.arrow_upward_rounded,
                        color: moveColor, size: 18),
                    onPressed: () => _moveBlockUp(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                if (index < _contentBlocks.length - 1)
                  IconButton(
                    icon: Icon(Icons.arrow_downward_rounded,
                        color: moveColor, size: 18),
                    onPressed: () => _moveBlockDown(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                if (_contentBlocks.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: deleteColor, size: 18),
                    onPressed: () => _removeContentBlock(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: block['controller'],
              maxLines: isHeading ? 2 : 5,
              minLines: isHeading ? 1 : 2,
              style: TextStyle(
                color: textPrimary,
                fontSize: isHeading ? 18 : 14,
                fontWeight: isHeading ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: isHeading
                    ? 'Enter heading...'
                    : 'Enter paragraph content...',
                hintStyle: TextStyle(
                  color: textSecondary.withValues(alpha: 0.7),
                  fontSize: isHeading ? 18 : 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
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
        title: Text(
          widget.isEditMode ? 'Edit Islamic Study' : 'Add Islamic Study',
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
        actions: [
          if (!widget.isEditMode)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _clearForm,
              tooltip: 'Reset Form',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.isEditMode
                            ? Icons.edit_rounded
                            : Icons.menu_book_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditMode
                                ? 'Edit Islamic Study'
                                : 'Create New Islamic Study',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.isEditMode
                                ? 'Editing: ${_titleController.text.isNotEmpty ? _titleController.text : 'Untitled'}'
                                : 'Add structured content with headings and paragraphs',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                  color: cardColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Study Title',
                      hintText: 'Enter main title...',
                      labelStyle: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.title_rounded,
                          color: primaryColor.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Category Section (MANDATORY - Always visible)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category_rounded, color: primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          'Category *',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Existing Categories
                    if (_existingCategories.isNotEmpty) ...[
                      Text(
                        'Select Category',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _existingCategories.map((category) {
                          final isSelected =
                              _selectedCategory == category && !_isNewCategory;
                          final categoryColor = _getCategoryColor(category);

                          return FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _isNewCategory = false;
                                _categoryController.clear();
                                // Reset folder when category changes
                                _selectedFolder = '';
                                _isNewFolder = false;
                                _folderController.clear();
                                _useFolder = false;
                                _loadFoldersForCategory(category);
                              });
                            },
                            selectedColor: categoryColor,
                            checkmarkColor: Colors.white,
                            backgroundColor: categoryColor.withValues(alpha: 0.1),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : categoryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: categoryColor.withValues(alpha: 0.5),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(color: borderColor, thickness: 1),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: borderColor, thickness: 1),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Create New Category
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Create New Category',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _categoryController,
                            onChanged: (value) {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  _isNewCategory = true;
                                  _selectedCategory = '';
                                });
                              }
                            },
                            decoration: InputDecoration(
                              hintText: 'Enter new category name...',
                              hintStyle: TextStyle(
                                color: textSecondary.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selected Category Preview
                    if (_selectedCategory.isNotEmpty || _isNewCategory)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                color: primaryColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isNewCategory
                                      ? 'New Category: ${_categoryController.text.trim()}'
                                      : 'Selected: $_selectedCategory',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Folder Section (OPTIONAL - Only shows when category is selected)
              if (_selectedCategory.isNotEmpty || _isNewCategory) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: folderColor.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: folderColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.folder_rounded,
                              color: folderColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Folder (Optional)',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Organize within ${_isNewCategory ? _categoryController.text.trim() : _selectedCategory}',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _useFolder,
                            activeThumbColor: folderColor,
                            onChanged: (value) {
                              setState(() {
                                _useFolder = value;
                                if (!value) {
                                  _selectedFolder = '';
                                  _isNewFolder = false;
                                  _folderController.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      if (_useFolder) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Existing Folders
                        if (_existingFolders.isNotEmpty) ...[
                          Text(
                            'Select Folder',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _existingFolders.map((folder) {
                              final isSelected =
                                  _selectedFolder == folder && !_isNewFolder;

                              return FilterChip(
                                label: Text(folder),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFolder = folder;
                                    _isNewFolder = false;
                                    _folderController.clear();
                                  });
                                },
                                selectedColor: folderColor,
                                checkmarkColor: Colors.white,
                                backgroundColor: folderColor.withValues(alpha: 0.1),
                                labelStyle: TextStyle(
                                  color:
                                      isSelected ? Colors.white : folderColor,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: folderColor.withValues(alpha: 0.5),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                      Divider(color: borderColor, thickness: 1),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child:
                                      Divider(color: borderColor, thickness: 1),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Create New Folder
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.create_new_folder_rounded,
                                    color: folderColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create New Folder',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _folderController,
                                onChanged: (value) {
                                  if (value.trim().isNotEmpty) {
                                    setState(() {
                                      _isNewFolder = true;
                                      _selectedFolder = '';
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Enter new folder name...',
                                  hintStyle: TextStyle(
                                    color: textSecondary.withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  isDense: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Content Blocks Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.view_stream_rounded,
                            color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Study Content',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: PopupMenuButton<String>(
                            icon: Icon(Icons.add_rounded,
                                color: primaryColor, size: 24),
                            onSelected: (type) => _addContentBlock(type: type),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'heading',
                                child: Row(
                                  children: [
                                    Icon(Icons.title_rounded),
                                    SizedBox(width: 8),
                                    Text('Add Heading'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'paragraph',
                                child: Row(
                                  children: [
                                    Icon(Icons.notes_rounded),
                                    SizedBox(width: 8),
                                    Text('Add Paragraph'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(
                      _contentBlocks.length,
                      (index) => _buildContentBlock(index),
                    ),
                    if (_contentBlocks.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(Icons.edit_note_rounded,
                                  color: textTertiary, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'No content added yet',
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveStudy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isEditMode ? editColor : primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.isEditMode ? 'Update Study' : 'Save Study',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),

              // Cancel/Reset Button
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : widget.isEditMode
                        ? () => Navigator.pop(context, false)
                        : _clearForm,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.isEditMode ? 'Cancel' : 'Clear All',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var block in _contentBlocks) {
      block['controller']?.dispose();
    }
    _categoryController.dispose();
    _folderController.dispose();
    super.dispose();
  }
}
