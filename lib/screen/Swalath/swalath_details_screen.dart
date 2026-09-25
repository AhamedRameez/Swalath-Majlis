// lib/screen/user/swalath_details_screen.dart
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SwalathDetailScreen extends StatefulWidget {
  final Map<String, dynamic> swalathData;
  final String docId;

  const SwalathDetailScreen({
    super.key,
    required this.swalathData,
    required this.docId,
  });

  @override
  State<SwalathDetailScreen> createState() => _SwalathDetailScreenState();
}

class _SwalathDetailScreenState extends State<SwalathDetailScreen> {
  // Font size variables
  double _arabicFontSize = 19.0;
  static const double _minFontSize = 16.0;
  static const double _maxFontSize = 32.0;

  // Font adjustment panel visibility
  bool _showFontAdjustPanel = false;

  // Counter variables
  int _counter = 0;
  bool _showCounter = false;

  // 🆕 Video visibility
  bool _showVideo = false;

  // Draggable counter position
  Offset _counterPosition = const Offset(0, 0);
  bool _isDragging = false;
  bool _isPositionInitialized = false;

  void _incrementCounter() => setState(() => _counter++);
  void _resetCounter() => setState(() => _counter = 0);

  void _toggleCounter() {
    setState(() {
      _showCounter = !_showCounter;
      if (_showCounter && !_isPositionInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            setState(() {
              _counterPosition = Offset(
                (screenWidth - 200) / 2,
                (screenHeight - 100) / 2,
              );
              _isPositionInitialized = true;
            });
          }
        });
      }
    });
  }

  // 🆕 Toggle video visibility
  void _toggleVideo() {
    setState(() {
      _showVideo = !_showVideo;
    });
  }

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

  void _toggleFontAdjustPanel() {
    setState(() {
      _showFontAdjustPanel = !_showFontAdjustPanel;
    });
  }

  void _resetFontSize() {
    setState(() {
      _arabicFontSize = 19.0;
      _showFontAdjustPanel = false;
    });
  }

  String _getString(String key) {
    return widget.swalathData[key]?.toString() ?? '';
  }

  List<String> _splitIntoLines(String text) {
    if (text.isEmpty) return [];

    List<String> lines = text.split('\n');

    if (lines.length <= 1) {
      lines = text.split(RegExp(r'[.،؛]'));
    }

    return lines
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();
  }

  // Extract YouTube video ID from URL
  String _extractVideoId(String url) {
    if (url.isEmpty) return '';

    final patterns = [
      r'(?:youtube\.com\/watch\?v=)([\w-]+)',
      r'(?:youtu\.be\/)([\w-]+)',
      r'(?:youtube\.com\/embed\/)([\w-]+)',
      r'(?:youtube\.com\/shorts\/)([\w-]+)',
      r'(?:youtube\.com\/v\/)([\w-]+)',
      r'(?:youtube\.com\/live\/)([\w-]+)',
    ];

    for (final pattern in patterns) {
      final match = RegExp(pattern).firstMatch(url);
      if (match != null && match.group(1) != null) {
        return match.group(1)!;
      }
    }

    if (RegExp(r'^[\w-]{11}$').hasMatch(url)) {
      return url;
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    final title = _getString('title');
    final description = _getString('description');
    final style = _getString('style');
    final arabic = _getString('arabic');
    final malayalam = _getString('malayalam');
    final dua = _getString('dua');
    final youtubeUrl = _getString('youtubeUrl');

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8ED),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.format_size_rounded,
              color: _showFontAdjustPanel ? accentColor : Colors.white,
              size: 22,
            ),
            onPressed: _toggleFontAdjustPanel,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Main content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 80,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Description
                        if (description.isNotEmpty) ...[
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                description,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Poppins',
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (arabic.isNotEmpty) ...[
                          if (style == 'alternating')
                            _buildAlternatingStyle(arabic)
                          else
                            _buildParagraphStyle(arabic),
                        ],

                        if (malayalam.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.translate_rounded,
                                      size: 16,
                                      color: primaryColor,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Malayalam ',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  malayalam,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.7,
                                    fontFamily: 'Noto Sans Malayalam',
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (dua.isNotEmpty) ...[
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withValues(alpha: 0.05),
                                  accentColor.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.favorite_rounded,
                                      color: accentColor,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Dua',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  dua,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: _arabicFontSize,
                                    height: 1.8,
                                    fontFamily: 'Scheherazade',
                                    color: arabicTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // 🆕 YouTube Video Section (only shows when _showVideo is true)
                        if (youtubeUrl.isNotEmpty && _showVideo) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.video_library_rounded,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Video',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildYouTubePlayer(youtubeUrl),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 30),

                        // Footer
                        Center(
                          child: Column(
                            children: [
                              Container(
                                height: 4,
                                width: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withValues(alpha: 0.6),
                                      accentColor.withValues(alpha: 0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'اللهم تقبل منا',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Amiri',
                                  color: textTertiary,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),

                        // EXTRA BOTTOM SPACE
                        const SizedBox(height: 150),
                      ],
                    ),
                  ),
                ),
              ),

              // Counter toggle button at bottom-left
              Positioned(
                left: 30,
                bottom: 50,
                child: Material(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  child: InkWell(
                    onTap: _toggleCounter,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dividerColor.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _showCounter
                            ? Icons.close_rounded
                            : Icons.calculate_rounded,
                        color: _showCounter ? textTertiary : primaryColor,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

              // 🆕 Video toggle button at bottom-right
              if (youtubeUrl.isNotEmpty)
                Positioned(
                  right: 30,
                  bottom: 50,
                  child: Material(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                    child: InkWell(
                      onTap: _toggleVideo,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showVideo
                                ? Colors.red
                                : Colors.red.withValues(alpha: 0.5),
                            width: _showVideo ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          _showVideo
                              ? Icons.close_rounded
                              : Icons.video_library_rounded,
                          color: Colors.red,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),

              // Draggable Counter
              if (_showCounter && _isPositionInitialized)
                Positioned(
                  left: _counterPosition.dx,
                  top: _counterPosition.dy,
                  child: Draggable(
                    feedback: _buildWhiteTransparentCounterWidget(
                      isDragging: true,
                    ),
                    childWhenDragging: Container(),
                    onDragEnd: (details) {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    onDraggableCanceled: (velocity, offset) {
                      setState(() {
                        _isDragging = false;
                        _counterPosition = offset;
                      });
                    },
                    child: GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _isDragging = true;
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _counterPosition += details.delta;
                          _counterPosition = Offset(
                            _counterPosition.dx.clamp(
                              0,
                              MediaQuery.of(context).size.width - 200,
                            ),
                            _counterPosition.dy.clamp(
                              0,
                              MediaQuery.of(context).size.height - 100,
                            ),
                          );
                        });
                      },
                      child: _buildWhiteTransparentCounterWidget(
                        isDragging: false,
                      ),
                    ),
                  ),
                ),

              // Font adjustment panel (top-right)
              if (_showFontAdjustPanel)
                Positioned(
                  top: kToolbarHeight + 5,
                  right: 16,
                  child: Material(
                    elevation: 10,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dividerColor.withValues(alpha: 0.8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Adjust Font Size',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${_arabicFontSize.toInt()}px',
                                      style: const TextStyle(
                                        color: primaryColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _toggleFontAdjustPanel,
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(
                                Icons.text_decrease,
                                size: 16,
                                color: textTertiary,
                              ),
                              Expanded(
                                child: Slider(
                                  value: _arabicFontSize,
                                  min: _minFontSize,
                                  max: _maxFontSize,
                                  divisions:
                                      (_maxFontSize - _minFontSize).toInt(),
                                  activeColor: primaryColor,
                                  inactiveColor: dividerColor,
                                  thumbColor: primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      _arabicFontSize = value;
                                    });
                                  },
                                ),
                              ),
                              const Icon(
                                Icons.text_increase,
                                size: 16,
                                color: textTertiary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: TextButton.icon(
                              onPressed: _resetFontSize,
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    accentColor.withValues(alpha: 0.08),
                                foregroundColor: accentColor,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Reset to Default',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // YouTube Player Widget
  Widget _buildYouTubePlayer(String url) {
    final videoId = _extractVideoId(url);

    if (videoId.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        color: Colors.grey[100],
        child: const Center(
          child: Text(
            'Invalid YouTube URL',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        // showLiveFullscreenButton: false,
        enableCaption: false,
      ),
    );

    return YoutubePlayer(
      controller: controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.red,
      progressColors: const ProgressBarColors(
        playedColor: Colors.red,
        handleColor: Colors.redAccent,
      ),
      bottomActions: const [
        CurrentPosition(),
        ProgressBar(isExpanded: true),
        RemainingDuration(),
        FullScreenButton(),
      ],
    );
  }

  // White Transparent Counter Widget with RETRY button
  Widget _buildWhiteTransparentCounterWidget({required bool isDragging}) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        decoration: BoxDecoration(
          color: isDragging
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: isDragging
                  ? primaryColor.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: isDragging ? 15 : 8,
              offset: Offset(0, isDragging ? 5 : 2),
              spreadRadius: isDragging ? 2 : 0,
            ),
          ],
          border: Border.all(
            color: isDragging
                ? primaryColor.withValues(alpha: 0.8)
                : primaryColor.withValues(alpha: 0.4),
            width: isDragging ? 2 : 1.5,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _resetCounter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$_counter',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    shadows: [
                      Shadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: _incrementCounter,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: primaryColor,
                    size: 22,
                    weight: 800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlternatingStyle(String arabic) {
    final lines = _splitIntoLines(arabic);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: arabicTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: arabicTextColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: [
          const Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Scheherazade',
                color: Color(0xFF2C5530),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(lines.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              alignment:
                  index % 2 == 0 ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                lines[index],
                textDirection: TextDirection.rtl,
                textAlign: index % 2 == 0 ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  fontSize: _arabicFontSize,
                  height: 1.9,
                  fontFamily: 'Amiri',
                  color: arabicTextColor,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParagraphStyle(String arabic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: arabicTextColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: arabicTextColor.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        children: [
          const Center(
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'Amiri',
                color: Color(0xFF2C5530),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            arabic,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: _arabicFontSize,
              height: 1.9,
              fontFamily: 'Scheherazade',
              color: arabicTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
