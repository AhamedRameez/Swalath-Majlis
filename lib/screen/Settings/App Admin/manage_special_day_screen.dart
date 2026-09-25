// lib/screen/admin/manage_special_day_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'special_day_duas_edit_screen.dart';
import 'special_day_duas_upload_screen.dart';

class ManageSpecialDayScreen extends StatefulWidget {
  const ManageSpecialDayScreen({super.key});

  @override
  State<ManageSpecialDayScreen> createState() => _ManageSpecialDayScreenState();
}

class _ManageSpecialDayScreenState extends State<ManageSpecialDayScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  // Collection path
  final String _collectionPath =
      'swalathmajlis/iM6QRMlgUuWNbUdgQ0/special_day_duas';

  Future<void> _toggleActiveStatus(String docId, bool currentStatus) async {
    setState(() => _isLoading = true);

    try {
      if (!currentStatus) {
        // If activating this item, deactivate all others first
        final allDocs = await _firestore.collection(_collectionPath).get();

        final batch = _firestore.batch();

        // Deactivate all documents
        for (var doc in allDocs.docs) {
          final docRef = _firestore.collection(_collectionPath).doc(doc.id);
          batch.update(docRef, {'isActive': false});
        }

        // Activate the selected document
        final selectedDocRef = _firestore
            .collection(_collectionPath)
            .doc(docId);
        batch.update(selectedDocRef, {'isActive': true});

        await batch.commit();
      } else {
        // If deactivating, just deactivate this one
        await _firestore.collection(_collectionPath).doc(docId).update({
          'isActive': false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus
                ? 'Dua deactivated successfully'
                : 'Dua activated successfully (others deactivated)',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDua(String docId, String heading) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Dua'),
        content: Text('Are you sure you want to delete "$heading"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                await _firestore
                    .collection(_collectionPath)
                    .doc(docId)
                    .delete();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"$heading" deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper method to get image URLs (supports both single and multiple)
  List<String> _getImageUrls(Map<String, dynamic> data) {
    // Check for multiple images (new format)
    if (data.containsKey('imageUrls') && data['imageUrls'] is List) {
      return List<String>.from(data['imageUrls']);
    }
    // Check for single image (old format)
    else if (data.containsKey('imageUrl') &&
        data['imageUrl'].toString().isNotEmpty) {
      return [data['imageUrl']];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        title: const Text(
          'Manage Special Day Duas',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 42, 172, 131),
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
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SpecialDayDuasUploadScreen(),
                ),
              );
            },
            tooltip: 'Add New Dua',
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection(_collectionPath)
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 42, 172, 131),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.celebration_rounded,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Special Day Duas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap + button to add a new dua',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              // Find which one is active
              String? activeId;
              for (var doc in docs) {
                final data = doc.data() as Map<String, dynamic>;
                if (data['isActive'] == true) {
                  activeId = doc.id;
                  break;
                }
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final heading = data['heading'] ?? 'Untitled';
                  final title = data['title'] ?? '';
                  final isActive = data['isActive'] == true;
                  final imageUrls = _getImageUrls(data);
                  final createdAt = data['createdAt'] as Timestamp?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? const Color.fromARGB(255, 42, 172, 131)
                            : Colors.grey.shade200,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Image(s) Preview - Show first image or image grid
                        if (imageUrls.isNotEmpty)
                          Stack(
                            children: [
                              // Main image
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrls[0],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color.fromARGB(
                                          255,
                                          42,
                                          172,
                                          131,
                                        ),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        height: 120,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              // Multiple images badge
                              if (imageUrls.length > 1)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.photo_library_rounded,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${imageUrls.length - 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),

                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          heading,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isActive
                                                ? const Color.fromARGB(
                                                    255,
                                                    42,
                                                    172,
                                                    131,
                                                  )
                                                : const Color(0xFF333333),
                                          ),
                                        ),
                                        if (title.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                        if (createdAt != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatDate(createdAt.toDate()),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                        // Image count indicator
                                        if (imageUrls.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.image_rounded,
                                                  size: 12,
                                                  color: Colors.grey.shade500,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${imageUrls.length} image${imageUrls.length > 1 ? 's' : ''}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Active/Inactive Toggle Button
                                  Switch(
                                    value: isActive,
                                    onChanged: _isLoading
                                        ? null
                                        : (value) => _toggleActiveStatus(
                                            doc.id,
                                            isActive,
                                          ),
                                    activeThumbColor: Colors.green,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor: Colors.grey.shade300,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Preview of paragraph (first 100 chars)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  data['paragraph']?.length > 100
                                      ? '${data['paragraph'].substring(0, 100)}...'
                                      : data['paragraph'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Action Buttons
                              Row(
                                children: [
                                  // Edit Button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      SpecialDayDuasEditScreen(
                                                        docId: doc.id,
                                                        data: data,
                                                      ),
                                                ),
                                              );
                                              if (result == true) {
                                                // Refresh will happen automatically via StreamBuilder
                                              }
                                            },
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Edit'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.blue,
                                        side: const BorderSide(
                                          color: Colors.blue,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Delete Button
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isLoading
                                          ? null
                                          : () => _deleteDua(doc.id, heading),
                                      icon: const Icon(
                                        Icons.delete_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Delete'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        side: const BorderSide(
                                          color: Colors.red,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // // View/Preview Button
                                  // Expanded(
                                  //   child: OutlinedButton.icon(
                                  //     onPressed: _isLoading
                                  //         ? null
                                  //         : () {
                                  //             showDialog(
                                  //               context: context,
                                  //               builder: (context) => AlertDialog(
                                  //                 title: Text(heading),
                                  //                 content: SingleChildScrollView(
                                  //                   child: Column(
                                  //                     crossAxisAlignment:
                                  //                         CrossAxisAlignment
                                  //                             .start,
                                  //                     mainAxisSize:
                                  //                         MainAxisSize.min,
                                  //                     children: [
                                  //                       // Show all images in preview
                                  //                       if (imageUrls
                                  //                           .isNotEmpty)
                                  //                         SizedBox(
                                  //                           height: 200,
                                  //                           child: ListView.builder(
                                  //                             scrollDirection:
                                  //                                 Axis.horizontal,
                                  //                             itemCount:
                                  //                                 imageUrls
                                  //                                     .length,
                                  //                             itemBuilder: (context, imgIndex) {
                                  //                               return Container(
                                  //                                 width: 150,
                                  //                                 margin:
                                  //                                     const EdgeInsets.only(
                                  //                                       right:
                                  //                                           8,
                                  //                                     ),
                                  //                                 child: ClipRRect(
                                  //                                   borderRadius:
                                  //                                       BorderRadius.circular(
                                  //                                         12,
                                  //                                       ),
                                  //                                   child: CachedNetworkImage(
                                  //                                     imageUrl:
                                  //                                         imageUrls[imgIndex],
                                  //                                     height:
                                  //                                         150,
                                  //                                     width:
                                  //                                         150,
                                  //                                     fit: BoxFit
                                  //                                         .cover,
                                  //                                     placeholder:
                                  //                                         (
                                  //                                           context,
                                  //                                           url,
                                  //                                         ) => Container(
                                  //                                           color:
                                  //                                               Colors.grey.shade200,
                                  //                                           child: const Center(
                                  //                                             child: CircularProgressIndicator(),
                                  //                                           ),
                                  //                                         ),
                                  //                                     errorWidget:
                                  //                                         (
                                  //                                           context,
                                  //                                           url,
                                  //                                           error,
                                  //                                         ) => Container(
                                  //                                           color:
                                  //                                               Colors.grey.shade200,
                                  //                                           child: const Icon(
                                  //                                             Icons.broken_image,
                                  //                                             size: 40,
                                  //                                           ),
                                  //                                         ),
                                  //                                   ),
                                  //                                 ),
                                  //                               );
                                  //                             },
                                  //                           ),
                                  //                         ),
                                  //                       if (imageUrls
                                  //                           .isNotEmpty)
                                  //                         const SizedBox(
                                  //                           height: 12,
                                  //                         ),
                                  //                       if (title.isNotEmpty)
                                  //                         Text(
                                  //                           title,
                                  //                           style:
                                  //                               const TextStyle(
                                  //                                 fontWeight:
                                  //                                     FontWeight
                                  //                                         .w600,
                                  //                                 fontSize: 16,
                                  //                               ),
                                  //                         ),
                                  //                       if (title.isNotEmpty)
                                  //                         const SizedBox(
                                  //                           height: 8,
                                  //                         ),
                                  //                       Text(
                                  //                         data['paragraph'] ??
                                  //                             '',
                                  //                         style:
                                  //                             const TextStyle(
                                  //                               fontSize: 14,
                                  //                             ),
                                  //                       ),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //                 actions: [
                                  //                   TextButton(
                                  //                     onPressed: () =>
                                  //                         Navigator.pop(
                                  //                           context,
                                  //                         ),
                                  //                     child: const Text(
                                  //                       'Close',
                                  //                     ),
                                  //                   ),
                                  //                 ],
                                  //               ),
                                  //             );
                                  //           },
                                  //     icon: const Icon(
                                  //       Icons.visibility_rounded,
                                  //       size: 18,
                                  //     ),
                                  //     label: const Text('Preview'),
                                  //     style: OutlinedButton.styleFrom(
                                  //       foregroundColor: Colors.purple,
                                  //       side: const BorderSide(
                                  //         color: Colors.purple,
                                  //       ),
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(
                                  //           10,
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 42, 172, 131),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
