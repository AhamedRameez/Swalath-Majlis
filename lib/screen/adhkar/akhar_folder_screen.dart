// lib/screen/user/adkar_folder_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'adkar_details_screen.dart';
// import '../../services/theme_service.dart';

class AdkarFolderScreen extends StatelessWidget {
  final String folderName;

  const AdkarFolderScreen({super.key, required this.folderName});

  // Theme colors from ThemeService
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              folderName,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Text(
              'Folder',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
          .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('adkar')
            .where('category', isEqualTo: folderName)
            .orderBy('createdAt', descending: true)
            .snapshots(),
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
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            print('🔥 Firestore Error: ${snapshot.error}');

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
                      'Error',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load adkar. Please try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (snapshot.error.toString().contains('index'))
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Missing Firestore Index',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please check the console for the link to create the required index.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                      child: Icon(
                        Icons.folder_open_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No adkar in $folderName',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Items added to this folder will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: docs.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final title = data['title']?.toString() ?? 'Untitled';
                final hasDua =
                    data['dua'] != null && data['dua'].toString().isNotEmpty;

                return _buildadkarCard(
                  index: index,
                  title: title,
                  hasDua: hasDua,
                  data: data,
                  docId: docs[index].id,
                  context: context,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildadkarCard({
    required int index,
    required String title,
    required bool hasDua,
    required Map<String, dynamic> data,
    required String docId,
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
              builder: (_) => AdkarDetailScreen(adkarData: data, docId: docId),
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
                      Text(
                        title,
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
                      if (hasDua) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Dua',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
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
