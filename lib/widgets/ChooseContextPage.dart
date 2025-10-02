import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

class ChooseContextPage extends StatefulWidget {
  const ChooseContextPage({super.key});

  @override
  State<ChooseContextPage> createState() => _ChooseContextPageState();
}

class _ChooseContextPageState extends State<ChooseContextPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  List<Map<String, dynamic>> allContexts = []; // All contexts from JSON
  List<Map<String, dynamic>> remainingContexts = []; // Contexts yet to be shown
  Map<String, dynamic>? currentContext;
  String? selectedImage;
  bool _showCelebration = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
    _loadGameState();
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/jsons/questionsChoseContexPage.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        allContexts = jsonData.cast<Map<String, dynamic>>();
        remainingContexts = List.from(allContexts)
          ..shuffle(); // Shuffle contexts initially
        if (remainingContexts.isNotEmpty) {
          currentContext = remainingContexts.removeAt(0); // Pick first context
        }
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  Future<void> _loadGameState() async {
    _loadJsonData();
    final prefs = await SharedPreferences.getInstance();
    final String? savedContexts = prefs.getString('remainingContexts');
    if (savedContexts != null) {
      final List<dynamic> jsonData = jsonDecode(savedContexts);
      setState(() {
        remainingContexts = jsonData.cast<Map<String, dynamic>>();
        if (remainingContexts.isNotEmpty) {
          currentContext = remainingContexts.removeAt(0);
        } else {
          _showCelebration = true; // Game finished if no contexts remain
        }
      });
    } else {
      _loadJsonData(); // Load fresh game if no saved state
    }
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remainingContexts', jsonEncode(remainingContexts));
  }

  void checkAnswer(String imagePath) async {
    final isCorrect = currentContext!['images']
        .firstWhere((img) => img['path'] == imagePath)['correct'];
    setState(() {
      selectedImage = imagePath;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _confettiController.play();
      await _playAudio(currentContext!['audio']);
      await Future.delayed(1.seconds);
      _nextContext(); // Auto-advance to next context
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  void _nextContext() {
    if (remainingContexts.isNotEmpty) {
      setState(() {
        currentContext = remainingContexts.removeAt(0);
        selectedImage = null;
        _isCorrect = false;
      });
      _saveGameState();
    } else {
      setState(() => _showCelebration = true);
      _saveGameState();
    }
  }

  void _restartGame() {
    setState(() {
      remainingContexts = List.from(allContexts)..shuffle();
      currentContext = remainingContexts.removeAt(0);
      _showCelebration = false;
    });
    _saveGameState();
  }

  Widget _showCelebrationDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: AppDecorations.primaryCard,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/badge.png', width: 120),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Baara Kabako!',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.primaryGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'I ye baara ɲuman kɛ!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.wisdomTeal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Ka daminɛ kokura',
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
              },
              icon: Icons.refresh,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allContexts.isEmpty || currentContext == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Center(
            child: LoadingOverlay(
              isLoading: true,
              message: 'Ja ɲuman sukandili...',
              child: Container(),
            ),
          ),
        ),
      );
    }

    if (_showCelebration) return _showCelebrationDialog(context);

    // Shuffle images for current context
    List<Map<String, dynamic>> images = List.from(currentContext!['images']);

    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Ja ɲuman sukandili',
        showLogo: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            margin: const EdgeInsets.only(right: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accentOrange,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Text(
              '${allContexts.length - remainingContexts.length}/${allContexts.length}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.pureWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Instruction card
              AppCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app,
                        color: AppColors.wisdomTeal, size: 24),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'Ja ɲuman sugandi',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.wisdomTeal,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Word display card
              AppCard(
                child: Column(
                  children: [
                    Text(
                      currentContext!['word'],
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primaryGreen,
                        fontSize: 36,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.volume_up,
                            color: AppColors.pureWhite, size: 32),
                        onPressed: () => _playAudio(currentContext!['audio']),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: AppSpacing.lg,
                  crossAxisSpacing: AppSpacing.lg,
                  children: images.map<Widget>((img) {
                    final isSelected = selectedImage == img['path'];
                    return AnimatedContainer(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                      decoration: AppDecorations.primaryCard.copyWith(
                        border: Border.all(
                          color: isSelected
                              ? (img['correct']
                                  ? AppColors.success
                                  : AppColors.error)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Stack(
                          children: [
                            Image.asset(img['path'], fit: BoxFit.cover),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  color: (img['correct']
                                          ? AppColors.success
                                          : AppColors.error)
                                      .withOpacity(0.8),
                                  child: Center(
                                    child: Icon(
                                      img['correct']
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: AppColors.pureWhite,
                                      size: 60,
                                    ).animate().scale(),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => checkAnswer(img['path']),
                                  splashColor: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(
                          delay: 100.ms * images.indexOf(img),
                        )
                        .slideY(
                          begin: 1,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn();
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playAudio(String path) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(path));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
