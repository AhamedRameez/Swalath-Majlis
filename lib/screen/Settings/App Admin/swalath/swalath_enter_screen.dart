// lib/screen/admin/swalath_enter_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SwalathEnterScreen extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? swalathData;
  final String? docId;

  const SwalathEnterScreen({
    super.key,
    this.isEditMode = false,
    this.swalathData,
    this.docId,
  });

  @override
  State<SwalathEnterScreen> createState() => _SwalathEnterScreenState();
}

class _SwalathEnterScreenState extends State<SwalathEnterScreen> {
  // Basic info controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Text entry controllers
  final _arabicController = TextEditingController();
  final _malayalamController = TextEditingController();
  final _duaController = TextEditingController(); // For optional dua section
  final _youtubeUrlController = TextEditingController(); // 🆕 For YouTube URL

  // Category/Folder management
  final _categoryController = TextEditingController();
  String _selectedCategory = '';
  List<String> _existingCategories = [];
  bool _useCategory = false;
  bool _isNewCategory = false;

  // 🔥 CLEAR STYLE SELECTION
  String _selectedStyle = 'paragraph'; // 'alternating' or 'paragraph'

  // Style options with clear descriptions
  final List<Map<String, dynamic>> _styleOptions = [
    {
      'id': 'alternating',
      'title': 'Poetic / Alternating Style',
      'subtitle': 'Text alternates right-left line by line',
      'icon': Icons.compare_arrows_rounded,
      'description': 'Best for poems, nasheeds, and rhythmic swalath',
    },
    {
      'id': 'paragraph',
      'title': 'Verse / Paragraph Style',
      'subtitle': 'Continuous text as one block',
      'icon': Icons.notes_rounded,
      'description': 'Best for duas, prayers, and continuous readings',
    },
  ];

  bool _isLoading = false;
  bool _showSuccess = false;

  // Your app's beautiful color scheme for admin
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color(0xFF1A472A);

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();

    if (widget.isEditMode && widget.swalathData != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final data = widget.swalathData!;

    // Load basic info
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _duaController.text = data['dua'] ?? '';
    _youtubeUrlController.text =
        data['youtubeUrl'] ?? ''; // 🆕 Load YouTube URL

    // 🔥 LOAD STYLE - handle old 'verse'/'normal' values
    final oldStyle = data['style'] ?? 'normal';
    if (oldStyle == 'verse') {
      _selectedStyle = 'paragraph'; // Old 'verse' maps to paragraph
    } else if (oldStyle == 'normal') {
      _selectedStyle = 'alternating';
    } else {
      _selectedStyle = data['style'] ?? 'paragraph';
    }

    // Load category properly
    if (data.containsKey('category') &&
        data['category'] != null &&
        data['category'].toString().isNotEmpty) {
      _useCategory = true;
      _selectedCategory = data['category'].toString();
    }

    // Load Arabic and Malayalam text
    _arabicController.text = data['arabic'] ?? '';
    _malayalamController.text = data['malayalam'] ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _arabicController.dispose();
    _malayalamController.dispose();
    _duaController.dispose();
    _youtubeUrlController.dispose(); // 🆕 Dispose YouTube URL controller
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('swalath_categories')
          .orderBy('name')
          .get();

      setState(() {
        _existingCategories =
            snapshot.docs.map((doc) => doc['name'] as String).toList();
      });

      print('✅ Loaded ${_existingCategories.length} categories');
    } catch (e) {
      print('❌ Error loading categories: $e');
    }
  }

  Future<void> _saveSwalath() async {
    final title = _titleController.text.trim();
    final arabic = _arabicController.text.trim();

    if (title.isEmpty) {
      _showErrorSnackBar('Please enter swalath title');
      return;
    }

    if (arabic.isEmpty) {
      _showErrorSnackBar('Please enter Arabic text');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 🔥 SIMPLE DATA STRUCTURE - same for both styles
      Map<String, dynamic> swalathData = {
        'title': title,
        'description': _descriptionController.text.trim(),
        'style': _selectedStyle,
        'arabic': arabic,
        'malayalam': _malayalamController.text.trim(),
      };

      // 🆕 Add YouTube URL if provided
      if (_youtubeUrlController.text.trim().isNotEmpty) {
        swalathData['youtubeUrl'] = _youtubeUrlController.text.trim();
      }

      // Handle category properly
      if (_useCategory) {
        String finalCategory = '';

        if (_isNewCategory && _categoryController.text.trim().isNotEmpty) {
          finalCategory = _categoryController.text.trim();

          if (!_existingCategories.contains(finalCategory)) {
            await FirebaseFirestore.instance
                .collection('swalathmajlis')
                .doc('iM6QRMlgUuWNbUdgQ0')
                .collection('swalath_categories')
                .doc(finalCategory.toLowerCase().replaceAll(' ', '_'))
                .set({
              'name': finalCategory,
              'createdAt': FieldValue.serverTimestamp(),
            });
            print('✅ Created new category: $finalCategory');
          }
        } else if (_selectedCategory.isNotEmpty) {
          finalCategory = _selectedCategory;
        }

        if (finalCategory.isNotEmpty) {
          swalathData['category'] = finalCategory;
        }
      }

      // Add optional dua section
      if (_duaController.text.trim().isNotEmpty) {
        swalathData['dua'] = _duaController.text.trim();
      }

      if (widget.isEditMode && widget.docId != null) {
        // UPDATE existing document
        swalathData['updatedAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('swalath')
            .doc(widget.docId)
            .update(swalathData);

        print('✅ Updated document with ID: ${widget.docId}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Swalath updated successfully!')),
                ],
              ),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        Navigator.pop(context, true);
      } else {
        // CREATE new document
        swalathData['createdAt'] = FieldValue.serverTimestamp();

        final docRef = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('swalath')
            .add(swalathData);

        print('✅ Created new document with ID: ${docRef.id}');

        setState(() {
          _showSuccess = true;
          _isLoading = false;
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showSuccess = false;
            });
          }
        });

        _clearForm();

        if (_isNewCategory && _categoryController.text.trim().isNotEmpty) {
          await _loadExistingCategories();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Swalath added successfully'),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      print('❌ Error saving: $e');
      _showErrorSnackBar('Error: $e');
    } finally {
      if (!widget.isEditMode) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _arabicController.clear();
    _malayalamController.clear();
    _duaController.clear();
    _youtubeUrlController.clear(); // 🆕 Clear YouTube URL
    _categoryController.clear();

    setState(() {
      _selectedCategory = '';
      _isNewCategory = false;
      _useCategory = false;
      _selectedStyle = 'paragraph';
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Swalath' : 'Enter Swalath',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
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
              Color(0xFFF5F3EF),
              backgroundColor,
              Color(0xFFF5F3EF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success Message
              if (_showSuccess && !widget.isEditMode)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Swalath Added!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _titleController.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // Main Form
              if (!_showSuccess || widget.isEditMode) ...[
                // Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: widget.isEditMode
                              ? primaryColor.withValues(alpha: 0.1)
                              : accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.isEditMode
                              ? Icons.edit_rounded
                              : Icons.auto_stories_rounded,
                          color: widget.isEditMode ? primaryColor : accentColor,
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
                                  ? 'Edit Swalath'
                                  : 'Add New Swalath',
                              style: const TextStyle(
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
                                  : 'Choose display style for your text',
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Style Selection
                _buildStyleSelection(),

                const SizedBox(height: 20),

                // Category Toggle
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.folder_copy_rounded,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Add to Category/Folder',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
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
                ),

                const SizedBox(height: 16),

                // Category Selection
                if (_useCategory) ...[
                  _buildCategorySection(),
                  const SizedBox(height: 16),
                ],

                // Title Field
                _buildTextField(
                  controller: _titleController,
                  label: 'Swalath Title',
                  hint: 'e.g., Swalath-ul-Burda, Swalath-ul-Mawlid...',
                  icon: Icons.title_rounded,
                ),

                const SizedBox(height: 16),

                // Description Field
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Brief description or occasion...',
                  icon: Icons.description_outlined,
                  maxLines: 2,
                ),

                const SizedBox(height: 20),

                // Style Indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedStyle == 'alternating'
                        ? accentColor.withValues(alpha: 0.1)
                        : primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedStyle == 'alternating'
                            ? Icons.compare_arrows_rounded
                            : Icons.text_fields_rounded,
                        size: 18,
                        color: _selectedStyle == 'alternating'
                            ? accentColor
                            : primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedStyle == 'alternating'
                            ? 'Poetic Style Entry'
                            : 'Paragraph Style Entry',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _selectedStyle == 'alternating'
                              ? accentColor
                              : primaryColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _arabicController,
                  label: 'Arabic Text',
                  hint: 'Enter Arabic swalath text...',
                  icon: Icons.language_rounded,
                  maxLines: 12,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _malayalamController,
                  label: 'Malayalam Translation (Optional)',
                  hint: 'Enter Malayalam translation...',
                  icon: Icons.translate_rounded,
                  maxLines: 10,
                ),

                const SizedBox(height: 24),

                // Optional Dua Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite_rounded,
                              color: primaryColor, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Optional Dua Section',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _duaController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add concluding dua if needed...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🆕 YouTube Video URL Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.video_library_rounded,
                              color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'YouTube Video (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _youtubeUrlController,
                        decoration: InputDecoration(
                          hintText: 'Paste YouTube video URL here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon:
                              const Icon(Icons.link_rounded, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Video will appear at the bottom of the swalath details screen',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveSwalath,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                              const Icon(Icons.save_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                widget.isEditMode
                                    ? 'Update Swalath'
                                    : 'Save Swalath',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Cancel button for edit mode
                if (widget.isEditMode) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[300]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 Style selection widget
  Widget _buildStyleSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.style_rounded,
                  color: accentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Select Display Style',
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

          // Style Options
          ..._styleOptions.map((option) {
            final isSelected = _selectedStyle == option['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedStyle = option['id'];
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primaryColor.withValues(alpha: 0.05)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? primaryColor : borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryColor
                            : (option['id'] == 'alternating'
                                    ? accentColor
                                    : primaryColor)
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        option['icon'],
                        color: isSelected
                            ? primaryColor
                            : (option['id'] == 'alternating'
                                ? accentColor
                                : primaryColor),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? primaryColor : textPrimary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option['subtitle'],
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['description'],
                            style: TextStyle(
                              color: textTertiary,
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          // Preview hint
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_rounded, size: 14, color: textTertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedStyle == 'alternating'
                        ? 'Preview: Text will alternate right-left alignment line by line'
                        : 'Preview: Text will display as a continuous paragraph',
                    style: TextStyle(
                      color: textTertiary,
                      fontSize: 11,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
        color: cardColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'Select or Create Folder',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            // Existing Categories
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
                        const Text(
                          'Existing Folders',
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
                            _selectedCategory == category && !_isNewCategory;
                        return ChoiceChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : primaryColor,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                              _isNewCategory = false;
                              _categoryController.clear();
                            });
                          },
                          selectedColor: primaryColor,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
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

              // Divider
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: borderColor, thickness: 1)),
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
                    Expanded(child: Divider(color: borderColor, thickness: 1)),
                  ],
                ),
              ),
            ],

            // New Category
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
                        Icons.create_new_folder_rounded,
                        size: 16,
                        color: primaryColor.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Create New Folder',
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
                          onChanged: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                _isNewCategory = true;
                                _selectedCategory = '';
                              });
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter folder name...',
                            hintStyle: TextStyle(
                              color: textSecondary.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: borderColor, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            isDense: true,
                          ),
                          style: const TextStyle(
                            color: textPrimary,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_categoryController.text.trim().isNotEmpty)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _isNewCategory = true;
                                _selectedCategory = '';
                              });
                            },
                            icon: Icon(
                              _isNewCategory
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color:
                                  _isNewCategory ? primaryColor : textSecondary,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Selected Preview
            if (_selectedCategory.isNotEmpty ||
                _categoryController.text.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_rounded,
                          color: primaryColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Selected folder: ${_isNewCategory ? _categoryController.text.trim() : _selectedCategory}',
                          style: const TextStyle(
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
            fontFamily: textAlign == TextAlign.right ? 'Amiri' : 'Poppins',
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle: TextStyle(color: textSecondary.withValues(alpha: 0.7)),
            labelStyle: const TextStyle(
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

  Widget _buildStyleOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : (isEnabled ? Colors.white : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isEnabled ? borderColor : Colors.grey[300]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? primaryColor
                  : (isEnabled ? textSecondary : Colors.grey[400]),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? primaryColor
                    : (isEnabled ? textPrimary : Colors.grey[500]),
                fontFamily: 'Poppins',
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isEnabled ? textTertiary : Colors.grey[400],
                fontSize: 10,
                fontFamily: 'Poppins',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
