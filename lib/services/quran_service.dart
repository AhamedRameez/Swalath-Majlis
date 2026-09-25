import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'hive_service.dart';

class QuranService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------- SURAH LIST ----------------
  Future<List<Map<String, dynamic>>> fetchSurahs() async {
    final Box surahBox = await HiveService.getQuranSurahBox();

    // ✅ OFFLINE FIRST
    if (surahBox.isNotEmpty) {
      return surahBox.values.cast<Map<String, dynamic>>().toList();
    }

    // 🔄 FIRESTORE FETCH
    final snapshot = await _firestore
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('quran')
        .orderBy('surahNumber')
        .get();

    for (var doc in snapshot.docs) {
      surahBox.put(doc.id, {
        'id': doc.id,
        'number': doc['surahNumber'],
        'name': doc['surahName'],
      });
    }

    return surahBox.values.cast<Map<String, dynamic>>().toList();
  }

  // ---------------- AYAH LIST ----------------
  Future<List<Map<String, dynamic>>> fetchAyahs(String surahId) async {
    final Box ayahBox = await HiveService.getQuranAyahBox();
    final String key = 'ayahs_$surahId';

    // ✅ OFFLINE FIRST
    if (ayahBox.containsKey(key)) {
      return List<Map<String, dynamic>>.from(ayahBox.get(key));
    }

    // 🔄 FIRESTORE FETCH
    final doc = await _firestore
        .collection('swalathmajlis')
        .doc('iM6QRMlgUuWNbUdgQ0')
        .collection('quran')
        .doc(surahId)
        .get();

    final List<Map<String, dynamic>> ayahs = [];
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      ayahs.add({
        'number': 1,
        'text': data['arabicText'] ?? '',
      });
    }

    ayahBox.put(key, ayahs);
    return ayahs;
  }

  // ---------------- CLEAR CACHE (OPTIONAL) ----------------
  Future<void> clearQuranCache() async {
    final surahBox = await HiveService.getQuranSurahBox();
    final ayahBox = await HiveService.getQuranAyahBox();
    await surahBox.clear();
    await ayahBox.clear();
  }
}
