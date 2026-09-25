// lib/screens/duas_enter_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DuasEnterScreen extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? duaData;
  final String? docId;

  const DuasEnterScreen({
    super.key,
    this.isEditMode = false,
    this.duaData,
    this.docId,
  });

  @override
  State<DuasEnterScreen> createState() => _DuasEnterScreenState();
}

class _DuasEnterScreenState extends State<DuasEnterScreen> {
  final _headingController = TextEditingController();
  final _arabicController = TextEditingController();
  final _englishController = TextEditingController();
  final _malayalamController = TextEditingController();
  final _categoryController = TextEditingController();

  String _selectedCategory = ''; // Empty means no category
  List<String> _existingCategories = [];
  bool _isLoading = false;
  bool _useCategory = false;
  bool _isNewCategory = false;

  // 🌈 Color scheme matching Admin Dashboard
  static const Color primaryColor = Color(0xFF3E63DD);
  static const Color backgroundColor = Color(0xFFF4F6FF);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color borderColor = Color(0xFFE7EBFF);
  static const Color editColor = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();

    // Load existing data if in edit mode
    if (widget.isEditMode && widget.duaData != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.duaData!;

    _headingController.text = data['heading'] ?? '';
    _arabicController.text = data['arabic'] ?? '';
    _englishController.text = data['english'] ?? '';
    _malayalamController.text = data['malayalam'] ?? '';

    // Load category if exists
    if (data.containsKey('category') &&
        data['category'] != null &&
        data['category'].toString().isNotEmpty) {
      _useCategory = true;
      _selectedCategory = data['category'].toString();
    }
  }

  Future<void> _loadExistingCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('categories')
          .orderBy('name')
          .get();

      setState(() {
        _existingCategories =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _saveDua() async {
    if (_headingController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a heading');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create a reference to the duas collection
      final duasRef = FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('duas');

      // Prepare Dua data
      Map<String, dynamic> duaData = {
        'heading': _headingController.text.trim(),
        'arabic': _arabicController.text.trim(),
        'english': _englishController.text.trim(),
        'malayalam': _malayalamController.text.trim(),
      };

      // Add timestamps based on mode
      if (widget.isEditMode) {
        duaData['updatedAt'] = FieldValue.serverTimestamp();
      } else {
        duaData['createdAt'] = FieldValue.serverTimestamp();
      }

      // Add category if selected
      if (_useCategory) {
        if (_isNewCategory && _categoryController.text.trim().isNotEmpty) {
          // Save new category
          final newCategory = _categoryController.text.trim();

          // Check if category already exists
          final categoryExists = _existingCategories.contains(newCategory);

          if (!categoryExists) {
            await FirebaseFirestore.instance
                .collection('swalathmajlis')
                .doc('iM6QRMlgUuWNbUdgQ0')
                .collection('categories')
                .doc(newCategory.toLowerCase().replaceAll(' ', '_'))
                .set({
              'name': newCategory,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }

          duaData['category'] = newCategory;
        } else if (_selectedCategory.isNotEmpty) {
          duaData['category'] = _selectedCategory;
        }
      }

      if (widget.isEditMode && widget.docId != null) {
        // UPDATE existing document
        await duasRef.doc(widget.docId).update(duaData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dua updated successfully'),
              backgroundColor: editColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }

        // Return to previous screen with success
        Navigator.pop(context, true);
      } else {
        // CREATE new document
        await duasRef.add(duaData);

        // Clear form for new entry
        _clearForm();

        // Reload categories if new one was added
        if (_isNewCategory) {
          await _loadExistingCategories();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dua added successfully'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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
    _headingController.clear();
    _arabicController.clear();
    _englishController.clear();
    _malayalamController.clear();
    _categoryController.clear();
    setState(() {
      _selectedCategory = '';
      _isNewCategory = false;
      _useCategory = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primaryColor,
        title: Text(
          widget.isEditMode ? 'Edit Dua' : 'Enter Dua',
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
                            : Icons.folder_copy_rounded,
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
                            widget.isEditMode ? 'Edit Dua' : 'Add New Dua',
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
                                ? 'Editing: ${_headingController.text.isNotEmpty ? _headingController.text : 'Untitled'}'
                                : 'Organize by category or add directly',
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

              // Category Toggle Switch (disabled in edit mode if category already set)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_rounded,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add to Category',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _useCategory,
                      activeThumbColor: primaryColor,
                      onChanged:
                          widget.isEditMode && _selectedCategory.isNotEmpty
                              ? null // Disable if editing and category exists
                              : (value) {
                                  setState(() {
                                    _useCategory = value;
                                    if (!value) {
                                      _selectedCategory = '';
                                      _isNewCategory = false;
                                      _categoryController.clear();
                                    }
                                  });
                                },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection (only shown when useCategory is true)
              if (_useCategory) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                    color: cardColor,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            'Select or Create Category',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),

                        // Existing Categories Section
                        if (_existingCategories.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.folder_open_rounded,
                                      size: 16,
                                      color: primaryColor.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Existing Categories',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _existingCategories.map((category) {
                                    final isSelected =
                                        _selectedCategory == category &&
                                            !_isNewCategory;
                                    return ChoiceChip(
                                      label: Text(
                                        category,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : primaryColor,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      selected: isSelected,
                                      onSelected: widget.isEditMode &&
                                              _selectedCategory.isNotEmpty
                                          ? null // Disable if editing with existing category
                                          : (_) {
                                              setState(() {
                                                _selectedCategory = category;
                                                _isNewCategory = false;
                                                _categoryController.clear();
                                              });
                                            },
                                      selectedColor: primaryColor,
                                      backgroundColor:
                                          primaryColor.withValues(alpha: 0.1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: BorderSide(
                                          color: isSelected
                                              ? primaryColor
                                              : primaryColor.withValues(alpha: 0.3),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Divider
                        if (_existingCategories.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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
                                  child: Divider(
                                    color: borderColor,
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // New Category Section
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 16,
                                    color: primaryColor.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Create New Category',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _categoryController,
                                      enabled: !widget.isEditMode ||
                                          _selectedCategory.isEmpty,
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
                                          fontFamily: 'Poppins',
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: borderColor, width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: borderColor, width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide(
                                              color: primaryColor, width: 1.5),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                        isDense: true,
                                      ),
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 13,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_categoryController.text
                                      .trim()
                                      .isNotEmpty)
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        onPressed: (widget.isEditMode &&
                                                _selectedCategory.isNotEmpty)
                                            ? null
                                            : () {
                                                setState(() {
                                                  _isNewCategory = true;
                                                  _selectedCategory = '';
                                                });
                                              },
                                        icon: Icon(
                                          _isNewCategory
                                              ? Icons.check_circle_rounded
                                              : Icons.radio_button_unchecked,
                                          color: _isNewCategory
                                              ? primaryColor
                                              : textSecondary,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                ],
                              ),
                              if (_categoryController.text.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'New category: ${_categoryController.text.trim()}',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 11,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Selected Category Preview
                        if (_selectedCategory.isNotEmpty ||
                            _categoryController.text.trim().isNotEmpty)
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
                                      'Selected category: ${_isNewCategory ? _categoryController.text.trim() : _selectedCategory}',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Poppins',
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
                ),
                const SizedBox(height: 16),
              ],

              // Form Fields
              _buildTextField(
                controller: _headingController,
                label: 'Main Heading',
                hint: 'Enter Dua heading...',
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _arabicController,
                label: 'Arabic Dua',
                hint: 'Enter Arabic text...',
                icon: Icons.language_rounded,
                maxLines: 4,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _englishController,
                label: 'English Meaning',
                hint: 'Enter English translation...',
                icon: Icons.translate_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _malayalamController,
                label: 'Malayalam Meaning',
                hint: 'Enter Malayalam translation...',
                icon: Icons.translate_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDua,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        widget.isEditMode ? editColor : primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: (widget.isEditMode ? editColor : primaryColor)
                              .withValues(alpha: 0.3)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isEditMode
                                  ? Icons.update_rounded
                                  : Icons.save_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isEditMode ? 'Update Dua' : 'Save Dua',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              // Cancel/Reset Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _isLoading
                      ? null
                      : widget.isEditMode
                          ? () => Navigator.pop(context, false) // Cancel edit
                          : _clearForm, // Reset form for new entry
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                        color: widget.isEditMode
                            ? Colors.grey
                            : primaryColor.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.isEditMode ? 'Cancel' : 'Clear All',
                    style: TextStyle(
                      color: widget.isEditMode ? Colors.grey : primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextAlign textAlign = TextAlign.left,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          textAlign: textAlign,
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
            labelStyle: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: primaryColor.withValues(alpha: 0.7)),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _headingController.dispose();
    _arabicController.dispose();
    _englishController.dispose();
    _malayalamController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
