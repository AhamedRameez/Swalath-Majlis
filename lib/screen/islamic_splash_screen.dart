// lib/screens/islamic_splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'user_dashboard.dart';
import '../services/dua_cache_service.dart';

class IslamicSplashScreen extends StatefulWidget {
  const IslamicSplashScreen({super.key});

  @override
  State<IslamicSplashScreen> createState() => _IslamicSplashScreenState();
}

class _IslamicSplashScreenState extends State<IslamicSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Image zoom animation (0-2 seconds)
    _zoomAnimation = Tween<double>(begin: 1.5, end: 1.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.67,
          curve: Curves.easeInOut,
        ), // 0-2 seconds
      ),
    );

    // Text animation (starts at 1.5 seconds, ends at 3 seconds)
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut), // 1.5-3 seconds
      ),
    );

    _controller.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Minimum display time of 3.5 seconds
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 3500)),
      _performBackgroundTasks(),
    ]);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserDashboard()),
      );
    }
  }

  Future<void> _performBackgroundTasks() async {
    try {
      await DuaCacheService.refreshCacheIfNeeded();
      print('✅ Dua cache refreshed successfully');
    } catch (e) {
      print('⚠️ Cache refresh failed: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image with zoom animation (0-2 seconds)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _zoomAnimation.value,
                  child: Image.asset(
                    'assets/images/splash.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: const Color.fromARGB(20, 42, 172, 131),
                        child: const Icon(
                          Icons.mosque_rounded,
                          color: Color.fromARGB(255, 42, 172, 131),
                          size: 80,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 50),

            // Text with fade-in animation (1.5-3 seconds)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _textOpacityAnimation.value)),
                    child: const Text(
                      'Swalath Majlis',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color.fromARGB(255, 42, 172, 131),
                        fontFamily: 'Poppins',
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
