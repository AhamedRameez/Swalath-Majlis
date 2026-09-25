// lib/utils/salah_constants.dart
class SalahConstants {
  static const List<Map<String, String>> defaultSalahs = [
    {'id': '1', 'arabic': 'صلاة الفرض', 'english': 'Fardh Prayer'},
    {'id': '2', 'arabic': 'صلاة التهجد', 'english': 'Tahajjud Prayer'},
    {'id': '3', 'arabic': 'صلاة الاستسقاء', 'english': 'Istisqa Prayer'},
    {'id': '4', 'arabic': 'صلاة الحاجة', 'english': 'Hajah Prayer'},
    {'id': '5', 'arabic': 'صلاة الجنازة', 'english': 'Janazah Prayer'},
    {'id': '6', 'arabic': 'صلاة التسبيح', 'english': 'Tasbih Prayer'},
    {'id': '7', 'arabic': 'صلاة التوبة', 'english': 'Tawbah Prayer'},
    {'id': '8', 'arabic': 'صلاة الوتر', 'english': 'Witr Prayer'},
    {'id': '9', 'arabic': 'صلاة الكسوف', 'english': 'Kusuf Prayer'},
    {'id': '10', 'arabic': 'صلاة الشكر', 'english': 'Shukr Prayer'},
    {'id': '11', 'arabic': 'صلاة الضحى', 'english': 'Duha Prayer'},
    {'id': '12', 'arabic': 'صلاة العيد', 'english': 'Eid Prayer'},
  ];

  // 🖼️ LIST IMAGES - Used only in list view (single image per Salah)
  static const Map<String, List<Map<String, String>>> listImagesMap = {
    'صلاة الفرض': [
      {'path': 'assets/namaz/farl_list.png', 'name': 'Fardh'},
    ],
    'صلاة التهجد': [
      {'path': 'assets/images/salah_tahajjud_list.png', 'name': 'Tahajjud'},
    ],
    'صلاة الاستسقاء': [
      {'path': 'assets/images/salah_istisqa_list.png', 'name': 'Istisqa'},
    ],
    'صلاة الحاجة': [
      {'path': 'assets/images/salah_hajah_list.png', 'name': 'Hajah'},
    ],
    'صلاة الجنازة': [
      {'path': 'assets/namaz/janaza_list.png', 'name': 'Janazah'},
    ],
    'صلاة التسبيح': [
      {'path': 'assets/images/salah_tasbih_list.png', 'name': 'Tasbih'},
    ],
    'صلاة التوبة': [
      {'path': 'assets/images/salah_tawbah_list.png', 'name': 'Tawbah'},
    ],
    'صلاة الوتر': [
      {'path': 'assets/images/salah_witr_list.png', 'name': 'Witr'},
    ],
    'صلاة الكسوف': [
      {'path': 'assets/images/salah_kusuf_list.png', 'name': 'Kusuf'},
    ],
    'صلاة الشكر': [
      {'path': 'assets/images/salah_shukr_list.png', 'name': 'Shukr'},
    ],
    'صلاة الضحى': [
      {'path': 'assets/images/salah_duha_list.png', 'name': 'Duha'},
    ],
    'صلاة العيد': [
      {'path': 'assets/images/salah_eid_list.png', 'name': 'Eid'},
    ],
  };

  // 🖼️ DETAIL IMAGES - Used in detail view (multiple images per Salah)
  static const Map<String, List<Map<String, String>>> detailImagesMap = {
    'صلاة الفرض': [
      {'path': 'assets/namaz/farl1.png', 'name': 'Fardh 1'},
      {'path': 'assets/namaz/farl2.png', 'name': 'Fardh 2'},
      {'path': 'assets/namaz/farl3.png', 'name': 'Fardh 3'},
      {'path': 'assets/namaz/farl4.png', 'name': 'Fardh 4'},
      {'path': 'assets/namaz/farl5.png', 'name': 'Fardh 5'},
      {'path': 'assets/namaz/farl6.png', 'name': 'Fardh 6'},
      {'path': 'assets/namaz/farl7.png', 'name': 'Fardh 7'},
      {'path': 'assets/namaz/farl8.png', 'name': 'Fardh 8'},
      {'path': 'assets/namaz/farl9.png', 'name': 'Fardh 9'},
    ],
    'صلاة التهجد': [
      {'path': 'assets/images/salah_tahajjud_1.png', 'name': 'Tahajjud 1'},
      {'path': 'assets/images/salah_tahajjud_2.png', 'name': 'Tahajjud 2'},
    ],
    'صلاة الاستسقاء': [
      {'path': 'assets/images/salah_istisqa_1.png', 'name': 'Istisqa 1'},
      {'path': 'assets/images/salah_istisqa_2.png', 'name': 'Istisqa 2'},
    ],
    'صلاة الحاجة': [
      {'path': 'assets/images/salah_hajah_1.png', 'name': 'Hajah 1'},
      {'path': 'assets/images/salah_hajah_2.png', 'name': 'Hajah 2'},
    ],
    'صلاة الجنازة': [
      {'path': 'assets/namaz/janaza.jpeg', 'name': 'Janazah 1'},
      {'path': 'assets/namaz/janaza1.png', 'name': 'Janazah 2'},
    ],
    'صلاة التسبيح': [
      {'path': 'assets/images/salah_tasbih_1.png', 'name': 'Tasbih 1'},
      {'path': 'assets/images/salah_tasbih_2.png', 'name': 'Tasbih 2'},
    ],
    'صلاة التوبة': [
      {'path': 'assets/images/salah_tawbah_1.png', 'name': 'Tawbah 1'},
      {'path': 'assets/images/salah_tawbah_2.png', 'name': 'Tawbah 2'},
    ],
    'صلاة الوتر': [
      {'path': 'assets/images/salah_witr_1.png', 'name': 'Witr 1'},
      {'path': 'assets/images/salah_witr_2.png', 'name': 'Witr 2'},
    ],
    'صلاة الكسوف': [
      {'path': 'assets/images/salah_kusuf_1.png', 'name': 'Kusuf 1'},
      {'path': 'assets/images/salah_kusuf_2.png', 'name': 'Kusuf 2'},
    ],
    'صلاة الشكر': [
      {'path': 'assets/namaz/tasbeeh.png', 'name': 'Shukr 1'},
    ],
    'صلاة الضحى': [
      {'path': 'assets/images/salah_duha_1.png', 'name': 'Duha 1'},
      {'path': 'assets/images/salah_duha_2.png', 'name': 'Duha 2'},
    ],
    'صلاة العيد': [
      {'path': 'assets/images/salah_eid_1.png', 'name': 'Eid 1'},
      {'path': 'assets/images/salah_eid_2.png', 'name': 'Eid 2'},
      {'path': 'assets/images/salah_eid_3.png', 'name': 'Eid 3'},
    ],
  };

  // Default images
  static const String defaultImage = 'assets/images/salah_default.png';
  static const String defaultListImage = 'assets/images/salah_default_list.png';

  // Helper methods
  static List<Map<String, String>> getListImagesForSalah(String salahName) {
    if (listImagesMap.containsKey(salahName)) {
      return listImagesMap[salahName]!;
    }
    return [
      {'path': defaultListImage, 'name': 'Default'},
    ];
  }

  static List<Map<String, String>> getDetailImagesForSalah(String salahName) {
    if (detailImagesMap.containsKey(salahName)) {
      return detailImagesMap[salahName]!;
    }
    return [
      {'path': defaultImage, 'name': 'Default'},
    ];
  }

  // Backward compatibility
  static List<Map<String, String>> getAllImagesForSalah(String salahName) {
    return getDetailImagesForSalah(salahName);
  }

  static Map<String, String>? getFirstImageForSalah(String salahName) {
    final images = getDetailImagesForSalah(salahName);
    return images.isNotEmpty ? images.first : null;
  }
}
