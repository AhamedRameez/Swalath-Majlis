// lib/screen/user/adkar_detail_screen.dart
import 'package:flutter/material.dart';

class AdkarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> adkarData;
  final String docId;

  const AdkarDetailScreen({
    super.key,
    required this.adkarData,
    required this.docId,
  });

  @override
  State<AdkarDetailScreen> createState() => _AdkarDetailScreenState();
}

class _AdkarDetailScreenState extends State<AdkarDetailScreen> {
  double _arabicFontSize = 18.0;
  double _duaFontSize = 18.0;
  final double _minFontSize = 16.0;
  final double _maxFontSize = 32.0;
  bool _showFontPanel = false;

  // Counter variables
  int _counter = 0;
  bool _showCounter = false;

  // Draggable counter position
  Offset _counterPosition = const Offset(0, 0);
  bool _isDragging = false;
  bool _isPositionInitialized = false;

  void _incrementCounter() => setState(() => _counter++);
  void _resetCounter() => setState(() => _counter = 0);

  void _toggleCounter() {
    setState(() {
      _showCounter = !_showCounter;
      if (_showCounter && !_isPositionInitialized) {
        // Set position to center of screen when first shown
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            setState(() {
              _counterPosition = Offset(
                (screenWidth - 200) / 2, // Center horizontally
                screenHeight / 2 - 50, // Center vertically
              );
              _isPositionInitialized = true;
            });
          }
        });
      }
    });
  }

  // Theme colors
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    final adminFontSize =
        (widget.adkarData['defaultFontSize'] as num?)?.toDouble() ?? 22.0;
    _arabicFontSize = adminFontSize;
    _duaFontSize = adminFontSize;
  }

  String _getString(String key) {
    return widget.adkarData[key]?.toString() ?? '';
  }

  List<String> _splitIntoVerses(String text) {
    List<String> lines = text.split('\n');
    if (lines.length <= 1) {
      lines = text.split(RegExp(r'[.،؛]'));
    }
    return lines.where((line) => line.trim().isNotEmpty).toList();
  }

  void _increaseFontSize() {
    setState(() {
      if (_arabicFontSize < _maxFontSize) {
        _arabicFontSize = (_arabicFontSize + 1).clamp(
          _minFontSize,
          _maxFontSize,
        );
        _duaFontSize = _arabicFontSize;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if (_arabicFontSize > _minFontSize) {
        _arabicFontSize = (_arabicFontSize - 1).clamp(
          _minFontSize,
          _maxFontSize,
        );
        _duaFontSize = _arabicFontSize;
      }
    });
  }

  void _resetFontSize() {
    final defaultSize =
        (widget.adkarData['defaultFontSize'] as num?)?.toDouble() ?? 22.0;
    setState(() {
      _arabicFontSize = defaultSize;
      _duaFontSize = defaultSize;
      _showFontPanel = false;
    });
  }

  void _toggleFontPanel() {
    setState(() {
      _showFontPanel = !_showFontPanel;
    });
  }

  // Draggable White Transparent Counter Widget
  Widget _buildDraggableCounterWidget({required bool isDragging}) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: isDragging
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: isDragging
                  ? primaryColor.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: isDragging ? 15 : 8,
              offset: Offset(0, isDragging ? 5 : 2),
              spreadRadius: isDragging ? 2 : 0,
            ),
          ],
          border: Border.all(
            color: isDragging
                ? primaryColor.withValues(alpha: 0.8)
                : primaryColor.withValues(alpha: 0.4),
            width: isDragging ? 2 : 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // RETRY/REFRESH button
              GestureDetector(
                onTap: _resetCounter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Counter number
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    shadows: [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Plus button
              GestureDetector(
                onTap: _incrementCounter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: primaryColor,
                    size: 22,
                    weight: 800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Font Adjustment Panel
  Widget _buildFontAdjustmentPanel() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Adjust Font Size',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_arabicFontSize.toInt()}px',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleFontPanel,
                    child: const Icon(Icons.close, size: 16, color: textTertiary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Slider
          Row(
            children: [
              const Icon(Icons.text_decrease, size: 16, color: textTertiary),
              Expanded(
                child: Slider(
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
                      _duaFontSize = value;
                    });
                  },
                ),
              ),
              const Icon(Icons.text_increase, size: 16, color: textTertiary),
            ],
          ),
          // Reset button
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: TextButton.icon(
              onPressed: _resetFontSize,
              style: TextButton.styleFrom(
                backgroundColor: accentColor.withValues(alpha: 0.08),
                foregroundColor: accentColor,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.restart_alt_rounded, size: 14),
              label: const Text(
                'Reset to Default',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _getString('title');
    final description = _getString('description');
    final style = _getString('style');
    final arabic = _getString('arabic');
    final malayalam = _getString('malayalam');
    final dua = _getString('dua');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Font adjustment button on top-right corner
          IconButton(
            icon: Icon(
              Icons.format_size_rounded,
              color: _showFontPanel ? accentColor : Colors.white,
              size: 22,
            ),
            onPressed: _toggleFontPanel,
            tooltip: 'Adjust Font Size',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Show content based on style
                  if (style == 'alternating') ...[
                    _buildAlternatingStyle(arabic, malayalam),
                  ] else if (style == 'paragraph') ...[
                    _buildParagraphStyle(arabic, malayalam),
                  ] else if (style == 'verse') ...[
                    _buildVerseContent(),
                  ] else ...[
                    _buildNormalContent(), // Fallback
                  ],

                  if (dua.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor.withValues(alpha: 0.05),
                            accentColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.favorite_rounded,
                                color: accentColor,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Dua',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            dua,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _duaFontSize,
                              height: 1.8,
                              fontFamily: 'Amiri',
                              color: textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  Center(
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          width: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withValues(alpha: 0.6),
                                accentColor.withValues(alpha: 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'اللهم تقبل منا',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Amiri',
                            color: textTertiary,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Font adjustment panel - Positioned in main body
          if (_showFontPanel)
            Positioned(
              top: kToolbarHeight + 5,
              right: 16,
              child: Material(
                elevation: 10,
                borderRadius: BorderRadius.circular(12),
                child: _buildFontAdjustmentPanel(),
              ),
            ),

          // Draggable Counter - Movable anywhere on screen
          if (_showCounter && _isPositionInitialized)
            Positioned(
              left: _counterPosition.dx,
              top: _counterPosition.dy,
              child: Draggable(
                feedback: _buildDraggableCounterWidget(isDragging: true),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                onDraggableCanceled: (velocity, offset) {
                  setState(() {
                    _isDragging = false;
                    _counterPosition = offset;
                  });
                },
                child: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _isDragging = true;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _counterPosition += details.delta;
                      _counterPosition = Offset(
                        _counterPosition.dx.clamp(
                          0,
                          MediaQuery.of(context).size.width - 200,
                        ),
                        _counterPosition.dy.clamp(
                          0,
                          MediaQuery.of(context).size.height - 100,
                        ),
                      );
                    });
                  },
                  child: _buildDraggableCounterWidget(isDragging: false),
                ),
              ),
            ),

          // Counter toggle button at bottom-left
          Positioned(
            left: 20,
            bottom: 20,
            child: Material(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.1),
              child: InkWell(
                onTap: _toggleCounter,
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
                    _showCounter
                        ? Icons.close_rounded
                        : Icons.calculate_rounded,
                    color: _showCounter ? textTertiary : primaryColor,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Alternating Style (Poetry - lines alternate right-left)
  Widget _buildAlternatingStyle(String arabic, String malayalam) {
    final verses = _splitIntoVerses(arabic);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: textPrimary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textPrimary.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Alternating lines
              ...List.generate(verses.length, (index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  alignment: index % 2 == 0
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Text(
                    verses[index].trim(),
                    textDirection: TextDirection.rtl,
                    textAlign: index % 2 == 0
                        ? TextAlign.right
                        : TextAlign.left,
                    style: TextStyle(
                      fontSize: _arabicFontSize,
                      height: 1.9,
                      fontFamily: 'Amiri',
                      color: textPrimary,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        if (malayalam.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Malayalam Translation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  malayalam,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    fontFamily: 'Noto Sans Malayalam',
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Paragraph Style (Continuous text - NO line splitting)
  Widget _buildParagraphStyle(String arabic, String malayalam) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: textPrimary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: textPrimary.withValues(alpha: 0.1), width: 1),
          ),
          child: Column(
            children: [
              const Center(
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Display as continuous paragraph (NO line splitting)
              Text(
                arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: _arabicFontSize,
                  height: 1.9,
                  fontFamily: 'Amiri',
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),

        if (malayalam.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.translate_rounded,
                      size: 16,
                      color: primaryColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Malayalam Translation',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  malayalam,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.7,
                    fontFamily: 'Noto Sans Malayalam',
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNormalContent() {
    final arabic = _getString('arabic');
    final malayalam = _getString('malayalam');

    // Default to paragraph style for normal content
    return _buildParagraphStyle(arabic, malayalam);
  }

  Widget _buildVerseContent() {
    final verses = widget.adkarData['verses'] as List<dynamic>? ?? [];

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Amiri',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        ...List.generate(verses.length, (index) {
          final verse = verses[index] as Map<String, dynamic>;
          final arabic = verse['arabic'] ?? '';
          final malayalam = verse['malayalam'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? accentColor.withValues(alpha: 0.02)
                  : primaryColor.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: index % 2 == 0
                    ? accentColor.withValues(alpha: 0.1)
                    : primaryColor.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentColor, primaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Verse ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                ..._splitIntoVerses(arabic).map((line) {
                  final lineIndex = _splitIntoVerses(arabic).indexOf(line);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    alignment: lineIndex % 2 == 0
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      line,
                      textDirection: TextDirection.rtl,
                      textAlign: lineIndex % 2 == 0
                          ? TextAlign.right
                          : TextAlign.left,
                      style: TextStyle(
                        fontSize: _arabicFontSize,
                        height: 1.8,
                        fontFamily: 'Amiri',
                        color: textPrimary,
                      ),
                    ),
                  );
                }),

                if (malayalam.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      malayalam,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        fontFamily: 'Noto Sans Malayalam',
                        color: textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }
}
