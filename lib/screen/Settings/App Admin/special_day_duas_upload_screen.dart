// lib/screen/admin/special_day_duas_upload_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class SpecialDayDuasUploadScreen extends StatefulWidget {
  const SpecialDayDuasUploadScreen({super.key});

  @override
  State<SpecialDayDuasUploadScreen> createState() =>
      _SpecialDayDuasUploadScreenState();
}

class _SpecialDayDuasUploadScreenState
    extends State<SpecialDayDuasUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _paragraphController = TextEditingController();

  // Multiple Images
  List<File> _selectedImages = [];
  final List<String> _uploadedImageUrls = [];
  bool _isUploading = false;
  String? _uploadError;

  // Theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);

  // Pick multiple images from gallery
  Future<void> _pickMultipleImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((img) => File(img.path)).toList();
        _uploadError = null;
      });
    }
  }

  // Add single image
  Future<void> _addSingleImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImages.add(File(image.path));
        _uploadError = null;
      });
    }
  }

  // Remove image at index
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // Upload multiple images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    List<String> urls = [];

    for (int i = 0; i < _selectedImages.length; i++) {
      final image = _selectedImages[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('special_duas_images/$fileName');

      print(
        '📤 Uploading image ${i + 1}/${_selectedImages.length} to: special_duas_images/$fileName',
      );

      final uploadTask = imageRef.putFile(image);
      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();
      urls.add(imageUrl);

      print('✅ Image ${i + 1} uploaded: $imageUrl');
    }

    return urls;
  }

  // Save to Firestore
  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadError = null;
    });

    try {
      // Upload all images
      List<String> uploadedImageUrls = await _uploadImages();

      if (uploadedImageUrls.isEmpty && _selectedImages.isNotEmpty) {
        throw Exception('Failed to upload images');
      }

      final data = {
        'heading': _headingController.text.trim(),
        'title': _titleController.text.trim(),
        'paragraph': _paragraphController.text.trim(),
        'imageUrls': uploadedImageUrls, // 🔥 Changed to array of URLs
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('special_day_duas')
          .add(data);

      print('✅ Saved to Firestore with ID: ${docRef.id}');
      print('📸 Uploaded ${uploadedImageUrls.length} images');

      // Clear form
      _headingController.clear();
      _titleController.clear();
      _paragraphController.clear();
      setState(() {
        _selectedImages.clear();
        _uploadedImageUrls.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Uploaded successfully! ${uploadedImageUrls.length} images added',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back after success
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
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
          'Upload Special Day Dua',
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Multiple Images Upload Section
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
                          'Upload Images',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Row(
                          children: [
                            // Add single image button
                            IconButton(
                              onPressed: _selectedImages.length < 5
                                  ? _addSingleImage
                                  : null,
                              icon: const Icon(
                                Icons.add_photo_alternate_rounded,
                              ),
                              color: primaryColor,
                              tooltip: 'Add single image',
                            ),
                            // Pick multiple button
                            IconButton(
                              onPressed: _selectedImages.length < 5
                                  ? _pickMultipleImages
                                  : null,
                              icon: const Icon(Icons.photo_library_rounded),
                              color: primaryColor,
                              tooltip: 'Pick multiple images',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Image Preview Grid
                    if (_selectedImages.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    if (_selectedImages.isEmpty)
                      GestureDetector(
                        onTap: _pickMultipleImages,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_rounded,
                                size: 48,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to select images (1-5)',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Selected: ${_selectedImages.length}/5',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_selectedImages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected: ${_selectedImages.length}/5 images',
                          style: const TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
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
                        hintText: 'Enter heading (e.g., Laylatul Qadr Dua)',
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

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading || _selectedImages.isEmpty
                      ? null
                      : _saveData,
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
                      : Text(
                          _selectedImages.isEmpty
                              ? 'Select Images First'
                              : 'Upload (${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''})',
                          style: const TextStyle(
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
