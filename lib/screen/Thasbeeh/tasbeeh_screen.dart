// lib/screen/tasbeeh_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'tasbeeh_history_screen.dart';
import 'tasbeeh_dua_section_screen.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  static const String boxName = 'tasbeeh_history';

  int _count = 0;
  Box? _box;

  /// ✅ Selected Dua (runtime only)
  Map<String, dynamic>? selectedDua;

  /// ✅ Custom text for user to paste/type
  String _customText = '';
  final TextEditingController _customTextController = TextEditingController();
  bool _useCustomText = false;

  /// ✅ Collapsible state
  bool _isCustomTextExpanded = false;

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

  @override
  void initState() {
    super.initState();
    _initHive();
    _customTextController.addListener(() {
      setState(() {
        _customText = _customTextController.text;
        _useCustomText = _customText.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(boxName)) {
      _box = await Hive.openBox(boxName);
    } else {
      _box = Hive.box(boxName);
    }
    setState(() {});
  }

  void _increment() {
    setState(() => _count++);
  }

  void _reset() {
    setState(() {
      _count = 0;
      // Don't reset the custom text or selected dua
    });
  }

  void _clearCustomText() {
    _customTextController.clear();
    setState(() {
      _customText = '';
      _useCustomText = false;
    });
  }

  void _toggleCustomText() {
    setState(() {
      _isCustomTextExpanded = !_isCustomTextExpanded;
    });
  }

  // Helper method to detect Arabic/RTL text
  bool _isArabicText(String text) {
    if (text.isEmpty) return false;
    // Check for Arabic Unicode range
    return text.contains(
      RegExp(
        r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
      ),
    );
  }

  Future<void> _saveTasbeeh() async {
    if (_count == 0) return;

    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Save Tasbeeh'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter Tasbeeh Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              // Determine what to save as the "dua" content
              String? duaContent;
              String? duaArabic;

              if (_useCustomText) {
                duaContent = 'Custom Text';
                duaArabic = _customText;
              } else if (selectedDua != null) {
                duaContent = selectedDua!['heading'];
                duaArabic = selectedDua!['arabic'];
              }

              await _box!.add({
                'name': name,
                'count': _count,
                'dua': duaContent,
                'duaArabic': duaArabic,
                'isCustomText': _useCustomText,
                'time': DateTime.now().toIso8601String(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tasbeeh saved'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openHistory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TasbeehHistoryScreen()),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _count = result['count'] ?? 0;

        // Check if it was custom text
        if (result['isCustomText'] == true) {
          _useCustomText = true;
          _customTextController.text = result['duaArabic'] ?? '';
          selectedDua = null;
          _isCustomTextExpanded = true; // Auto-expand when loading custom text
        } else if (result['duaName'] != null) {
          selectedDua = {
            'heading': result['duaName'],
            'arabic': result['duaArabic'] ?? '',
          };
          _clearCustomText();
          _isCustomTextExpanded = false; // Auto-collapse when loading dua
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Continuing from ${result['count']} counts'),
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_box == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tasbeeh Counter',
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
        actionsIconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _openHistory),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            /// 🟢 DUA SELECTION BOX
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TasbeehDuaSectionScreen(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    selectedDua = result;
                    _useCustomText = false;
                    _clearCustomText();
                    _isCustomTextExpanded = false;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _useCustomText
                        ? textTertiary.withValues(alpha: 0.3)
                        : primaryColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: selectedDua == null || _useCustomText
                    ? Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _useCustomText
                                  ? textTertiary.withValues(alpha: 0.1)
                                  : accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _useCustomText
                                    ? textTertiary.withValues(alpha: 0.3)
                                    : accentColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              _useCustomText
                                  ? Icons.edit_note_rounded
                                  : Icons.menu_book_rounded,
                              color: _useCustomText
                                  ? textTertiary
                                  : accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _useCustomText
                                  ? "Using custom text"
                                  : "Select a Dua to read while counting",
                              style: TextStyle(
                                color: _useCustomText
                                    ? textSecondary
                                    : textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          if (!_useCustomText)
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: textTertiary,
                              size: 16,
                            ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: primaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_circle_rounded,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedDua!['heading'],
                                  style: const TextStyle(
                                    color: textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: dividerColor.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              selectedDua!['arabic'],
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 20,
                                height: 1.8,
                                fontFamily: 'Amiri',
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            /// 📝 CUSTOM TEXT BOX - COLLAPSIBLE
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _useCustomText && _isCustomTextExpanded
                      ? accentColor.withValues(alpha: 0.5)
                      : dividerColor.withValues(alpha: 0.8),
                  width: _useCustomText && _isCustomTextExpanded ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🎯 HEADER - Always visible (toggle button)
                  InkWell(
                    onTap: _toggleCustomText,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: _isCustomTextExpanded
                            ? Border(
                                bottom: BorderSide(
                                  color: dividerColor.withValues(alpha: 0.5),
                                ),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          /// Icon with status indicator
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _useCustomText
                                  ? accentColor.withValues(alpha: 0.1)
                                  : textTertiary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _useCustomText
                                    ? accentColor.withValues(alpha: 0.3)
                                    : dividerColor.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.paste_rounded,
                              size: 18,
                              color: _useCustomText
                                  ? accentColor
                                  : textTertiary,
                            ),
                          ),
                          const SizedBox(width: 12),

                          /// Title and status
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Custom Text',
                                  style: TextStyle(
                                    color: _useCustomText
                                        ? accentColor
                                        : textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                if (!_isCustomTextExpanded &&
                                    _customText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      _customText.length > 30
                                          ? '${_customText.substring(0, 30)}...'
                                          : _customText,
                                      style: TextStyle(
                                        color: textTertiary,
                                        fontSize: 12,
                                        fontFamily: _isArabicText(_customText)
                                            ? 'Amiri'
                                            : 'Poppins',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          /// Active badge (when using custom text)
                          if (_useCustomText)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 12,
                                    color: accentColor,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          /// Expand/Collapse icon
                          Icon(
                            _isCustomTextExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: _useCustomText ? accentColor : textTertiary,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// 📄 EXPANDABLE CONTENT
                  if (_isCustomTextExpanded) ...[
                    /// Text Field
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _customTextController,
                        maxLines: 5,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Paste or type yourtext here...',
                          hintStyle: TextStyle(
                            color: textTertiary.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: accentColor,
                              width: 1.5,
                            ),
                          ),
                          filled: true,
                          fillColor: backgroundColor,
                          contentPadding: const EdgeInsets.all(16),
                          suffixIcon: _customTextController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    size: 20,
                                  ),
                                  onPressed: _clearCustomText,
                                  color: textTertiary,
                                )
                              : null,
                        ),
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 15,
                          height: 1.5,
                          fontFamily: _isArabicText(_customText)
                              ? 'Amiri'
                              : 'Poppins',
                        ),
                      ),
                    ),

                    /// Footer with actions and character count
                    if (_customText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_customText.length} characters',
                              style: const TextStyle(
                                color: textTertiary,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            Row(
                              children: [
                                if (selectedDua != null && _useCustomText)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _useCustomText = false;
                                        _clearCustomText();
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Switch to Dua',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: textTertiary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _clearCustomText,
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Clear',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red[400],
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    /// Empty state hint
                    if (_customText.isEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Text(
                          'Enter text above to use custom content',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// 🔢 COUNTER DISPLAY
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                _count.toString(),
                style: const TextStyle(
                  fontSize: 48,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 👆 INCREMENT BUTTON
            GestureDetector(
              onTap: _increment,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.touch_app_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 🔘 ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset'),
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red[300]!, width: 1),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                  onPressed: _saveTasbeeh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// ℹ️ Status indicator
            if (_useCustomText || selectedDua != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _useCustomText
                      ? accentColor.withValues(alpha: 0.08)
                      : primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _useCustomText
                          ? Icons.edit_note_rounded
                          : Icons.menu_book_rounded,
                      size: 14,
                      color: _useCustomText ? accentColor : primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _useCustomText
                          ? 'Reading custom text'
                          : 'Reading: ${selectedDua!['heading']}',
                      style: TextStyle(
                        color: _useCustomText ? accentColor : primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
