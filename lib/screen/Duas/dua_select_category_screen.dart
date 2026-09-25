// lib/screen/dua_select_category_screen.dart (NEW)
import 'package:flutter/material.dart';
import '../../services/dua_cache_service.dart';
import '../../models/dua_cache_model.dart';

class DuaSelectCategoryScreen extends StatefulWidget {
  final String category;
  final bool isOnline;

  const DuaSelectCategoryScreen({
    super.key,
    required this.category,
    required this.isOnline,
  });

  @override
  State<DuaSelectCategoryScreen> createState() =>
      _DuaSelectCategoryScreenState();
}

class _DuaSelectCategoryScreenState extends State<DuaSelectCategoryScreen> {
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

  List<DuaCache> _categoryDuas = [];

  @override
  void initState() {
    super.initState();
    _loadCategoryDuas();
  }

  void _loadCategoryDuas() {
    final allDuas = DuaCacheService.getAllCachedDuas();

    // Filter duas by category
    _categoryDuas = allDuas
        .where((dua) => dua.category == widget.category)
        .toList();

    setState(() {});
  }

  Widget _buildDuaCard({
    required int index,
    required DuaCache dua,
    required BuildContext context,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () {
          // Return selected dua back through both screens
          Navigator.pop(context, {
            'heading': dua.heading,
            'arabic': dua.arabic,
            'english': dua.english,
            'malayalam': dua.malayalam,
          });
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
                // Dua info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading with offline indicator
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dua.heading,
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
                          ),
                          if (!widget.isOnline) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'Offline',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Arabic preview
                      if (dua.arabic.isNotEmpty)
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            dua.arabic,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.6,
                              fontFamily: 'Scheherazade',
                              color: textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      const SizedBox(height: 4),
                      // Category badge
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //     horizontal: 10,
                      //     vertical: 4,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: primaryColor.withOpacity(0.08),
                      //     borderRadius: BorderRadius.circular(20),
                      //     border: Border.all(
                      //       color: primaryColor.withOpacity(0.2),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       Icon(
                      //         Icons.folder_open_rounded,
                      //         size: 12,
                      //         color: primaryColor.withOpacity(0.7),
                      //       ),
                      //       const SizedBox(width: 4),
                      //       Text(
                      //         widget.category,
                      //         style: TextStyle(
                      //           color: primaryColor,
                      //           fontSize: 11,
                      //           fontWeight: FontWeight.w500,
                      //           fontFamily: 'Poppins',
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Selection icon
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 22,
                  color: accentColor.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_categoryDuas.length} ${_categoryDuas.length == 1 ? 'dua' : 'duas'}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: _categoryDuas.isEmpty
          ? Center(
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
                      'No Duas in "${widget.category}"',
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This category has no duas yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _categoryDuas.length,
                separatorBuilder: (_, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildDuaCard(
                    index: index,
                    dua: _categoryDuas[index],
                    context: context,
                  );
                },
              ),
            ),
    );
  }
}
