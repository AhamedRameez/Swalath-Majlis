// quran_screen.dart (user app)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'quran_display_screen.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  // State variables
  int _selectedJuzh = 1;
  bool _isLoadingSurahs = true;

  // Color Theme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // Firestore data
  List<Map<String, dynamic>> _surahs = [];
  final List<Map<String, dynamic>> _juzhStartPages = [];

  @override
  void initState() {
    super.initState();
    _fetchSurahsAndJuzhInfo();
  }

  Future<void> _fetchSurahsAndJuzhInfo() async {
    try {
      setState(() => _isLoadingSurahs = true);

      // Fetch all pages from Firestore
      final pagesSnapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('quran_pages')
          .orderBy('pageNumber')
          .get();

      if (pagesSnapshot.docs.isEmpty) {
        setState(() => _isLoadingSurahs = false);
        return;
      }

      // Extract surah information and juzh start pages
      final Map<String, Map<String, dynamic>> surahMap =
          {}; // Use Arabic name as key
      final Map<int, int> juzhFirstPages = {};

      // First pass: find first page of each juzh and collect ALL surahs
      for (var pageDoc in pagesSnapshot.docs) {
        final pageData = pageDoc.data();
        final pageNumber = pageData['pageNumber'] as int? ?? 0;
        final juzhNumber = pageData['juzhNumber'] as int? ?? 1;

        // Track juzh first pages
        if (!juzhFirstPages.containsKey(juzhNumber)) {
          juzhFirstPages[juzhNumber] = pageNumber;
        }
        if (pageNumber < (juzhFirstPages[juzhNumber] ?? 9999)) {
          juzhFirstPages[juzhNumber] = pageNumber;
        }

        // 🔴 FIXED: Process ALL sections properly
        final sections = pageData['sections'] != null
            ? List<Map<String, dynamic>>.from(pageData['sections'] as List)
            : [];

        if (sections.isNotEmpty) {
          // NEW FORMAT: Process EVERY section that starts a new surah
          for (var section in sections) {
            if (section['type'] == 'newSurah') {
              final surahNameArabic =
                  section['surahNameArabic'] as String? ?? '';
              final surahNameEnglish =
                  section['surahNameEnglish'] as String? ?? '';

              if (surahNameArabic.isNotEmpty) {
                if (!surahMap.containsKey(surahNameArabic)) {
                  // New surah - add it
                  surahMap[surahNameArabic] = {
                    'number': surahMap.length + 1,
                    'arabic': surahNameArabic,
                    'english': surahNameEnglish,
                    'juzh': juzhNumber,
                    'startPage': pageNumber,
                    'endPage': pageNumber,
                  };
                } else {
                  // Update existing surah
                  final surah = surahMap[surahNameArabic]!;
                  if (pageNumber < surah['startPage']) {
                    surah['startPage'] = pageNumber;
                    surah['juzh'] = juzhNumber;
                  }
                  if (pageNumber > surah['endPage']) {
                    surah['endPage'] = pageNumber;
                  }
                }
              }
            }
          }
        } else {
          // OLD FORMAT: Check if page starts with new surah
          final isNewSurahOnPage =
              pageData['isNewSurahOnPage'] as bool? ?? false;
          if (isNewSurahOnPage) {
            final surahNameArabic =
                pageData['surahNameArabic'] as String? ?? '';
            final surahNameEnglish =
                pageData['surahNameEnglish'] as String? ?? '';

            if (surahNameArabic.isNotEmpty) {
              if (!surahMap.containsKey(surahNameArabic)) {
                surahMap[surahNameArabic] = {
                  'number': surahMap.length + 1,
                  'arabic': surahNameArabic,
                  'english': surahNameEnglish,
                  'juzh': juzhNumber,
                  'startPage': pageNumber,
                  'endPage': pageNumber,
                };
              } else {
                final surah = surahMap[surahNameArabic]!;
                if (pageNumber < surah['startPage']) {
                  surah['startPage'] = pageNumber;
                  surah['juzh'] = juzhNumber;
                }
                if (pageNumber > surah['endPage']) {
                  surah['endPage'] = pageNumber;
                }
              }
            }
          }
        }
      }

      // Second pass: ensure end pages are correctly set by scanning all pages in order
      String? currentSurahArabic;
      for (var pageDoc in pagesSnapshot.docs) {
        final pageData = pageDoc.data();
        final pageNumber = pageData['pageNumber'] as int? ?? 0;

        final sections = pageData['sections'] != null
            ? List<Map<String, dynamic>>.from(pageData['sections'] as List)
            : [];

        // Check for new surahs starting on this page
        bool foundNewSurah = false;

        if (sections.isNotEmpty) {
          for (var section in sections) {
            if (section['type'] == 'newSurah') {
              final surahNameArabic = section['surahNameArabic'] as String?;
              if (surahNameArabic != null && surahNameArabic.isNotEmpty) {
                currentSurahArabic = surahNameArabic;
                foundNewSurah = true;
              }
            }
          }
        } else {
          final isNewSurahOnPage =
              pageData['isNewSurahOnPage'] as bool? ?? false;
          if (isNewSurahOnPage) {
            final surahNameArabic = pageData['surahNameArabic'] as String?;
            if (surahNameArabic != null && surahNameArabic.isNotEmpty) {
              currentSurahArabic = surahNameArabic;
              foundNewSurah = true;
            }
          }
        }

        // Update end page for current surah
        if (currentSurahArabic != null &&
            surahMap.containsKey(currentSurahArabic)) {
          surahMap[currentSurahArabic]!['endPage'] = pageNumber;
        }

        // If no new surah found, continue with current surah
        if (!foundNewSurah && currentSurahArabic != null) {
          surahMap[currentSurahArabic]!['endPage'] = pageNumber;
        }
      }

      // Convert map to list and sort by start page
      _surahs = surahMap.values.toList();
      _surahs.sort(
        (a, b) => (a['startPage'] as int).compareTo(b['startPage'] as int),
      );

      // Assign sequential numbers based on order
      for (int i = 0; i < _surahs.length; i++) {
        _surahs[i]['number'] = i + 1;
      }

      // Update page ranges for display
      for (var surah in _surahs) {
        final startPage = surah['startPage'] as int? ?? 1;
        final endPage = surah['endPage'] as int? ?? startPage;
        surah['pages'] = startPage == endPage
            ? '$startPage'
            : '$startPage-$endPage';
      }

      // Build juzh start pages list
      _juzhStartPages.clear();
      for (int juzh = 1; juzh <= 30; juzh++) {
        final firstPage =
            juzhFirstPages[juzh] ?? _getDefaultJuzhStartPage(juzh);
        _juzhStartPages.add({'juzh': juzh, 'startPage': firstPage});
      }

      setState(() => _isLoadingSurahs = false);
    } catch (e) {
      print('Error fetching Quran data: $e');
      setState(() => _isLoadingSurahs = false);
      _setDefaultJuzhStartPages();
    }
  }

  void _addOrUpdateSurah(
    Map<int, Map<String, dynamic>> surahMap,
    String surahNameArabic,
    String surahNameEnglish,
    int juzhNumber,
    int pageNumber,
  ) {
    // Find if this surah already exists
    Map<String, dynamic>? existingSurah;
    int existingSurahNumber = 0;

    for (var entry in surahMap.entries) {
      if (entry.value['arabic'] == surahNameArabic) {
        existingSurah = entry.value;
        existingSurahNumber = entry.key;
        break;
      }
    }

    if (existingSurah == null) {
      // New surah - add to map
      final surahNumber = surahMap.length + 1;
      surahMap[surahNumber] = {
        'number': surahNumber,
        'arabic': surahNameArabic,
        'english': surahNameEnglish,
        'juzh': juzhNumber,
        'startPage': pageNumber,
        'endPage': pageNumber,
      };
    } else {
      // Update existing surah end page
      existingSurah['endPage'] = pageNumber;

      // Update juzh if this page has a lower page number
      if (pageNumber < (existingSurah['startPage'] as int? ?? 9999)) {
        existingSurah['startPage'] = pageNumber;
        existingSurah['juzh'] = juzhNumber;
      }

      // Update juzh for end page
      if (pageNumber > (existingSurah['endPage'] as int? ?? 0)) {
        existingSurah['endPage'] = pageNumber;
      }
    }
  }

  void _updateSurahEndPages(
    Map<int, Map<String, dynamic>> surahMap,
    QuerySnapshot<Map<String, dynamic>> pagesSnapshot,
  ) {
    if (surahMap.isEmpty) return;

    // Track current surah while iterating through pages
    int currentSurahNumber = 1;
    String? currentSurahArabic = _surahs.isNotEmpty
        ? _surahs[0]['arabic']
        : null;

    for (var pageDoc in pagesSnapshot.docs) {
      final pageData = pageDoc.data();
      final pageNumber = pageData['pageNumber'] as int? ?? 0;

      final sections = pageData['sections'] != null
          ? List<Map<String, dynamic>>.from(pageData['sections'] as List)
          : [];

      bool foundNewSurahOnPage = false;

      if (sections.isNotEmpty) {
        // NEW FORMAT: Check each section
        for (var section in sections) {
          if (section['type'] == 'newSurah') {
            final surahNameArabic = section['surahNameArabic'] as String?;
            if (surahNameArabic != null && surahNameArabic.isNotEmpty) {
              // Find surah number for this name
              for (var entry in surahMap.entries) {
                if (entry.value['arabic'] == surahNameArabic) {
                  currentSurahNumber = entry.key;
                  currentSurahArabic = surahNameArabic;
                  break;
                }
              }
              foundNewSurahOnPage = true;
            }
          }
        }
      } else {
        // OLD FORMAT
        final isNewSurahOnPage = pageData['isNewSurahOnPage'] as bool? ?? false;
        if (isNewSurahOnPage) {
          final surahNameArabic = pageData['surahNameArabic'] as String?;
          if (surahNameArabic != null && surahNameArabic.isNotEmpty) {
            // Find surah number for this name
            for (var entry in surahMap.entries) {
              if (entry.value['arabic'] == surahNameArabic) {
                currentSurahNumber = entry.key;
                currentSurahArabic = surahNameArabic;
                break;
              }
            }
            foundNewSurahOnPage = true;
          }
        }
      }

      // Update end page for current surah
      if (currentSurahNumber <= surahMap.length) {
        surahMap[currentSurahNumber]!['endPage'] = pageNumber;
      }

      // If no new surah found on this page, continue with current surah
      if (!foundNewSurahOnPage && currentSurahArabic != null) {
        // Update current surah's end page
        for (var entry in surahMap.entries) {
          if (entry.value['arabic'] == currentSurahArabic) {
            entry.value['endPage'] = pageNumber;
            break;
          }
        }
      }
    }
  }

  int _getDefaultJuzhStartPage(int juzh) {
    final Map<int, int> defaultJuzhPages = {
      1: 1,
      2: 22,
      3: 42,
      4: 62,
      5: 82,
      6: 102,
      7: 122,
      8: 142,
      9: 162,
      10: 182,
      11: 201,
      12: 222,
      13: 242,
      14: 262,
      15: 282,
      16: 302,
      17: 322,
      18: 342,
      19: 362,
      20: 382,
      21: 402,
      22: 422,
      23: 442,
      24: 462,
      25: 482,
      26: 502,
      27: 522,
      28: 542,
      29: 562,
      30: 582,
    };
    return defaultJuzhPages[juzh] ?? ((juzh - 1) * 20 + 1);
  }

  void _setDefaultJuzhStartPages() {
    _juzhStartPages.clear();
    for (int juzh = 1; juzh <= 30; juzh++) {
      _juzhStartPages.add({
        'juzh': juzh,
        'startPage': _getDefaultJuzhStartPage(juzh),
      });
    }

    _surahs = [
      {
        'number': 1,
        'arabic': 'الفاتحة',
        'english': 'Al-Fatihah',
        'juzh': 1,
        'pages': '1-1',
        'startPage': 1,
      },
      {
        'number': 2,
        'arabic': 'البقرة',
        'english': 'Al-Baqarah',
        'juzh': 1,
        'pages': '2-49',
        'startPage': 2,
      },
    ];
  }

  void _selectJuzh(int juzh, BuildContext context) {
    setState(() {
      _selectedJuzh = juzh;
    });

    final juzhInfo = _juzhStartPages.firstWhere(
      (j) => j['juzh'] == juzh,
      orElse: () => {'juzh': juzh, 'startPage': _getDefaultJuzhStartPage(juzh)},
    );

    final startPage = juzhInfo['startPage'] as int;

    // Find which surah contains this page
    Map<String, dynamic>? targetSurah;
    for (var surah in _surahs) {
      final surahStartPage = surah['startPage'] as int? ?? 0;
      final surahEndPage = surah['endPage'] as int? ?? 0;
      if (startPage >= surahStartPage && startPage <= surahEndPage) {
        targetSurah = surah;
        break;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranDisplayScreen(
          initialPage: startPage,
          initialSurahNameArabic: targetSurah?['arabic'] as String?,
          initialSurahNameEnglish: targetSurah?['english'] as String?,
        ),
      ),
    );
  }

  void _navigateToSurah(Map<String, dynamic> surah, BuildContext context) {
    final startPage = surah['startPage'] as int? ?? 1;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranDisplayScreen(
          initialPage: startPage,
          initialSurahNameArabic: surah['arabic'] as String?,
          initialSurahNameEnglish: surah['english'] as String?,
        ),
      ),
    );
  }

  Widget _buildSurahListItem(int index, BuildContext context) {
    final surah = _surahs[index];
    final isFirstSurah = index == 0;
    final isLastSurah = index == _surahs.length - 1;

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.only(
        topLeft: isFirstSurah ? const Radius.circular(16) : const Radius.circular(0),
        topRight: isFirstSurah ? const Radius.circular(16) : const Radius.circular(0),
        bottomLeft: isLastSurah ? const Radius.circular(16) : const Radius.circular(0),
        bottomRight: isLastSurah ? const Radius.circular(16) : const Radius.circular(0),
      ),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: () => _navigateToSurah(surah, context),
        borderRadius: BorderRadius.only(
          topLeft: isFirstSurah ? const Radius.circular(16) : const Radius.circular(0),
          topRight: isFirstSurah ? const Radius.circular(16) : const Radius.circular(0),
          bottomLeft: isLastSurah ? const Radius.circular(16) : const Radius.circular(0),
          bottomRight: isLastSurah ? const Radius.circular(16) : const Radius.circular(0),
        ),
        splashColor: primaryColor.withValues(alpha: 0.08),
        highlightColor: primaryColor.withValues(alpha: 0.04),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: !isLastSurah
                  ? BorderSide(color: dividerColor.withValues(alpha: 0.5), width: 0.5)
                  : BorderSide.none,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
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
                      '${surah['number']}',
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
                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // English name on left
                          Expanded(
                            child: Text(
                              surah['english'] ?? 'Unknown',
                              style: const TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                height: 1.4,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Arabic name on right
                          Expanded(
                            child: Text(
                              surah['arabic'] ?? '',
                              style: const TextStyle(
                                fontFamily: 'Uthmani',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Meta information
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Icon(
                              //   Icons.bookmark_border_rounded,
                              //   size: 12,
                              //   color: textTertiary,
                              // ),
                              const SizedBox(width: 4),
                              Text(
                                'Juzh ${surah['juzh']}',
                                style: const TextStyle(
                                  color: textTertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              // Icon(
                              //   Icons.auto_stories_rounded,
                              //   size: 12,
                              //   color: textTertiary,
                              // ),
                              const SizedBox(width: 4),
                              Text(
                                'Pages ${surah['pages']}',
                                style: const TextStyle(
                                  color: textTertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Chevron icon
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

  Widget _buildJuzhSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(30, (index) {
            final juzhNumber = index + 1;
            final juzhInfo = _juzhStartPages.firstWhere(
              (j) => j['juzh'] == juzhNumber,
              orElse: () => {
                'juzh': juzhNumber,
                'startPage': _getDefaultJuzhStartPage(juzhNumber),
              },
            );
            final hasData = _juzhStartPages.any((j) => j['juzh'] == juzhNumber);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Material(
                color: _selectedJuzh == juzhNumber
                    ? primaryColor
                    : hasData
                    ? cardColor
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                elevation: _selectedJuzh == juzhNumber ? 2 : 0,
                child: InkWell(
                  onTap: () => _selectJuzh(juzhNumber, context),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedJuzh == juzhNumber
                            ? primaryColor
                            : dividerColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$juzhNumber',
                      style: TextStyle(
                        color: _selectedJuzh == juzhNumber
                            ? Colors.white
                            : hasData
                            ? textPrimary
                            : textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Quran',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
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
      body: Column(
        children: [
          // Juzh Selector Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                bottom: BorderSide(color: dividerColor.withValues(alpha: 0.8)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bookmark_rounded, color: primaryColor, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Browse by Juzh',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildJuzhSelector(context),
              ],
            ),
          ),

          // Surah List Section
          Expanded(
            child: _isLoadingSurahs
                ? Center(
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
                          'Loading Quran...',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fetching surahs and juzh information',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  )
                : _surahs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
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
                              Icons.menu_book_rounded,
                              color: primaryColor.withValues(alpha: 0.6),
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Quran Data Available',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Admin needs to upload Quran pages first',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                              height: 1.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _fetchSurahsAndJuzhInfo,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    color: backgroundColor,
                    child: Column(
                      children: [
                        // List header
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          decoration: BoxDecoration(
                            color: cardColor,
                            border: Border(
                              bottom: BorderSide(
                                color: dividerColor.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Surah List',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '${_surahs.length} Surahs',
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Surah list
                        Expanded(
                          child: ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 12,
                              bottom: 12,
                            ),
                            itemCount: _surahs.length,
                            separatorBuilder: (_, index) =>
                                const SizedBox(height: 0),
                            itemBuilder: (context, index) {
                              return _buildSurahListItem(index, context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(
                top: BorderSide(color: dividerColor.withValues(alpha: 0.8)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            // child: Center(
            //   child: Column(
            //     children: [
            //       // Text(
            //       //   'Total: ${_surahs.length} Surahs • Juzh $_selectedJuzh',
            //       //   style: TextStyle(
            //       //     color: textTertiary,
            //       //     fontSize: 13,
            //       //     fontWeight: FontWeight.w500,
            //       //     fontFamily: 'Poppins',
            //       //   ),
            //       // ),
            //       const SizedBox(height: 4),
            //       Text(
            //         'Tap on a surah to read, or select a Juzh above',
            //         style: TextStyle(
            //           color: textTertiary,
            //           fontSize: 11,
            //           fontFamily: 'Poppins',
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ),
        ],
      ),
    );
  }
}
