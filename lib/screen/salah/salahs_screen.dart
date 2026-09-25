// // lib/screen/user/salahs_screen.dart
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'salah_detail_screen.dart';

// // ✅ Import the constants for image mapping
// import '../../utils/salah_constants.dart';

// class SalahsScreen extends StatelessWidget {
//   const SalahsScreen({super.key});

//   // Your color scheme
//   static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
//   static const Color accentColor = Color(0xFFD4AF37);
//   static const Color backgroundColor = Color(0xFFFAF9F6);
//   static const Color textPrimary = Color(0xFF333333);
//   static const Color textSecondary = Color(0xFF666666);
//   static const Color textTertiary = Color(0xFF888888);
//   static const Color cardColor = Color(0xFFFFFFFF);
//   static const Color dividerColor = Color(0xFFE0E0E0);

//   // Safe data access helper
//   static String _getString(Map<String, dynamic> data, String key) {
//     return data[key]?.toString() ?? '';
//   }

//   // 🖼️ Get image path based on Salah name
//   static String _getImagePath(String name) {
//     if (SalahConstants.salahImages.containsKey(name)) {
//       return SalahConstants.salahImages[name]!;
//     }
//     return SalahConstants.defaultImage;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Salah Guide',
//           style: TextStyle(
//             fontFamily: 'Poppins',
//             fontWeight: FontWeight.w600,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: primaryColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: false,
//         iconTheme: const IconThemeData(color: Colors.white),
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('swalathmajlis')
//             .doc('iM6QRMlgUuWNbUdgQ0')
//             .collection('salahs')
//             .orderBy('createdAt', descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: primaryColor,
//                 strokeWidth: 3,
//                 backgroundColor: primaryColor.withValues(alpha: 0.1),
//               ),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.error_outline_rounded,
//                     color: Colors.red[400],
//                     size: 48,
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Error loading salahs',
//                     style: TextStyle(
//                       color: textPrimary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     snapshot.error.toString(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: textSecondary,
//                       fontSize: 12,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.mosque_rounded, color: textTertiary, size: 48),
//                   SizedBox(height: 16),
//                   Text(
//                     'No Salahs Available',
//                     style: TextStyle(
//                       color: textPrimary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w500,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     'Check back later for updates',
//                     style: TextStyle(
//                       color: textSecondary,
//                       fontSize: 14,
//                       fontFamily: 'Poppins',
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final docs = snapshot.data!.docs;

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView.separated(
//               physics: const BouncingScrollPhysics(),
//               itemCount: docs.length,
//               separatorBuilder: (_, index) => const SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 final doc = docs[index];
//                 final dataMap = doc.data() as Map<String, dynamic>;

//                 final name = _getString(dataMap, 'name');
//                 final description = _getString(dataMap, 'description');
//                 final englishName = _getString(dataMap, 'englishName');
//                 final textBlocks = dataMap['textBlocks'] ?? [];

//                 return _buildSalahCard(
//                   context: context,
//                   name: name,
//                   englishName: englishName,
//                   description: description,
//                   textBlocks: textBlocks,
//                   imagePath: _getImagePath(name), // 🖼️ Get image from assets
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) =>
//                             SalahDetailScreen(docId: doc.id, data: dataMap),
//                       ),
//                     );
//                   },
//                   index: index,
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSalahCard({
//     required BuildContext context,
//     required String name,
//     required String englishName,
//     required String description,
//     required List textBlocks,
//     required String imagePath,
//     required VoidCallback onTap,
//     required int index,
//   }) {
//     // Get language icons for preview
//     final languageIcons = {
//       'Malayalam': Icons.translate,
//       'Arabic': Icons.translate_rounded,
//       'English': Icons.language,
//     };

//     final languageColors = {
//       'Malayalam': primaryColor,
//       'Arabic': accentColor,
//       'English': Colors.blue,
//     };

//     return Material(
//       color: cardColor,
//       borderRadius: BorderRadius.circular(16),
//       elevation: 0.5,
//       shadowColor: Colors.black.withValues(alpha: 0.05),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//                 color: dividerColor.withValues(alpha: 0.8), width: 1),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // 🖼️ IMAGE THUMBNAIL (instead of number badge)
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(10),
//                   child: Container(
//                     width: 60,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Image.asset(
//                       imagePath,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         // Fallback if image not found
//                         return Container(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [
//                                 primaryColor,
//                                 Color.fromARGB(255, 35, 150, 115)
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Center(
//                             child: Text(
//                               '${index + 1}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 18,
//                                 fontFamily: 'Poppins',
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 14),

//                 // Content
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Salah Name (Arabic)
//                       Text(
//                         name.isNotEmpty ? name : 'Unnamed Salah',
//                         style: const TextStyle(
//                           color: textPrimary,
//                           fontSize: 17,
//                           fontWeight: FontWeight.w600,
//                           fontFamily: 'Amiri',
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         textDirection: TextDirection.rtl,
//                       ),

//                       // English Name (if available)
//                       if (englishName.isNotEmpty) ...[
//                         const SizedBox(height: 2),
//                         Text(
//                           englishName,
//                           style: TextStyle(
//                             color: textSecondary,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w400,
//                             fontFamily: 'Poppins',
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],

//                       const SizedBox(height: 6),

//                       // Language indicators (preview of available languages)
//                       if (textBlocks.isNotEmpty)
//                         Wrap(
//                           spacing: 6,
//                           runSpacing: 4,
//                           children: textBlocks
//                               .map((block) => block['language'] as String)
//                               .toSet()
//                               .map((language) {
//                             return Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 3,
//                               ),
//                               decoration: BoxDecoration(
//                                 color:
//                                     (languageColors[language] ?? primaryColor)
//                                         .withValues(alpha: 0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color:
//                                       (languageColors[language] ?? primaryColor)
//                                           .withValues(alpha: 0.3),
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Icon(
//                                     languageIcons[language] ?? Icons.translate,
//                                     size: 11,
//                                     color: languageColors[language] ??
//                                         primaryColor,
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     language == 'Malayalam'
//                                         ? 'മലയാളം'
//                                         : language == 'Arabic'
//                                             ? 'العربية'
//                                             : 'English',
//                                     style: TextStyle(
//                                       color: languageColors[language] ??
//                                           primaryColor,
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.w500,
//                                       fontFamily: 'Poppins',
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }).toList(),
//                         ),

//                       // Description (if available)
//                       if (description.isNotEmpty) ...[
//                         const SizedBox(height: 6),
//                         Text(
//                           description,
//                           style: TextStyle(
//                             color: textSecondary,
//                             fontSize: 12,
//                             fontFamily: 'Poppins',
//                             height: 1.3,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),

//                 const SizedBox(width: 8),

//                 // Chevron icon
//                 Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: primaryColor.withValues(alpha: 0.08),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 14,
//                     color: primaryColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
