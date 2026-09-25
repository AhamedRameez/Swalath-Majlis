// lib/screen/user/asmaul_husna_name_screen.dart
import 'package:flutter/material.dart';

class AsmaulHusnaNameScreen extends StatefulWidget {
  const AsmaulHusnaNameScreen({super.key});

  @override
  State<AsmaulHusnaNameScreen> createState() => _AsmaulHusnaNameScreenState();
}

class _AsmaulHusnaNameScreenState extends State<AsmaulHusnaNameScreen> {
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

  // List of 99 names
  final List<Map<String, String>> asmaulHusna = const [
    {"arabic": "ٱلرَّحْمَٰنُ", "transliteration": "Ar-Raḥmān"},
    {"arabic": "ٱلرَّحِيمُ", "transliteration": "Ar-Raḥīm"},
    {"arabic": "ٱلْمَلِكُ", "transliteration": "Al-Malik"},
    {"arabic": "ٱلْقُدُّوسُ", "transliteration": "Al-Quddūs"},
    {"arabic": "ٱلسَّلَامُ", "transliteration": "As-Salām"},
    {"arabic": "ٱلْمُؤْمِنُ", "transliteration": "Al-Mu’min"},
    {"arabic": "ٱلْمُهَيْمِنُ", "transliteration": "Al-Muhaymin"},
    {"arabic": "ٱلْعَزِيزُ", "transliteration": "Al-‘Azīz"},
    {"arabic": "ٱلْجَبَّارُ", "transliteration": "Al-Jabbār"},
    {"arabic": "ٱلْمُتَكَبِّرُ", "transliteration": "Al-Mutakabbir"},
    {"arabic": "ٱلْخَٰلِقُ", "transliteration": "Al-Khāliq"},
    {"arabic": "ٱلْبَارِئُ", "transliteration": "Al-Bāriʾ"},
    {"arabic": "ٱلْمُصَوِّرُ", "transliteration": "Al-Muṣawwir"},
    {"arabic": "ٱلْغَفَّارُ", "transliteration": "Al-Ghaffār"},
    {"arabic": "ٱلْقَهَّارُ", "transliteration": "Al-Qahhār"},
    {"arabic": "ٱلْوَهَّابُ", "transliteration": "Al-Wahhāb"},
    {"arabic": "ٱلرَّزَّاقُ", "transliteration": "Ar-Razzāq"},
    {"arabic": "ٱلْفَتَّاحُ", "transliteration": "Al-Fattāḥ"},
    {"arabic": "ٱلْعَلِيمُ", "transliteration": "Al-ʿAlīm"},
    {"arabic": "ٱلْقَابِضُ", "transliteration": "Al-Qābiḍ"},
    {"arabic": "ٱلْبَاسِطُ", "transliteration": "Al-Bāsiṭ"},
    {"arabic": "ٱلْخَافِضُ", "transliteration": "Al-Khāfiḍ"},
    {"arabic": "ٱلرَّافِعُ", "transliteration": "Ar-Rāfiʿ"},
    {"arabic": "ٱلْمُعِزُّ", "transliteration": "Al-Muʿizz"},
    {"arabic": "ٱلْمُذِلُّ", "transliteration": "Al-Mudhill"},
    {"arabic": "ٱلسَّمِيعُ", "transliteration": "As-Samīʿ"},
    {"arabic": "ٱلْبَصِيرُ", "transliteration": "Al-Baṣīr"},
    {"arabic": "ٱلْحَكَمُ", "transliteration": "Al-Ḥakam"},
    {"arabic": "ٱلْعَدْلُ", "transliteration": "Al-‘Adl"},
    {"arabic": "ٱللَّطِيفُ", "transliteration": "Al-Laṭīf"},
    {"arabic": "ٱلْخَبِيرُ", "transliteration": "Al-Khabīr"},
    {"arabic": "ٱلْحَلِيمُ", "transliteration": "Al-Ḥalīm"},
    {"arabic": "ٱلْعَظِيمُ", "transliteration": "Al-ʿAẓīm"},
    {"arabic": "ٱلْغَفُورُ", "transliteration": "Al-Ghafūr"},
    {"arabic": "ٱلشَّكُورُ", "transliteration": "Ash-Shakūr"},
    {"arabic": "ٱلْعَلِيُّ", "transliteration": "Al-ʿAlī"},
    {"arabic": "ٱلْكَبِيرُ", "transliteration": "Al-Kabīr"},
    {"arabic": "ٱلْحَفِيظُ", "transliteration": "Al-Ḥafīẓ"},
    {"arabic": "ٱلْمُقِيتُ", "transliteration": "Al-Muqīt"},
    {"arabic": "ٱلْحَسِيبُ", "transliteration": "Al-Ḥasīb"},
    {"arabic": "ٱلْجَلِيلُ", "transliteration": "Al-Jalīl"},
    {"arabic": "ٱلْكَرِيمُ", "transliteration": "Al-Karīm"},
    {"arabic": "ٱلرَّقِيبُ", "transliteration": "Ar-Raqīb"},
    {"arabic": "ٱلْمُجِيبُ", "transliteration": "Al-Mujīb"},
    {"arabic": "ٱلْوَاسِعُ", "transliteration": "Al-Wāsiʿ"},
    {"arabic": "ٱلْحَكِيمُ", "transliteration": "Al-Ḥakīm"},
    {"arabic": "ٱلْوَدُودُ", "transliteration": "Al-Wadūd"},
    {"arabic": "ٱلْمَجِيدُ", "transliteration": "Al-Majīd"},
    {"arabic": "ٱلْبَاعِثُ", "transliteration": "Al-Bāʿith"},
    {"arabic": "ٱلشَّهِيدُ", "transliteration": "As-Shahīd"},
    {"arabic": "ٱلْحَقُّ", "transliteration": "Al-Ḥaqq"},
    {"arabic": "ٱلْوَكِيلُ", "transliteration": "Al-Wakīl"},
    {"arabic": "ٱلْقَوِيُّ", "transliteration": "Al-Qawiyy"},
    {"arabic": "ٱلْمَتِينُ", "transliteration": "Al-Matīn"},
    {"arabic": "ٱلْوَلِيُّ", "transliteration": "Al-Waliyy"},
    {"arabic": "ٱلْحَمِيدُ", "transliteration": "Al-Ḥamīd"},
    {"arabic": "ٱلْمُحْصِي", "transliteration": "Al-Muḥṣī"},
    {"arabic": "ٱلْمُبْدِئُ", "transliteration": "Al-Mubdiʾ"},
    {"arabic": "ٱلْمُعِيدُ", "transliteration": "Al-Muʿīd"},
    {"arabic": "ٱلْمُحْيِي", "transliteration": "Al-Muḥyī"},
    {"arabic": "ٱلْمُمِيتُ", "transliteration": "Al-Mumīt"},
    {"arabic": "ٱلْحَيُّ", "transliteration": "Al-Ḥayy"},
    {"arabic": "ٱلْقَيُّومُ", "transliteration": "Al-Qayyūm"},
    {"arabic": "ٱلْوَاجِدُ", "transliteration": "Al-Wājid"},
    {"arabic": "ٱلْمَاجِدُ", "transliteration": "Al-Mājid"},
    {"arabic": "ٱلْوَاحِدُ", "transliteration": "Al-Wāḥid"},
    {"arabic": "ٱلْأَحَدُ", "transliteration": "Al-Aḥad"},
    {"arabic": "ٱلصَّمَدُ", "transliteration": "Aṣ-Ṣamad"},
    {"arabic": "ٱلْقَادِرُ", "transliteration": "Al-Qādir"},
    {"arabic": "ٱلْمُقْتَدِرُ", "transliteration": "Al-Muqtadir"},
    {"arabic": "ٱلْمُقَدِّمُ", "transliteration": "Al-Muqaddim"},
    {"arabic": "ٱلْمُؤَخِّرُ", "transliteration": "Al-Muʾakhkhir"},
    {"arabic": "ٱلْأَوَّلُ", "transliteration": "Al-Awwal"},
    {"arabic": "ٱلْآخِرُ", "transliteration": "Al-Ākhir"},
    {"arabic": "ٱلظَّاهِرُ", "transliteration": "Aẓ-Ẓāhir"},
    {"arabic": "ٱلْبَاطِنُ", "transliteration": "Al-Bāṭin"},
    {"arabic": "ٱلْوَالِي", "transliteration": "Al-Wālī"},
    {"arabic": "ٱلْمُتَعَالِي", "transliteration": "Al-Mutaʿālī"},
    {"arabic": "ٱلْبَرُّ", "transliteration": "Al-Barr"},
    {"arabic": "ٱلتَّوَابُ", "transliteration": "At-Tawwāb"},
    {"arabic": "ٱلْمُنْتَقِمُ", "transliteration": "Al-Muntaqim"},
    {"arabic": "ٱلْعَفُوُّ", "transliteration": "Al-ʿAfūw"},
    {"arabic": "ٱلرَّءُوفُ", "transliteration": "Ar-Raʾūf"},
    {"arabic": "مَالِكُ ٱلْمُلْكِ", "transliteration": "Mālik al-Mulk"},
    {
      "arabic": "ذُو ٱلْجَلَالِ وَٱلْإِكْرَامِ",
      "transliteration": "Dhū al-Jalāli wa’l-Ikrām",
    },
    {"arabic": "ٱلْمُقْسِطُ", "transliteration": "Al-Muqsiṭ"},
    {"arabic": "ٱلْجَامِعُ", "transliteration": "Al-Jāmiʿ"},
    {"arabic": "ٱلْغَنِيُّ", "transliteration": "Al-Ghaniyy"},
    {"arabic": "ٱلْمُغْنِيُ", "transliteration": "Al-Mughnī"},
    {"arabic": "ٱلْمَانِعُ", "transliteration": "Al-Māniʿ"},
    {"arabic": "ٱلضَّارُّ", "transliteration": "Aḍ-Ḍārr"},
    {"arabic": "ٱلنَّافِعُ", "transliteration": "An-Nāfiʿ"},
    {"arabic": "ٱلنُّورُ", "transliteration": "An-Nūr"},
    {"arabic": "ٱلْهَادِي", "transliteration": "Al-Hādī"},
    {"arabic": "ٱلْبَدِيعُ", "transliteration": "Al-Badīʿ"},
    {"arabic": "ٱلْبَاقِي", "transliteration": "Al-Bāqī"},
    {"arabic": "ٱلْوَارِثُ", "transliteration": "Al-Wāriṯ"},
    {"arabic": "ٱلرَّشِيدُ", "transliteration": "Ar-Rashīd"},
    {"arabic": "ٱلصَّبُورُ", "transliteration": "Aṣ-Ṣabūr"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Asmaul Husna',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F3EF), backgroundColor, Color(0xFFF5F3EF)],
          ),
        ),
        child: Column(
          children: [
            // Header with count
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dividerColor),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '99 Names of Allah',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '99',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Names List with Dua at the END
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: asmaulHusna.length + 1, // +1 for Dua at the end
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  // If this is the last item, show Dua
                  if (index == asmaulHusna.length) {
                    return _buildDuaSection();
                  }

                  // Otherwise show name
                  final name = asmaulHusna[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Number badge
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor,
                                primaryColor.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 🔥 FIXED: Arabic name on right, transliteration on left
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end, // Right align Arabic
                            children: [
                              Text(
                                name['arabic']!,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Amiri',
                                  color: arabicTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Transliteration aligned left
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  name['transliteration']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: textSecondary,
                                    fontFamily: 'Poppins',
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  // 🔥 NEW: Separate widget for Dua section
  Widget _buildDuaSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 1),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, color: accentColor, size: 20),
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
          SizedBox(height: 16),
          Text(
            'اللَّهُمَّ إِنِّي أَسْأَلُكَ بِأَنَّ لَكَ الْحَمْدَ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ الْمَنَّانُ يَا بَدِيعَ السَّمَاوَاتِ وَالْأَرْضِ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.8,
              fontFamily: 'Amiri',
              color: arabicTextColor,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'O Allah, I ask You by every name that belongs to You, the Praised, there is no god but You alone, You have no partner, the Benefactor, O Originator of the heavens and earth, O Possessor of Majesty and Honor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
