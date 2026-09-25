// // lib/screen/duas_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'dua_detail_screen.dart';

// class DuasListScreen extends StatefulWidget {
//   final String? category;

//   const DuasListScreen({super.key, this.category});

//   @override
//   State<DuasListScreen> createState() => _DuasListScreenState();
// }

// class _DuasListScreenState extends State<DuasListScreen> {
//   // 🔥 NEW: Search functionality
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = '';
//   bool _isSearching = false;

//   // Your specified color scheme
//   static const Color primaryColor = Color.fromARGB(
//     255,
//     42,
//     172,
//     131,
//   ); // Deep Teal Green
//   static const Color accentColor = Color(0xFFD4AF37); // Warm Gold
//   static const Color backgroundColor = Color(0xFFFAF9F6); // Warm White
//   static const Color textPrimary = Color(0xFF333333); // Dark Gray
//   static const Color textSecondary = Color(0xFF666666); // Medium Gray
//   static const Color textTertiary = Color(0xFF888888); // Light Gray
//   static const Color cardColor = Color(0xFFFFFFFF); // Pure White
//   static const Color dividerColor = Color(0xFFE0E0E0); // Light Gray Divider

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }

//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged() {
//     setState(() {
//       _searchQuery = _searchController.text.toLowerCase().trim();
//     });
//   }

//   void _clearSearch() {
//     setState(() {
//       _searchController.clear();
//       _searchQuery = '';
//     });
//   }

//   void _toggleSearch() {
//     setState(() {
//       _isSearching = !_isSearching;
//       if (!_isSearching) {
//         _clearSearch();
//       }
//     });
//   }

//   Stream<QuerySnapshot> _getDuasStream() {
//     final collection = FirebaseFirestore.instance
//         .collection('swalathmajlis')
//         .doc('iM6QRMlgUuWNbUdgQ0')
//         .collection('duas');

//     if (widget.category != null) {
//       if (widget.category == 'uncategorized') {
//         // Get uncategorized duas (those without category field or with empty category)
//         return collection
//             .where('category', isEqualTo: '')
//             .orderBy('createdAt', descending: true)
//             .snapshots();
//       } else {
//         // Get duas for specific category
//         return collection
//             .where('category', isEqualTo: widget.category)
//             .orderBy('createdAt', descending: true)
//             .snapshots();
//       }
//     } else {
//       // Get all duas (for "All Duas" tab)
//       return collection.orderBy('createdAt', descending: true).snapshots();
//     }
//   }

//   // 🔥 NEW: Filter duas based on search query
//   List<QueryDocumentSnapshot> _filterDuas(List<QueryDocumentSnapshot> docs) {
//     if (_searchQuery.isEmpty) {
//       return docs;
//     }

//     return docs.where((doc) {
//       final heading = doc['heading']?.toString().toLowerCase() ?? '';
//       final arabic = doc['arabic']?.toString().toLowerCase() ?? '';
//       final malayalam = doc['malayalam']?.toString().toLowerCase() ?? '';
//       final english = doc['english']?.toString().toLowerCase() ?? '';

//       return heading.contains(_searchQuery) ||
//           arabic.contains(_searchQuery) ||
//           malayalam.contains(_searchQuery) ||
//           english.contains(_searchQuery);
//     }).toList();
//   }

//   // Helper method to safely get category
//   String? _getCategory(QueryDocumentSnapshot data) {
//     try {
//       if (data.data().toString().contains("'category':")) {
//         final categoryValue = data['category'];
//         if (categoryValue != null && categoryValue.toString().isNotEmpty) {
//           return categoryValue.toString();
//         }
//       }
//       return null;
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: _isSearching
//             ? TextField(
//                 controller: _searchController,
//                 autofocus: true,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontFamily: 'Poppins',
//                   fontSize: 16,
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Search duas...',
//                   hintStyle: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontFamily: 'Poppins',
//                   ),
//                   border: InputBorder.none,
//                   prefixIcon: const Icon(
//                     Icons.search_rounded,
//                     color: Colors.white,
//                   ),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.clear_rounded, color: Colors.white),
//                     onPressed: _clearSearch,
//                   ),
//                 ),
//               )
//             : Text(
//                 widget.category != null
//                     ? widget.category == 'uncategorized'
//                           ? 'Uncategorized Duas'
//                           : widget.category!
//                     : 'All Duas',
//                 style: const TextStyle(
//                   fontFamily: 'Poppins',
//                   fontWeight: FontWeight.w600,
//                   fontSize: 20,
//                   color: Colors.white,
//                 ),
//               ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           // 🔥 NEW: Search toggle button
//           IconButton(
//             icon: Icon(
//               _isSearching ? Icons.close_rounded : Icons.search_rounded,
//             ),
//             onPressed: _toggleSearch,
//             tooltip: _isSearching ? 'Close search' : 'Search',
//           ),
//         ],
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _getDuasStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     color: primaryColor,
//                     strokeWidth: 3,
//                     backgroundColor: primaryColor.withOpacity(0.1),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Loading Duas...',
//                     style: TextStyle(
//                       color: textSecondary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 80,
//                       height: 80,
//                       decoration: BoxDecoration(
//                         color: Colors.red[50],
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         Icons.error_outline,
//                         color: Colors.red[400],
//                         size: 40,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Connection Error',
//                       style: TextStyle(
//                         color: textPrimary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'Unable to load duas. Please check your connection.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: textSecondary,
//                         fontSize: 14,
//                         height: 1.5,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 100,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: primaryColor.withOpacity(0.1),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         widget.category != null
//                             ? Icons.folder_open_rounded
//                             : Icons.handshake_rounded,
//                         color: primaryColor.withOpacity(0.6),
//                         size: 50,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                       widget.category != null
//                           ? 'No Duas in ${widget.category == "uncategorized" ? "Uncategorized" : widget.category}'
//                           : 'No Duas Available',
//                       style: const TextStyle(
//                         color: textPrimary,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       widget.category != null
//                           ? 'Check other categories for duas.'
//                           : 'New duas will appear here once they are added.',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         color: textSecondary,
//                         fontSize: 14,
//                         height: 1.5,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }

//           final docs = snapshot.data!.docs;
//           final filteredDocs = _filterDuas(docs);

//           // Show "No results" message if search returns nothing
//           if (filteredDocs.isEmpty && _searchQuery.isNotEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.search_off_rounded,
//                     size: 80,
//                     color: textTertiary.withOpacity(0.5),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No results found',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: textPrimary,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'No duas match "$_searchQuery"',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: textSecondary,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   ElevatedButton.icon(
//                     onPressed: _clearSearch,
//                     icon: const Icon(Icons.clear_rounded),
//                     label: const Text('Clear Search'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           // 🔥 FIXED: Removed the nested Column and Expanded
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               children: [
//                 // 🔥 NEW: Search results count (when searching)
//                 if (_searchQuery.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 8,
//                     ),
//                     margin: const EdgeInsets.only(bottom: 8),
//                     decoration: BoxDecoration(
//                       color: primaryColor.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: primaryColor.withOpacity(0.2)),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.search_rounded,
//                           size: 16,
//                           color: primaryColor,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Found ${filteredDocs.length} ${filteredDocs.length == 1 ? 'dua' : 'duas'}',
//                           style: TextStyle(
//                             color: primaryColor,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                             fontFamily: 'Poppins',
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                 // Dua list - Expanded is removed because Column is inside a Padding
//                 Expanded(
//                   child: ListView.separated(
//                     physics: const BouncingScrollPhysics(),
//                     itemCount: filteredDocs.length,
//                     separatorBuilder: (_, index) => const SizedBox(height: 12),
//                     itemBuilder: (_, index) {
//                       final data = filteredDocs[index];
//                       final heading =
//                           data['heading']?.toString() ?? 'Untitled Dua';
//                       final duaCategory = _getCategory(data);

//                       return _buildDuaCard(
//                         index: index,
//                         heading: heading,
//                         category: duaCategory,
//                         data: data,
//                         context: context,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDuaCard({
//     required int index,
//     required String heading,
//     required String? category,
//     required QueryDocumentSnapshot data,
//     required BuildContext context,
//   }) {
//     return Material(
//       color: cardColor,
//       borderRadius: BorderRadius.circular(16),
//       elevation: 0.5,
//       shadowColor: Colors.black.withOpacity(0.05),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) =>
//                   DuaDetailScreen(data: data.data() as Map<String, dynamic>),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(16),
//         splashColor: primaryColor.withOpacity(0.08),
//         highlightColor: primaryColor.withOpacity(0.04),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: dividerColor.withOpacity(0.8), width: 1),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Number badge with accent gold
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: accentColor.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: accentColor.withOpacity(0.3),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${index + 1}',
//                       style: const TextStyle(
//                         color: accentColor,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 14,
//                         fontFamily: 'Poppins',
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Heading with primary color
//                       Text(
//                         heading,
//                         style: const TextStyle(
//                           color: textPrimary,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 16,
//                           height: 1.4,
//                           fontFamily: 'Poppins',
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 8),
//                       // Category badge (if available)
//                       if (category != null && category.isNotEmpty)
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: primaryColor.withOpacity(0.08),
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: primaryColor.withOpacity(0.2),
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.folder_open_rounded,
//                                 size: 12,
//                                 color: primaryColor.withOpacity(0.7),
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 category,
//                                 style: const TextStyle(
//                                   color: primaryColor,
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w500,
//                                   fontFamily: 'Poppins',
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 // Chevron with accent color
//                 Icon(
//                   Icons.arrow_forward_ios_rounded,
//                   size: 16,
//                   color: accentColor.withOpacity(0.8),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
