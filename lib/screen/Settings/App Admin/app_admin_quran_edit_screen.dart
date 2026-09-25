// lib/screen/App Admin/app_admin_quran_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppAdminQuranEditScreen extends StatefulWidget {
  const AppAdminQuranEditScreen({super.key});

  @override
  State<AppAdminQuranEditScreen> createState() =>
      _AppAdminQuranEditScreenState();
}

class _AppAdminQuranEditScreenState extends State<AppAdminQuranEditScreen> {
  // 🎨 Your app theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);
  static const Color tharjeemColor =
      Color(0xFF1A472A); // deep green for tharjeem

  // State
  bool _isLoading = false;
  bool _editMode = false;
  String _searchQuery = '';
  String? _selectedPageId;

  // Simple editing - ONLY Arabic text
  final TextEditingController _arabicTextController = TextEditingController();
  int _currentPageNumber = 0;
  int _currentJuzhNumber = 0;

  // All pages data
  List<Map<String, dynamic>> _allPages = [];
  List<Map<String, dynamic>> _filteredPages = [];

  // 🔥 NEW: Tharjeem (meaning) state
  // Structure: { ayathNumber: "meaning text" }
  Map<String, String> _ayathMeanings = {};
  // Store the original sections to preserve on save
  List<Map<String, dynamic>> _originalSections = [];
  // Toggle to show/hide tharjeem panel
  bool _showTharjeemPanel = false;

  @override
  void initState() {
    super.initState();
    _loadAllPages();
  }

  @override
  void dispose() {
    _arabicTextController.dispose();
    super.dispose();
  }

  // Load all pages from Firestore
  Future<void> _loadAllPages() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('quran_pages')
          .orderBy('pageNumber')
          .get();

      setState(() {
        _allPages = snapshot.docs.map((doc) {
          final data = doc.data();
          return {...data, 'documentId': doc.id};
        }).toList();
        _filteredPages = List.from(_allPages);
        _isLoading = false;
      });
    } catch (e) {
      _showMessage('Error loading pages: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  // Filter pages by search query
  void _filterPages() {
    setState(() {
      _filteredPages = _allPages.where((page) {
        final pageNum = page['pageNumber'].toString();
        return _searchQuery.isEmpty || pageNum.contains(_searchQuery);
      }).toList();
    });
  }

  // ============================================================
  // 🔥 NEW: Extract ayath markers from Arabic text
  // ============================================================
  // Detects patterns like ﴿١﴾ ﴿٢﴾ ... ﴿١٢٣﴾
  // Also supports (1) [1] {1} ١ ٢ ٣ formats as fallback
  List<String> _extractAyathNumbers(String arabicText) {
    final Set<String> foundNumbers = {};

    // ✅ Primary pattern: Arabic ornate brackets ﴿...﴾
    // Matches ﴿١﴾ ﴿٢﴾ ﴿١٢٣﴾ etc.
    final ornatePattern = RegExp(r'﴿([\u0660-\u0669]+)﴾');
    for (final m in ornatePattern.allMatches(arabicText)) {
      final arabicNum = m.group(1)!;
      final normal = _arabicToNormalNumber(arabicNum);
      if (normal.isNotEmpty) foundNumbers.add(normal);
    }

    // ✅ Fallback patterns if ornate not found
    if (foundNumbers.isEmpty) {
      // (1) [1] {1}
      final bracketPattern = RegExp(r'[\(\[\{]([0-9\u0660-\u0669]+)[\)\]\}]');
      for (final m in bracketPattern.allMatches(arabicText)) {
        final numStr = m.group(1)!;
        final normal = _normalizeDigits(numStr);
        if (normal.isNotEmpty) foundNumbers.add(normal);
      }
    }

    // Sort numerically
    final sorted = foundNumbers.toList()
      ..sort((a, b) => int.tryParse(a)!.compareTo(int.tryParse(b)!));
    return sorted;
  }

  // Convert Arabic-Indic digits to normal digits
  String _arabicToNormalNumber(String arabicNum) {
    return _normalizeDigits(arabicNum);
  }

  String _normalizeDigits(String input) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    String result = input;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(arabicDigits[i], '$i');
    }
    return result.trim();
  }

  // ============================================================
  // 🔥 NEW: Load ayath meanings when starting to edit
  // ============================================================
  void _loadAyathMeanings(Map<String, dynamic> pageData) {
    _ayathMeanings = {};

    // Load existing meanings from Firestore document
    if (pageData['ayathMeanings'] != null) {
      try {
        final raw = pageData['ayathMeanings'];
        if (raw is Map) {
          raw.forEach((key, value) {
            _ayathMeanings[key.toString()] = value.toString();
          });
        } else if (raw is List) {
          for (final item in raw) {
            if (item is Map && item['number'] != null) {
              _ayathMeanings[item['number'].toString()] =
                  (item['meaning'] ?? '').toString();
            }
          }
        }
      } catch (e) {
        debugPrint('Error loading ayath meanings: $e');
      }
    }
  }

  // Start editing a page - ONLY load Arabic text
  void _startEditing(Map<String, dynamic> pageData) {
    // Extract Arabic text from the page
    String arabicText = '';

    // Preserve original sections for saving later
    _originalSections = [];
    if (pageData['sections'] != null && pageData['sections'].isNotEmpty) {
      final sections = pageData['sections'] as List;
      _originalSections = sections
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      // Combine all sections' Arabic text
      arabicText = sections.map((s) => s['arabicText'] ?? '').join('\n\n');
    } else {
      // Legacy format
      arabicText = pageData['arabicText'] ?? '';
    }

    // 🔥 Load existing ayath meanings
    _loadAyathMeanings(pageData);

    // 🔥 Auto-detect ayath numbers from the text
    final detected = _extractAyathNumbers(arabicText);
    // Ensure every detected ayath has an entry (even if empty)
    for (final num in detected) {
      _ayathMeanings.putIfAbsent(num, () => '');
    }

    setState(() {
      _editMode = true;
      _selectedPageId = pageData['documentId'];
      _currentPageNumber = pageData['pageNumber'] ?? 0;
      _currentJuzhNumber = pageData['juzhNumber'] ?? 1;
      _arabicTextController.text = arabicText;
      _showTharjeemPanel = false;
    });
  }

  // Cancel editing
  void _cancelEditing() {
    setState(() {
      _editMode = false;
      _selectedPageId = null;
      _arabicTextController.clear();
      _currentPageNumber = 0;
      _currentJuzhNumber = 0;
      // 🔥 Reset tharjeem state
      _ayathMeanings = {};
      _originalSections = [];
      _showTharjeemPanel = false;
    });
  }

  // ============================================================
  // 🔥 NEW: Extract ayath numbers from the CURRENT text field
  // ============================================================
  List<String> _getCurrentDetectedAyaths() {
    final text = _arabicTextController.text;
    return _extractAyathNumbers(text);
  }

  // ============================================================
  // 🔥 NEW: Get the Arabic ayath text for a given number
  // ============================================================
  String _getAyathArabicText(String ayathNumber) {
    final text = _arabicTextController.text;
    if (text.isEmpty) return '';

    // Find the marker ﴿N﴾ where N is the arabic number
    final arabicNum = _normalToArabicNumber(ayathNumber);
    final marker = '﴿$arabicNum﴾';

    final idx = text.indexOf(marker);
    if (idx == -1) return '';

    // Find the previous marker to know where this ayath starts
    final beforeText = text.substring(0, idx);
    final prevMatch =
        RegExp(r'﴿[\u0660-\u0669]+﴾').allMatches(beforeText).toList();
    final startIdx = prevMatch.isEmpty ? 0 : prevMatch.last.end;

    // This ayath's text: from startIdx to idx + marker length
    final ayathText = text.substring(startIdx, idx).trim();
    return ayathText;
  }

  // Convert "1" → "١"
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
  // 🔥 NEW: Save ayath meaning (called from the tharjeem editor)
  // ============================================================
  Future<void> _saveAyathMeaning(String ayathNumber, String meaning) async {
    setState(() {
      _ayathMeanings[ayathNumber] = meaning;
    });
  }

  // ============================================================
  // 🔥 UPDATED: Now also saves ayath meanings to Firestore
  // ============================================================
  Future<void> _updateArabicText() async {
    if (_arabicTextController.text.isEmpty) {
      _showMessage('Arabic text cannot be empty', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the original document
      final doc = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('quran_pages')
          .doc(_selectedPageId)
          .get();

      if (!doc.exists) {
        throw Exception('Document not found');
      }

      final data = doc.data() as Map<String, dynamic>;

      // Update ONLY the Arabic text while preserving everything else
      if (data.containsKey('sections') && data['sections'] != null) {
        // Multi-section format - update each section's Arabic text
        final sections = List<Map<String, dynamic>>.from(data['sections']);
        final newText = _arabicTextController.text;

        // Simple split by double newlines (adjust as needed)
        final textParts = newText.split('\n\n');

        for (int i = 0; i < sections.length; i++) {
          if (i < textParts.length) {
            sections[i]['arabicText'] = textParts[i].trim();
          }
        }

        // 🔥 NEW: Save ayath meanings too
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('quran_pages')
            .doc(_selectedPageId)
            .update({
          'sections': sections,
          'ayathMeanings': _ayathMeanings, // ← NEW
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Legacy single-section format
        await FirebaseFirestore.instance
            .collection('swalathmajlis')
            .doc('iM6QRMlgUuWNbUdgQ0')
            .collection('quran_pages')
            .doc(_selectedPageId)
            .update({
          'arabicText': _arabicTextController.text,
          'ayathMeanings': _ayathMeanings, // ← NEW
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      _showMessage('Arabic text & Tharjeem updated successfully');
      _loadAllPages();
      _cancelEditing();
    } catch (e) {
      _showMessage('Error updating: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Show message
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? errorColor : successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _editMode ? 'Edit Quran Page' : 'Quran Pages',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_editMode) {
              _cancelEditing();
            } else {
              Navigator.pop(context);
            }
          },
          tooltip: 'Back',
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: _isLoading
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
                    'Loading...',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            )
          : _editMode
              ? _buildEditForm()
              : _buildPagesList(),
    );
  }

  // ========== PAGES LIST VIEW ==========
  Widget _buildPagesList() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by page number...',
                hintStyle: const TextStyle(color: textTertiary),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: primaryColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _filterPages();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterPages();
              },
            ),
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.menu_book_rounded,
                  size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                '${_filteredPages.length} pages found',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Pages list
        Expanded(
          child: _filteredPages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        size: 60,
                        color: textTertiary.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No pages found'
                            : 'No pages matching "$_searchQuery"',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredPages.length,
                  itemBuilder: (context, index) {
                    final page = _filteredPages[index];
                    final pageNumber = page['pageNumber'] ?? 0;
                    final juzhNumber = page['juzhNumber'] ?? 1;
                    final sections = page['sections'] as List? ?? [];
                    final hasMultiple = sections.length > 1;
                    // 🔥 NEW: Show tharjeem count badge
                    final ayathMeanings = page['ayathMeanings'];
                    int tharjeemCount = 0;
                    if (ayathMeanings is Map) {
                      tharjeemCount = ayathMeanings.entries
                          .where((e) => e.value.toString().trim().isNotEmpty)
                          .length;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dividerColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => _startEditing(page),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Page number badge
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [primaryColor, accentColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      pageNumber.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Page details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Page $pageNumber',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: textPrimary,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: accentColor.withValues(
                                                alpha: 0.1,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Juzh $juzhNumber',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: accentColor,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.menu_book_rounded,
                                            size: 12,
                                            color: textTertiary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${sections.length} section${sections.length != 1 ? 's' : ''}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: textTertiary,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          if (hasMultiple) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'Multiple',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                          // 🔥 NEW: Tharjeem badge
                                          if (tharjeemCount > 0) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: tharjeemColor.withValues(
                                                    alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: tharjeemColor
                                                      .withValues(alpha: 0.3),
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.translate_rounded,
                                                    size: 9,
                                                    color: tharjeemColor,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '$tharjeemCount',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      color: tharjeemColor,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Edit icon only
                                Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    onPressed: () => _startEditing(page),
                                    tooltip: 'Edit Arabic Text & Tharjeem',
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ========== SIMPLE EDIT FORM - ONLY ARABIC TEXT ==========
  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryColor, accentColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _currentPageNumber.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
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
                        'Page $_currentPageNumber',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Juzh $_currentJuzhNumber',
                        style: const TextStyle(
                          fontSize: 14,
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Arabic text card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.text_fields_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Arabic Text',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Large Arabic text area
                Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: dividerColor),
                  ),
                  child: TextFormField(
                    controller: _arabicTextController,
                    maxLines: 15,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 20,
                      fontFamily: 'Amiri',
                      height: 1.8,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Enter Arabic text...',
                      hintStyle: TextStyle(color: textTertiary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(20),
                    ),
                    // 🔥 Auto-refresh the detected ayaths while typing
                    onChanged: (_) => setState(() {}),
                  ),
                ),

                // Character count
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(
                        Icons.text_fields_rounded,
                        size: 14,
                        color: textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_arabicTextController.text.length} characters',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textTertiary,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ============================================================
          // 🔥 NEW: THARJEEM (MEANING) SECTION
          // ============================================================
          _buildTharjeemSection(),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateArabicText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Update Arabic Text',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textTertiary,
                    side: const BorderSide(color: dividerColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ============================================================
  // 🔥 NEW: THARJEEM SECTION WIDGET
  // ============================================================
  Widget _buildTharjeemSection() {
    final detectedAyaths = _getCurrentDetectedAyaths();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - tappable to expand/collapse
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _showTharjeemPanel = !_showTharjeemPanel;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tharjeemColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: tharjeemColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: tharjeemColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tharjeem (Ayath Meanings)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detectedAyaths.isEmpty
                                ? 'No ayath markers found in text'
                                : '${detectedAyaths.length} ayath${detectedAyaths.length != 1 ? 's' : ''} detected',
                            style: const TextStyle(
                              fontSize: 12,
                              color: textTertiary,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Badge showing how many have meanings
                    if (detectedAyaths.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: tharjeemColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_ayathMeanings.values.where((v) => v.trim().isNotEmpty).length}/${detectedAyaths.length}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: tharjeemColor,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      _showTharjeemPanel
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: textTertiary,
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded panel with ayath list
          if (_showTharjeemPanel) ...[
            Divider(
              height: 1,
              color: dividerColor.withValues(alpha: 0.6),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: detectedAyaths.isEmpty
                  ? _buildEmptyTharjeemState()
                  : Column(
                      children: detectedAyaths
                          .map((n) => _buildAyathMeaningEditor(n))
                          .toList(),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  // Empty state when no ayaths detected
  Widget _buildEmptyTharjeemState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.translate_rounded,
            size: 40,
            color: textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Ayath Markers Detected',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Make sure your Arabic text contains\nayath markers like ﴿١﴾ ﴿٢﴾ ﴿٣﴾',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textTertiary,
              fontSize: 12,
              height: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  // Single ayath meaning editor card
  Widget _buildAyathMeaningEditor(String ayathNumber) {
    final arabicNum = _normalToArabicNumber(ayathNumber);
    final ayathText = _getAyathArabicText(ayathNumber);
    final meaning = _ayathMeanings[ayathNumber] ?? '';
    final hasMeaning = meaning.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              hasMeaning ? tharjeemColor.withValues(alpha: 0.4) : dividerColor,
          width: hasMeaning ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayath number badge + Arabic preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tharjeemColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
              border: Border(
                bottom: BorderSide(
                  color: tharjeemColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Ayath number badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: tharjeemColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bookmark_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ayath $ayathNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Arabic marker preview
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '﴿$arabicNum﴾',
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Amiri',
                      color: tharjeemColor,
                    ),
                  ),
                ),
                const Spacer(),
                // Status
                if (hasMeaning)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: successColor,
                    size: 18,
                  )
                else
                  Icon(
                    Icons.circle_outlined,
                    color: textTertiary.withValues(alpha: 0.5),
                    size: 18,
                  ),
              ],
            ),
          ),

          // Arabic text preview (read-only)
          if (ayathText.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.text_fields_rounded,
                        size: 12,
                        color: textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Arabic Text',
                        style: TextStyle(
                          fontSize: 10,
                          color: textTertiary,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: dividerColor.withValues(alpha: 0.7),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ayathText,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Amiri',
                        height: 1.6,
                        color: textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Meaning input field
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 12,
                      color: tharjeemColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tharjeem (Meaning)',
                      style: TextStyle(
                        fontSize: 10,
                        color: tharjeemColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasMeaning
                          ? tharjeemColor.withValues(alpha: 0.5)
                          : dividerColor,
                      width: hasMeaning ? 1.5 : 1,
                    ),
                  ),
                  child: TextFormField(
                    initialValue: meaning,
                    maxLines: 4,
                    minLines: 2,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      fontFamily: 'Poppins',
                      color: textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText:
                          'Enter the meaning of this ayath in English/Malayalam...',
                      hintStyle: TextStyle(
                        color: textTertiary,
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    onChanged: (value) {
                      _saveAyathMeaning(ayathNumber, value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
