// lib/screen/admin/namaz_enter_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/salah_constants.dart';

class NamazEnterScreen extends StatefulWidget {
  final bool isEditMode;
  final Map<String, dynamic>? namazData;
  final String? docId;

  const NamazEnterScreen({
    super.key,
    this.isEditMode = false,
    this.namazData,
    this.docId,
  });

  @override
  State<NamazEnterScreen> createState() => _NamazEnterScreenState();
}

class _NamazEnterScreenState extends State<NamazEnterScreen> {
  // ==================== CONTROLLERS ====================
  final _subtitleController = TextEditingController();

  // ==================== SELECTED VALUES ====================
  String? _selectedNamazName;

  // 🖼️ LIST IMAGE - Shows only in list view
  String? _selectedListImagePath;
  String? _selectedListImageName;

  // 🖼️ DETAIL IMAGES - Shows in detail view
  List<String> _selectedDetailImagePaths = [];
  List<String> _selectedDetailImageNames = [];

  // 🖼️ ALL AVAILABLE IMAGES for the selected Salah
  List<Map<String, String>> _availableDetailImages = [];
  List<Map<String, String>> _availableListImages = [];

  // ==================== TEXT BLOCKS (Paragraphs) ====================
  List<TextBlock> _textBlocks = [];

  // ==================== STATE ====================
  bool _isSaving = false;
  bool _showSuccess = false;
  bool _isLoading = true;

  // ==================== LANGUAGE OPTIONS ====================
  final List<String> _languages = ['Malayalam', 'Arabic', 'English'];
  final List<IconData> _languageIcons = [
    Icons.translate,
    Icons.translate_rounded,
    Icons.language,
  ];
  final List<Color> _languageColors = [
    const Color.fromARGB(255, 42, 172, 131),
    const Color(0xFFD4AF37),
    Colors.blue,
  ];

  // ==================== COLOR SCHEME ====================
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);

  // ==================== INIT ====================
  @override
  void initState() {
    super.initState();
    if (widget.isEditMode && widget.namazData != null) {
      _loadExistingData();
    } else {
      _addTextBlock();
      _selectedDetailImagePaths = [];
      _selectedDetailImageNames = [];
      _selectedListImagePath = null;
      _selectedListImageName = null;
      _isLoading = false;
    }
  }

  void _loadExistingData() {
    final data = widget.namazData!;
    _selectedNamazName = data['name'] ?? '';
    _subtitleController.text = data['englishName'] ?? '';

    // Load list image (separate from detail images)
    _selectedListImagePath =
        data['listImagePath'] ?? SalahConstants.defaultListImage;
    _selectedListImageName = data['listImageName'] ?? 'List Image';

    // Load detail images
    final detailPaths = data['detailImagePaths'] as List<dynamic>? ?? [];
    final detailNames = data['detailImageNames'] as List<dynamic>? ?? [];

    if (detailPaths.isNotEmpty) {
      _selectedDetailImagePaths = detailPaths.map((e) => e.toString()).toList();
      _selectedDetailImageNames = detailNames.map((e) => e.toString()).toList();
    } else {
      // Fallback for backward compatibility
      final singlePath = data['imagePaths'] as List<dynamic>? ?? [];
      final singleName = data['imageNames'] as List<dynamic>? ?? [];
      if (singlePath.isNotEmpty) {
        _selectedDetailImagePaths =
            singlePath.map((e) => e.toString()).toList();
        _selectedDetailImageNames =
            singleName.map((e) => e.toString()).toList();
      } else {
        _selectedDetailImagePaths = [SalahConstants.defaultImage];
        _selectedDetailImageNames = ['Default'];
      }
    }

    // Load available images for this Salah
    _loadAvailableImages(_selectedNamazName!);

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
    _isLoading = false;
  }

  // 🔥 LOAD AVAILABLE IMAGES FOR SELECTED SALAH
  void _loadAvailableImages(String salahName) {
    // Get detail images from constants
    final allDetailImages = SalahConstants.getDetailImagesForSalah(salahName);
    final allListImages = SalahConstants.getListImagesForSalah(salahName);

    setState(() {
      _availableDetailImages = allDetailImages;
      _availableListImages = allListImages;

      // Auto-select first list image if none selected
      if (_selectedListImagePath == null && _availableListImages.isNotEmpty) {
        _selectedListImagePath = _availableListImages.first['path']!;
        _selectedListImageName = _availableListImages.first['name']!;
      }

      // Auto-select all detail images if none selected
      if (_selectedDetailImagePaths.isEmpty &&
          _availableDetailImages.isNotEmpty) {
        _selectedDetailImagePaths =
            _availableDetailImages.map((img) => img['path']!).toList();
        _selectedDetailImageNames =
            _availableDetailImages.map((img) => img['name']!).toList();
      }
    });
  }

  @override
  void dispose() {
    _subtitleController.dispose();
    for (var block in _textBlocks) {
      block.controller.dispose();
    }
    super.dispose();
  }

  // ==================== TEXT BLOCK METHODS ====================
  void _addTextBlock() {
    setState(() {
      _textBlocks.add(TextBlock(
        controller: TextEditingController(),
        language: 'Malayalam',
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

  // ==================== IMAGE SELECTION METHODS ====================

  // Select list image (single selection)
  void _selectListImage(String imagePath, String imageName) {
    setState(() {
      _selectedListImagePath = imagePath;
      _selectedListImageName = imageName;
    });
  }

  // Toggle detail image selection (multiple selection)
  void _toggleDetailImageSelection(String imagePath, String imageName) {
    setState(() {
      if (_selectedDetailImagePaths.contains(imagePath)) {
        final index = _selectedDetailImagePaths.indexOf(imagePath);
        _selectedDetailImagePaths.removeAt(index);
        _selectedDetailImageNames.removeAt(index);
      } else {
        _selectedDetailImagePaths.add(imagePath);
        _selectedDetailImageNames.add(imageName);
      }
    });
  }

  // Select all detail images
  void _selectAllDetailImages() {
    setState(() {
      _selectedDetailImagePaths =
          _availableDetailImages.map((img) => img['path']!).toList();
      _selectedDetailImageNames =
          _availableDetailImages.map((img) => img['name']!).toList();
    });
  }

  // Deselect all detail images
  void _deselectAllDetailImages() {
    setState(() {
      _selectedDetailImagePaths = [];
      _selectedDetailImageNames = [];
    });
  }

  // ==================== SAVE ====================
  Future<void> _saveNamaz() async {
    final subtitle = _subtitleController.text.trim();

    // Filter out empty text blocks
    final validBlocks = _textBlocks
        .where((block) => block.controller.text.trim().isNotEmpty)
        .map((block) => {
              'language': block.language,
              'text': block.controller.text.trim(),
            })
        .toList();

    // VALIDATION
    if (_selectedNamazName == null || _selectedNamazName!.isEmpty) {
      _showErrorSnackBar('Please select a Namaz name');
      return;
    }
    if (subtitle.isEmpty) {
      _showErrorSnackBar('Please enter subtitle (English name)');
      return;
    }
    if (_selectedListImagePath == null || _selectedListImagePath!.isEmpty) {
      _showErrorSnackBar('Please select a list image');
      return;
    }
    if (_selectedDetailImagePaths.isEmpty) {
      _showErrorSnackBar('Please select at least one detail image');
      return;
    }
    if (validBlocks.isEmpty) {
      _showErrorSnackBar('Please add at least one paragraph');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final data = {
        'name': _selectedNamazName!,
        'englishName': subtitle,
        // List image (for list view)
        'listImagePath': _selectedListImagePath!,
        'listImageName': _selectedListImageName ?? 'List Image',
        // Detail images (for detail view)
        'detailImagePaths': _selectedDetailImagePaths,
        'detailImageNames': _selectedDetailImageNames,
        // Backward compatibility
        'imagePaths': _selectedDetailImagePaths,
        'imageNames': _selectedDetailImageNames,
        'textBlocks': validBlocks,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.isEditMode && widget.docId != null) {
        // UPDATE
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('salahs')
            .doc(widget.docId)
            .update(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Namaz Guide Updated Successfully!')),
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
        // CREATE
        data['createdAt'] = FieldValue.serverTimestamp();

        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('salahs')
            .add(data);

        // Clear all fields
        _selectedNamazName = null;
        _subtitleController.clear();
        _selectedListImagePath = null;
        _selectedListImageName = null;
        _selectedDetailImagePaths = [];
        _selectedDetailImageNames = [];
        _availableDetailImages = [];
        _availableListImages = [];
        for (var block in _textBlocks) {
          block.controller.clear();
        }
        _textBlocks.clear();
        _addTextBlock();

        setState(() {
          _showSuccess = true;
          _isSaving = false;
        });

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

  // ==================== HELPERS ====================
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
      _selectedNamazName = null;
      _subtitleController.clear();
      _selectedListImagePath = null;
      _selectedListImageName = null;
      _selectedDetailImagePaths = [];
      _selectedDetailImageNames = [];
      _availableDetailImages = [];
      _availableListImages = [];
      for (var block in _textBlocks) {
        block.controller.clear();
      }
      _textBlocks.clear();
      _addTextBlock();
    });
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Namaz Guide' : 'Add Namaz Guide',
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success Message
                  if (_showSuccess && !widget.isEditMode)
                    _buildSuccessMessage(),

                  // Main Form
                  if (!_showSuccess || widget.isEditMode) ...[
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // 1. Namaz Name Dropdown
                    _buildNamazNameDropdown(),
                    const SizedBox(height: 20),

                    // 2. Subtitle (English Name)
                    _buildSubtitleField(),
                    const SizedBox(height: 20),

                    // 🖼️ 3. LIST IMAGE SELECTION (Single - for list view)
                    _buildListImageSelection(),
                    const SizedBox(height: 20),

                    // 🖼️ 4. DETAIL IMAGES SELECTION (Multiple - for detail view)
                    _buildDetailImageSelection(),
                    const SizedBox(height: 24),

                    // 5. Paragraphs Section
                    _buildParagraphsSection(),
                    const SizedBox(height: 16),

                    // 6. Dynamic Text Blocks
                    _buildTextBlocks(),
                    const SizedBox(height: 16),

                    // 7. Add Paragraph Button
                    _buildAddParagraphButton(),
                    const SizedBox(height: 24),

                    // 8. Preview
                    _buildPreview(),
                    const SizedBox(height: 24),

                    // 9. Save Button
                    _buildSaveButton(),

                    // 10. Cancel Button (Edit Mode)
                    if (widget.isEditMode) _buildCancelButton(),
                  ],
                ],
              ),
            ),
    );
  }

  // ==================== BUILD WIDGETS ====================

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
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
            'Namaz Guide Added!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedNamazName ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Amiri',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${_selectedDetailImagePaths.length} images selected',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
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
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            widget.isEditMode ? Icons.edit_rounded : Icons.mosque_rounded,
            color: primaryColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.isEditMode
                  ? 'Editing: ${_selectedNamazName ?? "Namaz Guide"}'
                  : 'Select a Namaz type and add prayer text',
              style: TextStyle(
                fontSize: 14,
                color: widget.isEditMode ? primaryColor : Colors.grey,
                fontWeight:
                    widget.isEditMode ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Poppins',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNamazNameDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Namaz Name (Arabic)',
          style: TextStyle(
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedNamazName,
              isExpanded: true,
              hint: const Text(
                'Select Namaz Type...',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
              items: SalahConstants.defaultSalahs.map((salah) {
                final arabicName = salah['arabic']!;
                final englishName = salah['english']!;
                return DropdownMenuItem(
                  value: arabicName,
                  child: Row(
                    children: [
                      Text(
                        arabicName,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 18,
                          color: Color(0xFF1A472A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '($englishName)',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedNamazName = value;
                  // Auto-fill subtitle with English name
                  final selected = SalahConstants.defaultSalahs.firstWhere(
                    (s) => s['arabic'] == value,
                    orElse: () => {'arabic': value!, 'english': ''},
                  );
                  if (_subtitleController.text.isEmpty) {
                    _subtitleController.text = selected['english'] ?? '';
                  }

                  // 🔥 LOAD AVAILABLE IMAGES FOR THIS SALAH
                  _loadAvailableImages(value!);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Select one of the 12 prescribed Namaz types',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subtitle (English Name)',
          style: TextStyle(
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
            controller: _subtitleController,
            decoration: InputDecoration(
              hintText: 'e.g., Fardh Prayer, Tahajjud Prayer...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(Icons.translate, color: primaryColor),
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== 🖼️ LIST IMAGE SELECTION (Single) ====================
  Widget _buildListImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'List Image (for list view)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Single',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedNamazName == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'Please select a Namaz name first',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          )
        else if (_availableListImages.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.warning_rounded, color: Colors.orange.shade700),
                const SizedBox(height: 8),
                Text(
                  'No list images found for this Namaz',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _availableListImages.map((image) {
                final imagePath = image['path']!;
                final imageName = image['name']!;
                final isSelected = _selectedListImagePath == imagePath;

                return GestureDetector(
                  onTap: () => _selectListImage(imagePath, imageName),
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? primaryColor : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(11),
                                bottomRight: Radius.circular(11),
                              ),
                            ),
                            child: Text(
                              imageName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontFamily: 'Poppins',
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Select one image to display in the list view',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  // ==================== 🖼️ DETAIL IMAGES SELECTION (Multiple) ====================
  Widget _buildDetailImageSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Detail Images (for detail view)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Multiple',
                style: TextStyle(
                  fontSize: 10,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            if (_availableDetailImages.isNotEmpty) ...[
              TextButton(
                onPressed: _selectAllDetailImages,
                child: const Text(
                  'Select All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: _deselectAllDetailImages,
                child: const Text(
                  'Deselect All',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedNamazName == null)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Center(
              child: Text(
                'Please select a Namaz name first to see available images',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
            ),
          )
        else if (_availableDetailImages.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Column(
              children: [
                Icon(Icons.warning_rounded, color: Colors.orange.shade700),
                const SizedBox(height: 8),
                Text(
                  'No detail images found for this Namaz',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.image_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedDetailImagePaths.length} / ${_availableDetailImages.length} images selected',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _availableDetailImages.map((image) {
                    final imagePath = image['path']!;
                    final imageName = image['name']!;
                    final isSelected =
                        _selectedDetailImagePaths.contains(imagePath);

                    return GestureDetector(
                      onTap: () =>
                          _toggleDetailImageSelection(imagePath, imageName),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.cover,
                                width: 90,
                                height: 90,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSelected
                                      ? Icons.check_rounded
                                      : Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(11),
                                    bottomRight: Radius.circular(11),
                                  ),
                                ),
                                child: Text(
                                  imageName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontFamily: 'Poppins',
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'Select multiple images to display in the detail view (swipeable)',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildParagraphsSection() {
    return Container(
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
            'Paragraphs (Add in any order)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Text(
            '${_textBlocks.length} paragraphs',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBlocks() {
    return ListView.separated(
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
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          icon: Icon(Icons.arrow_drop_down, color: iconColor),
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
                        icon: const Icon(Icons.arrow_upward_rounded, size: 20),
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
                        icon:
                            const Icon(Icons.arrow_downward_rounded, size: 20),
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
                        icon: const Icon(Icons.close_rounded, size: 20),
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
                      fontFamily:
                          block.language == 'Arabic' ? 'Amiri' : 'Poppins',
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
                    fontFamily:
                        block.language == 'Arabic' ? 'Amiri' : 'Poppins',
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddParagraphButton() {
    return OutlinedButton.icon(
      onPressed: _addTextBlock,
      icon: const Icon(Icons.add_circle_outline),
      label: const Text('Add Paragraph'),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    final hasContent = _textBlocks.any((b) => b.controller.text.isNotEmpty);
    if (!hasContent) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
              const Spacer(),
              Text(
                '${_selectedDetailImagePaths.length} images',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
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
            children: [
              // 🖼️ List Image Preview
              if (_selectedListImagePath != null) ...[
                const Text(
                  'List Image:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _selectedListImagePath!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 🖼️ Detail Images Preview
              if (_selectedDetailImagePaths.isNotEmpty) ...[
                const Text(
                  'Detail Images:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedDetailImagePaths.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          _selectedDetailImagePaths[index],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Name Preview
              Text(
                _selectedNamazName ?? 'Namaz Name',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 4),
              Text(
                _subtitleController.text.isNotEmpty
                    ? _subtitleController.text
                    : 'Subtitle',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ..._textBlocks
                  .where((b) => b.controller.text.isNotEmpty)
                  .map((block) {
                final languageIndex = _languages.indexOf(block.language);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color:
                              _languageColors[languageIndex].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _languageIcons[languageIndex],
                          size: 12,
                          color: _languageColors[languageIndex],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          block.controller.text,
                          style: TextStyle(
                            fontSize: block.language == 'Arabic' ? 18 : 13,
                            fontFamily: block.language == 'Arabic'
                                ? 'Amiri'
                                : 'Poppins',
                            height: block.language == 'Arabic' ? 1.8 : 1.5,
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
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveNamaz,
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
                widget.isEditMode ? 'Update Namaz Guide' : 'Save Namaz Guide',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return Column(
      children: [
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
    );
  }
}

// ==================== TEXT BLOCK CLASS ====================
class TextBlock {
  TextEditingController controller;
  String language;

  TextBlock({
    required this.controller,
    required this.language,
  });
}
