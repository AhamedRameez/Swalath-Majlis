// lib/screen/user/rifaai_moulood_screen.dart
import 'package:flutter/material.dart';

class RifaaiMouloodScreen extends StatefulWidget {
  const RifaaiMouloodScreen({super.key});

  @override
  State<RifaaiMouloodScreen> createState() => _RifaaiMouloodScreenState();
}

class _RifaaiMouloodScreenState extends State<RifaaiMouloodScreen> {
  // Font size variables
  double _arabicFontSize = 21.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;

  // Font adjustment panel visibility
  bool _showFontAdjustPanel = false;

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

  // Color scheme
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color(0xFF1A472A);

  void _toggleFontAdjustPanel() {
    setState(() {
      _showFontAdjustPanel = !_showFontAdjustPanel;
    });
  }

  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 21.0;
      _showFontAdjustPanel = false;
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
                    onTap: _toggleFontAdjustPanel,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8ED),
      appBar: AppBar(
        title: const Text(
          'Rifaai Moulood',
          style: TextStyle(
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
              color: _showFontAdjustPanel ? accentColor : Colors.white,
              size: 22,
            ),
            onPressed: _toggleFontAdjustPanel,
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
                  // Main Title
                  _buildTitleSection('رِفَاعِي مَوْلِدْ'),

                  const SizedBox(height: 24),

                  // Opening Bismillah
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Amiri',
                        color: arabicTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // First prose section - Introduction
                  _buildArabicParagraph(
                    'اَلْحَمْدُ لِلَّهِ الَّذِي مَا خَلَقَ الْجِنَّ وَالْإِنْسَ إِلا لِيَعْبُدُوهُ * وَاخْتَارَ مِنْهُمْ بَنِي آدَمَ لِيَذْكُرُوهُ * وَاصْطَفَى مِنْ بَنِي آدَمَ الْأَنْبِيَاءَ وَالرُّسُلَ لِيَسْتَهْدُوهُ * وَخَيَّرَ مِنْهُمْ سَيِّدَ الْكَائِنَاتِ مُحَمَّدًا لِيَقْتَدُوهُ * وَأَعْطَى لَهُمْ مَلَأَ وَسُبُلاً وَأُمَمًا * وَجَعَلَ أُمَّةَ نَبِيِّنَا وَشَفِيعِنَا وَسَيِّدِنَا مُحَمَّدٍ خَيْرَ الْأُمَمِ ذِمَمًا * وَصَيَّرَ بَعْضًا مِنْ أُمَمِهِ أَقْطَابًا وَأَغْيَانًا وَأَفْرَادًا هِمَمًا وَفَضَّلَ مِنْهُمْ سَيِّدَنَا أَبَا الْعَبَّاسِ سُلْطَانَ الْعَارِفِينَ السَّيِّدَ أَحْمَدَ الْكَبِيرَ الرِّفَاعِيَّمَعْرِفَةً وَعِلْمًا وَكَانَتْ وِلادَتُهُ يَوْمَ الْإِثْنَيْنِ السَّابِعَ وَالْعِشْرِينَ مِنْ شَهْرٍ رَجَبٍ سَنَةَ خَمْسِمِائَةٍ مِنْ هِجْرَةِ سَيّدِ الْكَوْنَيْنِ شَرَفًا وَنِعَمَّا * وَهُوَ السَّيِّدُ أَحْمَدُ بْنُ السَّيِّدِ عَلِيِّ بْنِ السَّيِّدِ يَحْيَى بْنِ السَّيِّدِ ثَابِتِ بْنِ السَّيِّدِ حَازِمِ بْنِ السَّيِّدِ عَلِيِّ بْنِ السَّيِّدِ حَسَنِ بْنِ السَّيِّدِ مَهْدِي بْنِ السَّيّدِ مُحَمَّدِ بْنِ السَّيِّدِ حُسَيْنِ بْنِ السَّيِّدِ أَحْمَدَ بْنِ السَّيِّدِ مُوسَى الثَّانِي بْنِ السَّيِّدِ إِبْرَاهِيمَ بْنِ السَّيِّدِ مُوسَى الْكَاظِمِ بْنِ السَّيِّدِ جَعْفَرِنِ الصَّادِقِ بْنِ السَّيِّدِ مُحَمَّدِ نِ الْبَاقِرِ بْنِ السَّيِّدِ زَيْنِ الْعَابِدِينَ عَلِيِّ بْنِ السَّيِّدِ الْإِمَامِ حُسَيْنِ بْنِ السَّيِّدِ الْإِمَامِ عَلِيِّ بْنِ أَبِي طَالِبٍ أَجْمَعِينَ وَصَلَّى اللَّهُ عَلَى سَيِّدِنَا مُحَمَّدٍ وَآلِهِ وَصَحْبِهِ وَأَوْلاَدِهِ أَجْمَعِينَ مَادَامَتِ الْأَرْضُ وَالسَّمَاءُ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section 1
                  _buildPoetryCouplets([
                    [
                      'صَلاةٌ وَتَسْلِيمْ وَأَزْكَى تَحِيَّةِ',
                      'عَلَى الْمُصْطَفَى الْمُخْتَارِ خَيْرِ الْبَرِيَّةِ',
                    ],
                    [
                      'أَلا لِلْإِلَهِ الْحَمْدُ فِي كُلِّ حَالَةٍ',
                      'هُوَ الْخَالِقُ الْأَشْيَاءَ كُلاً بِحِكْمَةٍ',
                    ],
                    [
                      'يُفِيضُ إِلَيْهِمْ رَحْمَةً بِجَوَادِهِ',
                      'وَفَضْلٍ وَإِحْسَانٍ وَلُطْفٍ وَمِنَّةٍ',
                    ],
                    [
                      'وُجُوبٌ عَلَيْنَا شُكْرُ فَضْلِ إِلَهِنَا',
                      'بِالآئِهِ مِنْ غَيْرِ حَدٍ وَحَصْرَةٍ',
                    ],
                    [
                      'وَأَشْهَدُ أَنَّ اللَّهَ لَا رَبَّ غَيْرَهُ',
                      'مُصَوِّرُ كُلِ الْخَلْقِ مِنْ غَيْرِ صُنْعَةٍ',
                    ],
                    [
                      'وَكَرَّمَ بَيْنَ الْخَلْقِ أَبْنَاءَ آدَمٍ',
                      'وَأَرْسَلَ رُسُلاً بِالْكِتَابِ وَسُنَّةٍ',
                    ],
                    [
                      'وَخَيَّرَ مِنْهُمْ شَافِعَ الْخَلْقِ أَحْمَدَا',
                      'وَأُمَّتُهُ سَمَّاهُمُ خَيْرَ أُمَّةٍ',
                    ],
                    [
                      'وَمِنْهُمْ شُمُوسٌ ثُمَّ بَدْرٌ وَأَنْجُمٌ',
                      'وَشُهُبٌ ضَوِيٌّ فِي السَّمَاءِ الْعَلِيَّةِ',
                    ],
                    [
                      'وَمِنْهُمْ كَشَمْسِ فِي الْبَطَائِحِ لاَئِحَا',
                      'جَلَتْ نُورُهَا فِي الشَّرْقِ وَالْغَرْبِ صَوْأَةٍ',
                    ],
                    [
                      'وَأَحْمَدُ كَبِيراً اِسْمُهُ الْمُتَبَرَّكُ',
                      'أَبُوهُ أَبُو الْحَسَنِ الْعَلِيُّ الْمُقِنَّةِ',
                    ],
                    [
                      'عَلَى جَدِهِ صَلَّى الْإِلَهُ وَسَلَّمَا',
                      'صَلاَةً وَتَسْلِيمًا وَأَعْلَى تَحِيَّةٍ',
                    ],
                    [
                      'وَآلٍ وَأَصْحَابٍ وَمَنْ تَابَعُوا لَهُمْ',
                      'وَأَوْلاَدِهِ مِنْ كُلِّ عَامٍ وَخَاصَّةٍ',
                    ],
                    [
                      'وَرِضْوَانُ رَبِّي عَنْهُ مَاطَلَعَ طَالِعُ',
                      'وَمَا دَارَ أَفْلَاكُ الْبُرُوج بِحِكْمَةٍ',
                    ],
                    [
                      'عَلَى اللَّهُ عَنْ مُدَّاحِ غَوْثِ الْبَرِيَّةِ',
                      'وَسُمَّاعٍ مَدْحِ كُلَّ شَوْمِ وَزَلَّةٍ',
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Prose section - Story of Sultan al-Arifeen
                  _buildArabicParagraph(
                    'ذُكِرَ فِي كِتَابِ نُورِ الْأَحْمَدِيَّةِ فِي اخْتِصَارِ مَنَاقِبِ السَّيِّدِ أَحْمَدَ الْكَبِيرِ عَنِ الشَّيْخِ عَلِي الْبِيتِي قَالَ سُئِلَ شَيْخُنَا سُلْطَانُ الْعَارِفِينَ سَيّدِي أَحْمَدُ الْكَبِيرُ عَنْ سَبَبٍ لَقَبِهِ وَخِطَابِهِ بِسُلْطَانِ الْعَارِفِينَ ﴿ قَالَ كُنْتُ يَوْمًا قَائِماً فِي الْعَرَفَاتِ عَلَى قَدَمِ التَّجْرِيدِ فَتَجَلَّى اللَّهُ تَعَالَى فِي قَلْبِي صَاحِكًا بِنُورِ جَلَالِهِ وَجَمَالِهِ وَخَاطَبَنِي يَا سُلْطَانَ الْعَارِفِينَ السَّيِّدَ أَحْمَدَ الْكَبِيرَ الرِّفَاعِيَّ وَيَاغَوْثُ الْأَعْظَمُ أَنْتَ حَبِيبِي وَمَعْشُوقِي وَأَنَا مُشْتَاقُ إِلَيْكَ وَأَنْتَ مُشْتَاقُ وَأَنَا مَقْصُودُكَ وَأَنْتَ مَقْصُودِي * ثُمَّ رَأَيْتُ رِجَالَ الْغَيْبِ يَنْزِلُونَ عَلَى الْهَوَاءِ مَثْنَى وَثُلاثَ وَرُبَاعَ وَيَقُولُونَ أَنْتَ سُلْطَانُ الْعَارِفِينَ وَمَحْبُوبُ رَبِّ الْعَالَمِينَ * ثُمَّ جَاءَ النَّبِيُّ وَأَصْحَابُهُ حَوْلَهُ وَأَنَا عَرَفْتُهُ وسكلام علية فَتَقَدَّمْتُ بِثَلَاثَةِ أَقْدَامٍ وَقُلْتُ السَّلَامُ عَلَيْكَ يَاجَدِي فَأَجَابَ وَعَلَيْكَ السَّلَامُ يَا وَلَدِي أَنْتَ سُلْطَانُ الْعَارِفِينَ وَمَحْبُوبُ رَبِّ الْعَالَمِينَ * وَأَنَا أَفْتَخِرُ بِكَ فِي أَوْلِيَاءِ اللَّهِ تَعَالَى وَالْأَنْبِيَاءِ وَالْمُرْسَلِينَ صَلَوَاتُ اللَّهِ عَلَيْهِمْ أَجْمَعِينَ * فَقَبَّلَ عَلَى جَبْتِي وَوَضَعَ يَدَيْهِ عَلَى صَدْرِي وَدَعَا لِي بِهَذِهِ الْأَلْفَاظِ اللَّهُمَّ زِدْ مَحَبَّتَكَ وَمَعْرِفَتَكَ لِوَلَدِي هَذَا سُلْطَانِ الْعَارِفِينَ السُّلْطَانِ أَحْمَدَ الْكَبِيرِ ثُمَّ رَجَعَ إِلَى الْمَدِينَةِ الْمُشَرَّفَةِ وَأَنَا جِئْتُ مِنَ الْعَرَفَاتِ إِلَى الْوَاسِطِ وَكُلُّ مَنْ رَأَوْنِي مِنَ الْأَوْلِيَاءِ يَقُومُونَ وَيُقَتِلُونَ يَدِي * وَيَقُولُونَ يَاسُلْطَانَ الْعَارِفِينَ وَيَا سُلْطَانَ الْمَحْبُوبِينَ * نَحْنُ قَبِلْنَا أَنْ تَكُونَ لَنَا سُلْطَانًا حَقًّا حَقًّا * ثُمَّ جِئْتُ فِي الْبَطَائِحِ فِي قَرْيَةِ أُمِّ عَبِيدَةَ وَكُلُّ مَنْ رَأَوْنِي يَقُولُونَ بِهَذَا الْخِطَابِ الْأَعْظَمِ ﴿ ثُمَّ مَرَرْتُ بِالْمَقَابِرِ فَيَقُومُ أَهْلُهَا وَيَقُولُونَ السَّلَامُ عَلَيْكَ يَاغَوْثُ الأَعْظَمُ وَيَا سُلْطَانُ السَّيِّدُ أَحْمَدُ الْكَبِيرُ ثُمَّ أُمِرْتُ بِإِبْرَازِ هَذَا الْخِطَابِ سَبِعِينَ مَرَّةً فَأَظْهَرْتُ رَضِيَ اللَّهُ عَنْهُ وَنَفَعَنَا بِهِ فِي الدَّارَيْنِ بِفَضْلِهِ آمِينَ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section 2
                  _buildPoetryCouplets([
                    [
                      'صَلَّى عَلَيْكَ اللهُ يَاعَلَمَ الْهُدَى',
                      'يَا مَنْ يُسَمَّى أَحْمَدًا وَمُحَمَّدًا',
                    ],
                    [
                      'رَضَى عَلَيْكَ اللَّهُ خَيْرَ الأَوْلِيَا',
                      'يَا مَنْ يُنَادَى سَيّدًا وَأَحْمَدَا',
                    ],
                    [
                      'نَارَتْ كَرَامَاتُ الْوَلِي الْأَكْبَرِ',
                      'في الْأَرْضِ وَالْآفَاقِ مِثْلَ الْأَنْجُمِ',
                    ],
                    [
                      'قَدْ قَالَ شَيْخُ شُيُوخِنَا أَبُو الْوَفَا',
                      'قَوْلاً صَحِيحًا مَا لَهُ مِنْ مُنْهَمِ',
                    ],
                    [
                      'إِنِّي سَمِعْتُ الْخِضْرَ يَوْمًا قَالَ لِي',
                      'يَوْمَ الْمَعَادِ سَيَفْتَخِرُ ذُوالْعِصَمِ',
                    ],
                    [
                      'مُحَمَّدٌ صَلَّى عَلَيْهِ الصَّمَدُ',
                      'بِالسَّيِّدِ الْكَبِيرِ بَيْنَ الْأُمَمِ',
                    ],
                    [
                      'يَسْئَلُ جَمِيعُ الْأَنْبِيَاءِ آخِذَا',
                      'بِيَدِي الْكَبِيرِ ابْنِ الْعَلِيَ الْمُكْرَمِ',
                    ],
                    [
                      'هَلْ عِنْدَكُمْ فِي أُمَمٍ مِنْ رَجُلٍ',
                      'لاَ لاَ فَوَ اللَّهُ مِثْلَهُ مِنْ أَرِمٍ',
                    ],
                    [
                      'فَيَجِيُّ آدَمُ عِنْدَ طَهَ مُسْرِعًا',
                      'مُتَصَافِحًا مُتَسَلِّمًا بِالْكَرَمِ',
                    ],
                    [
                      'وَقَائِلاً بِكَ أَفْتَخِرُ حَبِيبَنَا',
                      'بِالْوَلَدِ هَذَا أَحْمَدَ الْمُعَظَّمِ',
                    ],
                    [
                      'فَخْرِي حَبِيبَ اللَّهِ يَا خَيْرَ الْوَرَى',
                      'فِي أُمَّتِي بِكَ وَالْكَبِيرِ الْأَفْخَمِ',
                    ],
                    [
                      'ثُمَّ يَجِييُّ الْأَنْبِيَاءُ جَمِيعُهُمْ',
                      'وَيُصَافِحُونَ مَعَ النَّبِي ذِي الْكَرَمِ',
                    ],
                    [
                      'وَالشَّيْخِ أَحْمَدَ نَوَّرَ اللَّهُ به',
                      'قَلْبِي قُلُوبَ الْحَاضِرِينَ الْفَهِمِ',
                    ],
                    [
                      'صَلَّى عَلَيْهِ اللَّهُ كُلَّ لَحْظَةٍ',
                      'مَاطَافَتِ الْحُجَّاجُ بَيْتَ الْحَرَمِ',
                    ],
                    [
                      'رَضَى عَلَى سُلْطَانٍ عُرَفَا أَحْمَدَا',
                      'مَافَاحَ طَيْبَةُ بِالنَّبِيِّ الْمُكْرَمِ',
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Prose section - Story of Sheikh Ibrahim
                  _buildArabicParagraph(
                    'وَحُكِي عَنِ الشَّيْخِ الْوَاصِلِ الشَّيْخِ إِبْرَاهِيمَ الْأَغْرَب دَخَلَ يَوْمًا رَجُلٌ عَلَى قُطْبٍ ? الْعَالَمِ بِالْإِتِّفَاقِ سُلْطَانِ الْعَارِفِينَ سَيِّدِي أَحْمَدَ الْكَبِيرِ وَوَضَعَ لَهُ شَخْصٌ طَعَامًا فَقَالَ إِذَا جَاءَ وَقْتِي أَكُلُ فَقَالَ الرَّجُلُ دُلَّنِي وَقْتَكَ يَاسَيِّدِي » قَالَ بَعْدَ سَبْعِ سِنِينَ * قَالَ الرَّاوِي فَسَأَلْتُهُ عَنْ سَبَبٍ ذَلِكَ قَالَ سُلْطَانُ الْعَارِفِينَ دَخَلْتُ دَارًا لَنَا يَوْمًا شَدِيدَ الْحَرِّ وَأَنَا عَطْشَانُ فَوَجَدتُّ مَاءً مَخْلُوطًا بِبَيَاضِ الْعَجِينِ قَدْ فَضْلَ مِنْ مَاءِ الْعَجِينِ فَأَرَدتُ أَنْ أَشْرَبَهُ * فَقَالَتْ لِي نَفْسِي يُرَى الْمَاءُ الْبَارِدُ * فَامْتَنَعَتِ النَّفْسُ مِنَ السُّرْبِ وَعَاهَدتُ اللَّهَ تَعَالَى أَنْ لَا أكُلَ وَلَا أَشْرَبَ عَشَرَ سَنَةً * وَهُوَ أَخَذَ مِنْ قَهْرٍ نَفْسِهِ وَكَانَ سُلْطَانُ الْعَارِفِينَ سَيِّدِي أَحْمَدُ الْكَبِيرُ عَلامَةً نِحْرِيرًا فِي كُلِ الْعُلُومِ خُصُوصًا فِي عِلْمِ الْكَلاَمِ وَالْحَقَائِقِ وَفِي عِلْمِ التَّفَاسِيرِ وَالْأَحَادِيثِ عَلَى الْاِتِّفَاقِ * وَكَانَ عَادَتُهُ فِي ابْتِدَائِهِ قَدْ يَحْفَظُ مَا يَقْرَأُ مِنَ الْكُتُبِ وَإِنْ كَانَتْ مِنَ الْمُطَوَّلَاتِ فِي مَجْلِسِ دَرْسِهِ بِالْعِنَايَاتِ وَمَنْ جَاءَ لِطَلَبِ الْعِلْمِ عَلَّمَهُ بِالْبِشَارَاتِ * فَبَعْدَ مُدَّةٍ تَرَكَ الدَّرْسَ وَالتَّعْلِيمَ وَاقْتَصَرَ عَلَى الدَّعْوَةِ وَالْإِرْشَادِ إِلَى اللَّهِ الْعَلِيمِ * وَلَهُ تَصَانِيفُ فَاخِرَةٌ فِي الْعُلُومِ الظَّاهِرَةِ وَالْحَقَائِقِ الْبَاطِنَةِ وَلَهُ كَلامٌ عَالٍ عَلَى لِسَانِ أَهْلِ التَّحْقِيقِ رَضِيَ اللَّهُ عَنْهُ وَنَفَعَنَا بِهِ آمِينَ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section 3 - Ya Wali Rida
                  _buildPoetryCouplets([
                    ['يَا وَلِي رِضَا عَلَيْكَ', 'يَا كَبِيرٌ رِضَا عَلَيْكَ'],
                    [
                      'يَا غِيَاتْ رِضَا عَلَيْكَ',
                      'الرَّحِيمُ حَيَّا عَلَيْكَ',
                    ],
                    ['يَا جُمُوعَ الْمَادِحِينَا', 'يَا جُنُودَ الْوَاصِلِينَ'],
                    ['أَكْثِرُوا مَدْحًا مُبِينًا', 'بِقُلُوبِ الرَّاغِبِينَا'],
                    [
                      'أَنْ تُنَادُوا يَا كَبِيرُ',
                      'وَاهِبَ الْخَيْرِ الْكَثِيرُ',
                    ],
                    [
                      'وَاسِعَ الْعِلْمِ الْمُنِيرُ',
                      'وَسِعَنْ عِلْمًا مُبِينًا',
                    ],
                    [
                      'أَنْتَ غَوْثُ الْعَالَمِينَا',
                      'أَنْتَ مُنْجِي الْهَالِكِينَا',
                    ],
                    [
                      'أَنْتَ مُرْشِدُ الْأَمِينَا',
                      'وَارْحَمَنَّ الْمُذْنِبِينَا',
                    ],
                    [
                      'أَنْتَ زَيْنُ الأَوْلِيَاءِ',
                      'أَنْتَ حِبُّ الْأَنْبِيَاءِ',
                    ],
                    [
                      'كُنْتَ قُطْبَ الأَصْفِيَاءِ',
                      'جُدْ لَنَا فَوْزًا قَمِينَا',
                    ],
                    [
                      'رَبِّ وَارْحَمْ وَاغْفِرَنَا',
                      'وَاعْفُ عَنَّا وَاصْلِحَنَّا',
                    ],
                    ['وَسِعَنَّا وَارْزُقَنَّا', 'لِجَمِيعِ الْعَالَمِينَ'],
                  ]),

                  const SizedBox(height: 32),

                  // Poetry section 4 - Rida Allah
                  _buildPoetryCouplets([
                    [
                      'رِضَاءُ اللَّهِ عَلَى أَحْمَدَ الرِّفَاعِي',
                      'وَهُوَ خَيْرُ الْأَوْلِيَا وَلَدُ الشَّفِيع',
                    ],
                    [
                      'يَا سُلْطَانَ الْعَارِفِينَ يَامُنَائِي',
                      'سَيِّدِي أَحْمَدَ الْكَبِيرَ رَجَائِي',
                    ],
                    [
                      'يَاسُلْطَانَ السَّالِكِينَ يَا مَلاَذِي',
                      'سَيّدِي أَحْمَدَ الْكَبِيرَ شِفَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْعَاشِقِينَ يَاغِيَانِي',
                      'سَيِّدِي أَحْمَدَ الْكَبِيرَ غِنَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْمَعْشُوقِينَ يَا فَلَاحِي',
                      'سَيِّدِي أَحْمَدَ الْكَبِيرَ هَنَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْأَفْرَادِينَ يَا نَصِيرِي',
                      'سَيّدِي أَحْمَدَ الْكَبِيرَ بَهَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْأَغْيَاتِ يَاذَا الصِّيَاءِ',
                      'سيدي أَحْمَدَ الْكَبِيرَ جَلَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْأَبْدَالِ يَا ذَا الثَّنَاءِ',
                      'سَيّدِي أَحْمَدَ الْكَبِيرَ دَوَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْأَوْتَادِ كَيْفَ الْمُرِيدِ',
                      'سَيّدِي أَحْمَدَ الْكَبِيرَ عَطَائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْأَوْلِيَا مُرْشِدَ النَّاسِ',
                      'سَيّدِي أَحْمَدَ الْكَبِيرَ كِلائِي',
                    ],
                    [
                      'يَا سُلْطَانَ الْأَتْقِيَا وَمُقْتَدَاهُمْ',
                      'سَيِّدِي أَحْمَدَ الْكَبِيرَ حِمَائِي',
                    ],
                    [
                      'أَرْشِدَنِّي قُطْبَ الْعَالَمِ غَوْثُ الْأَعْظَمُ',
                      'سَيّدِي أَحْمَدَ الْكَبِيرَ الرِّفَاعِي',
                    ],
                    [
                      'إِلَى الطَّرِيقِ الْمُسْتَقِيمِ مُرَبِّي',
                      'سَيِّدِي أَحْمَدَ الْكَبِيرَ رَجَائِي',
                    ],
                    [
                      'رَضَى عَلَيْكَ الْإِلَهُ كُلَّ وَقْتٍ',
                      'وَكُلَّ صُبْحٍ وَآنٍ وَمَسَائِي',
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Prose section - Visit to Madinah
                  _buildArabicParagraph(
                    'وَقَدْ رُوِيَ أَنَّ السَّيِّدَ الشَّرِيفَ سُلْطَانَ السَّيِّدَ أَحْمَدَ الْكَبِيرَ قَدْ أَتَى إِلَى الْمَدِينَةِ الْمُشَرَّفَةِ لِزِيَارَةِ جَدِهِ سُلْطَانِ الْأَنْبِيَاءِ سَيِّدِنَا مُحَمَّدٍ فَقَامَ عِنْدَ رَوْضَتِهِ وَأَنْشَدَ يَقُولُ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section 5 - Fi Halatil Bu'd
                  _buildPoetryCouplets([
                    [
                      'فِي حَالَةِ الْبُعْدِ رُوحِي كُنْتُ أُرْسِلُهَا',
                      'تُقَبِّلُ الْأَرْضَ عَنِّي وَهِيَ نَائِبَتِي',
                    ],
                    [
                      'فَهَذِهِ نَوْبَةُ الْأَشْبَاحِ قَدْ حَضَرَتْ',
                      'فَامْدُدْ يَدَيْكَ لِكَيْ تَحْطَى بِهَا شَفَتِي',
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Prose - Hand of Prophet
                  _buildArabicParagraph(
                    'فَعِنْدَ ذَلِكَ أَخْرَجَ رَسُولُ اللَّهِ صلى الله عليه وسلم يَدَهُ الْمُبَارَكَةَ الْمُعَظَمَةَ فَقَبَّلَهَا السَّيِّدُ أَحْمَدُ الْكَبِيرُ ثُمَّ غَابَتْ يَدُهُ وَرُوِيَ أَيْضًا ﴿ أَنَّ هَذِهِ الْكَرَامَةَ مَا كَانَتْ لِأَحَدٍ مِنَ الْمَشَايِخِ الْعِظَامِ وَالْأَوْلِيَاءِ الْكِرَامِ إِلا لَهُ اللَّهُ عَنْهُ وَنَفَعَنَا بِهِ وَبِهِمْ فِي الدَّارَيْنِ رَضِيَ وَصَلَّى اللَّهُ عَلَى خَيْرٍ خَلْقِهِ مَا لَجَأَ به اللأجِئُونَ سَيِّدِنَا مُحَمَّدٍ وَآلِهِ وَصَحْبِهِ وَأَوْلَادِهِ أَجْمَعِينَ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section 6 - Mawlaya Salli
                  _buildPoetryCouplets([
                    [
                      'مَوْلايَ صَلِّ وَسَلّمْ دَائِمًا أَبَدًا',
                      'عَلَى حَبِيبِكَ خَيْرِ الْخَلْقِ كُلّهم',
                    ],
                    [
                      'رَضُوا أَحِبَّتَنَا شَوْقًا وَعِشْقًا لِمَنْ',
                      'مِنْهُ الْإِجَازَةُ لِلْأَقْطَابِ فِي الْقِدَمِ',
                    ],
                    [
                      'تَحْطَوْا بِإِدْخَالِكُمْ رَبُّ الْعُلَى كَرَمًا',
                      'فِي صُحْبِ سَيِّدِنَا الْمَعْشُوقِ ذِي الْعِظَمِ',
                    ],
                    [
                      'يَارَبِّ صَلِّ عَلَى الْمَعْشُوقِ ذِي الْعِظَمِ',
                      'نَسْلِ النَّبِيِّ الَّذِي قَدْ خُصَّ بِالْكَرَمِ',
                    ],
                    [
                      'وَهُوَ الَّذِي قَالَ مَأْمُورًا مِنَ الصَّمَدِ',
                      'بِمَحْضَرِ كُلِ أَقْطَابِ ذَوِي الْكَرَمِ',
                    ],
                    [
                      'في عَصْرِهِ قَبْلَهُ وَبَعْدَهُ كُونُوا',
                      'إِنِّي أَنَا فِيكُمُ كَالْبَحْرِ مُلْتَطِمِ',
                    ],
                    [
                      'وَالشَّمْسُ أَنْتُمْ كَأَنْهَارِ كَوَاكِبُهَا',
                      'وَالنَّهْرُ يَحْتَاجُهُ وَالنَّجْمُ مِنْ قَرِمِ',
                    ],
                    [
                      'لَمْ تَحْتَجِ الشَّمْسُ وَالْبِحَارُ يَا إِخْوَتِي',
                      'إِلَى الْكَوَاكِبِ وَالْأَنْهَارِ فِي الْحِكَمِ',
                    ],
                    [
                      'إِنِّي أَقُولُ كَمَا أُمِرْتُ مِنْ رَّبِّنَا',
                      'لَا فَخْرَ فِي هَذِهِ الْأَقْوَالِ ذِي الْحِكَمِ',
                    ],
                    [
                      'وَحِينَ قَالَ عَلَى رَقَبَاتِ أَقْطَابِهِمْ',
                      'قَدَمِي فَكُلُّهُمُ قَبِلُوهُ بِالْعَزَمِ',
                    ],
                    [
                      'أَحْيَاءُ مِنْهُمْ بِأَجْسَادٍ وَأَمْوَاتُهُمْ',
                      'بِالرُّوحِ كُلٌّ حَنَوْا خَضْعًا بِلاَ سَدَمٍ',
                    ],
                    [
                      'مَنْ تَابَعُوا بِطَرِيقِ الْأَحْمَدِي فَقَدْ',
                      'نَالَ الْمُنَا كُلَّهُ وَالسُّولَ وَالنِّعَمِ',
                    ],
                    [
                      'مُحِبُّ سَيِّدِنَا الرَّحْمَنُ أَدْخَلَهُ',
                      'بِلا حِسَابِ عَذَابٍ جَنَّةَ النَّعِمِ',
                    ],
                    [
                      'كَذَا لِأَوْلاَدِهِ أَوْلَادِ أَوْلَادِهِ',
                      'حَتَّى الْقِيَامَةِ وَالْخُلَفَا أُولِي الْفَهَمِ',
                    ],
                    [
                      'يَارَبِّ إِجْعَلْنَا أَوْلاَدَنَا أَهْلَنَا',
                      'إِخْوَانَنَا فِي مُرِيدِي غَوْثِنَا الشَّهَمِ',
                    ],
                    [
                      'اللَّهُ صَلَّى عَلَى طَةَ الشَّفِيعِ لِمَنْ',
                      'عَصَى مِنْ أُمَّتِهِ بِالْخَطَا وَالْجَرَمِ',
                    ],
                    [
                      'وَالْآلِ صَحْبٍ مَعَ الْأَوْلَادِ قَاطِبَةً',
                      'مَا زَارَ رَوْضَتَهُ ذُو الْعِشْقِ وَالْغَرَمِ',
                    ],
                    [
                      'غُفْرَانُ رَبِّي عَنِ الْمُدَّاحِ غَوْثَ الْوَرَى',
                      'خَيْرَ الْمَشَائِخِ وَالْأَقْطَابِ كُلِّهِمِ',
                    ],
                    [
                      'وَالسَّامِعِينَ وَمَنْ لِلسَّمْعِ قَدْ حَضَرُوا',
                      'وَمُكْرِمِهِمْ بِإِطْعَامٍ مَعَ الْحَشَمِ',
                    ],
                  ]),

                  const SizedBox(height: 40),

                  // Dua Section
                  _buildDuaSection(),

                  const SizedBox(height: 30),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),

          // Font adjustment panel - Positioned in main body (top-right)
          if (_showFontAdjustPanel)
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

  Widget _buildTitleSection(String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryColor.withValues(alpha: 0.15), width: 1),
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
    );
  }

  Widget _buildArabicParagraph(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: arabicTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: arabicTextColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: _arabicFontSize,
          height: 1.9,
          fontFamily: 'Scheherazade',
          color: arabicTextColor,
        ),
      ),
    );
  }

  // Poetry couplets format - first line on RIGHT, second line on LEFT
  Widget _buildPoetryCouplets(List<List<String>> couplets) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: arabicTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: arabicTextColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: couplets.asMap().entries.map((entry) {
          final index = entry.key;
          final couplet = entry.value;
          final firstLine = couplet[0];
          final secondLine = couplet.length > 1 ? couplet[1] : '';

          return Column(
            children: [
              // First line - RIGHT side
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                alignment: Alignment.centerRight,
                child: Text(
                  firstLine,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: _arabicFontSize,
                    height: 1.9,
                    fontFamily: 'Scheherazade',
                    color: arabicTextColor,
                  ),
                ),
              ),
              // Second line - LEFT side
              if (secondLine.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    secondLine,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: _arabicFontSize,
                      height: 1.9,
                      fontFamily: 'Scheherazade',
                      color: arabicTextColor,
                    ),
                  ),
                ),
              // Add space after each couplet (except the last one)
              if (index != couplets.length - 1) const SizedBox(height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDuaSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.08),
            accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dua Header
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: accentColor, size: 24),
              SizedBox(width: 8),
              Text(
                'دُعَاء',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: accentColor,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.favorite_rounded, color: accentColor, size: 24),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 2,
            width: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [primaryColor, accentColor]),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Dua Text
          Text(
            'اَلْحَمْدُ للهِ رَبِّ الْعَالَمِينَ ﴿ اللَّهُمَّ صَلِ وَسَلّمْ وَبَارِكْ عَلَى سَيِّدِنَا مُحَمَّدٍ حَبِيبِكَ سَيّدِ الْأَنْبِيَاءِ وَالْمُرْسَلِينَ * كَمَا صَلَّيْتَ وَسَلَّمْتَ وَبَارَكْتَ عَلَى سَيِّدِنَا إِبْرَاهِيمَ خَلِيلِكَ يَارَبَّ الْعَالَمِينَ * اَللَّهُمَّ إِنَّا نَسْتَلُكَ أَنْ تَجْعَلَنَا فِي أَصْحَابِ وَمُرِيدِي خَيْرِ الْأَوْلِيَاءِ أَجْمَعِينَ سُلْطَانٍ الْعَارِفِينَ وَالصِّدِّيقِينَ سَيِّدِنَا أَحْمَدَ الْكَبِيرِ الرِّفَاعِي رَضِيَ اللَّهُ عَنْهُ وَعَنْ جَمِيعِ الْمَشَايِخِ وَالْعُلَمَاءِ وَالصَّالِحِينَ بِحُرْمَةِ سَيِّدِنَا مُحَمَّدٍ شَفِيعِ الْمُذْنِبِينَ ﴿ اللَّهُمَّ إِنَّا قَدْ حَضَرْنَا فِي هَذَا المَجْلِسِ المُبَارَكِ الْمَيْمُونِ وَقَرْأْنَا مَدْحَ وَلِيَكَ الْمَعْشُوقِ الْمَأْمُونِ * وَتَمِّمْ أَحْسَنَ الثَّوَابِ وَأَجْزَلَ الْجَزَاءِ عَلَى النَّاظِمِ الْمُذْنِبِ وَالْقُرَّاءِ وَالسَّامِعِينَ وَالصَّانِعِينَ لَهُمْ بِأَنْوَاعِ الطَّعَامِ وَالشَّرَابِ بِجَاهِهِ عِنْدَكَ يَا رَبَّ الْعَالَمِينَ * اللَّهُمَّ صَلِّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِهِ الْهَادِينَ وَأَصْحَابِهِ الَّذِينَ نَصَرُوا وَهَاجَرُوا وَغَزَوْا مَعَهُ لِإِعْلَاءِ الدِّينِ وَأَزْوَاجِهِ أُمَّهَاتِ الْمُؤْمِنِينَ وَأَوْلَادِهِ وَأَحِبَّائِهِ مَعَ سُلْطَانٍ الْعَارِفِينَ وَاجْعَلْنَا لِهَدْيِهِ وَهَدْيِهِمْ مُتَّبِعِينَ وَانْفَعْنَا بِهِ وَبِهِمْ أَجْمَعِينَ * رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ وَالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ آمِينَ',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: _arabicFontSize,
              height: 1.8,
              fontFamily: 'Scheherazade',
              color: arabicTextColor,
            ),
          ),
          const SizedBox(height: 20),

          // Ameen decoration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'آمِينْ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'Scheherazade',
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
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
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Amiri',
              color: textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
