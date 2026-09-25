// lib/screen/user/thawba_screen.dart
import 'package:flutter/material.dart';
import 'thouba_instruction_screen.dart'; // Import the instruction screen

class ThawbaScreen extends StatefulWidget {
  const ThawbaScreen({super.key});

  @override
  State<ThawbaScreen> createState() => _ThawbaScreenState();
}

class _ThawbaScreenState extends State<ThawbaScreen> {
  // 🔥 NEW: Font size variables for both Arabic and Malayalam
  double _arabicFontSize = 22.0;
  double _malayalamFontSize = 17.0; // Separate control for Malayalam

  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 36.0;

  // Font adjustment panel visibility
  bool _showFontAdjustPanel = false;

  // Your color scheme - same as ThoubaScreen
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color arabicTextColor = Color.fromARGB(255, 0, 0, 0);
  static const Color malayalamTextColor = Color.fromARGB(255, 0, 0, 0);

  // 🔥 NEW: Toggle function
  void _toggleFontAdjustPanel() {
    setState(() {
      _showFontAdjustPanel = !_showFontAdjustPanel;
    });
  }

  // 🔥 NEW: Reset function - resets both sizes
  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 22.0;
      _malayalamFontSize = 17.0;
      _showFontAdjustPanel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8ED), // WARM PARCHMENT/GOLDEN COLOR
      appBar: AppBar(
        title: const Text(
          'Thouba',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 🔥 INSTRUCTION BOX AT THE TOP
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ThoubaInstructionScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: accentColor,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'തൗബ ചെയ്യേണ്ട ശരിയായ രൂപം',
                                  style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'എങ്ങനെ ശരിയായി തൗബ ചെയ്യാം? കാണുവാൻ ടാപ്പ് ചെയ്യുക',
                                  style: TextStyle(
                                    color: textSecondary,
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'വിശദമായി കാണുക',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Main White Container
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Title Section
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
                                child: const Column(
                                  children: [
                                    Text(
                                      'തൗബ',
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Arabic Text 1 - With centered Bismillah
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: 26,
                                  height: 1.9,
                                  fontFamily: 'Uthmanic',
                                  color: Color(0xFF2C5530),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ (۳).\nالْقَدِيمَ الْكَرِيمَ الرَّحِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ مِنْ كُلِّ ذَنْبٍ أَذْنَبْتُهُ عَمْدًا أَوْ خَطَأً أَوْ سِرًّا أَوْ عَلَانِيَّةً أَوْ صَغِيرًا أَوْ كَبِيرًا وَآتُوبُ إِلَيْهِ مِنَ الذَّنْبِ الَّذِي أَعْلَمُ وَمِنَ الذَّنْبِ الَّذِي لَا أَعْلَمُ إِنَّكَ أَنْتَ عَلَّامُ الْغُيُوبِ أَسْتَغْفِرُ اللَّهَ عَنْ جَمِيعِ مَا كَرِهَ اللَّهُ قَوْلًا وَفِعْلًا وَعَمَلًا وخَاطِرًا وَنَاظِرًا يَأَيُّهَا الَّذِينَ آمَنُوا تُوبُوا إِلَى اللَّهِ تَوْبَةً نَصُوحًا',
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize: _arabicFontSize,
                                height: 1.9,
                                fontFamily: 'Uthmanic',
                                color: arabicTextColor,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Malayalam Text 1 - NOW ADJUSTABLE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              ' ഞങ്ങൾ നിന്നോട് അറിഞ്ഞു ചെയ്ത ദോഷത്തിനെ തൊട്ടും അറിയാതെ ചെയ്ത ദോഷത്തിനെ തൊട്ടും മറച്ചു ചെയ്ത ദോഷത്തിനെ തൊട്ടും പരസ്യമായി ചെയ്ത ദോഷത്തിനെ തൊട്ടും എല്ലാ വൻദോഷത്തിനെ തൊട്ടും എല്ലാ ചെറു ദോഷത്തിനെ തൊട്ടും ഞങ്ങൾ എല്ലാവരും നിന്നോട് ഖേദിച്ചു മടങ്ങുന്നു തമ്പുരാനേ',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize:
                                    _malayalamFontSize, // 🔥 NOW ADJUSTABLE
                                height: 1.7,
                                fontFamily: 'Noto Sans Malayalam',
                                color: malayalamTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Arabic Text 2
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِن لَّمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  height: 1.7,
                                  fontFamily: 'Uthmanic',
                                  color: arabicTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Malayalam Text 2 - NOW ADJUSTABLE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' ഞങ്ങളുടെ തമ്പുരാനേ, ഞങ്ങൾ എല്ലാവരും ഞങ്ങളുടെ തടിയോട് അനേകം കുറ്റവും ദുർമര്യാദയും ഏറ്റം ഏറ്റം ചെയ്തു നടന്ന അടിയാർ കളാകുന്നു കമ്പുരാനെ. ഇപ്പോൾ നിന്റെ റഹ്മതെന്ന തൗബ എന്ന വാതുക്കൾ ഞങ്ങൾ എല്ലാ വരും ഖേദിച്ചു പേടിച്ചു മടങ്ങി വന്നിരിക്കുന്നു തമ്പുരാനേ, ഇനി ഒരിക്കലും ഒരു ദോഷം കൊള്ളയും മടങ്ങുകയില്ലെന്ന് ഞങ്ങൾ എല്ലാവരും ഞങ്ങളുടെ ഖൽബ് കൊണ്ട് നല്ലവണ്ണം കരുതി ഉറപ്പിച്ചു തമ്പുരാനേ. നീ ഞങ്ങളുടെ ദോഷത്തിനെ പൊറുത്ത് തൗബയെ ഖബൂൽ ചെയ്തില്ല എന്ന് വന്നാൽ ഞങ്ങൾ ജഹന്നം എന്ന നരകത്തിൽ വീണ് വെന്തുരുകുന്ന അടിയാർകളാൽ ആയിപ്പോകും തമ്പുരാനേ. നിന്റെ കൃപ കൊണ്ടും നിന്റെ മുഹമ്മദ് ബേദാമ്പർ തങ്ങളുടെ ബർകത് കൊണ്ടും, നീ ജഹന്നമെന്ന നരകത്തിനെ തൊട്ട് ഞങ്ങളെ സലാമത്താക്കണം തമ്പുരാനേ. ',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize:
                                    _malayalamFontSize, // 🔥 NOW ADJUSTABLE
                                height: 1.7,
                                fontFamily: 'Noto Sans Malayalam',
                                color: malayalamTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Arabic Text 3
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِن لَّدُنكَ رَحْمَةً إِنَّكَ أَنتَ الْوَهَّابُ',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  height: 1.7,
                                  fontFamily: 'Uthmanic',
                                  color: arabicTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Malayalam Text 3 - NOW ADJUSTABLE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ഞങ്ങളുടെ തമ്പുരാനേ, നീ ഞങ്ങൾക്ക് എല്ലാവർക്കും ഈ തൗബയും നേർവഴിയും ദീൻ ഇസ്ലാമും തന്നതിൽ പിറകെ അതിനെ വിട്ട് ഞങ്ങളെ ഖൽബിനെ തട്ടിത്തിരിച്ചു നിന്റെ മാറ്റക്കാരനായ ശൈത്വാൻ ഇബ്ലീസിന്റെ ചെല്ല് കൊള്ളയും ചേല് കൊള്ളയും നീ ഞങ്ങളെ ആക്കി കളയല്ല തമ്പുരാനേ. നീ നിന്റെ പക്കൽ നിന്നുള്ള റഹ്മത്തിനെ ഞങ്ങളെല്ലാവരെ അളവിലും ഓശാരമായി ഏറ്റം ഏറ്റം വഴിങ്ങിതരണം തമ്പുരാനേ',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize:
                                    _malayalamFontSize, // 🔥 NOW ADJUSTABLE
                                height: 1.7,
                                fontFamily: 'Noto Sans Malayalam',
                                color: malayalamTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Arabic Text 4
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ عَلَيْهَا نَحْيَا وَعَلَيْهَا نَمُوتُ وَعَلَيْهَا نُبْعَثُ إِنْشَاءَ الله',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  height: 1.7,
                                  fontFamily: 'Uthmanic',
                                  color: arabicTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Malayalam Text 4 - NOW ADJUSTABLE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ഞങ്ങളുടെ തമ്പുരാനേ, നീ ഞങ്ങളെല്ലാവരേയും ശഹാദത് കലിമയോടെ ഈമാനോടുകൂടി മരിപ്പിച്ച് ഖബറിൽ അകം കടത്തി ഖബറിൽ നിന്ന് രണ്ടാമത് ഹയാത്തിട്ട് മഹ്ശറ കൊള്ള യാത്രയാക്കിയും ഞങ്ങളുടെ എല്ലാവരുടേയും നന്മയും തിന്മയും എഴുതപ്പെട്ട ഏട് കിതാബിനെ നീ ഞങ്ങൾ എല്ലാവരെ വലൻ കയ്യിൽ തരിപ്പിച്ചു നിന്റെ ആലത്തിൽ കാരുണ്യമാക്കപ്പെട്ട നബി മുഹമ്മദുൻ സ്വല്ലല്ലാഹു അലൈഹിവ സല്ലമ തങ്ങളെ ശഫാഅത്തിൽ ഒരു മിച്ചുകൂട്ടി സ്വർഗത്തിൽ അകം കടത്തി നിന്റെ ലിഖാനെയും ആദരവായ നബിന്റെ തൃക്കല്ലിയാണത്തിനെയും ഞങ്ങളുടെ രണ്ട് കണ്ണും കൊണ്ട് കാണുവാനും അതിൽ കൂടുവാനും ഏറ്റം ഏറ്റം ഉദവി ചെയ്യണം തമ്പുരാനേ.  ',
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontSize:
                                    _malayalamFontSize, // 🔥 NOW ADJUSTABLE
                                height: 1.7,
                                fontFamily: 'Noto Sans Malayalam',
                                color: malayalamTextColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Final Arabic Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'بِحَقِّ لَا إِلَهَ إِلَّا اللَّهُ مُحَمَّدٌ رَسُولُ اللَّهِ (۳)',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  height: 1.7,
                                  fontFamily: 'Uthmanic',
                                  color: arabicTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Thawba Dua Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'തൗബയുടെ ദുആ',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Container(
                                  height: 3,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        accentColor.withValues(alpha: 0.7),
                                        accentColor.withValues(alpha: 0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Center(
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 24,
                                    height: 1.8,
                                    fontFamily: 'Uthmanic',
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ اللَّهُمَّ صَلَّ عَلَى سَيِّدِنَا مُحَمَّدٍ وَعَلَى آلِ سَيِّدِنَا مُحَمَّدٍ اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ وَاجْعَلْنِي مِنْ عِبَادِكَ الصَّالِحِينَ * سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا أَنْتَ أَسْتَغْفِرُكَ وَأَتُوبُ إِلَيْكَ رَبَّنَا وَآتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ وَصَلَّى اللَّهُ عَلَى خَيْرِ خَلْقِهِ سَيِّدِنَا مُحَمَّدٍ وَآلِهِ وَصَحْبِهِ أَجْمَعِينَ ۝ آمِينَ ۝ بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ ۝',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontSize: _arabicFontSize,
                                  height: 1.8,
                                  fontFamily: 'Uthmanic',
                                  color: arabicTextColor,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Footer Divider
                        Center(
                          child: Container(
                            height: 4,
                            width: 120,
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
                        ),
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'اللهم تقبل منا',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Uthmanic',
                              color: textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Font adjustment panel
          Positioned(left: 20, bottom: 20, child: _buildFontAdjustmentPanel()),
        ],
      ),
    );
  }

  // Font adjustment panel - UPDATED with both Arabic and Malayalam controls
  Widget _buildFontAdjustmentPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font adjustment panel
        if (_showFontAdjustPanel)
          Material(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: Container(
              width: 300,
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
                      // Reset button
                      IconButton(
                        icon: const Icon(Icons.restart_alt_rounded, size: 18),
                        color: accentColor,
                        onPressed: _resetFontSize,
                        tooltip: 'Reset to default',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Arabic Font Size Control
                  Row(
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'العربية',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_arabicFontSize.toInt()} px',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
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

                  // Malayalam Font Size Control
                  Row(
                    children: [
                      Container(
                        width: 60,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Text(
                            'മലയാളം',
                            style: TextStyle(
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${_malayalamFontSize.toInt()} px',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _malayalamFontSize,
                    min: _minFontSize,
                    max: _maxFontSize,
                    divisions: (_maxFontSize - _minFontSize).toInt(),
                    activeColor: accentColor,
                    inactiveColor: dividerColor,
                    thumbColor: accentColor,
                    onChanged: (value) {
                      setState(() {
                        _malayalamFontSize = value;
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
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Large',
                        style: TextStyle(
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
}
