// lib/screen/admin/special_day_duas_edit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SpecialDayDuasEditScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const SpecialDayDuasEditScreen({
    super.key,
    required this.docId,
    required this.data,
  });

  @override
  State<SpecialDayDuasEditScreen> createState() =>
      _SpecialDayDuasEditScreenState();
}

class _SpecialDayDuasEditScreenState extends State<SpecialDayDuasEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _paragraphController = TextEditingController();

  // Existing images URLs
  List<String> _existingImageUrls = [];

  // New images to upload
  final List<File> _newImages = [];

  // Images to delete
  final List<String> _imagesToDelete = [];

  bool _isUploading = false;
  bool _isLoading = true;
  String? _uploadError;

  // Theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final data = widget.data;

    _headingController.text = data['heading'] ?? '';
    _titleController.text = data['title'] ?? '';
    _paragraphController.text = data['paragraph'] ?? '';

    // Load image URLs (supports both old and new format)
    if (data.containsKey('imageUrls') && data['imageUrls'] is List) {
      _existingImageUrls = List<String>.from(data['imageUrls']);
    } else if (data.containsKey('imageUrl') &&
        data['imageUrl'].toString().isNotEmpty) {
      _existingImageUrls = [data['imageUrl']];
    }

    _isLoading = false;
  }

  Future<void> _pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _addSingleImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newImages.add(File(image.path));
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _imagesToDelete.add(_existingImageUrls[index]);
      _existingImageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadNewImages() async {
    if (_newImages.isEmpty) return [];

    List<String> urls = [];

    for (int i = 0; i < _newImages.length; i++) {
      final image = _newImages[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('special_duas_images/$fileName');

      print('📤 Uploading new image ${i + 1}/${_newImages.length}');

      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      urls.add(imageUrl);

      print('✅ New image uploaded: $imageUrl');
    }

    return urls;
  }

  Future<void> _deleteImagesFromStorage(List<String> imageUrls) async {
    for (String imageUrl in imageUrls) {
      try {
        // Extract path from URL
        final ref = FirebaseStorage.instance.refFromURL(imageUrl);
        await ref.delete();
        print('✅ Deleted image: $imageUrl');
      } catch (e) {
        print('❌ Error deleting image: $e');
      }
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      // Delete removed images from Storage
      if (_imagesToDelete.isNotEmpty) {
        await _deleteImagesFromStorage(_imagesToDelete);
      }

      // Upload new images
      List<String> newImageUrls = await _uploadNewImages();

      // Combine existing images (not deleted) with new ones
      List<String> allImageUrls = [..._existingImageUrls, ...newImageUrls];

      final updateData = {
        'heading': _headingController.text.trim(),
        'title': _titleController.text.trim(),
        'paragraph': _paragraphController.text.trim(),
        'imageUrls': allImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('special_day_duas')
          .doc(widget.docId)
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dua updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _headingController.dispose();
    _titleController.dispose();
    _paragraphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          'Edit Special Day Dua',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _saveChanges,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Images',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _addSingleImage,
                                    icon: const Icon(
                                      Icons.add_photo_alternate_rounded,
                                    ),
                                    color: primaryColor,
                                    tooltip: 'Add single image',
                                  ),
                                  IconButton(
                                    onPressed: _pickMultipleImages,
                                    icon: const Icon(
                                      Icons.photo_library_rounded,
                                    ),
                                    color: primaryColor,
                                    tooltip: 'Pick multiple images',
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Existing Images
                          if (_existingImageUrls.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Images',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _existingImageUrls.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    _existingImageUrls[index],
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                placeholder: (context, url) =>
                                                    Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          child: const Icon(
                                                            Icons.broken_image,
                                                            size: 40,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _removeExistingImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // New Images
                          if (_newImages.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'New Images',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 100,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _newImages.length,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        children: [
                                          Container(
                                            width: 100,
                                            height: 100,
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.shade200,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.file(
                                                _newImages[index],
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 4,
                                            right: 12,
                                            child: GestureDetector(
                                              onTap: () =>
                                                  _removeNewImage(index),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),

                          // Add images hint
                          if (_existingImageUrls.isEmpty && _newImages.isEmpty)
                            GestureDetector(
                              onTap: _pickMultipleImages,
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload_rounded,
                                      size: 40,
                                      color: primaryColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap to select images',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Poppins',
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

                    // Heading Field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Heading',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _headingController,
                            decoration: InputDecoration(
                              hintText:
                                  'Enter heading (e.g., Laylatul Qadr Dua)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter heading';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Title Field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Title (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'Enter subtitle (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Paragraph Field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Paragraph',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _paragraphController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              hintText: 'Enter the Dua/Supplication text...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter paragraph';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
