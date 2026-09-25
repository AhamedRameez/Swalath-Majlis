//lib/screen/important_surah_detail_screen.dart
import 'package:flutter/material.dart';

class ImportantSurahDetailScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String arabic;
  final String description;

  const ImportantSurahDetailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.arabic,
    required this.description,
  });

  @override
  State<ImportantSurahDetailScreen> createState() =>
      _ImportantSurahDetailScreenState();
}

class _ImportantSurahDetailScreenState
    extends State<ImportantSurahDetailScreen> {
  // Font size variables
  double _arabicFontSize = 20.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;

  // Font adjustment panel visibility
  bool _showFontAdjustPanel = false;

  // Same color scheme from AyathsScreen
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

  void _toggleFontAdjustPanel() {
    setState(() {
      _showFontAdjustPanel = !_showFontAdjustPanel;
    });
  }

  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 18.0;
      _showFontAdjustPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Description card (if available)
                if (widget.description.isNotEmpty) ...[
                  _buildDescriptionCard(),
                  const SizedBox(height: 20),
                ],

                // Arabic text card with Surah name
                _buildArabicTextCard(),
                const SizedBox(height: 80), // Space for floating buttons
              ],
            ),
          ),

          // Font adjustment panel
          Positioned(left: 20, bottom: 20, child: _buildFontAdjustmentPanel()),
        ],
      ),
    );
  }

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

  Widget _buildDescriptionCard() {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description header
              const Row(
                children: [
                  Icon(Icons.description_rounded, color: accentColor, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Rewards For who read this Surah',
                    style: TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description text
              Text(
                widget.description,
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 15,
                  height: 1.6,
                  fontFamily: 'Poppins',
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArabicTextCard() {
    if (widget.arabic.isEmpty) {
      return Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        elevation: 0.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
          ),
          child: const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                'No Arabic text available',
                style: TextStyle(
                  color: textTertiary,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Surah name header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book_rounded, color: primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Surah label
              const Text(
                'Surah',
                style: TextStyle(
                  color: textTertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),

              // Divider - MOVED BEFORE SUBTITLE
              Container(height: 1, color: dividerColor),
              const SizedBox(height: 16),

              // Subtitle (displayed in Arabic style, centered)
              if (widget.subtitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    widget.subtitle,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.6,
                      fontFamily: 'Amiri', // Same Arabic font
                      color: Color.fromARGB(
                        255,
                        0,
                        0,
                        0,
                      ), // Same color as Arabic text
                      fontWeight:
                          FontWeight.w600, // Slightly bolder for subtitle
                    ),
                  ),
                ),

              // Arabic text container with proper styling
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontSize: _arabicFontSize,
                    height: 1.9,
                    fontFamily: 'Scheherazade', // 🔥 Naskh font
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0,
                    wordSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
