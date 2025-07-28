import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:literacy_app/models/alphabet_model.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  _AlphabetPageState createState() => _AlphabetPageState();
}

class _AlphabetPageState extends State<AlphabetPage> {
  List<AlphabetItem> alphabetList = [];
  int currentIndex = 0;
  bool isLoading = true;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: currentIndex,
      viewportFraction: 1.0,
    );
    loadData();
  }

  Future<void> loadData() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/jsons/alphabet.json');
      List<dynamic> jsonData = json.decode(jsonString);
      alphabetList =
          jsonData.map((item) => AlphabetItem.fromJson(item)).toList();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading JSON: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Center(
            child: LoadingOverlay(
              isLoading: true,
              message: 'Sigini kalan...',
              child: Container(),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Sigini kalan',
        showLogo: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ɲɛtaa',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        Text(
                          '${currentIndex + 1} / ${alphabetList.length}',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.wisdomTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / alphabetList.length,
                      backgroundColor: AppColors.lightGrey,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ],
                ),
              ),
            ),
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: PageView.builder(
                  controller: pageController,
                  itemCount: alphabetList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return AlphabetCard(item: alphabetList[index]);
                  },
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.primaryCard.copyWith(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavigationButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: currentIndex > 0
                        ? () {
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                  _buildNavigationButton(
                    icon: Icons.arrow_forward_ios,
                    onPressed: currentIndex < alphabetList.length - 1
                        ? () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: 120,
      height: 56,
      decoration: AppDecorations.primaryButtonDecoration.copyWith(
        gradient: onPressed != null
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [AppColors.lightGrey, AppColors.lightGrey]),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Center(
            child: Icon(
              icon,
              color: onPressed != null
                  ? AppColors.pureWhite
                  : AppColors.mediumGrey,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class AlphabetCard extends StatefulWidget {
  final AlphabetItem item;

  const AlphabetCard({super.key, required this.item});

  @override
  _AlphabetCardState createState() => _AlphabetCardState();
}

class _AlphabetCardState extends State<AlphabetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool isPlaying = false;
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();

    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  Future<void> playAudio() async {
    if (isPlaying) {
      await _player.stop();
    } else {
      await _player.play(AssetSource(widget.item.audio1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: playAudio,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            widget.item.image,
                            fit: BoxFit.cover,
                          ),
                          // Gradient overlay
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.4),
                                ],
                              ),
                            ),
                          ),
                          //   // Audio button
                          //   Positioned(
                          //     bottom: 16,
                          //     right: 16,
                          //     child: GestureDetector(
                          //       onTap: playAudio,
                          //       child: Container(
                          //         padding: const EdgeInsets.all(12),
                          //         decoration: BoxDecoration(
                          //           color: Colors.black.withOpacity(0.8),
                          //           shape: BoxShape.circle,
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: Colors.black.withOpacity(0.3),
                          //               blurRadius: 8,
                          //               offset: const Offset(0, 4),
                          //             ),
                          //           ],
                          //         ),
                          //         child: AnimatedSwitcher(
                          //           duration: const Duration(milliseconds: 200),
                          //           child: Icon(
                          //             isPlaying ? Icons.stop : Icons.volume_up,
                          //             color: Colors.white,
                          //             size: 28,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: playAudio,
                        child: Text(
                          widget.item.letter,
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        height: 3,
                        width: MediaQuery.of(context).size.width * 0.6,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: playAudio,
                            child: Text(
                              widget.item.letter,
                              style: const TextStyle(
                                fontSize: 48,
                                fontFamily: 'Caveat VariableFont',
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: playAudio,
                            child: Text(
                              widget.item.letter.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
