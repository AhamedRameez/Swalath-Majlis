// lib/screen/user/thouba_instruction_screen.dart
import 'package:flutter/material.dart';

class ThoubaInstructionScreen extends StatelessWidget {
  const ThoubaInstructionScreen({super.key});

  // 🎨 Same color scheme as ThawbaScreen
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);
  static const Color parchmentColor = Color(0xFFFDF8ED); // Same warm parchment

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: parchmentColor, // Same warm parchment background
      appBar: AppBar(
        title: const Text(
          'തൗബ ചെയ്യേണ്ട രൂപം',
          style: TextStyle(
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // White container like ThawbaScreen
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
              // Header - Motivation Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'റബ്ബിന്റെ കാരുണ്യം',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ഒരുപാട് പേരുടെ ചിന്തയാണ് , ഒരുപാട് തെറ്റുകൾ ജീവിതത്തിൽ വന്നു പോയി, എനിക്ക് റബ്ബ് പൊറുത്തുതരുമോ എന്ന്.\n\nഹബീബീങ്ങളെ, 100 പേരെ കൊലപ്പെടുത്തിയ വ്യക്തിക്ക് റബ്ബ് പൊറുത്തുകൊടുത്തിട്ടുണ്ട്. അത്രക്കൊന്നും ഒരിക്കലും നമ്മൾ ചെയ്തിട്ടില്ലല്ലോ.\n\nപേടിക്കണ്ട ഹബീബീങ്ങളെ, മനസറിഞ്ഞു ഒന്ന് തൗബ ചെയ്യ്, റബ്ബ് പൊറുത്തു തരും إن شاء الله. അത്രമാത്രം വിശാലമാണ് നമ്മുടെ റബ്ബിന്റെ മഗ്ഫിറത്ത്.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                        height: 1.7,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 🔴 FIXED: തൗബയുടെ ശർത്തുകൾ Section - Now responsive
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon - FIXED for mobile screens
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.rule_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // FIXED: Expanded to prevent overflow
                        const Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'തൗബയുടെ ശർത്തുകൾ',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: dividerColor, thickness: 1),
                    const SizedBox(height: 16),

                    // Conditions List
                    const Text(
                      'തൗബയുടെ ശർതുകൾ നാല്:',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Condition 1
                    _buildConditionItem(
                      number: '١',
                      condition: 'ചെയ്ത ദോഷത്തിന്റെ അളവിൽ ഖേദിക്കൽ.',
                    ),

                    // Condition 2
                    _buildConditionItem(
                      number: '٢',
                      condition: 'ചെയ്തുവരുന്ന ദോഷങ്ങളെതൊട്ട് ഒഴിയൽ.',
                    ),

                    // Condition 3
                    _buildConditionItem(
                      number: '٣',
                      condition: 'മേലിൽ ഒരു ദോഷവും ചെയ്യുകയില്ലെന്ന് കരുതൽ.',
                    ),

                    // Condition 4
                    _buildConditionItem(
                      number: '٤',
                      condition:
                          'വീട്ടുവാനുള്ള ഹഖുകൾ ഒക്കെയും കൊടുത്തു വീട്ടൽ കൊണ്ടോ പൊരുത്തപ്പെടീക്കൽ കൊണ്ടോ വെടിപ്പാക്കുന്നത്.',
                    ),

                    const SizedBox(height: 16),

                    // Important note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'ഇങ്ങനെ നാല് ശരത് കൂടാതെ തൗബ ഖബൂലാകുന്നതല്ലെന്ന് തീർച്ചയായി പറയപ്പെട്ടിരിക്കുന്നു.',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Title Section - Similar to "തൗബ" title in ThawbaScreen
              Center(
                child: Container(
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
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'ചെയ്യേണ്ട രൂപം',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Instruction Items
              _buildInstructionItem(
                number: 1,
                title: 'കുളിയും നിയ്യത്തും',
                description:
                    'ഒന്ന് നന്നായി കുളിക്കുക, കുളിയിൽ നിയ്യത് വെക്കുക (ഈ കുളിയോട് കൂടെ എന്റെ മനസ്സിനെ അങ്ങ് നന്നാക്കി തരണം അല്ലാഹ്)',
              ),

              _buildInstructionItem(
                number: 2,
                title: 'സുഗന്ധം പൂശുക',
                description: 'അത്തർ പോലെയുള്ള സുഗന്ധം പൂശുന്നത് നല്ലതാണ്',
              ),

              _buildInstructionItem(
                number: 3,
                title: '2 റക്കഅത്ത് നിസ്ക്കാരം',
                description: 'വുളു എടുത്തിട്ട് ഒരു 2 റക്കഅത്ത് നിസ്ക്കരിക്കുക.',
              ),

              _buildInstructionItem(
                number: 4,
                title: 'ഒറ്റക്കുള്ള സ്ഥലം',
                description:
                    'ആരും ഇല്ലാത്ത ഒറ്റക്ക് ആയ സ്ഥലം ആണ് ഏറ്റവും നല്ലത്.',
              ),

              _buildInstructionItem(
                number: 5,
                title: 'ഫാത്തിഹയും സ്വലാത്തും',
                description:
                    'നബിയുടെ പേരിൽ ഒരു ഫാത്തിഹയും കുറച്ച് സ്വലാത്തും കൂടി ചൊല്ലുക. തൗബ പെട്ടന്ന് സ്വീകരിക്കാൻ കാരണമാവും ഇത്.',
              ),

              _buildInstructionItem(
                number: 6,
                title: 'കൈകൾ ഉയർത്തുക',
                description:
                    'കൈകൾ റബ്ബിലേക്ക് ഉയർത്തിയിട്ട്, ചെയ്ത പാപങ്ങൾ മുഴുവൻ റബ്ബിനോട് പറയുക.',
              ),

              _buildInstructionItem(
                number: 7,
                title: 'മനസറിഞ്ഞു പറയുക',
                description:
                    'ചെയ്ത് കൂട്ടിയ പാപങ്ങൾ റബ്ബിനോട് മനസറിഞ്ഞു പറയുക.',
              ),

              _buildInstructionItem(
                number: 8,
                title: 'കണ്ണുകൾ നിറയട്ടെ',
                description:
                    'കണ്ണുകൾ നിറയാൻ പറ്റിയാൽ (ഒന്ന് റബ്ബിന്റെ മുന്നിൽ മനസ്സ് തുറന്നു കരയാൻ സാധിച്ചാൽ അത്രയും നല്ലത്)',
              ),

              _buildInstructionItem(
                number: 9,
                title: 'പാപങ്ങൾ ഏറ്റുപറയുക',
                description:
                    'പാപങ്ങൾ ഒക്കെ റബ്ബിനോട് പറഞ്ഞ ശേഷം പറയുക:\n\n"അല്ലാഹ്, ആ സമയത്ത് അങ്ങനെ പറ്റിപ്പോയി റബ്ബേ, ഒരിക്കലും ഞാൻ അങ്ങയെ ധിക്കരിച്ചു ചെയ്തതല്ല അല്ലാഹ്, ആ സമയം ശൈതാന്റെ കെണിയിൽ ഞാൻ പെട്ടുപോയി റബ്ബേ, മാപ്പാക്കണം അല്ലാഹ്.\n\nഎന്നിട്ടും ഒരു കുഴപ്പവും ഇല്ലാതെ റാഹത്തായി എനിക്ക് വേണ്ടതെല്ലാം തന്ന റബ്ബേ, എനിക്ക് അങ്ങനെ പറ്റിപ്പോയി, അല്ലാഹ് എന്നോട് പൊറുക്കണം.\n\nറബ്ബേ, എന്റെ ജീവിതത്തിൽ പലതും സംഭവിച്ചു അല്ലാഹ്, എല്ലാം പൊറുക്കുന്ന റബ്ബേ എനിക്ക് മാപ്പ് തരണം."',
              ),

              _buildInstructionItem(
                number: 10,
                title: 'ഉറച്ച തീരുമാനം',
                description:
                    'അവസാനം പറയുക: "റബ്ബേ ഇനി ഞാൻ ഇത്തരത്തിൽ തെറ്റുകൾ ചെയ്യില്ല അല്ലാഹ്". എന്ന് പറഞ്ഞു തെറ്റുകളെ ജീവിതത്തിൽ നിന്നും പറിച്ചു കളയുക.',
              ),

              _buildInstructionItem(
                number: 11,
                title: 'ചിന്തിക്കുക',
                description:
                    'ഇനി എപ്പോ തെറ്റ് ചെയ്യാൻ തോന്നിയാലും "നാളെ റബ്ബിന്റെ മുന്നിൽ പോയി നിൽക്കണമല്ലോ" എന്ന് ഒന്ന് ചിന്തിക്കുക.\n\nശൈത്താൻ പലപ്പോഴും വന്നു പറയും "നാളെ നന്നാവാം" എന്ന്. അതിൽ ഒരിക്കലും ഇനി നിങ്ങൾ പെട്ടുപോവരുത്.',
              ),

              const SizedBox(height: 32),

              // Final Message Container - Similar to Dua Container in ThawbaScreen
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: primaryColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'ഇങ്ങനെ ഒന്ന് തൗബ ചെയ്ത് നോക്കൂ',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'എല്ലാം കഴിഞ്ഞ് മനസ്സിന് ഒരു സന്തോഷവും സമാധാനവും ഒക്കെ കിട്ടുന്നുണ്ടെങ്കിൽ ഉറപ്പിക്കുക: റബ്ബ് നിന്റെ തൗബ സ്വീകരിച്ചിട്ടുണ്ട് എന്നതിന്റെ ഒരടയാളം ആണ് അത്.\n\nപിന്നീട് ഈ തെറ്റിലേക്ക് നീ ഒരിക്കലും മടങ്ങാതിരിക്കുക.\n\nറബ്ബ് നമുക്കൊക്കെ തൗബ ചെയ്ത് നന്നാവാൻ തൗഫീഖ് നൽകുമാറാകട്ടെ.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 15,
                        height: 1.7,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 16),
                    const Text(
                      'آمِيْنَ يَا رَبَّ الْعَالَمِيْنَ',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Amiri',
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for condition items
  Widget _buildConditionItem({
    required String number,
    required String condition,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              condition,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem({
    required int number,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number Circle - Like the number badge in ThawbaScreen
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryColor, Color.fromARGB(255, 35, 150, 115)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 15,
                    height: 1.7,
                    fontFamily: 'Poppins',
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
