import 'package:hive/hive.dart';

class HiveService {
  // Existing
  static const String tasbeehBox = 'tasbeeh_history';

  // Quran cache
  static const String quranSurahBox = 'quran_surahs';
  static const String quranAyahBox = 'quran_ayahs';

  // ---------------- TASBEEH ----------------
  static Future<Box> getTasbeehBox() async {
    if (!Hive.isBoxOpen(tasbeehBox)) {
      return await Hive.openBox(tasbeehBox);
    }
    return Hive.box(tasbeehBox);
  }

  // ---------------- QURAN ----------------
  static Future<Box> getQuranSurahBox() async {
    if (!Hive.isBoxOpen(quranSurahBox)) {
      return await Hive.openBox(quranSurahBox);
    }
    return Hive.box(quranSurahBox);
  }

  static Future<Box> getQuranAyahBox() async {
    if (!Hive.isBoxOpen(quranAyahBox)) {
      return await Hive.openBox(quranAyahBox);
    }
    return Hive.box(quranAyahBox);
  }
}
