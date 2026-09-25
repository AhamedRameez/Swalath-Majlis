// lib/screens/ramzan_duas_list_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ramzan_dua_detail_screen.dart';

class RamzanDuasListScreen extends StatelessWidget {
  final String? category;

  const RamzanDuasListScreen({super.key, this.category});

  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(
    255,
    42,
    172,
    131,
  ); // Deep Teal Green
  static const Color accentColor = Color(0xFFD4AF37); // Warm Gold
  static const Color backgroundColor = Color(0xFFFAF9F6); // Warm White
  static const Color textPrimary = Color(0xFF333333); // Dark Gray
  static const Color textSecondary = Color(0xFF666666); // Medium Gray
  static const Color textTertiary = Color(0xFF888888); // Light Gray
  static const Color cardColor = Color(0xFFFFFFFF); // Pure White
  static const Color dividerColor = Color(0xFFE0E0E0); // Light Gray Divider

  Stream<QuerySnapshot> _getDuasStream() {
    final collection = FirebaseFirestore.instance
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('Ramzan_duas');

    if (category != null) {
      if (category == 'uncategorized') {
        // 🔴 FIXED: Get uncategorized duas properly
        // Firestore doesn't support != null queries directly with multiple conditions
        // So we need to get all and filter, but for stream we'll use a different approach
        return collection.orderBy('createdAt', descending: true).snapshots();
      } else {
        // Get duas for specific category
        return collection
            .where('category', isEqualTo: category)
            .orderBy('createdAt', descending: true)
            .snapshots();
      }
    } else {
      // Get all duas (for "All Duas" tab)
      return collection.orderBy('createdAt', descending: true).snapshots();
    }
  }

  // Helper method to safely get category
  String? _getCategory(Map<String, dynamic> data) {
    try {
      if (data.containsKey('category') &&
          data['category'] != null &&
          data['category'].toString().isNotEmpty) {
        return data['category'].toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if a dua is uncategorized
  bool _isUncategorized(Map<String, dynamic> data) {
    return !data.containsKey('category') ||
        data['category'] == null ||
        data['category'].toString().isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: StreamBuilder<QuerySnapshot>(
        stream: _getDuasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: primaryColor,
                    strokeWidth: 3,
                    backgroundColor: primaryColor.withValues(alpha: 0.1),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    category == 'uncategorized'
                        ? 'Loading Uncategorized Duas...'
                        : category != null
                        ? 'Loading $category Duas...'
                        : 'Loading Duas...',
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Connection Error',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load duas. Please check your connection.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          // 🔴 FIXED: Filter the documents based on category
          final allDocs = snapshot.data!.docs;
          List<QueryDocumentSnapshot> filteredDocs;

          if (category == 'uncategorized') {
            // Filter to only show uncategorized duas
            filteredDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _isUncategorized(data);
            }).toList();
          } else if (category != null) {
            // Filter for specific category
            filteredDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['category']?.toString() == category;
            }).toList();
          } else {
            // Show all duas
            filteredDocs = allDocs;
          }

          if (filteredDocs.isEmpty) {
            return _buildEmptyState();
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredDocs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final doc = filteredDocs[index];
                final data = doc.data() as Map<String, dynamic>;
                final heading = data['heading']?.toString() ?? 'Untitled Dua';
                final duaCategory = _getCategory(data);

                return _buildDuaCard(
                  index: index,
                  heading: heading,
                  category: duaCategory,
                  data: data,
                  context: context,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String message;
    IconData icon;

    if (category == 'uncategorized') {
      title = 'No Uncategorized Duas';
      message = 'All duas are properly organized in categories.';
      icon = Icons.folder_special_rounded;
    } else if (category != null) {
      title = 'No Duas in $category';
      message = 'This category doesn\'t have any duas yet.';
      icon = Icons.folder_open_rounded;
    } else {
      title = 'No Duas Available';
      message = 'New duas will appear here once they are added.';
      icon = Icons.ramen_dining_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
              child: Icon(icon, color: primaryColor.withValues(alpha: 0.6), size: 50),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard({
    required int index,
    required String heading,
    required String? category,
    required Map<String, dynamic> data,
    required BuildContext context,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RamzanDuaDetailScreen(data: data),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryColor.withValues(alpha: 0.08),
        highlightColor: primaryColor.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge with accent gold
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading
                      Text(
                        heading,
                        style: const TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.4,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Category badge (if available and not showing in categorized view)
                      if (category != null &&
                          category.isNotEmpty &&
                          this.category ==
                              null) // Only show category in "All" view
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          // decoration: BoxDecoration(
                          //   color: primaryColor.withOpacity(0.08),
                          //   borderRadius: BorderRadius.circular(20),
                          //   border: Border.all(
                          //     color: primaryColor.withOpacity(0.2),
                          //     width: 1,
                          //   ),
                          // ),
                          // child: Row(
                          //   mainAxisSize: MainAxisSize.min,
                          //   children: [
                          //     Icon(
                          //       Icons.folder_open_rounded,
                          //       size: 12,
                          //       color: primaryColor.withOpacity(0.7),
                          //     ),
                          //     const SizedBox(width: 4),
                          //     Text(
                          //       category,
                          //       style: TextStyle(
                          //         color: primaryColor,
                          //         fontSize: 11,
                          //         fontWeight: FontWeight.w500,
                          //         fontFamily: 'Poppins',
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ),
                      // Show "Uncategorized" badge for uncategorized items in all view
                      // if ((category == null || category.isEmpty) &&
                      //     this.category == null)
                      //   Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 10,
                      //       vertical: 4,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: Colors.grey.withOpacity(0.08),
                      //       borderRadius: BorderRadius.circular(20),
                      //       border: Border.all(
                      //         color: Colors.grey.withOpacity(0.2),
                      //         width: 1,
                      //       ),
                      //     ),
                      //     child: const Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         Icon(
                      //           Icons.help_outline_rounded,
                      //           size: 12,
                      //           color: Colors.grey,
                      //         ),
                      //         SizedBox(width: 4),
                      //         Text(
                      //           'Uncategorized',
                      //           style: TextStyle(
                      //             color: Colors.grey,
                      //             fontSize: 11,
                      //             fontWeight: FontWeight.w500,
                      //             fontFamily: 'Poppins',
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chevron with accent color
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
