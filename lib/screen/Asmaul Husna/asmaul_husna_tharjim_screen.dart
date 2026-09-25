// lib/screen/user/asmaul_husna_tharjim_screen.dart
import 'package:flutter/material.dart';

class AsmaulHusnaTharjimScreen extends StatefulWidget {
  const AsmaulHusnaTharjimScreen({super.key});

  @override
  State<AsmaulHusnaTharjimScreen> createState() =>
      _AsmaulHusnaTharjimScreenState();
}

class _AsmaulHusnaTharjimScreenState extends State<AsmaulHusnaTharjimScreen> {
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

  // List of 99 names with English and Malayalam meanings
  final List<Map<String, String>> asmaulHusna = const [
    {
      "arabic": "ٱلرَّحْمَٰنُ",
      "transliteration": "Ar-Raḥmān",
      "meaning": "The Most or Entirely Merciful",
      "malayalam": "ഏറ്റവും കരുണയുള്ളവൻ",
    },
    {
      "arabic": "ٱلرَّحِيمُ",
      "transliteration": "Ar-Raḥīm",
      "meaning": "The Especially Merciful",
      "malayalam": "പരമകാരുണികൻ",
    },
    {
      "arabic": "ٱلْمَلِكُ",
      "transliteration": "Al-Malik",
      "meaning": "The King and Owner of Dominion",
      "malayalam": "സർവ്വാധിപതി",
    },
    {
      "arabic": "ٱلْقُدُّوسُ",
      "transliteration": "Al-Quddūs",
      "meaning": "The Absolutely Pure and Perfect",
      "malayalam": "പരിശുദ്ധൻ",
    },
    {
      "arabic": "ٱلسَّلَامُ",
      "transliteration": "As-Salām",
      "meaning": "The Perfection and Giver of Peace",
      "malayalam": "സമാധാനത്തിന്റെ ഉറവിടം",
    },
    {
      "arabic": "ٱلْمُؤْمِنُ",
      "transliteration": "Al-Mu’min",
      "meaning": "The Granter of Security and Faith",
      "malayalam": "ശാന്തി നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُهَيْمِنُ",
      "transliteration": "Al-Muhaymin",
      "meaning": "The Guardian, The Witness, The Overseer",
      "malayalam": "മേൽനോട്ടം വഹിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْعَزِيزُ",
      "transliteration": "Al-‘Azīz",
      "meaning": "The Almighty, The All-Powerful, The Invincible",
      "malayalam": "പ്രതാപശാലി",
    },
    {
      "arabic": "ٱلْجَبَّارُ",
      "transliteration": "Al-Jabbār",
      "meaning": "The Compeller, The Restorer",
      "malayalam": "ശക്തനായവൻ",
    },
    {
      "arabic": "ٱلْمُتَكَبِّرُ",
      "transliteration": "Al-Mutakabbir",
      "meaning": "The Supreme, The Majestic",
      "malayalam": "മഹത്വമുള്ളവൻ",
    },
    {
      "arabic": "ٱلْخَٰلِقُ",
      "transliteration": "Al-Khāliq",
      "meaning": "The Creator, The Maker",
      "malayalam": "സ്രഷ്ടാവ്",
    },
    {
      "arabic": "ٱلْبَارِئُ",
      "transliteration": "Al-Bāriʾ",
      "meaning": "The Originator, The Inventor",
      "malayalam": "ഉണ്ടാക്കിയവൻ",
    },
    {
      "arabic": "ٱلْمُصَوِّرُ",
      "transliteration": "Al-Muṣawwir",
      "meaning": "The Fashioner, The Shaper",
      "malayalam": "രൂപം നൽകിയവൻ",
    },
    {
      "arabic": "ٱلْغَفَّارُ",
      "transliteration": "Al-Ghaffār",
      "meaning": "The Constant Forgiver, The Great Forgiver",
      "malayalam": "ഏറെ പൊറുക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْقَهَّارُ",
      "transliteration": "Al-Qahhār",
      "meaning": "The Subduer, The Ever-Dominating",
      "malayalam": "അടക്കിഭരിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْوَهَّابُ",
      "transliteration": "Al-Wahhāb",
      "meaning": "The Giver of Gifts, The Bestower",
      "malayalam": "ഔദാര്യദായകൻ",
    },
    {
      "arabic": "ٱلرَّزَّاقُ",
      "transliteration": "Ar-Razzāq",
      "meaning": "The Ever-Providing, The Constant Provider",
      "malayalam": "ഉപജീവനം നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلْفَتَّاحُ",
      "transliteration": "Al-Fattāḥ",
      "meaning": "The Opener, The Judge",
      "malayalam": "വിജയം നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلْعَلِيمُ",
      "transliteration": "Al-ʿAlīm",
      "meaning": "The All-Knowing, The Omniscient",
      "malayalam": "സർവ്വജ്ഞൻ",
    },
    {
      "arabic": "ٱلْقَابِضُ",
      "transliteration": "Al-Qābiḍ",
      "meaning": "The Withholder, The Restrainer",
      "malayalam": "പിടിച്ചുവെക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْبَاسِطُ",
      "transliteration": "Al-Bāsiṭ",
      "meaning": "The Extender, The Expander",
      "malayalam": "വിശാലമാക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْخَافِضُ",
      "transliteration": "Al-Khāfiḍ",
      "meaning": "The Reducer, The Abaser",
      "malayalam": "താഴ്ത്തുന്നവൻ",
    },
    {
      "arabic": "ٱلرَّافِعُ",
      "transliteration": "Ar-Rāfiʿ",
      "meaning": "The Exalter, The Elevator",
      "malayalam": "ഉയർത്തുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُعِزُّ",
      "transliteration": "Al-Muʿizz",
      "meaning": "The Honourer, The Bestower of Honor",
      "malayalam": "ബഹുമാനം നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُذِلُّ",
      "transliteration": "Al-Mudhill",
      "meaning": "The Dishonourer, The Humiliator",
      "malayalam": "അപമാനിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلسَّمِيعُ",
      "transliteration": "As-Samīʿ",
      "meaning": "The All-Hearing",
      "malayalam": "എല്ലാം കേൾക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْبَصِيرُ",
      "transliteration": "Al-Baṣīr",
      "meaning": "The All-Seeing",
      "malayalam": "എല്ലാം കാണുന്നവൻ",
    },
    {
      "arabic": "ٱلْحَكَمُ",
      "transliteration": "Al-Ḥakam",
      "meaning": "The Judge, The Giver of Justice",
      "malayalam": "വിധികർത്താവ്",
    },
    {
      "arabic": "ٱلْعَدْلُ",
      "transliteration": "Al-‘Adl",
      "meaning": "The Utterly Just",
      "malayalam": "പൂർണ്ണനീതിമാൻ",
    },
    {
      "arabic": "ٱللَّطِيفُ",
      "transliteration": "Al-Laṭīf",
      "meaning": "The Most Gentle, The Subtle One",
      "malayalam": "ലാളിത്യമുള്ളവൻ",
    },
    {
      "arabic": "ٱلْخَبِيرُ",
      "transliteration": "Al-Khabīr",
      "meaning": "The All-Aware, The All-Acquainted",
      "malayalam": "സൂക്ഷ്മജ്ഞാനി",
    },
    {
      "arabic": "ٱلْحَلِيمُ",
      "transliteration": "Al-Ḥalīm",
      "meaning": "The Most Forbearing",
      "malayalam": "സഹനശീലൻ",
    },
    {
      "arabic": "ٱلْعَظِيمُ",
      "transliteration": "Al-ʿAẓīm",
      "meaning": "The Magnificent, The Supreme",
      "malayalam": "മഹാനായവൻ",
    },
    {
      "arabic": "ٱلْغَفُورُ",
      "transliteration": "Al-Ghafūr",
      "meaning": "The Forgiving, The Exceedingly Forgiving",
      "malayalam": "പാപമോചകൻ",
    },
    {
      "arabic": "ٱلشَّكُورُ",
      "transliteration": "Ash-Shakūr",
      "meaning": "The Most Appreciative",
      "malayalam": "നന്ദിയുള്ളവൻ",
    },
    {
      "arabic": "ٱلْعَلِيُّ",
      "transliteration": "Al-ʿAlī",
      "meaning": "The Most High, The Exalted",
      "malayalam": "ഉന്നതൻ",
    },
    {
      "arabic": "ٱلْكَبِيرُ",
      "transliteration": "Al-Kabīr",
      "meaning": "The Greatest, The Most Grand",
      "malayalam": "മഹാൻ",
    },
    {
      "arabic": "ٱلْحَفِيظُ",
      "transliteration": "Al-Ḥafīẓ",
      "meaning": "The Preserver, The All-Heedful and All-Protecting",
      "malayalam": "സംരക്ഷകൻ",
    },
    {
      "arabic": "ٱلْمُقِيتُ",
      "transliteration": "Al-Muqīt",
      "meaning": "The Sustainer, The Maintainer",
      "malayalam": "ആഹാരദാതാവ്",
    },
    {
      "arabic": "ٱلْحَسِيبُ",
      "transliteration": "Al-Ḥasīb",
      "meaning": "The Reckoner",
      "malayalam": "കണക്ക് നോക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْجَلِيلُ",
      "transliteration": "Al-Jalīl",
      "meaning": "The Majestic",
      "malayalam": "മഹത്വമുള്ളവൻ",
    },
    {
      "arabic": "ٱلْكَرِيمُ",
      "transliteration": "Al-Karīm",
      "meaning": "The Most Generous, The Most Noble",
      "malayalam": "ഔദാര്യവാനായവൻ",
    },
    {
      "arabic": "ٱلرَّقِيبُ",
      "transliteration": "Ar-Raqīb",
      "meaning": "The Watchful, The All-Watchful",
      "malayalam": "നിരീക്ഷകൻ",
    },
    {
      "arabic": "ٱلْمُجِيبُ",
      "transliteration": "Al-Mujīb",
      "meaning": "The Responsive, The Answerer",
      "malayalam": "പ്രാർത്ഥന സ്വീകരിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْوَاسِعُ",
      "transliteration": "Al-Wāsiʿ",
      "meaning": "The All-Encompassing, the Boundless",
      "malayalam": "വിശാലനായവൻ",
    },
    {
      "arabic": "ٱلْحَكِيمُ",
      "transliteration": "Al-Ḥakīm",
      "meaning": "The All-Wise",
      "malayalam": "യുക്തിമാൻ",
    },
    {
      "arabic": "ٱلْوَدُودُ",
      "transliteration": "Al-Wadūd",
      "meaning": "The Most Loving",
      "malayalam": "സ്നേഹമയൻ",
    },
    {
      "arabic": "ٱلْمَجِيدُ",
      "transliteration": "Al-Majīd",
      "meaning": "The Glorious, The Most Honorable",
      "malayalam": "മഹത്വമേറിയവൻ",
    },
    {
      "arabic": "ٱلْبَاعِثُ",
      "transliteration": "Al-Bāʿith",
      "meaning": "The Infuser of New Life, The Resurrector",
      "malayalam": "ഉയിർപ്പിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلشَّهِيدُ",
      "transliteration": "As-Shahīd",
      "meaning": "The All-Witnessing",
      "malayalam": "സാക്ഷിയായവൻ",
    },
    {
      "arabic": "ٱلْحَقُّ",
      "transliteration": "Al-Ḥaqq",
      "meaning": "The Absolute Truth",
      "malayalam": "സത്യമായവൻ",
    },
    {
      "arabic": "ٱلْوَكِيلُ",
      "transliteration": "Al-Wakīl",
      "meaning": "The Trustee, The Disposer of Affairs",
      "malayalam": "ചുമതലയേറ്റവൻ",
    },
    {
      "arabic": "ٱلْقَوِيُّ",
      "transliteration": "Al-Qawiyy",
      "meaning": "The All-Strong",
      "malayalam": "ശക്തനായവൻ",
    },
    {
      "arabic": "ٱلْمَتِينُ",
      "transliteration": "Al-Matīn",
      "meaning": "The Firm, The Steadfast",
      "malayalam": "ഉറപ്പുള്ളവൻ",
    },
    {
      "arabic": "ٱلْوَلِيُّ",
      "transliteration": "Al-Waliyy",
      "meaning": "The Protector, The Guardian",
      "malayalam": "രക്ഷാധികാരി",
    },
    {
      "arabic": "ٱلْحَمِيدُ",
      "transliteration": "Al-Ḥamīd",
      "meaning": "The Praiseworthy, The Most Praised",
      "malayalam": "സ്തുത്യർഹൻ",
    },
    {
      "arabic": "ٱلْمُحْصِي",
      "transliteration": "Al-Muḥṣī",
      "meaning": "The All-Enumerating, The Counter",
      "malayalam": "കണക്കെടുക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُبْدِئُ",
      "transliteration": "Al-Mubdiʾ",
      "meaning": "The Originator, The Initiator",
      "malayalam": "ആരംഭിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُعِيدُ",
      "transliteration": "Al-Muʿīd",
      "meaning": "The Restorer, The Reinstater",
      "malayalam": "പുനരാരംഭിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُحْيِي",
      "transliteration": "Al-Muḥyī",
      "meaning": "The Giver of Life",
      "malayalam": "ജീവൻ നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُمِيتُ",
      "transliteration": "Al-Mumīt",
      "meaning": "The Creator of Death",
      "malayalam": "മരണം നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلْحَيُّ",
      "transliteration": "Al-Ḥayy",
      "meaning": "The Ever-Living",
      "malayalam": "എന്നും ജീവിച്ചിരിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْقَيُّومُ",
      "transliteration": "Al-Qayyūm",
      "meaning": "The Sustainer, The Self-Subsisting",
      "malayalam": "സ്വയം നിലനിൽക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْوَاجِدُ",
      "transliteration": "Al-Wājid",
      "meaning": "The Finder, The Perceiver",
      "malayalam": "കണ്ടെത്തുന്നവൻ",
    },
    {
      "arabic": "ٱلْمَاجِدُ",
      "transliteration": "Al-Mājid",
      "meaning": "The Illustrious, The Magnificent",
      "malayalam": "മഹത്വപൂർണൻ",
    },
    {
      "arabic": "ٱلْوَاحِدُ",
      "transliteration": "Al-Wāḥid",
      "meaning": "The One, The Indivisible",
      "malayalam": "ഏകൻ",
    },
    {
      "arabic": "ٱلْأَحَدُ",
      "transliteration": "Al-Aḥad",
      "meaning": "The Unique, The Only One",
      "malayalam": "അദ്വിതീയൻ",
    },
    {
      "arabic": "ٱلصَّمَدُ",
      "transliteration": "Aṣ-Ṣamad",
      "meaning": "The Eternal, The Absolute",
      "malayalam": "അഭയം തേടപ്പെടുന്നവൻ",
    },
    {
      "arabic": "ٱلْقَادِرُ",
      "transliteration": "Al-Qādir",
      "meaning": "The Omnipotent, The All-Able",
      "malayalam": "കഴിവുള്ളവൻ",
    },
    {
      "arabic": "ٱلْمُقْتَدِرُ",
      "transliteration": "Al-Muqtadir",
      "meaning": "The All-Powerful, The Dominant",
      "malayalam": "പരമശക്തൻ",
    },
    {
      "arabic": "ٱلْمُقَدِّمُ",
      "transliteration": "Al-Muqaddim",
      "meaning": "The Expediter, The Promoter",
      "malayalam": "മുന്നിലാക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُؤَخِّرُ",
      "transliteration": "Al-Muʾakhkhir",
      "meaning": "The Delayer, The Postponer",
      "malayalam": "പിന്തിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْأَوَّلُ",
      "transliteration": "Al-Awwal",
      "meaning": "The First, The Foremost",
      "malayalam": "ആദിയിലുള്ളവൻ",
    },
    {
      "arabic": "ٱلْآخِرُ",
      "transliteration": "Al-Ākhir",
      "meaning": "The Last, The Utmost",
      "malayalam": "അന്ത്യത്തിലുള്ളവൻ",
    },
    {
      "arabic": "ٱلظَّاهِرُ",
      "transliteration": "Aẓ-Ẓāhir",
      "meaning": "The Manifest, The All-Surpassing",
      "malayalam": "പ്രകടമായവൻ",
    },
    {
      "arabic": "ٱلْبَاطِنُ",
      "transliteration": "Al-Bāṭin",
      "meaning": "The Hidden One, Knower of the Hidden",
      "malayalam": "അന്തർഭാഗത്തുള്ളവൻ",
    },
    {
      "arabic": "ٱلْوَالِي",
      "transliteration": "Al-Wālī",
      "meaning": "The Sole Governor",
      "malayalam": "ഭരണകർത്താവ്",
    },
    {
      "arabic": "ٱلْمُتَعَالِي",
      "transliteration": "Al-Mutaʿālī",
      "meaning": "The Self-Exalted",
      "malayalam": "ഉന്നതനായവൻ",
    },
    {
      "arabic": "ٱلْبَرُّ",
      "transliteration": "Al-Barr",
      "meaning": "The Source of All Goodness",
      "malayalam": "നന്മയുടെ ഉറവിടം",
    },
    {
      "arabic": "ٱلتَّوَابُ",
      "transliteration": "At-Tawwāb",
      "meaning": "The Ever-Pardoning",
      "malayalam": "പശ്ചാത്താപം സ്വീകരിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْمُنْتَقِمُ",
      "transliteration": "Al-Muntaqim",
      "meaning": "The Avenger",
      "malayalam": "പ്രതികാരം ചെയ്യുന്നവൻ",
    },
    {
      "arabic": "ٱلْعَفُوُّ",
      "transliteration": "Al-ʿAfūw",
      "meaning": "The Pardoner",
      "malayalam": "മാപ്പ് നൽകുന്നവൻ",
    },
    {
      "arabic": "ٱلرَّءُوفُ",
      "transliteration": "Ar-Raʾūf",
      "meaning": "The Most Kind",
      "malayalam": "ദയാപരൻ",
    },
    {
      "arabic": "مَالِكُ ٱلْمُلْكِ",
      "transliteration": "Mālik al-Mulk",
      "meaning": "Master of the Dominion, Owner of the Kingdom",
      "malayalam": "രാജ്യാധിപതി",
    },
    {
      "arabic": "ذُو ٱلْجَلَالِ وَٱلْإِكْرَامِ",
      "transliteration": "Dhū al-Jalāli wa’l-Ikrām",
      "meaning": "Possessor of Glory and Honour",
      "malayalam": "മഹത്വത്തിന്റെ ഉടമ",
    },
    {
      "arabic": "ٱلْمُقْسِطُ",
      "transliteration": "Al-Muqsiṭ",
      "meaning": "The Just One",
      "malayalam": "നീതിമാൻ",
    },
    {
      "arabic": "ٱلْجَامِعُ",
      "transliteration": "Al-Jāmiʿ",
      "meaning": "The Gatherer, the Uniter",
      "malayalam": "ഒരുമിപ്പിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْغَنِيُّ",
      "transliteration": "Al-Ghaniyy",
      "meaning": "The Self-Sufficient, The Wealthy",
      "malayalam": "സ്വയം പര്യാപ്തൻ",
    },
    {
      "arabic": "ٱلْمُغْنِيُ",
      "transliteration": "Al-Mughnī",
      "meaning": "The Enricher",
      "malayalam": "സമ്പന്നനാക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْمَانِعُ",
      "transliteration": "Al-Māniʿ",
      "meaning": "The Withholder",
      "malayalam": "തടയുന്നവൻ",
    },
    {
      "arabic": "ٱلضَّارُّ",
      "transliteration": "Aḍ-Ḍārr",
      "meaning": "The Distresser",
      "malayalam": "ഉപദ്രവിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلنَّافِعُ",
      "transliteration": "An-Nāfiʿ",
      "meaning": "The Propitious, The Benefactor",
      "malayalam": "ഉപകാരം ചെയ്യുന്നവൻ",
    },
    {
      "arabic": "ٱلنُّورُ",
      "transliteration": "An-Nūr",
      "meaning": "The Light",
      "malayalam": "പ്രകാശം",
    },
    {
      "arabic": "ٱلْهَادِي",
      "transliteration": "Al-Hādī",
      "meaning": "The Guide",
      "malayalam": "വഴികാട്ടി",
    },
    {
      "arabic": "ٱلْبَدِيعُ",
      "transliteration": "Al-Badīʿ",
      "meaning": "The Incomparable Originator",
      "malayalam": "അത്ഭുതകരമായി സൃഷ്ടിക്കുന്നവൻ",
    },
    {
      "arabic": "ٱلْبَاقِي",
      "transliteration": "Al-Bāqī",
      "meaning": "The Ever-Lasting",
      "malayalam": "ശാശ്വതൻ",
    },
    {
      "arabic": "ٱلْوَارِثُ",
      "transliteration": "Al-Wāriṯ",
      "meaning": "The Inheritor",
      "malayalam": "അനന്തരാവകാശി",
    },
    {
      "arabic": "ٱلرَّشِيدُ",
      "transliteration": "Ar-Rashīd",
      "meaning": "The Guide to the Right Path",
      "malayalam": "നേർവഴി കാട്ടുന്നവൻ",
    },
    {
      "arabic": "ٱلصَّبُورُ",
      "transliteration": "Aṣ-Ṣabūr",
      "meaning": "The Patient",
      "malayalam": "ക്ഷമാശീലൻ",
    },
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
                      Icons.translate_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Names with Meanings',
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

            // Names List with Meanings
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: asmaulHusna.length,
                separatorBuilder: (_, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final name = asmaulHusna[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row with number badge and Arabic name - FIXED LAYOUT
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Number badge
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withValues(alpha: 0.7),
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
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Arabic name - right aligned with proper wrapping
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    name['arabic']!,
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Amiri',
                                      color: arabicTextColor,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Meaning container - FIXED LAYOUT
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transliteration
                              Text(
                                name['transliteration']!,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 8),
                              // English Meaning
                              Text(
                                '• ${name['meaning']!}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                  fontFamily: 'Poppins',
                                  height: 1.4,
                                ),
                                softWrap: true,
                              ),
                              const SizedBox(height: 6),
                              // Malayalam Meaning
                              Text(
                                '• ${name['malayalam']!}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textSecondary,
                                  fontFamily: 'Noto Sans Malayalam',
                                  height: 1.5,
                                ),
                                softWrap: true,
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
}
