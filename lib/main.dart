// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screen/islamic_splash_screen.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/dua_cache_service.dart';
import 'services/announcement_service.dart'; // 🔥 ADD THIS LINE

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Firebase Init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 🔥 Hive Init (for OFFLINE Duas / Quran text)
  await Hive.initFlutter();

  // 🆕 SAFE MIGRATION: Delete old cache box if it exists to prevent adapter conflicts
  // This runs ONLY once when upgrading to the new model
  try {
    // Check if box exists before trying to delete
    final boxExists = await Hive.boxExists('dua_cache');
    if (boxExists) {
      // Close box if it's open
      if (Hive.isBoxOpen('dua_cache')) {
        await Hive.box('dua_cache').close();
      }
      // Delete the box
      await Hive.deleteBoxFromDisk('dua_cache');
      print('✅ Successfully deleted old dua_cache box for migration');
    }
  } catch (e) {
    // If any error occurs, just continue - we can still create a new box
    print('⚠️ Cache migration note: $e');
  }

  // Initialize Dua Cache Service FIRST (this will create new box with updated model)
  await DuaCacheService.init();

  // Open required boxes
  await Hive.openBox('tasbeeh_history'); // For Tasbeeh history
  await Hive.openBox('quran_surahs'); // For Quran (future use)
  await Hive.openBox('quran_bookmark'); // For last read ayah
  await Hive.openBox('quran_ayahs'); // For Quran ayahs

  AnnouncementService(); // Initialize singleton

  // Try to refresh cache in background (won't block app startup)
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    try {
      await DuaCacheService.refreshCacheIfNeeded();
      print('✅ Dua cache refreshed successfully');
    } catch (e) {
      print('⚠️ Cache refresh failed (might be offline): $e');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<AuthService>(create: (_) => AuthService())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Swalath Majlis',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
          fontFamily: 'Poppins',
        ),
        home: const IslamicSplashScreen(),
      ),
    );
  }
}
