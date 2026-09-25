// lib/screen/islamic_studies_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Q&A/qa_list_screen.dart';
import 'islamic_study_list_screen.dart';

class IslamicStudiesMenuScreen extends StatefulWidget {
  const IslamicStudiesMenuScreen({super.key});

  @override
  State<IslamicStudiesMenuScreen> createState() =>
      _IslamicStudiesMenuScreenState();
}

class _IslamicStudiesMenuScreenState extends State<IslamicStudiesMenuScreen> {
  // 🎨 Using the same theme colors as UserDashboard
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  int _qaCount = 0; // 🆕 Q&A count

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadQACount(); // 🆕 Load Q&A count
  }

  // 🆕 Load Q&A count
  Future<void> _loadQACount() async {
    try {
      final countSnapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('qa_section')
          .count()
          .get();

      setState(() {
        _qaCount = countSnapshot.count ?? 0;
      });
    } catch (e) {
      print('Error loading Q&A count: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('islamicstudy_categories')
          .orderBy('name')
          .get();

      // Get study counts for each category
      List<Map<String, dynamic>> categoriesWithCounts = [];

      for (var doc in snapshot.docs) {
        final categoryName = doc['name'] as String;

        // Count studies in this category
        final countSnapshot = await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('islamicstudy')
            .where('category', isEqualTo: categoryName)
            .count()
            .get();

        // Assign icons based on category name
        IconData icon;
        Color color;

        switch (categoryName.toLowerCase()) {
          case 'fiqh':
            icon = Icons.account_balance_rounded;
            color = primaryColor;
            break;
          case 'thajweed':
            icon = Icons.volume_up_rounded;
            color = accentColor;
            break;
          case 'thareeq':
            icon = Icons.timeline_rounded;
            color = const Color.fromARGB(255, 255, 152, 0); // Orange
            break;
          default:
            icon = Icons.menu_book_rounded;
            color = const Color(0xFF3E63DD); // Blue for other categories
        }

        categoriesWithCounts.add({
          'name': categoryName,
          'count': countSnapshot.count,
          'icon': icon,
          'color': color,
        });
      }

      setState(() {
        _categories = categoriesWithCounts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 6,
        backgroundColor: primaryColor,
        title: const Text(
          'Islamic Studies',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F3EF), Color(0xFFFAF9F6), Color(0xFFF5F3EF)],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: primaryColor),
                    SizedBox(height: 20),
                    Text(
                      'Loading categories...',
                      style: TextStyle(
                        color: textSecondary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              )
            : _categories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.category_rounded,
                              size: 40,
                              color: primaryColor.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No Categories Available',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Check back later for Islamic studies content',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              fontFamily: 'Poppins',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: dividerColor, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  color: primaryColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Islamic Studies',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Learn Fiqh, Thajweed & Thareeq',
                                      style: TextStyle(
                                        color: textSecondary,
                                        fontSize: 13,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 🆕 Q&A Card (Full width)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const QAListScreen(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF9C27B0)
                                      .withValues(alpha: 0.1),
                                  const Color(0xFFE91E63)
                                      .withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF9C27B0)
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF9C27B0)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.quiz_rounded,
                                    color: Color(0xFF9C27B0),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Question & Answer',
                                        style: TextStyle(
                                          color: textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _qaCount > 0
                                            ? '$_qaCount Q&A available'
                                            : 'Learn from Q&A',
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 13,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '$_qaCount',
                                    style: const TextStyle(
                                      color: Color(0xFF9C27B0),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF9C27B0),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Categories Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            final color = category['color'] as Color;

                            return GestureDetector(
                              onTap: () {
                                if (category['count'] > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => IslamicStudyListScreen(
                                        category: category['name'],
                                        categoryColor: color,
                                      ),
                                    ),
                                  );
                                } else {
                                  _showEmptyCategorySnackbar(
                                    context,
                                    category['name'],
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: dividerColor,
                                    width: 0.8,
                                  ),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 38,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          category['icon'],
                                          size: 20,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Text(
                                          category['name'],
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.onSurface,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11,
                                                fontFamily: 'Poppins',
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: category['count'] > 0
                                              ? color.withValues(alpha: 0.1)
                                              : textSecondary.withValues(
                                                  alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          category['count'] > 0
                                              ? '${category['count']}'
                                              : '0',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 8,
                                            color: category['count'] > 0
                                                ? color
                                                : textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  void _showEmptyCategorySnackbar(BuildContext context, String categoryName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No lessons available in $categoryName yet'),
        duration: const Duration(seconds: 2),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
