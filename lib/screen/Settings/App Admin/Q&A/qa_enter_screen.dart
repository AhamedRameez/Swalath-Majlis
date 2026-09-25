// lib/screen/Settings/App Admin/qa_enter_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QAEnterScreen extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? qaData;
  final String? docId;

  const QAEnterScreen({
    super.key,
    this.isEditMode = false,
    this.qaData,
    this.docId,
  });

  @override
  State<QAEnterScreen> createState() => _QAEnterScreenState();
}

class _QAEnterScreenState extends State<QAEnterScreen> {
  // Controllers
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final _categoryController = TextEditingController();

  // Category
  String _selectedCategory = '';
  List<String> _existingCategories = [];
  bool _isLoading = false;
  bool _useCategory = false; // 🆕 Optional - default OFF
  bool _isNewCategory = false;

  // 🌈 Color scheme (Royal Purple & Gold Admin Theme)
  static const Color primaryColor = Color(0xFF3D2A5B); // Royal Purple
  static const Color accentColor = Color(0xFFD4AF37); // Gold
  static const Color backgroundColor = Color(0xFFFAF5FF); // Lavender White
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2E1065); // Dark Purple
  static const Color textSecondary = Color(0xFF7E22CE); // Medium Purple
  static const Color textTertiary = Colors.grey;
  static const Color borderColor = Color(0xFFE0D5F5);
  static const Color editColor = Color(0xFF4CAF50);

  // Category colors
  final List<Color> _categoryColors = [
    const Color(0xFF3D2A5B), // Royal Purple
    const Color(0xFFD4AF37), // Gold
    const Color(0xFF4CAF50), // Green
    const Color(0xFFE91E63), // Pink
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF607D8B), // Blue Grey
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();

    if (widget.isEditMode && widget.qaData != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.qaData!;
    _questionController.text = data['question'] ?? '';
    _answerController.text = data['answer'] ?? '';

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
          .collection('qa_categories')
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

  Color _getCategoryColor(String category) {
    final index = _existingCategories.indexOf(category);
    if (index != -1) {
      return _categoryColors[index % _categoryColors.length];
    }
    return primaryColor;
  }

  Future<void> _saveQA() async {
    if (_questionController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a question');
      return;
    }

    if (_answerController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an answer');
      return;
    }

    // Validate category only if using category
    if (_useCategory) {
      if (_isNewCategory && _categoryController.text.trim().isEmpty) {
        _showErrorSnackBar('Please enter a category name');
        return;
      } else if (!_isNewCategory && _selectedCategory.isEmpty) {
        _showErrorSnackBar('Please select a category');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final qaRef = FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_section');

      Map<String, dynamic> qaData = {
        'question': _questionController.text.trim(),
        'answer': _answerController.text.trim(),
      };

      if (widget.isEditMode) {
        qaData['updatedAt'] = FieldValue.serverTimestamp();
      } else {
        qaData['createdAt'] = FieldValue.serverTimestamp();
      }

      // Handle category (optional)
      if (_useCategory) {
        if (_isNewCategory && _categoryController.text.trim().isNotEmpty) {
          final newCategory = _categoryController.text.trim();

          if (!_existingCategories.contains(newCategory)) {
            await FirebaseFirestore.instance
                .collection('swalathmajlis')
                .doc('iM6QRMlgUuWNbUdgQ0')
                .collection('qa_categories')
                .doc(newCategory.toLowerCase().replaceAll(' ', '_'))
                .set({
              'name': newCategory,
              'createdAt': FieldValue.serverTimestamp(),
              'isDefault': false,
            });

            _existingCategories.add(newCategory);
          }

          qaData['category'] = newCategory;
        } else if (_selectedCategory.isNotEmpty) {
          qaData['category'] = _selectedCategory;
        }
      }

      if (widget.isEditMode && widget.docId != null) {
        await qaRef.doc(widget.docId).update(qaData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Q&A updated successfully'),
              backgroundColor: editColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        Navigator.pop(context, true);
      } else {
        await qaRef.add(qaData);

        _clearForm();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Q&A added successfully'),
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
    _questionController.clear();
    _answerController.clear();
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
          widget.isEditMode ? 'Edit Q&A' : 'Add Q&A',
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
              Color(0xFFF3ECFF),
              Color(0xFFFAF5FF),
              Color(0xFFF0E8FF),
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
                            : Icons.quiz_rounded,
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
                                ? 'Edit Question & Answer'
                                : 'Add Question & Answer',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create Q&A for users to learn',
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

              // Category Toggle (Optional - TOP)
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
                          'Category (Optional)',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _useCategory,
                          activeThumbColor: primaryColor,
                          onChanged: (value) {
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
                    if (_useCategory) ...[
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
                            final isSelected = _selectedCategory == category &&
                                !_isNewCategory;
                            final categoryColor = _getCategoryColor(category);

                            return FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  _isNewCategory = false;
                                  _categoryController.clear();
                                });
                              },
                              selectedColor: categoryColor,
                              checkmarkColor: Colors.white,
                              backgroundColor: categoryColor.withValues(alpha: 0.1),
                              labelStyle: TextStyle(
                                color:
                                    isSelected ? Colors.white : categoryColor,
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (_categoryController.text.trim().isNotEmpty)
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _isNewCategory
                                          ? primaryColor
                                          : primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _isNewCategory
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      color: _isNewCategory
                                          ? Colors.white
                                          : primaryColor,
                                      size: 20,
                                    ),
                                  ),
                              ],
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
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Question Field
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
                    controller: _questionController,
                    maxLines: 3,
                    minLines: 2,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Question *',
                      hintText: 'Enter question here...',
                      labelStyle: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.help_rounded,
                          color: primaryColor.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Answer Field
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
                    controller: _answerController,
                    maxLines: 8,
                    minLines: 4,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Answer *',
                      hintText: 'Enter answer here...',
                      labelStyle: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.chat_rounded,
                          color: primaryColor.withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveQA,
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
                          widget.isEditMode ? 'Update Q&A' : 'Save Q&A',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),

              // Cancel/Reset
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
    _questionController.dispose();
    _answerController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
