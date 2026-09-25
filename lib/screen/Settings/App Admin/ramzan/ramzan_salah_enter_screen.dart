// lib/screen/admin/ramzan_salah_enter_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RamzanSalahEnterScreen extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? salahData;
  final String? docId;

  const RamzanSalahEnterScreen({
    super.key,
    this.isEditMode = false,
    this.salahData,
    this.docId,
  });
  @override
  State<RamzanSalahEnterScreen> createState() => _RamzanSalahEnterScreenState();
}

class _RamzanSalahEnterScreenState extends State<RamzanSalahEnterScreen> {
  // Basic info controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // List of text blocks with language selection
  List<TextBlock> _textBlocks = [];

  bool _isSaving = false;
  bool _showSuccess = false;

  // Language options
  final List<String> _languages = ['Malayalam', 'Arabic', 'English'];
  final List<IconData> _languageIcons = [
    Icons.translate,
    Icons.translate_rounded,
    Icons.language,
  ];
  final List<Color> _languageColors = [
    const Color.fromARGB(255, 42, 172, 131), // Teal - Malayalam
    const Color(0xFFD4AF37), // Gold - Arabic
    Colors.blue, // Blue - English
  ];

  // Your app's beautiful color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);

  @override
  void initState() {
    super.initState();
    // Load existing data if in edit mode
    if (widget.isEditMode && widget.salahData != null) {
      _loadExistingData();
    } else {
      // Add first empty text block for new entry
      _addTextBlock();
    }
  }

  void _loadExistingData() {
    final data = widget.salahData!;
    _nameController.text = data['name'] ?? '';
    _descriptionController.text = data['description'] ?? '';

    final textBlocks = data['textBlocks'] as List<dynamic>? ?? [];
    if (textBlocks.isNotEmpty) {
      _textBlocks = textBlocks.map((block) {
        return TextBlock(
          controller: TextEditingController(text: block['text'] ?? ''),
          language: block['language'] ?? 'Malayalam',
        );
      }).toList();
    } else {
      _addTextBlock();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (var block in _textBlocks) {
      block.controller.dispose();
    }
    super.dispose();
  }

  void _addTextBlock() {
    setState(() {
      _textBlocks.add(TextBlock(
        controller: TextEditingController(),
        language: 'Malayalam', // Default language
      ));
    });
  }

  void _removeTextBlock(int index) {
    setState(() {
      _textBlocks[index].controller.dispose();
      _textBlocks.removeAt(index);
    });
  }

  void _moveBlockUp(int index) {
    if (index > 0) {
      setState(() {
        final block = _textBlocks.removeAt(index);
        _textBlocks.insert(index - 1, block);
      });
    }
  }

  void _moveBlockDown(int index) {
    if (index < _textBlocks.length - 1) {
      setState(() {
        final block = _textBlocks.removeAt(index);
        _textBlocks.insert(index + 1, block);
      });
    }
  }

  Future<void> _saveSalah() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    // Filter out empty text blocks
    final validBlocks = _textBlocks
        .where((block) => block.controller.text.trim().isNotEmpty)
        .map((block) => {
              'language': block.language,
              'text': block.controller.text.trim(),
            })
        .toList();

    if (name.isEmpty) {
      _showErrorSnackBar('Please enter Salah name');
      return;
    }
    if (description.isEmpty) {
      _showErrorSnackBar('Please enter description');
      return;
    }
    if (validBlocks.isEmpty) {
      _showErrorSnackBar('Please add at least one text block');
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.isEditMode && widget.docId != null) {
        // UPDATE existing document
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('ramzan_salahs')
            .doc(widget.docId)
            .update({
          'name': name,
          'description': description,
          'textBlocks': validBlocks,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Show success message for edit
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Salah Guide Updated Successfully!')),
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

        // Return to previous screen with success
        Navigator.pop(context, true);
      } else {
        // CREATE new document
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('ramzan_salahs')
            .add({
          'name': name,
          'description': description,
          'textBlocks': validBlocks,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Clear all fields
        _nameController.clear();
        _descriptionController.clear();
        for (var block in _textBlocks) {
          block.controller.clear();
        }
        _textBlocks.clear();
        _addTextBlock(); // Add one empty block for next entry

        // Show success message
        setState(() {
          _showSuccess = true;
          _isSaving = false;
        });

        // Auto-hide success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showSuccess = false;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted && !widget.isEditMode) {
        setState(() => _isSaving = false);
      }
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _showSuccess = false;
      _nameController.clear();
      _descriptionController.clear();
      for (var block in _textBlocks) {
        block.controller.clear();
      }
      _textBlocks.clear();
      _addTextBlock();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Salah Guide' : 'Add Salah Guide',
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
        actions: [
          if (!widget.isEditMode)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetForm,
              tooltip: 'Reset Form',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Success Message (only for new entries)
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
                      'Salah Guide Added!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _resetForm,
                      icon: const Icon(Icons.add_comment_rounded),
                      label: const Text('Add Another'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Main Form
            if (!_showSuccess || widget.isEditMode) ...[
              // Header with edit mode indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                        widget.isEditMode
                            ? Icons.edit_rounded
                            : Icons.mosque_rounded,
                        color: primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isEditMode
                            ? 'Editing: ${_nameController.text.isNotEmpty ? _nameController.text : 'Salah Guide'}'
                            : 'Build your prayer guide step by step',
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.isEditMode ? primaryColor : Colors.grey,
                          fontWeight: widget.isEditMode
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 1. Salah Name
              _buildInputField(
                title: 'Salah Name',
                controller: _nameController,
                hintText: 'e.g., Fajr, Dhuhr, Asr, Maghrib, Isha...',
                icon: Icons.mosque_rounded,
              ),

              const SizedBox(height: 20),

              // 2. Description
              _buildInputField(
                title: 'Description',
                controller: _descriptionController,
                hintText: 'e.g., 2 Rakah Sunnah, 2 Rakah Fardh...',
                icon: Icons.description_outlined,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // 3. Text Blocks Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Prayer Text (Add in any order)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_textBlocks.length} blocks',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Dynamic Text Blocks
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _textBlocks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final block = _textBlocks[index];
                  final languageIndex = _languages.indexOf(block.language);
                  final iconColor = _languageColors[languageIndex];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: iconColor.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header with language selector and controls
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.circular(14),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: iconColor.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Language selector
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: iconColor.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: block.language,
                                    icon: Icon(Icons.arrow_drop_down,
                                        color: iconColor),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: iconColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                    items: _languages.map((language) {
                                      final idx = _languages.indexOf(language);
                                      return DropdownMenuItem(
                                        value: language,
                                        child: Row(
                                          children: [
                                            Icon(
                                              _languageIcons[idx],
                                              size: 16,
                                              color: _languageColors[idx],
                                            ),
                                            const SizedBox(width: 6),
                                            Text(language),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        block.language = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),

                              const Spacer(),

                              // Move Up button
                              if (index > 0)
                                IconButton(
                                  icon: const Icon(Icons.arrow_upward_rounded,
                                      size: 20),
                                  color: Colors.grey[600],
                                  onPressed: () => _moveBlockUp(index),
                                  tooltip: 'Move Up',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),

                              // Move Down button
                              if (index < _textBlocks.length - 1)
                                IconButton(
                                  icon: const Icon(Icons.arrow_downward_rounded,
                                      size: 20),
                                  color: Colors.grey[600],
                                  onPressed: () => _moveBlockDown(index),
                                  tooltip: 'Move Down',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),

                              // Delete button
                              if (_textBlocks.length > 1)
                                IconButton(
                                  icon:
                                      const Icon(Icons.close_rounded, size: 20),
                                  color: Colors.red[400],
                                  onPressed: () => _removeTextBlock(index),
                                  tooltip: 'Remove',
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),

                        // Text field
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: block.controller,
                            maxLines: null,
                            minLines: 3,
                            textDirection: block.language == 'Arabic'
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: block.language == 'Arabic'
                                ? TextAlign.right
                                : TextAlign.left,
                            decoration: InputDecoration(
                              hintText: block.language == 'Malayalam'
                                  ? 'മലയാളത്തിൽ ടൈപ്പ് ചെയ്യുക...'
                                  : block.language == 'Arabic'
                                      ? 'اكتب بالعربية...'
                                      : 'Type in English...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                                fontFamily: block.language == 'Arabic'
                                    ? 'Amiri'
                                    : 'Poppins',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            style: TextStyle(
                              fontSize: block.language == 'Arabic' ? 20 : 15,
                              height: block.language == 'Arabic' ? 1.8 : 1.6,
                              fontFamily: block.language == 'Arabic'
                                  ? 'Amiri'
                                  : 'Poppins',
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Add Text Block Button
              OutlinedButton.icon(
                onPressed: _addTextBlock,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Text Block'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Preview Section
              if (_textBlocks
                  .where((b) => b.controller.text.isNotEmpty)
                  .isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _textBlocks
                        .where((b) => b.controller.text.isNotEmpty)
                        .map((block) {
                      final languageIndex = _languages.indexOf(block.language);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _languageColors[languageIndex]
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                _languageIcons[languageIndex],
                                size: 14,
                                color: _languageColors[languageIndex],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                block.controller.text,
                                style: TextStyle(
                                  fontSize:
                                      block.language == 'Arabic' ? 18 : 14,
                                  fontFamily: block.language == 'Arabic'
                                      ? 'Amiri'
                                      : 'Poppins',
                                  height:
                                      block.language == 'Arabic' ? 1.8 : 1.5,
                                  color: Colors.grey[800],
                                ),
                                textDirection: block.language == 'Arabic'
                                    ? TextDirection.rtl
                                    : TextDirection.ltr,
                                textAlign: block.language == 'Arabic'
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveSalah,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Saving...'),
                          ],
                        )
                      : Text(
                          widget.isEditMode
                              ? 'Update Salah Guide'
                              : 'Save Salah Guide',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
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
    );
  }

  Widget _buildInputField({
    required String title,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(icon, color: primaryColor),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}

class TextBlock {
  TextEditingController controller;
  String language;

  TextBlock({
    required this.controller,
    required this.language,
  });
}
