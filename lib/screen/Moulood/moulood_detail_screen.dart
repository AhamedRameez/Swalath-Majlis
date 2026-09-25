// lib/screen/user/moulood_detail_screen.dart
import 'package:flutter/material.dart';

class MouloodDetailScreen extends StatefulWidget {
  // Changed to StatefulWidget
  final Map<String, dynamic> mouloodData;
  final String docId;

  const MouloodDetailScreen({
    super.key,
    required this.mouloodData,
    required this.docId,
  });

  @override
  State<MouloodDetailScreen> createState() => _MouloodDetailScreenState();
}

class _MouloodDetailScreenState extends State<MouloodDetailScreen> {
  // 🔥 NEW: Font size variables (from important_surah_detail_screen)
  double _arabicFontSize = 19.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;

  // Font adjustment panel visibility
  bool _showFontAdjustPanel = false;

  // Your specified color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color(0xFF1A472A);

  // 🔥 NEW: Toggle function
  void _toggleFontAdjustPanel() {
    setState(() {
      _showFontAdjustPanel = !_showFontAdjustPanel;
    });
  }

  // 🔥 NEW: Reset function
  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 19.0; // Reset to default
      _showFontAdjustPanel = false;
    });
  }

  String _getString(String key) {
    return widget.mouloodData[key]?.toString() ?? '';
  }

  List<String> _splitIntoLines(String text) {
    if (text.isEmpty) return [];

    // Split by newline first
    List<String> lines = text.split('\n');

    // If no newlines, try to split by Arabic poetic markers
    if (lines.length <= 1) {
      lines = text.split(RegExp(r'[.،؛]'));
    }

    // Remove empty lines and trim
    return lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = _getString('title');
    final description = _getString('description');
    final style = _getString('style'); // 'alternating' or 'paragraph'
    final arabic = _getString('arabic');
    final malayalam = _getString('malayalam');
    final dua = _getString('dua');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8ED), // Warm parchment color
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
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
                  // Title Section
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

                  // Content based on style - NOW USING FONT SIZE VARIABLE
                  if (arabic.isNotEmpty) ...[
                    if (style == 'alternating')
                      _buildAlternatingStyle(arabic)
                    else
                      _buildParagraphStyle(arabic),
                  ],

                  // Malayalam Translation
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

                  // Optional Dua Section - NOW USING FONT SIZE VARIABLE
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
                              fontSize:
                                  _arabicFontSize, // 🔥 USING FONT SIZE VARIABLE
                              height: 1.8,
                              fontFamily: 'Scheherazade',
                              color: arabicTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Footer
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

          // 🔥 NEW: Font adjustment panel positioned at bottom-left
          Positioned(left: 20, bottom: 20, child: _buildFontAdjustmentPanel()),
        ],
      ),
    );
  }

  // 🔥 NEW: Font adjustment panel (copied from important_surah_detail_screen)
  Widget _buildFontAdjustmentPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font adjustment panel (shown when icon is clicked)
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
                  // Panel header
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
                      // Current font size display
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

                  // Horizontal linear slider
                  Column(
                    children: [
                      // Slider
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

                      // Min/Max labels
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

                  // Reset button
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

        // Toggle icon button
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
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Alternating style for poetry (right-left alternating) - UPDATED with font size
  Widget _buildAlternatingStyle(String arabic) {
    final lines = _splitIntoLines(arabic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: arabicTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: arabicTextColor.withValues(alpha: 0.1), width: 1),
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
                color: Color(0xFF2C5530),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Lines with alternating alignment - USING FONT SIZE VARIABLE
          ...List.generate(lines.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              alignment: index % 2 == 0
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Text(
                lines[index],
                textDirection: TextDirection.rtl,
                textAlign: index % 2 == 0 ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: _arabicFontSize, // 🔥 USING FONT SIZE VARIABLE
                  height: 1.9,
                  fontFamily: 'Scheherazade',
                  color: arabicTextColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Paragraph style for continuous text - UPDATED with font size
  Widget _buildParagraphStyle(String arabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: arabicTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: arabicTextColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: [
          const Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Scheherazade',
                color: Color(0xFF2C5530),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: _arabicFontSize,
              height: 1.9,
              fontFamily: 'Scheherazade',
              color: arabicTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
