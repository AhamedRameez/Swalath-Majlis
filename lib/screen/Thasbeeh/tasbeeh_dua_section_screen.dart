import 'package:flutter/material.dart';
import 'dua_select_screen.dart';
import 'ramzandua_select_screen.dart';

class TasbeehDuaSectionScreen extends StatefulWidget {
  const TasbeehDuaSectionScreen({super.key});

  @override
  State<TasbeehDuaSectionScreen> createState() =>
      _TasbeehDuaSectionScreenState();
}

class _TasbeehDuaSectionScreenState extends State<TasbeehDuaSectionScreen> {
  // Color scheme matching TasbeehScreen
  static const Color primaryColor = Color.fromARGB(255, 42, 172, 131);
  static const Color accentColor = Color(0xFFD4AF37);
  static const Color backgroundColor = Color(0xFFFAF9F6);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF888888);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Select Dua Source',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            letterSpacing: 0.8,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Regular Duas Card
            _buildSelectionCard(
              icon: Icons.menu_book_rounded,
              title: 'Regular Duas',
              description: 'Select from general duas collection',
              color: primaryColor,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DuaSelectScreen()),
                );
                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
            ),

            const SizedBox(height: 20),

            // Ramadan Duas Card
            _buildSelectionCard(
              icon: Icons.mosque_rounded,
              title: 'Ramadan Duas',
              description: 'Select from special Ramadan duas',
              color: accentColor,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RamzanDuaSelectScreen(),
                  ),
                );
                if (result != null) {
                  Navigator.pop(context, result);
                }
              },
            ),

            const SizedBox(height: 40),

            // Or use custom text option
            TextButton.icon(
              onPressed: () {
                // Just go back without selection - user will use custom text
                Navigator.pop(context);
              },
              icon: const Icon(Icons.edit_note_rounded, color: textTertiary),
              label: const Text(
                'Use custom text instead',
                style: TextStyle(
                  color: textTertiary,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dividerColor.withValues(alpha: 0.8), width: 1),
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Icon with colored background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: color.withValues(alpha: 0.8),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
