// lib/models/dua_cache_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'dua_cache_model.g.dart'; // For Hive code generation

@HiveType(typeId: 2) // ⚠️ CHANGED FROM 1 TO 2 (to avoid conflicts)
class DuaCache {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String heading;

  @HiveField(2)
  final String arabic;

  @HiveField(3)
  final String english;

  @HiveField(4)
  final String malayalam;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String author;

  @HiveField(7)
  final DateTime cachedAt;

  @HiveField(8)
  final DateTime? updatedAt;

  // ✅ NEW: Add category as optional field (won't break existing code)
  @HiveField(9)
  final String? category;

  DuaCache({
    required this.id,
    required this.heading,
    required this.arabic,
    required this.english,
    required this.malayalam,
    required this.description,
    required this.author,
    required this.cachedAt,
    this.updatedAt,
    this.category, // ✅ NEW: Add optional parameter
  });

  factory DuaCache.fromFirestore(String id, Map<String, dynamic> data) {
    return DuaCache(
      id: id,
      heading: data['heading'] ?? '',
      arabic: data['arabic'] ?? '',
      english: data['english'] ?? '',
      malayalam: data['malayalam'] ?? '',
      description: data['description'] ?? '',
      author: data['author'] ?? '',
      cachedAt: DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      // ✅ NEW: Get category from Firestore (may be null)
      category: data['category']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'heading': heading,
      'arabic': arabic,
      'english': english,
      'malayalam': malayalam,
      'description': description,
      'author': author,
      // ✅ Note: category is NOT included in toMap()
      // This preserves existing functionality
    };
  }
}
