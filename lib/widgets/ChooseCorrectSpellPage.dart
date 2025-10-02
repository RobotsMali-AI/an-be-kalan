import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

class ChooseCorrectSpellPage extends StatefulWidget {
  const ChooseCorrectSpellPage({super.key});

  @override
  State<ChooseCorrectSpellPage> createState() => _ChooseCorrectSpellPageState();
}

class _ChooseCorrectSpellPageState extends State<ChooseCorrectSpellPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  List<Map<String, dynamic>> allSpells = []; // All spells from JSON
  List<Map<String, dynamic>> remainingSpells = []; // Spells yet to be shown
  Map<String, dynamic>? currentSpell;
  String? selectedOption;
  bool _showCelebration = false;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _showWordCompletion = false;
  final TextEditingController _wordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJsonData();
    _loadGameState();
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/jsons/chooseCorrectSpellPage.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        allSpells = jsonData.cast<Map<String, dynamic>>();
        remainingSpells = List.from(allSpells)
          ..shuffle(); // Shuffle spells initially
        if (remainingSpells.isNotEmpty) {
          currentSpell = remainingSpells.removeAt(0); // Pick first spell
        }
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  Future<void> _loadGameState() async {
    _loadJsonData();
    final prefs = await SharedPreferences.getInstance();
    final String? savedSpells = prefs.getString('remainingSpells');
    if (savedSpells != null) {
      final List<dynamic> jsonData = jsonDecode(savedSpells);
      setState(() {
        remainingSpells = jsonData.cast<Map<String, dynamic>>();
        if (remainingSpells.isNotEmpty) {
          currentSpell = remainingSpells.removeAt(0);
        } else {
          _showCelebration = true; // Game finished if no spells remain
        }
      });
    } else {
      _loadJsonData(); // Load fresh game if no saved state
    }
  }

  Future<void> _saveGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('remainingSpells', jsonEncode(remainingSpells));
  }

  void checkAnswer(String option) async {
    setState(() {
      selectedOption = option;
      _isCorrect = option == currentSpell!['word'];
    });

    if (_isCorrect) {
      _confettiController.play();
      _playAudio(currentSpell!['audio']);
      await Future.delayed(1.seconds);
      //_nextWord(); // Automatically proceed to next spell after correct answer
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  void _nextWord() {
    if (remainingSpells.isNotEmpty) {
      setState(() {
        currentSpell = remainingSpells.removeAt(0); // Take next spell
        selectedOption = null;
        _isCorrect = false;
        _showHint = false;
        _showWordCompletion = false;
        _wordController.clear();
      });
      _saveGameState(); // Save state after moving to next spell
    } else {
      setState(() => _showCelebration = true); // Show celebration when done
      _saveGameState();
    }
  }

  void _checkTypedAnswer() {
    if (_wordController.text.toUpperCase() == currentSpell!['word']) {
      setState(() {
        selectedOption = _wordController.text.toUpperCase();
        _isCorrect = true;
      });
      _confettiController.play();
      _playAudio(currentSpell!['audio']);
      _nextWord(); // Proceed to next spell after correct typed answer
    } else {
      _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  Widget _buildOption(String option) {
    final isSelected = selectedOption == option;
    final isCorrectOption = option == currentSpell!['word'];

    return GestureDetector(
      onTap: (selectedOption != null && _isCorrect)
          ? null
          : () => checkAnswer(option),
      child: AnimatedContainer(
        duration: 300.ms,
        decoration: AppDecorations.primaryCard.copyWith(
          color: isSelected
              ? (isCorrectOption ? AppColors.success : AppColors.error)
              : AppColors.pureWhite,
          border: Border.all(
            color: isSelected
                ? (isCorrectOption ? AppColors.success : AppColors.error)
                : AppColors.accentOrange,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              if (isSelected)
                Icon(
                  isCorrectOption ? Icons.check : Icons.close,
                  color: AppColors.pureWhite,
                ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  option,
                  style: AppTextStyles.heading4.copyWith(
                    color: isSelected
                        ? AppColors.pureWhite
                        : AppColors.accentOrange,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .scaleXY(
            begin: 1,
            end: isSelected ? 1.05 : 1,
            duration: 200.ms,
          )
          .then()
          .shakeX(
            duration: 300.ms,
            hz: 4,
            amount: isSelected && !isCorrectOption ? 1 : 0,
          ),
    );
  }

  Widget _showCelebrationDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/badge.png', width: 150),
                      const SizedBox(height: 20),
                      const Text(
                        'Baara Kabako!',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _restartGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 20),
                          elevation: 5,
                        ),
                        child: const Text(
                          'Restart!',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
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

  void _restartGame() {
    setState(() {
      remainingSpells = List.from(allSpells)..shuffle(); // Reshuffle all spells
      currentSpell = remainingSpells.removeAt(0);
      _showCelebration = false;
    });
    _saveGameState();
  }

  @override
  Widget build(BuildContext context) {
    if (allSpells.isEmpty || currentSpell == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Center(
            child: LoadingOverlay(
              isLoading: true,
              message: 'Sɛbɛn cogo ɲuman sugandili...',
              child: Container(),
            ),
          ),
        ),
      );
    }

    if (_showCelebration) return _showCelebrationDialog(context);

    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Sɛbɛn cogo ɲuman sugandili',
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
              '${allSpells.length - remainingSpells.length}/${allSpells.length}',
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
              // Word display card
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.spellcheck,
                            color: AppColors.accentOrange, size: 24),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          'Sɛbɛnni ɲuman sugandi',
                          style: AppTextStyles.heading4.copyWith(
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentOrange.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.volume_up,
                            color: AppColors.pureWhite, size: 32),
                        onPressed: () => _playAudio(currentSpell!['audio']),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: currentSpell!['options'].length,
                  itemBuilder: (context, index) {
                    final option = currentSpell!['options'][index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildOption(option),
                    );
                  },
                ),
              ),

              // Action buttons
              if (selectedOption != null && _isCorrect)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: PrimaryButton(
                    text: 'Ka taa fɛ',
                    onPressed: _nextWord,
                    icon: Icons.arrow_forward,
                    width: double.infinity,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _playAudio(String path) {
    _audioPlayer.play(AssetSource(path));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _wordController.dispose();
    super.dispose();
  }
}
