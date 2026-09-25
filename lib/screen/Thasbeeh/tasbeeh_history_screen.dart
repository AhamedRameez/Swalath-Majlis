// lib/screen/tasbeeh_history_screen.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class TasbeehHistoryScreen extends StatelessWidget {
  const TasbeehHistoryScreen({super.key});

  // Your specified color scheme
  static const Color primaryColor =
      Color.fromARGB(255, 42, 172, 131); // Deep Teal Green
  static const Color accentColor = Color(0xFFD4AF37); // Warm Gold
  static const Color backgroundColor = Color(0xFFFAF9F6); // Warm White
  static const Color textPrimary = Color(0xFF333333); // Dark Gray
  static const Color textSecondary = Color(0xFF666666); // Medium Gray
  static const Color textTertiary = Color(0xFF888888); // Light Gray
  static const Color cardColor = Color(0xFFFFFFFF); // Pure White
  static const Color dividerColor = Color(0xFFE0E0E0); // Light Gray Divider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Tasbeeh History',
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
        actionsIconTheme: const IconThemeData(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever_rounded),
            onPressed: () {
              Hive.box('tasbeeh_history').clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All history cleared'),
                  backgroundColor: primaryColor,
                ),
              );
            },
            tooltip: 'Clear All History',
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('tasbeeh_history').listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_toggle_off_rounded,
                        color: primaryColor.withValues(alpha: 0.6),
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No History Found',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your saved tasbeehs will appear here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: box.length,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item =
                    box.getAt(box.length - 1 - index); // Show newest first
                final date = DateFormat('dd MMM yyyy, hh:mm a')
                    .format(DateTime.parse(item['time']));

                return _buildHistoryCard(
                  index: box.length - 1 - index,
                  name: item['name'] ?? 'Unnamed Tasbeeh',
                  count: item['count'] ?? 0,
                  dua: item['dua'],
                  duaArabic: item['duaArabic'], // We need to save Arabic too
                  date: date,
                  box: box,
                  context: context,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required int index,
    required String name,
    required int count,
    required String? dua,
    required String? duaArabic, // New parameter
    required String date,
    required Box box,
    required BuildContext context,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dividerColor.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number badge with accent gold
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tasbeeh name
                    Text(
                      name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        height: 1.4,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Dua if available
                    if (dua != null && dua.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 12,
                            color: textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dua,
                              style: const TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                                fontFamily: 'Poppins',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Count and date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.countertops_rounded,
                                size: 12,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$count counts',
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            date,
                            style: const TextStyle(
                              color: textTertiary,
                              fontSize: 11,
                              fontFamily: 'Poppins',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Continue button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 18,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        // Return both count and dua data
                        Navigator.pop(context, {
                          'count': count,
                          'duaName': dua,
                          'duaArabic': duaArabic,
                        });
                      },
                      tooltip: 'Continue from $count',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Delete button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Tasbeeh'),
                            content: const Text('Delete this tasbeeh record?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  box.deleteAt(index);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tasbeeh deleted'),
                                      backgroundColor: primaryColor,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                      tooltip: 'Delete',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
