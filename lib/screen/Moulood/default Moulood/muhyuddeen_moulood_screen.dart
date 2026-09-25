// lib/screen/user/muhyuddeen_moulood_screen.dart
import 'package:flutter/material.dart';

class MuhyuddeenMouloodScreen extends StatefulWidget {
  const MuhyuddeenMouloodScreen({super.key});

  @override
  State<MuhyuddeenMouloodScreen> createState() =>
      _MuhyuddeenMouloodScreenState();
}

class _MuhyuddeenMouloodScreenState extends State<MuhyuddeenMouloodScreen> {
  // Font size variables
  double _arabicFontSize = 21.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;

  // Font adjustment panel visibility
  bool _showFontAdjustPanel = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8ED),
      appBar: AppBar(
        title: const Text(
          'Muhyuddeen Moulood',
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
          IconButton(
            icon: Icon(
              _showFontAdjustPanel
                  ? Icons.close_rounded
                  : Icons.format_size_rounded,
              color: Colors.white,
              size: 22,
            ),
            onPressed: _toggleFontAdjustPanel,
            tooltip: _showFontAdjustPanel ? 'Close' : 'Adjust Font Size',
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
                  _buildTitleSection('مُحْيِي الدِّينَ مَوْلِدْ'),

                  const SizedBox(height: 24),

                  // Opening Bismillah and first section
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

                  // First prose section
                  _buildArabicParagraph(
                    'الْحَمْدُ للَّه الْعَلِيِّ الْعَظِيمِ * اَلْوَلِي الْكَرِيمِ ﴾ الَّذِي لاَ يُدْرَكُ لِأَسْمَائِهِ نِهَايَةٌ وَلَا يُبْلَغُ لَهَا غَايَةٌ وَمَعَ هَذَا تَرْجِعُ مِنْ حَيْثُ إِنَّ لَهَا مَحْتِدًا إِلَى الْأُمَّهَاتِ الْأَرْبَعِ أَرْبَابِ الْعِنَايَةِ الْمَنْصُوصِ عَلَيْهَا فِي الْكِتَابِ الْحَكِيمِ بِقَوْلِهِ تَعَالَى هُوَ الأَوَّلُ وَالآخِرُ وَالظَّاهِرُ وَالْبَاطِنِّ وَهُوَ بِكُلِّ شَيْءٍ عَلِيمٌ ٣ وَالصَّلاَةُ وَالسَّلاَمُ عَلَى سَيِّدِنَا مُحَمَّدٍ خَيْرِ مَنْ أُلْبِسَ دِثَارَ النُّبُوَّةِ وَشِعَارَ الْوِلَايَةِ وَعَلَى آلِهِ وَأَصْحَابِهِ أَرْبَابِ الْفُتُوَّةِ وَالْهِدَايَةِ وَعَلَى خُلَفَائِهِ الرَّاشِدِينَ وَالْقَائِمِينَ مَقَامَهُ إِلَى يَوْمِ الدِّينِ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section - Salawat
                  _buildPoetryCouplets([
                    [
                      'صَلاةٌ وَتَسْلِيمٌ وَأَزْكَى تَحِيَّةٍ',
                      'عَلَى الْمُصْطَفَى الْمُخْتَارِ خَيْرِ الْبَرِيَّةِ',
                    ],
                    [
                      'أَلا لِلْإِلَهِ الْحَمْدُ فِي كُلِّ لَحْظَةٍ',
                      'عَلَى مَا حَبَانًا نِعْمَةً بَعْدَ نِعْمَةٍ',
                    ],
                    [
                      'لَهُ أَسْمَاءُ لَيْسَ يُدْرَكُ كُنْهُمَا',
                      'وَلَوْ لِنَبِي أَوْ وَلِي بِهمَّةٍ',
                    ],
                    [
                      'نَعَمْ إِنَّهَا عِنْدَ اعْتِبَارِ انْتِسَابِهَا',
                      'لَهَا أُمَّهَاتٌ أَرْبَعٌ ذَاتُ رِفْعَةٍ',
                    ],
                    [
                      'هي الْأَوَّلُ وَالْبَاطِنُ الْآخِرُ الَّذِي',
                      'هُوَ الظَّاهِرُ فِي الْكَوْنِ مِنْ دُونِ خُفْيَةٍ',
                    ],
                    [
                      'كَمَا الْأَوَّلَآنِ مَنْشَأْ لِلْوِلَايَةِ',
                      'كَذَا الْآخِرَانِ مَعْدِنٌ لِلنُّبُوَّةِ',
                    ],
                    [
                      'وَأَعْظِمْ بِهَاتَيْنِ اللَّتَيْنِ عَلَيْهِمَا',
                      'مَدَارُ مُهمَّاتِ الْوُجُودِ بِحِكْمَةِ',
                    ],
                    [
                      'فَفِي بَعْضِ أَعْيَانٍ قَدْ انْصَمَّتَا كَمَا',
                      'لِتَيْنِ افْتِرَاقٌ فِي مَظَاهِرٍ ثُلَّةِ',
                    ],
                    [
                      'صَلاَةً دَوَامًا مَعْ سَلَامٍ مُؤَيَّدِ',
                      'عَلَى خَيْرِ مَبْعُوثٍ إِلَى خَيْرِ أُمَّةِ',
                    ],
                    [
                      'مُحَمَّدِنِ الْمَاحِي وَآلٍ وَصَحْبِهِ',
                      'وَوُرَّاثِهِمْ وَالنَّائِبِيهِمْ بِخُلَّةِ',
                    ],
                    [
                      'وَعَفْو عَنِ الْمُدَّاحِ غَوْثَ الْوَرَى الَّذِي',
                      'تَسَمَّى بِمُحْيِ الدِّينِ قُطْبِ الْمُقِلَّةِ',
                    ],
                    [
                      'وَسُمَّاعِهِ وَالْحَاضِرِينَ وَأَهْلِهِمْ',
                      'وَمُطْعِمِهِمْ حُبًّا لَهُ كُلَّ لَحْظَةٍ',
                    ],
                  ]),

                  const SizedBox(height: 32),

                  // Prose section - Biography
                  _buildArabicParagraph(
                    'ذُكِرَ فِي خُلاصَةِ الْمَفَاخِرِ فِي اخْتِصَارِ مَنَاقِبِ الشَّيْخِ عَبْدِ الْقَادِرِ نُبْدَةً يَسِيرَةً أَنَّهُ قَدَّسَ اللَّهُ سِرَّهُ تَوَلَّدَ بِجِيلَانَ سَنَةَ إِحْدَى وَسَبْعِينَ وَأَرْبَعِمِائَةٍ مِنَ الْهَجْرَةِ * وَدَخَلَ بَغْدَادَ وَلَهُ مِنَ الْعُمُرِ ثَمَانِيَ عَشَرَ سَنَةً * وَهُوَ أَبُو مُحَمَّدٍ عَبْدُ الْقَادِرِ بْنُ أَبِي صَالِحِنِ بْنِ مُوسَى بْنِ خَنْدَكُوسَ بْن أَبِي عَبْدِ اللَّهِ بْنِ يَحْيَى الزَّاهِدِ بْنِ مُحَمَّدِ بْنِ دَاوُدَ بْنِ مُوسَى بْنِ عَبْدِ اللَّهِ بْنِ مُوسَى الْجَوْنِ بْنِ عَبْدِ اللَّهِ الْمَحْضِ بْنِ الْحَسَنِ الْمُثَنَّى بْنِ حَسَنِ بْنِ عَلِيَّ نِ بْنِ أَبِي طَالِبٍ كَرَّمَ اللَّهُ وَجْهَهُ * وَكُلُّهُمُ السَّادَاتُ رَضِيَ اللَّهُ عَنْهُمْ أَجْمَعِينَ ﴿ مِنْهَا مَا رُوِيَ عَنْ عَبْدِ الْحَقِّ أَنَّهُ قَالَ كُنَّا عِنْدَ الشَّيْخِ رَضِيَ اللَّهُ عَنْهُ يَوْمًا فَتَوَضَأَ فِي قَبْقَابٍ وَصَلَّى رَكْعَتَيْنِ وَرَمَى بِفَرْدَتَيْهِ بَعْدَ مَا صَرَخَ صَرْخَتَيْنِ فَسَكَتَ بِحَالِهِ وَلَمْ يُجَاسِرُ أَحَدٌ عَلَى سُؤَالِهِ ثُمَّ قَدِمَتْ قَافِلَةٌ مِنَ الْعَجَمِ بِنَذْرٍ لَهُ مِنْ ذَهَبٍ وَثِيَابٍ وَكَانَ مَعَهُ ذَلِكَ الْقَبْقَابُ فَقُلْنَا أَنَّى لَكُمْ هَذَا؟ قَالُوا بَيْنَنَا سَائِرُونَ خَرَجَتْ عَلَيْنَا طَائِفَةٌ مَعَ مُقَدَّمَيْنِ لَهُمْ مِنَ الْأَعْرَابِ ﴿ فَقَتَلُوا مِنَّا وَنَهَبُوا مَا مَعَنَا مِنَ الْأَسْبَابِ ﴿ فَقُلْنَا لَوْ نَذَرْنَا لِلشَّيْخِ وَذَكَرْنَا بِكَلِمَتَيْنِ فَمَا تَمَّ ذَلِكَ إِلا أَنْ سَمِعْنَا صَرْخَتَيْنِ شَدِيدَتَيْنِ فَقَالَ وَاحِدٌ مِنْهُمْ تَعَالَوْا وَانْظُرُوا مَا نَزَلَ مِنَ الْقَهْرِ عَلَيْنَا فَنَظَرْنَا وَوَجَدْنَا مَعَ مُقَدَّمَيْهِمْ مَيِّتَيْنِ وَعِنْدَ كُلِّ مِنْهُمَا فَرْدَةٌ مِنْ هَاتَيْنِ هَذَا وَجَمِيعُ مَا ذُكِرَ مِنْ فَيْضِ رَسُولِ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ تَسْلِيمًا كَثِيرًا كَثِيرًا',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section - Allah Allah
                  _buildPoetryCouplets([
                    [
                      'الله اللَّه رَبُّنَا اللَّه',
                      'الله اللَّه حَسْبُنَا اللَّه',
                    ],
                    [
                      'نَحْمَدُ اللَّه نَشْكُرُ اللَّه',
                      'ذَلِكَ فَضْلٌ مِنَ اللَّه',
                    ],
                    ['يَا جُنُودَ الذَّاكِرِينَ', 'يَاشُهُودَ الْحَاضِرِينَ'],
                    ['أَكْثِرُوا ذِكْرًا مُبِينًا', 'لِدَلِيلِ الطَّالِبينَ'],
                    [
                      'أَنْ تَقُولُوا يَا مَلاَذُ',
                      'وَاسِعَ الْفَضْلِ الْمَعَاذُ',
                    ],
                    ['مِنْكُمُ لَنَا نَفَاذُ', 'كُنْ لَنَا عَوْنًا مُعِينَا'],
                    ['انْتَ حَقًّا مُحْي دِينِ', 'أَنْتَ قُطْبٌ بِالْيَقِينِ'],
                    [
                      'أَنْتَ غَوْتٌ كُلَّ حِينٍ',
                      'فَادْفَعَنْ عَنَّا حَنِينًا',
                    ],
                    [
                      'أَنْتَ غَوْتُ الثَّقَلَيْنِ',
                      'أَنْتَ زَيْنُ الْحَرَمَيْنِ',
                    ],
                    ['وَمُنِيرُ الْمَلَوَيْن', 'إِجْعَلَنَّا مُقْبِلِينَا'],
                    [
                      'أَنْتَ أَتْقَى الْأَنْقِيَاءِ',
                      'أَنْتَ أَصْفَى الْأَصْفِيَاءِ',
                    ],
                    ['صِرْتَ تَاجَ الْأَوْلِيَاءِ', 'آتِنَا فَتْحًا مُبِينًا'],
                    [
                      'أَنْتَ مُبْدِئُ النَّوَادِرُ',
                      'مُظْهِرٌ مَافِي الضَّمَائِرُ',
                    ],
                    [
                      'مُخْبِرٌ مَافِي السَّرَائِرُ',
                      'رَحْمَةً دُنْيَا وَدِينَا',
                    ],
                    ['يَا حَفِيدَ الْحَسَنَيْنِ', 'يَا نَجِيبَ الْأَبَوَيْنِ'],
                    [
                      'يَا كَرِيمَ الطَّرَفَيْنِ',
                      'كُنْ لَنَا حِرْزًا كَمِينَا',
                    ],
                    ['كُنْ لَنَا كَهْفًا مَنِيعًا', 'عَنْ بَلِيَّاتٍ جَمِيعًا'],
                    ['خَطِيئَاتٍ وَسِيعًا', 'مِنْ عَطِيَّاتٍ تَفِينَا'],
                    ['أَنْزَلَ اللَّهُ سَلَامًا', 'مَعْ صَلَوَاتٍ دَوَامًا'],
                    ['لِلَّذِي غَدَا ختاما', 'لِجَمِيعِ الْمُرْسَلِينَ'],
                    [
                      'أَحْمَدٍ وَالْآلِ أَسْرَى',
                      'وَالْأُولَى احْتَشَوْهُ نَصْرًا',
                    ],
                    [
                      'مَعْ مَنِ اقْتَفَوْهُ إِثْرًا',
                      'وَالْفَرِيقِ النَّائِبِينَا',
                    ],
                    ['وَعَفَى عَنْ سَامِعِينَا', 'مَدْحَكُمْ وَالصَّانِعِينَا'],
                    ['طُعْمَهُمْ وَالْحَاضِرِينَا', 'هَاهُنَا وَالذَّاكِرِينَ'],
                  ]),

                  const SizedBox(height: 32),

                  // Prose section - Quran verse explanation
                  _buildArabicParagraph(
                    'قَالَ اللهُ تَعَالَى يَا أَيُّهَا الَّذِينَ آمَنُوا اتَّقُوا اللَّهَ وَابْتَغُوا إِلَيْهِ الْوَسِيلَةَ وَجَاهِدُوا فِي سَبِيلِهِ لَعَلَّكُمْ تُفْلِحُونَ * نَبَّهَ اللَّهُ تَعَالَى بِهَذِهِ الْآيَةِ أَهْلَ الطَّرِيقَةِ عَلَى أَنَّ رَجَاءَ الْفَلَاحِ الْحَقِيقِيّ مُتَوَقَّفٌ عَلَى أَرْبَعَةِ أَعْمَالٍ مِنَ الدَّقَائِقِ * أَحَدُهَا الْإِيمَانُ الْمُتَأَكِدُ بِالْبُرْهَانِ الْمُتَأَيِّدُ بِالْمُكَاشَفَةِ وَالْعِيَانِ الَّذِي يَخْرُجُ بِهِ الْعَبْدُ مِنْ أَقْسَامِ الشِّرْكِ وَالطُّغْيَانِ الثاني التَّقْوَى بِثَلَاثَةِ أَنْوَاعِهَا الْأَدْنَى تَجَنُّبُ الْمُؤْمِنِ لِلْعِصْيَانِ * وَالْأَوْسَطُ الَّذِي هُوَ تَحَفُظُ السَّالِكِ عَنِ النِّسْيَانِ * وَالْأَعْلَى الَّذِي هُوَ جَعْلُ الْعَارِفِ رَبَّهُ فِي مَوَارِدِ الْخَيْرِ وِقَايَةً لِنَفْسِهِ وَجَعْلُ نَفْسِهِ فِي مَوَارِدِ الشَّرِ وِقَايَةً لِحَضْرَةِ قُدْسِهِ * والثَّالِثُ إِبْتِغَاءُ الْوَسِيلَةِ بِنَوْعَهَا الْأَعَمِ الَّذِي هُوَ تَقْدِيمُ الْأَعْمَالِ الْحَسَنَةِ وَتَقْوِيمُ الْأَفْعَالِ الْمُسْتَحْسَنَةِ وَالْأَخَصَ الَّذِي هُوَ اتِّخَاذُ الطَّالِبِ لِنَفْسِهِ مِنَ الْهُدَاةِ الْكُمَّلِ خَلِيلاً لِيَهْتَدِيَ بِهِ إِلَى أَقْرَبِ الطُّرُقِ مِنَ اللَّهِ سَبِيلاً * والرَّابِعُ اَلْجِهَادُ بِنَوْعَيْهِ الْأَصْغَرِ الَّذِي هُوَ مُحَارَبَةُ أَعْدَاءِ الدِّينِ الْخَلْقِ وَالدُّنْيَا وَالشَّيْطَانِ * الَّذِينَ يَدْعُونَ الْإِنْسَانَ إِلَى مَظَانِ الْخُسْرَانِ وَالْخِزْلاَنِ وَالْعِصْيَانِ وَالْأَكْبَرِ الَّذِي هُوَ مُخَالَفَةُ النَّفْسِ فِي حُبّ الشَّهَوَاتِ بِتَزْكِيَتِهَا عَنِ الْأَخْلَاقِ النَّمِيمَةِ وَبِتَحْلِيَتِهَا بِالْأَوْصَافِ السَّلِيمَةِ وَصَلَّى اللَّهُ وَسَلَّمَ عَلَى سَيِّدِنَا مُحَمَّدٍ خَيْرٍ مَنْ أُوتِيَ الْحِكْمَةَ وَفَصْلَ الْخِطَابِ وَعَلَى الْآلِ وَالْأَصْحَابِ وَالْأَوْلِيَاءِ وَالْأَقْطَابِ',
                  ),

                  const SizedBox(height: 32),

                  // Poetry section - Ilahi Ya Ilahi
                  _buildPoetryCouplets([
                    [
                      'إِلَهِي يَا إِلَهِي يَا إِلَهِي',
                      'إِلهِي تَوْبَةً قَبْلَ الْمَمَاتِ',
                    ],
                    [
                      'سَقَانِي الشَّوْقُ كَأَسَاتِ الْفَنَاءِ',
                      'فَقُلْتُ بِسَكْرَتِي فَوْقَ الْبَقَاءِ',
                    ],
                    [
                      'سَعَتْ وَأَتَتْ بِإِثْرِي فِي شَبَابِي',
                      'فَهِمْتُ بِعِشْقَتِي بَيْنَ الرِّوَاءِ',
                    ],
                    [
                      'فَقُلْتُ لِفِرْقَةِ الْأَقْطَابِ قُومُوا',
                      'بِحَالِي وَادْخُلُوا بَيْتَ اللّقَاءِ',
                    ],
                    [
                      'وَفُوزُوا وَاصِلُوا أَنْتُمْ جُنُودِي',
                      'فَبَابُ الْوَصْلِ يُفْتَحُ بِالدُّعَاءِ',
                    ],
                    [
                      'أَخَذْتُمْ فَضْلَتِي مِنْ بَعْدِ وَجْدِي',
                      'وَلاَ نِلْتُمْ مَقَامِي وَالْعَطَاءِ',
                    ],
                    [
                      'مَقَامُكُمُ الْهُدَى طُرًّا وَلَكِنْ',
                      'مَقَامِي فِي التَّفَوُّقِ وَالْعَلَاءِ',
                    ],
                    [
                      'أَنَا فِي حَضْرَةِ التَّوْصِيلِ فَرْدِي',
                      'يُقَلِّبُنِي وَحَسْبِي ذُو السَّمَاءِ',
                    ],
                    [
                      'أَنَا الْعَالِي بِعُلْوِ كُلَّ قُطْبٍ',
                      'وَنَسْتَوْفِي الْكَمَالَ مِنَ الْعَمَاءِ',
                    ],
                    [
                      'أَتَانِي خِلْعَةً بِطِرَازِ قُرْبٍ',
                      'وَأَكْرَمَنِي بِتِيجَانِ الْوَفَاءِ',
                    ],
                    [
                      'وَأَشْرَفَنِي عَلَى سِرٍ خَفِيّ',
                      'وَعَزَّزَنِي بِإِعْطَاءِ الْفَنَاءِ',
                    ],
                    [
                      'وَوَلأَنِي عَلَى النُّوَّابِ طُرَّا',
                      'فَأَمْرِي نَافِةٌ فِي كُلِ دَاءٍ',
                    ],
                    [
                      'وَلَوْ أَظْهَرْتُ عِشْقِى فِي بِحَارٍ',
                      'لَكَانَ الْكُلُّ غَوْرًا فِي الْفَنَاءِ',
                    ],
                    [
                      'وَلَوْ أَلْهَمْتُ شَوْقِي فِي جِبَالٍ',
                      'لَمَرَّتْ كَالسَّحَابِ عَلَى الْهَوَاءِ',
                    ],
                    [
                      'وَلَوْ أَلْقَيْتُ ذَوْقِي فَوْقَ نَارٍ',
                      'لَخَمَدَتْ وَاخْتَفَتْ حَقَّ الْخَفَاءِ',
                    ],
                    [
                      'وَلَوْ أَسْمَعْتُ سِرِّي سَمْعَ مَيْتٍ',
                      'لَقَامَ وَصَارَ حَيَّا بِالنِّدَاءِ',
                    ],
                    [
                      'وَمَا مِنَّا السَّرَائِرَ وَالْخَفَايَا',
                      'تَرَى بِالْقَوْمِ إِلَّا بِالرِّضَاءِ',
                    ],
                    [
                      'وَأَخْبَرَنِي بِمَا يَأْتِي وَيَجْرِي',
                      'وَأَعْلَمَنِي الْعُلُومَ وَبِالْوَلَاءِ',
                    ],
                    [
                      'مُرِيدِي عِشْ وَدُمْ وَافْرِغْ وَغَنِّ',
                      'وَإِسْمِي مُدْخَلٌ تَحْتَ اللّوَاءِ',
                    ],
                    [
                      'مُرِيدِي لَا تَخَفْ رَبِّي كَرِيمٌ',
                      'هَدَانِي لِلْوُصُولِ مَعَ الْبَهَاءِ',
                    ],
                    [
                      'شُمُوسِي أَشْرَقَتْ عُلُوًّا وَسُفْلاً',
                      'وَأَعْلَامِي عَلَى رَأْسِ الْبِنَاءِ',
                    ],
                    [
                      'جُيُوسُ اللَّهِ جُنْدِي تَحْتَ حُكْمِي',
                      'وَوَقْتِي قَدصَّفَا كُلَّ الصَّفَاءِ',
                    ],
                    [
                      'رَأَيْتُ إِلَى بِلادِ اللَّهِ طُرًّا',
                      'بِحُكْمِ الْوَصْلِ خَرْدَلَةَ الْهَوَاءِ',
                    ],
                    [
                      'وَكُلٌّ وَلِي لَهُ قَلْبٌ وَإِنِّي',
                      'عَلَى قَلْبِ الْمُحَمَّدِ ذِي السَّنَاءِ',
                    ],
                    [
                      'وَإِسْمِي إِسْمُ خَيْرِ الْأَنْبِيَاءِ',
                      'وَأَحْوَالِي تُؤَثِرُ فِي الْحَشَاءِ',
                    ],
                    [
                      'إِلهِي سَيّدِي صَلِّ وَسَلِّمْ',
                      'عَلَى طَةَ وَآلٍ بِالْوِلَاءِ',
                    ],
                    [
                      'وَأَصْحَابِ وَتُبَّاعٍ جَمِيعًا',
                      'بِمَا صَاءَتْ نُجُومٌ فِي السَّمَاءِ',
                    ],
                    [
                      'إِلَهِي فَاعْفُوَنْ لِأَبِي وَأُمِّي',
                      'السَّنَاء وَأُسْتَاذِي بِحُرْمَةِ ذِي',
                    ],
                    [
                      'وَمُدَّاحًا وَسُمَّاعًا وَحُضًا',
                      'رَنِ الْمُطْعِمَ دَوْمًا بِالْبَقَاءِ',
                    ],
                    [
                      'إِلَهِي عَبْدَكَ الْمِسْكِينَ فَارْحَمْ',
                      'بِغُفْرَانِ الذُّنُوبِ وَبِالْقَنَاءِ',
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
          Positioned(left: 20, bottom: 20, child: _buildFontAdjustmentPanel()),
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
              gradient: const LinearGradient(
                colors: [primaryColor, accentColor],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Dua Text
          Text(
            'اَلْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ * اَللَّهُمَّ صَلِ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ اللَّهُمَّ إِنَّا نَحْنُ عَبِيدُكَ الْفُقَرَاءُ وَبِحِبَالِ الْأَهْوَاءِ أُسَرَاءُ حَضَرْنَا فِي هَذَا الْمَجْلِسِ الْعَاطِرِ وَقَرَأْنَا بِإِذْنِ صَاحِبِهِ مَنَاقِبَ وَلِيِّكَ عَبْدِ الْقَادِرِ فَبِجَاهِهِ لَدَيْكَ وَبِقُرْبِهِ إِلَيْكَ وَفِّقْنَا لِلْإِقْتِدَاءِ بِهِ وَسَائِرِ الْأَوْلِيَاءِ وَامْتِثَالِ الْمَأْمُورَاتِ وَاجْتِنَابِ الْمَحْظُورَاتِ وَاحْفَظْ ظَوَاهِرَنَا عَنِ الْعَثَرَاتِ رَبَّنَا لاَ تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا رَبَّنَا وَلَا تُحَمِّلْنَا مَا لاَ طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ وَصَلَّى اللهُ عَلَى سَيِّدِنَا مُحَمَّدٍ وَآلِهِ وَصَحْبِهِ أَجْمَعِينَ وَالْحَمْدُ للهِ رَبِّ الْعَالَمِينَ',
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
                    children: [Text('Small'), Text('Large')],
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
                      ),
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Reset to Default'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        // Material(
        //   color: cardColor,
        //   borderRadius: BorderRadius.circular(12),
        //   elevation: 4,
        //   shadowColor: Colors.black.withOpacity(0.1),
        //   child: InkWell(
        //     onTap: _toggleFontAdjustPanel,
        //     borderRadius: BorderRadius.circular(12),
        //     child: Container(
        //       width: 48,
        //       height: 48,
        //       decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(12),
        //         border: Border.all(
        //           color: dividerColor.withOpacity(0.8),
        //           width: 1,
        //         ),
        //       ),
        //       // child: Icon(
        //       //   _showFontAdjustPanel
        //       //       ? Icons.close_rounded
        //       //       : Icons.format_size_rounded,
        //       //   color: _showFontAdjustPanel ? textTertiary : primaryColor,
        //       //   size: 22,
        //       // ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
