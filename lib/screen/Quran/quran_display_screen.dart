// lib/screen/quran_display_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranDisplayScreen extends StatefulWidget {
  final int initialPage;
  final String? initialSurahNameArabic;
  final String? initialSurahNameEnglish;

  const QuranDisplayScreen({
    super.key,
    this.initialPage = 1,
    this.initialSurahNameArabic,
    this.initialSurahNameEnglish,
  });

  @override
  State<QuranDisplayScreen> createState() => _QuranDisplayScreenState();
}

class _QuranDisplayScreenState extends State<QuranDisplayScreen> {
  late PageController _pageController;
  int _currentPage = 1;
  bool _isLoadingSurahs = true;
  List<Map<String, dynamic>> _surahs = [];

  // Bookmark variables
  final Map<int, Map<String, dynamic>> _bookmarks = {};
  bool _isLoadingBookmarks = false;

  // Color Theme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  // 🔥 NEW: tharjeem color
  static const Color tharjeemColor = Color(0xFF1A472A);

  // For navigation drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Font size variables
  double _arabicFontSize = 26.0;
  static const double _minFontSize = 22.0;
  static const double _maxFontSize = 34.0;
  bool _showFontAdjustPanel = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage - 1);
    _fetchSurahsForDrawer();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      setState(() => _isLoadingBookmarks = true);
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getString('quran_bookmarks');

      if (bookmarksJson != null && bookmarksJson.isNotEmpty) {
        try {
          final bookmarksData = bookmarksJson.split('||');
          _bookmarks.clear();

          for (var bookmarkStr in bookmarksData) {
            if (bookmarkStr.contains('::')) {
              final parts = bookmarkStr.split('::');
              if (parts.length >= 6) {
                final page = int.tryParse(parts[0]);
                if (page != null) {
                  _bookmarks[page] = {
                    'page': page,
                    'surahArabic': parts[1],
                    'surahEnglish': parts[2],
                    'juzh': int.tryParse(parts[3]) ?? 1,
                    'date': parts[4],
                    'time': parts[5],
                  };
                }
              }
            }
          }
        } catch (e) {
          print('Error parsing bookmarks: $e');
          _bookmarks.clear();
        }
      }
    } catch (e) {
      print('Error loading bookmarks: $e');
    } finally {
      setState(() => _isLoadingBookmarks = false);
    }
  }

  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksList = <String>[];

      for (var bookmark in _bookmarks.values) {
        final page = bookmark['page']?.toString() ?? '';
        final surahArabic = bookmark['surahArabic']?.toString() ?? '';
        final surahEnglish = bookmark['surahEnglish']?.toString() ?? '';
        final juzh = bookmark['juzh']?.toString() ?? '1';
        final date = bookmark['date']?.toString() ?? '';
        final time = bookmark['time']?.toString() ?? '';

        bookmarksList.add(
          '$page::$surahArabic::$surahEnglish::$juzh::$date::$time',
        );
      }

      await prefs.setString('quran_bookmarks', bookmarksList.join('||'));
    } catch (e) {
      print('Error saving bookmarks: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    final currentTime = DateTime.now();
    final formattedDate =
        "${currentTime.day}/${currentTime.month}/${currentTime.year}";
    final hour = currentTime.hour % 12;
    final hour12 = hour == 0 ? 12 : hour;
    final amPm = currentTime.hour < 12 ? 'AM' : 'PM';
    final formattedTime =
        "$hour12:${currentTime.minute.toString().padLeft(2, '0')} $amPm";

    if (_bookmarks.containsKey(_currentPage)) {
      _bookmarks.remove(_currentPage);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bookmark removed'),
          backgroundColor: Colors.grey[700],
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      final currentSurah = _getCurrentSurah();

      _bookmarks[_currentPage] = {
        'page': _currentPage,
        'surahArabic': currentSurah['arabic'],
        'surahEnglish': currentSurah['english'],
        'juzh': _getCurrentJuzh(),
        'date': formattedDate,
        'time': formattedTime,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Page bookmarked successfully!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Date: $formattedDate | Time: $formattedTime',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    await _saveBookmarks();
    setState(() {});
  }

  Future<void> _removeBookmark(int page) async {
    _bookmarks.remove(page);
    await _saveBookmarks();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmark for Page $page removed'),
        backgroundColor: Colors.grey[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removeAllBookmarks() async {
    if (_bookmarks.isEmpty) return;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove All Bookmarks'),
        content: const Text(
          'Are you sure you want to remove all bookmarks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _bookmarks.clear();
      await _saveBookmarks();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_bookmarks.length} bookmarks removed'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Map<String, dynamic> _getCurrentSurah() {
    for (var surah in _surahs) {
      final startPage = surah['startPage'] as int? ?? 0;
      final endPage = surah['endPage'] as int? ?? 0;
      if (_currentPage >= startPage && _currentPage <= endPage) {
        return surah;
      }
    }
    return {'arabic': '', 'english': 'Unknown Surah'};
  }

  int _getCurrentJuzh() {
    if (_currentPage <= 21) return 1;
    if (_currentPage <= 41) return 2;
    if (_currentPage <= 61) return 3;
    if (_currentPage <= 81) return 4;
    if (_currentPage <= 101) return 5;
    if (_currentPage <= 121) return 6;
    if (_currentPage <= 141) return 7;
    if (_currentPage <= 161) return 8;
    if (_currentPage <= 181) return 9;
    if (_currentPage <= 200) return 10;
    if (_currentPage <= 221) return 11;
    if (_currentPage <= 241) return 12;
    if (_currentPage <= 261) return 13;
    if (_currentPage <= 281) return 14;
    if (_currentPage <= 301) return 15;
    if (_currentPage <= 321) return 16;
    if (_currentPage <= 341) return 17;
    if (_currentPage <= 361) return 18;
    if (_currentPage <= 381) return 19;
    if (_currentPage <= 401) return 20;
    if (_currentPage <= 421) return 21;
    if (_currentPage <= 441) return 22;
    if (_currentPage <= 461) return 23;
    if (_currentPage <= 481) return 24;
    if (_currentPage <= 501) return 25;
    if (_currentPage <= 521) return 26;
    if (_currentPage <= 541) return 27;
    if (_currentPage <= 561) return 28;
    if (_currentPage <= 581) return 29;
    return 30;
  }

  Future<void> _fetchSurahsForDrawer() async {
    try {
      setState(() => _isLoadingSurahs = true);
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

      final Map<String, Map<String, dynamic>> surahMap = {};

      for (var pageDoc in pagesSnapshot.docs) {
        final pageData = pageDoc.data();
        final pageNumber = pageData['pageNumber'] as int? ?? 0;
        final sections = pageData['sections'] != null
            ? List<Map<String, dynamic>>.from(pageData['sections'] as List)
            : [];

        if (sections.isNotEmpty) {
          for (var section in sections) {
            if (section['type'] == 'newSurah') {
              final surahNameArabic =
                  section['surahNameArabic'] as String? ?? '';
              final surahNameEnglish =
                  section['surahNameEnglish'] as String? ?? '';

              if (surahNameArabic.isNotEmpty) {
                if (!surahMap.containsKey(surahNameArabic)) {
                  surahMap[surahNameArabic] = {
                    'arabic': surahNameArabic,
                    'english': surahNameEnglish,
                    'startPage': pageNumber,
                    'endPage': pageNumber,
                  };
                } else {
                  final surah = surahMap[surahNameArabic]!;
                  if (pageNumber < surah['startPage']) {
                    surah['startPage'] = pageNumber;
                  }
                  if (pageNumber > surah['endPage']) {
                    surah['endPage'] = pageNumber;
                  }
                }
              }
            }
          }
        } else {
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
                  'arabic': surahNameArabic,
                  'english': surahNameEnglish,
                  'startPage': pageNumber,
                  'endPage': pageNumber,
                };
              } else {
                final surah = surahMap[surahNameArabic]!;
                if (pageNumber < surah['startPage']) {
                  surah['startPage'] = pageNumber;
                }
                if (pageNumber > surah['endPage']) {
                  surah['endPage'] = pageNumber;
                }
              }
            }
          }
        }
      }

      String? currentSurahArabic;
      for (var pageDoc in pagesSnapshot.docs) {
        final pageData = pageDoc.data();
        final pageNumber = pageData['pageNumber'] as int? ?? 0;
        final sections = pageData['sections'] != null
            ? List<Map<String, dynamic>>.from(pageData['sections'] as List)
            : [];

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

        if (currentSurahArabic != null &&
            surahMap.containsKey(currentSurahArabic)) {
          surahMap[currentSurahArabic]!['endPage'] = pageNumber;
        }

        if (!foundNewSurah && currentSurahArabic != null) {
          surahMap[currentSurahArabic]!['endPage'] = pageNumber;
        }
      }

      _surahs = surahMap.values.toList();
      _surahs.sort(
        (a, b) => (a['startPage'] as int).compareTo(b['startPage'] as int),
      );

      setState(() => _isLoadingSurahs = false);
    } catch (e) {
      print('Error fetching surahs for drawer: $e');
      setState(() => _isLoadingSurahs = false);
    }
  }

  void _addOrUpdateSurah(
    Map<int, Map<String, dynamic>> surahMap,
    String surahNameArabic,
    String surahNameEnglish,
    int pageNumber,
  ) {
    Map<String, dynamic>? existingSurah;
    for (var entry in surahMap.entries) {
      if (entry.value['arabic'] == surahNameArabic) {
        existingSurah = entry.value;
        break;
      }
    }

    if (existingSurah == null) {
      surahMap[surahMap.length + 1] = {
        'number': surahMap.length + 1,
        'arabic': surahNameArabic,
        'english': surahNameEnglish,
        'startPage': pageNumber,
        'endPage': pageNumber,
      };
    } else {
      if (pageNumber < (existingSurah['startPage'] as int? ?? 9999)) {
        existingSurah['startPage'] = pageNumber;
      }
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

    int currentSurahNumber = 1;
    String? currentSurahArabic =
        _surahs.isNotEmpty ? _surahs[0]['arabic'] : surahMap[1]?['arabic'];

    for (var pageDoc in pagesSnapshot.docs) {
      final pageData = pageDoc.data();
      final pageNumber = pageData['pageNumber'] as int? ?? 0;
      final sections = pageData['sections'] != null
          ? (pageData['sections'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
          : <Map<String, dynamic>>[];

      bool foundNewSurahOnPage = false;

      if (sections.isNotEmpty) {
        for (var section in sections) {
          if (section['type'] == 'newSurah') {
            final surahNameArabic = section['surahNameArabic'] as String?;
            if (surahNameArabic != null && surahNameArabic.isNotEmpty) {
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
        final isNewSurahOnPage = pageData['isNewSurahOnPage'] as bool? ?? false;
        if (isNewSurahOnPage) {
          final surahNameArabic = pageData['surahNameArabic'] as String?;
          if (surahNameArabic != null && surahNameArabic.isNotEmpty) {
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

      if (currentSurahNumber <= surahMap.length && currentSurahNumber >= 1) {
        surahMap[currentSurahNumber]!['endPage'] = pageNumber;
      }

      if (!foundNewSurahOnPage && currentSurahArabic != null) {
        for (var entry in surahMap.entries) {
          if (entry.value['arabic'] == currentSurahArabic) {
            entry.value['endPage'] = pageNumber;
            break;
          }
        }
      }
    }
  }

  void _goToPage(int pageNumber) {
    setState(() {
      _currentPage = pageNumber;
      _pageController.jumpToPage(pageNumber - 1);
    });
    Navigator.pop(_scaffoldKey.currentContext!);
  }

  void _goToSurah(Map<String, dynamic> surah) {
    final startPage = surah['startPage'] as int? ?? 1;
    _goToPage(startPage);
  }

  void _toggleFontAdjustPanel() {
    setState(() {
      _showFontAdjustPanel = !_showFontAdjustPanel;
    });
  }

  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 26.0;
      _showFontAdjustPanel = false;
    });
  }

  // ============================================================
  // 🔥 NEW: Show Tharjeem dialog when user taps an ayath marker
  // ============================================================
  void _showTharjeemDialog(
    BuildContext context,
    String ayathNumber,
    String meaning,
    Map<String, dynamic>? ayathMeanings,
  ) {
    final arabicNum = _normalToArabicNumber(ayathNumber);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: tharjeemColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: tharjeemColor.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        tharjeemColor,
                        primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Ayath badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.translate_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ayath $ayathNumber',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Arabic marker preview
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '﴿$arabicNum﴾',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Close button
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                ),

                // ── Meaning body ───────────────────────────
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // "Tharjeem / Meaning" label
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: tharjeemColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: tharjeemColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: tharjeemColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Tharjeem (Meaning)',
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Divider
                        Container(
                          height: 1,
                          color: dividerColor.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        // Meaning text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: tharjeemColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: tharjeemColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            meaning,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              height: 1.7,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: dividerColor.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Tap outside to close',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      // Optional: show if there are other tharjeems on the page
                      if (ayathMeanings != null && ayathMeanings.length > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: tharjeemColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${ayathMeanings.length} ayaths on page',
                            style: const TextStyle(
                              color: tharjeemColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔥 NEW: Empty tharjeem dialog when admin hasn't added meaning yet
  // ============================================================
  void _showEmptyTharjeemDialog(BuildContext context, String ayathNumber) {
    final arabicNum = _normalToArabicNumber(ayathNumber);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: dividerColor,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF888888), Color(0xFFAAAAAA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Ayath $ayathNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: textTertiary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '﴿$arabicNum﴾',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 24,
                              color: textTertiary,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Meaning Not Available',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'The tharjeem for this ayath hasn\'t been added yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 13,
                          height: 1.5,
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
      },
    );
  }

  // ============================================================
  // 🔥 NEW: Convert "1" → "١" (helper for display)
  // ============================================================
  String _normalToArabicNumber(String normal) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (final ch in normal.split('')) {
      final d = int.tryParse(ch);
      if (d != null) buffer.write(arabicDigits[d]);
    }
    return buffer.toString();
  }

  // ============================================================
  // 🔥 NEW: Convert "١٢٣" → "123"
  // ============================================================
  String _arabicToNormalNumber(String arabicNum) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = arabicNum;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabicDigits[i], '$i');
    }
    return result.trim();
  }

  // ============================================================
  // 🔥 NEW: Build RichText with tappable ayath markers
  // ============================================================
  Widget _buildInteractiveArabicText({
    required String text,
    required Map<String, dynamic>? ayathMeanings,
    required double fontSize,
  }) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    // If no ayath meanings exist for this page, just render plain text
    if (ayathMeanings == null || ayathMeanings.isEmpty) {
      return Text(
        text,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'lateef',
          fontSize: fontSize,
          height: 2.2,
          color: Colors.black87,
        ),
        textAlign: TextAlign.justify,
      );
    }

    // Regex to detect ﴿...﴾ markers
    final markerPattern = RegExp(r'﴿([\u0660-\u0669]+)﴾');

    final List<InlineSpan> spans = [];
    int lastIndex = 0;

    for (final match in markerPattern.allMatches(text)) {
      // Add text before the marker
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: text.substring(lastIndex, match.start),
            style: TextStyle(
              fontFamily: 'lateef',
              fontSize: fontSize,
              height: 2.2,
              color: Colors.black87,
            ),
          ),
        );
      }

      // Extract ayath number
      final arabicNum = match.group(1) ?? '';
      final normalNum = _arabicToNormalNumber(arabicNum);
      final markerText = match.group(0) ?? '';

      // Check if there's a meaning for this ayath
      final meaning = ayathMeanings[normalNum]?.toString() ?? '';
      final hasMeaning = meaning.trim().isNotEmpty;

      // Add the tappable marker
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: GestureDetector(
            onTap: () {
              if (hasMeaning) {
                _showTharjeemDialog(
                  context,
                  normalNum,
                  meaning,
                  ayathMeanings,
                );
              } else {
                _showEmptyTharjeemDialog(context, normalNum);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 2,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: hasMeaning
                    ? tharjeemColor.withValues(alpha: 0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: hasMeaning
                    ? Border.all(
                        color: tharjeemColor.withValues(alpha: 0.25),
                        width: 1,
                      )
                    : null,
              ),
              child: Text(
                markerText,
                style: TextStyle(
                  fontFamily: 'lateef',
                  fontSize: fontSize * 0.95,
                  height: 1.4,
                  color: hasMeaning ? tharjeemColor : Colors.black87,
                  fontWeight: hasMeaning ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    // Add remaining text after the last marker
    if (lastIndex < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastIndex),
          style: TextStyle(
            fontFamily: 'lateef',
            fontSize: fontSize,
            height: 2.2,
            color: Colors.black87,
          ),
        ),
      );
    }

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      text: TextSpan(children: spans),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: 300,
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () =>
                        Navigator.pop(_scaffoldKey.currentContext!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Surah Navigator',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Page: $_currentPage',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
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
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _currentPage > 1
                        ? () => _goToPage(_currentPage - 1)
                        : null,
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor.withValues(alpha: 0.1),
                      foregroundColor: accentColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: accentColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _currentPage < 604
                        ? () => _goToPage(_currentPage + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_bookmarks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bookmark_rounded,
                      color: accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bookmarks',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_bookmarks.length}',
                      style: const TextStyle(
                        color: textTertiary,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _removeAllBookmarks,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      tooltip: 'Remove all bookmarks',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final sortedKeys = _bookmarks.keys.toList()
                      ..sort((a, b) => b.compareTo(a));
                    final page = sortedKeys[index];
                    final bookmark = _bookmarks[page]!;
                    final surahArabic = bookmark['surahArabic'] ?? '';
                    final surahEnglish = bookmark['surahEnglish'] ?? '';
                    final date = bookmark['date'] ?? '';
                    final time = bookmark['time'] ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _goToPage(page),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$page',
                                        style: const TextStyle(
                                          color: accentColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                surahEnglish,
                                                style: const TextStyle(
                                                  color: textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Poppins',
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                surahArabic,
                                                style: const TextStyle(
                                                  fontFamily: 'lateef',
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textDirection:
                                                    TextDirection.rtl,
                                                textAlign: TextAlign.right,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time_rounded,
                                              size: 12,
                                              color: textTertiary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '$date at $time',
                                              style: const TextStyle(
                                                color: textTertiary,
                                                fontSize: 11,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.book_rounded,
                                              size: 12,
                                              color: textTertiary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Page $page • Juzh ${bookmark['juzh'] ?? 1}',
                                              style: const TextStyle(
                                                color: textTertiary,
                                                fontSize: 11,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => _removeBookmark(page),
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Colors.red.withValues(alpha: 0.7),
                                      size: 18,
                                    ),
                                    tooltip: 'Remove bookmark',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: dividerColor.withValues(alpha: 0.5), height: 1),
              const SizedBox(height: 12),
            ] else if (!_isLoadingBookmarks) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      color: textTertiary.withValues(alpha: 0.5),
                      size: 50,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No Bookmarks Yet',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the bookmark icon on any page\nto save it here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textTertiary,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    color: primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Jump to Surah',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_surahs.length}',
                    style: const TextStyle(
                      color: textTertiary,
                      fontSize: 13,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoadingSurahs
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _surahs.length,
                      itemBuilder: (context, index) {
                        final surah = _surahs[index];
                        final isCurrentSurah =
                            _currentPage >= (surah['startPage'] as int? ?? 0) &&
                                _currentPage <= (surah['endPage'] as int? ?? 0);
                        return Material(
                          color: isCurrentSurah
                              ? primaryColor.withValues(alpha: 0.1)
                              : cardColor,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => _goToSurah(surah),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentSurah
                                      ? primaryColor.withValues(alpha: 0.3)
                                      : dividerColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCurrentSurah
                                          ? primaryColor
                                          : accentColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${surah['number']}',
                                        style: TextStyle(
                                          color: isCurrentSurah
                                              ? Colors.white
                                              : accentColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                surah['english'] ?? 'Unknown',
                                                style: TextStyle(
                                                  color: isCurrentSurah
                                                      ? primaryColor
                                                      : textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  fontFamily: 'Poppins',
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                surah['arabic'] ?? '',
                                                style: TextStyle(
                                                  fontFamily: 'lateef',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: isCurrentSurah
                                                      ? primaryColor
                                                      : textPrimary,
                                                ),
                                                textDirection:
                                                    TextDirection.rtl,
                                                textAlign: TextAlign.right,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Pages ${surah['startPage']}-${surah['endPage']}',
                                          style: const TextStyle(
                                            color: textTertiary,
                                            fontSize: 11,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontAdjustmentPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_showFontAdjustPanel)
          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dividerColor.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Adjust Font Size',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_arabicFontSize.toInt()} px',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Slider(
                        value: _arabicFontSize,
                        min: _minFontSize,
                        max: _maxFontSize,
                        divisions: (_maxFontSize - _minFontSize).toInt(),
                        activeColor: primaryColor,
                        inactiveColor: dividerColor,
                        thumbColor: primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _arabicFontSize = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Small',
                            style: TextStyle(
                              color: textTertiary,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Large',
                            style: TextStyle(
                              color: textTertiary,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: _resetFontSize,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor.withValues(alpha: 0.1),
                        foregroundColor: accentColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text(
                        'Reset to Default',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          child: InkWell(
            onTap: _toggleFontAdjustPanel,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: dividerColor.withValues(alpha: 0.8),
                  width: 1,
                ),
              ),
              child: Icon(
                _showFontAdjustPanel
                    ? Icons.close_rounded
                    : Icons.format_size_rounded,
                color: _showFontAdjustPanel ? textTertiary : primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageContent(Map<String, dynamic> pageData) {
    final sections = pageData['sections'] != null
        ? (pageData['sections'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];
    final juzhNumber = pageData['juzhNumber'] ?? 1;
    // 🔥 NEW: Extract ayath meanings
    final ayathMeanings = pageData['ayathMeanings'] as Map<String, dynamic>?;

    if (sections.isEmpty) {
      return _buildLegacyPageContent(pageData);
    }

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: dividerColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        () => _scaffoldKey.currentState?.openDrawer(),
                        Icons.menu_rounded,
                        primaryColor,
                      ),
                      Column(
                        children: [
                          Text(
                            'Page $_currentPage',
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Juzh $juzhNumber',
                            style: const TextStyle(
                              color: textTertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      _buildIconButton(
                        _toggleBookmark,
                        _bookmarks.containsKey(_currentPage)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        _bookmarks.containsKey(_currentPage)
                            ? accentColor
                            : accentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // 🔥 UPDATED: pass ayathMeanings
                ..._buildSectionsWithHeaders(sections, ayathMeanings),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        Positioned(left: 20, bottom: 20, child: _buildFontAdjustmentPanel()),
      ],
    );
  }

  Widget _buildIconButton(VoidCallback onPressed, IconData icon, Color color) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dividerColor),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // 🔥 UPDATED: Accept ayathMeanings parameter
  List<Widget> _buildSectionsWithHeaders(
    List<Map<String, dynamic>> sections,
    Map<String, dynamic>? ayathMeanings,
  ) {
    List<Widget> widgets = [];

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];
      final type = section['type'];
      final arabicText = section['arabicText'] ?? '';
      final surahNameArabic = section['surahNameArabic'];
      final surahNameEnglish = section['surahNameEnglish'];
      final isBismillahRequired = section['isBismillahRequired'] ?? false;
      final startsMidPage = section['startsMidPage'] ?? false;

      if (type == 'newSurah' && startsMidPage && surahNameArabic != null) {
        widgets.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 17),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 42, 172, 131)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromARGB(255, 42, 172, 131)
                    .withValues(alpha: 0.4),
                width: 2,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  surahNameArabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'lateef',
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 46, 50, 49),
                  ),
                ),
                const SizedBox(height: 5),
                if (isBismillahRequired) ...[
                  const SizedBox(height: 9),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'lateef',
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 42, 172, 131),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      } else if (type == 'newSurah' && i == 0 && surahNameArabic != null) {
        widgets.add(
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 21),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  surahNameArabic,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'lateef',
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 5),
                if (isBismillahRequired) ...[
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'lateef',
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF2AAA83),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ],
            ),
          ),
        );
        widgets.add(const SizedBox(height: 17));
      }

      // 🔥 UPDATED: Use interactive RichText if ayathMeanings exists,
      //              otherwise use plain Text (unchanged behavior)
      final hasTharjeem = ayathMeanings != null && ayathMeanings.isNotEmpty;

      widgets.add(
        Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          elevation: 0.5,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: i < sections.length - 1 ? 32 : 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dividerColor),
            ),
            child: hasTharjeem
                ? _buildInteractiveArabicText(
                    text: arabicText,
                    ayathMeanings: ayathMeanings,
                    fontSize: _arabicFontSize,
                  )
                : Text(
                    arabicText,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'lateef',
                      fontSize: _arabicFontSize,
                      height: 2.2,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.justify,
                  ),
          ),
        ),
      );

      if (i < sections.length - 1 && sections.length > 1) {
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }

  Widget _buildLegacyPageContent(Map<String, dynamic> pageData) {
    final arabicText = pageData['arabicText'] ?? '';
    final isNewSurahOnPage = pageData['isNewSurahOnPage'] ?? false;
    final surahNameArabic = pageData['surahNameArabic'] ?? '';
    final surahNameEnglish = pageData['surahNameEnglish'] ?? '';
    final isBismillahRequired = pageData['isBismillahRequired'] ?? false;
    final juzhNumber = pageData['juzhNumber'] ?? 1;
    // 🔥 NEW: Extract ayath meanings
    final ayathMeanings = pageData['ayathMeanings'] as Map<String, dynamic>?;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: dividerColor)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIconButton(
                        () => _scaffoldKey.currentState?.openDrawer(),
                        Icons.menu_rounded,
                        primaryColor,
                      ),
                      Column(
                        children: [
                          Text(
                            'Page $_currentPage',
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Juzh $juzhNumber',
                            style: const TextStyle(
                              color: textTertiary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      _buildIconButton(
                        _toggleBookmark,
                        _bookmarks.containsKey(_currentPage)
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        _bookmarks.containsKey(_currentPage)
                            ? accentColor
                            : accentColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 17),
                if (isNewSurahOnPage) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          surahNameArabic,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'lateef',
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (isBismillahRequired) ...[
                          const SizedBox(height: 13),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: const Text(
                              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'lateef',
                                fontSize: 30,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF2AAA83),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 21),
                ],
                Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0.5,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor),
                    ),
                    // 🔥 UPDATED: Use interactive RichText if ayathMeanings exists
                    child: (ayathMeanings != null && ayathMeanings.isNotEmpty)
                        ? _buildInteractiveArabicText(
                            text: arabicText,
                            ayathMeanings: ayathMeanings,
                            fontSize: _arabicFontSize,
                          )
                        : Text(
                            arabicText,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'Lateef',
                              fontSize: _arabicFontSize,
                              height: 2.2,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.justify,
                          ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        Positioned(left: 20, bottom: 20, child: _buildFontAdjustmentPanel()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('swalathmajlis')
              .doc('iM6QRMlgUuWNbUdgQ0')
              .collection('quran_pages')
              .doc('page_$_currentPage')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.exists) {
              final pageData = snapshot.data!.data() as Map<String, dynamic>;
              final sections = pageData['sections'] != null
                  ? List<Map<String, dynamic>>.from(
                      pageData['sections'] as List,
                    )
                  : [];
              String? surahName = '';
              if (sections.isNotEmpty) {
                for (var section in sections) {
                  if (section['type'] == 'newSurah') {
                    surahName = section['surahNameEnglish'];
                    break;
                  }
                }
              } else {
                final isNewSurah = pageData['isNewSurahOnPage'] ?? false;
                surahName = isNewSurah ? pageData['surahNameEnglish'] : '';
              }
              return Text(
                surahName?.isNotEmpty == true
                    ? surahName!
                    : 'Page $_currentPage',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.5,
                  color: Colors.white,
                ),
              );
            }
            return Text(
              'Page $_currentPage',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            );
          },
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
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
      drawer: _buildDrawer(),
      body: Container(
        color: backgroundColor,
        child: PageView.builder(
          controller: _pageController,
          itemCount: 604,
          reverse: true,
          onPageChanged: (pageIndex) =>
              setState(() => _currentPage = pageIndex + 1),
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('swalathmajlis')
                  .doc('iM6QRMlgUuWNbUdgQ0')
                  .collection('quran_pages')
                  .doc('page_$pageNumber')
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 3,
                    ),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
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
                          child: const Icon(
                            Icons.error_outline_rounded,
                            color: primaryColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Page $pageNumber not found',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This page may not be uploaded yet',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final pageData = snapshot.data!.data() as Map<String, dynamic>;
                return _buildPageContent(pageData);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
