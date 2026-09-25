// lib/services/dua_cache_service.dart
import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dua_cache_model.dart';

class DuaCacheService {
  static const String boxName = 'dua_cache';
  static Box<DuaCache>? _box;

  // Initialize Hive box
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      // Register adapter
      Hive.registerAdapter(DuaCacheAdapter());

      // Try to open the box
      try {
        _box = await Hive.openBox<DuaCache>(boxName);
      } catch (e) {
        // If opening fails, delete and recreate
        print('⚠️ Failed to open box, deleting and recreating: $e');
        await Hive.deleteBoxFromDisk(boxName);
        _box = await Hive.openBox<DuaCache>(boxName);
      }
    } else {
      _box = Hive.box<DuaCache>(boxName);
    }
  }

  // ✅ NEW: Get all unique categories
  static List<String> getAllCategories() {
    final box = _box;
    if (box == null || box.isEmpty) return [];

    final Set<String> categories = {};
    for (var dua in box.values) {
      if (dua.category != null && dua.category!.isNotEmpty) {
        categories.add(dua.category!);
      }
    }
    return categories.toList()..sort();
  }

  // ✅ NEW: Get duas by category
  static List<DuaCache> getDuasByCategory(String category) {
    final box = _box;
    if (box == null || box.isEmpty) return [];

    return box.values.where((dua) => dua.category == category).toList();
  }

  // ✅ NEW: Get uncategorized duas
  static List<DuaCache> getUncategorizedDuas() {
    final box = _box;
    if (box == null || box.isEmpty) return [];

    return box.values
        .where((dua) => dua.category == null || dua.category!.isEmpty)
        .toList();
  }

  // ✅ NEW: Get count of duas in a category
  static int getCategoryCount(String category) {
    final box = _box;
    if (box == null || box.isEmpty) return 0;

    return box.values.where((dua) => dua.category == category).length;
  }

  // Get all cached duas (unchanged)
  static List<DuaCache> getAllCachedDuas() {
    return _box?.values.toList() ?? [];
  }

  // Check if cache is empty (unchanged)
  static bool isCacheEmpty() {
    return _box?.isEmpty ?? true;
  }

  // Check when cache was last updated (unchanged)
  static DateTime? getLastCacheTime() {
    if (_box?.isEmpty ?? true) return null;

    final latest = _box?.values
        .map((dua) => dua.cachedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return latest;
  }

  // Check if cache is stale (unchanged)
  static bool isCacheStale() {
    final lastUpdate = getLastCacheTime();
    if (lastUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    return difference.inDays > 1;
  }

  // Fetch from Firebase and cache (UPDATED to include category)
  static Future<void> fetchAndCacheFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('swalathmajlis')
          .doc('iM6QRMlgUuWNbUdgQ0')
          .collection('duas')
          .orderBy('createdAt', descending: true)
          .get();

      // Clear old cache
      await _box?.clear();

      // Cache new data with categories
      for (var doc in snapshot.docs) {
        final duaCache = DuaCache.fromFirestore(doc.id, doc.data());
        await _box?.put(doc.id, duaCache);
      }

      print('✅ Dua cache updated: ${snapshot.docs.length} duas cached');

      // Log categories found
      final categories = getAllCategories();
      print('📁 Categories found: $categories');
    } catch (e) {
      print('❌ Error caching duas: $e');
    }
  }

  // Get cached dua by ID (unchanged)
  static DuaCache? getCachedDua(String id) {
    return _box?.get(id);
  }

  // Clear cache (unchanged)
  static Future<void> clearCache() async {
    await _box?.clear();
  }

  // Check if we should refresh cache (unchanged)
  static Future<bool> shouldRefreshCache() async {
    await init();
    return isCacheEmpty() || isCacheStale();
  }

  // Refresh cache if needed (unchanged)
  static Future<void> refreshCacheIfNeeded() async {
    if (await shouldRefreshCache()) {
      await fetchAndCacheFromFirebase();
    }
  }
}
