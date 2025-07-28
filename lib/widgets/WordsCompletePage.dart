import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

class WordsCompletePage extends StatefulWidget {
  const WordsCompletePage({super.key});

  @override
  State<WordsCompletePage> createState() => _WordsCompletePageState();
}

class _WordsCompletePageState extends State<WordsCompletePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  final Random _random = Random();

  List<Map<String, dynamic>> words = [];
  List<Map<String, dynamic>> gameWords = [];
  int currentIndex = 0;
  String userInput = '';
  bool _isCorrect = false;
  bool _showCelebration = false;
  bool _showHint = false;
  List<String> completedWords = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
    _loadCompletedWords();
  }

  Widget buildHintText(String word, String partial) {
    List<TextSpan> spans = [];
    for (int i = 0; i < word.length; i++) {
      if (partial[i] == '_') {
        // Missing letter: show in bold
        spans.add(TextSpan(
          text: word[i],
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ));
      } else {
        // Already revealed letter: show normally
        spans.add(TextSpan(
          text: word[i],
          style: const TextStyle(color: Colors.black),
        ));
      }
    }
    return RichText(
      text: TextSpan(children: spans, style: const TextStyle(fontSize: 18)),
    );
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/jsons/wordCompletPage.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        words = jsonData.cast<Map<String, dynamic>>();
        _initializeGame();
      });
    } catch (e) {
      print('Erreur lors du chargement du JSON: $e');
    }
  }

  Future<void> _loadCompletedWords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      completedWords = prefs.getStringList('completedWords') ?? [];
    });
  }

  Future<void> _saveCompletedWords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completedWords', completedWords);
  }

  void _initializeGame() {
    setState(() {
      gameWords = List.from(words)..shuffle(_random);
      for (var word in gameWords) {
        word['partial'] = _generatePartialWord(word['word']);
      }
      currentIndex = 0;
      userInput = '';
      _isCorrect = false;
      _showCelebration = false;
      _showHint = false;
    });
  }

  String _generatePartialWord(String word) {
    final length = word.length;
    final numToHide = (length / 2).ceil();
    final indicesToHide = <int>{};
    while (indicesToHide.length < numToHide) {
      indicesToHide.add(_random.nextInt(length));
    }
    return word.split('').asMap().entries.map((entry) {
      return indicesToHide.contains(entry.key) ? '_' : entry.value;
    }).join();
  }

  List<String> _generateKeyboardLetters() {
    final word = gameWords[currentIndex]['word'] as String;
    final partial = gameWords[currentIndex]['partial'] as String;
    List<String> missing = [
      for (int i = 0; i < word.length; i++)
        if (partial[i] == '_') word[i]
    ];
    final distractors = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        .split('')
        .where((c) => !missing.contains(c))
        .toList()
      ..shuffle(_random);
    return (missing + distractors.take(5).toList()).toSet().toList()
      ..shuffle(_random);
  }

  void _addLetter(String letter) {
    final maxLength = gameWords[currentIndex]['partial']
        .replaceAll(RegExp(r'[^_]'), '')
        .length;
    if (userInput.length < maxLength) {
      setState(() {
        userInput += letter;
        _audioPlayer.play(AssetSource('sounds/click.mp3'));
      });
    }
  }

  void _checkWord() {
    final word = gameWords[currentIndex]['word'];
    final partial = gameWords[currentIndex]['partial'];
    final expectedLength = partial.replaceAll(RegExp(r'[^_]'), '').length;

    if (userInput.length != expectedLength) {
      _handleWrongAnswer();
      return;
    }

    final reconstructed = _reconstructWord(partial, userInput);
    if (reconstructed.toLowerCase() == word) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  String _reconstructWord(String partial, String input) {
    final inputChars = input.toUpperCase().split('');
    int inputIndex = 0;
    return partial.split('').map((char) {
      if (char == '_') {
        return inputIndex < inputChars.length ? inputChars[inputIndex++] : '_';
      }
      return char;
    }).join();
  }

  void _handleCorrectAnswer() async {
    setState(() => _isCorrect = true);
    _confettiController.play();
    _playAudio(gameWords[currentIndex]['audio']);
    await Future.delayed(const Duration(seconds: 2));
  }

  void _handleWrongAnswer() async {
    setState(() => _isCorrect = false);
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  void _playAudio(String path) async {
    await _audioPlayer.play(AssetSource(path));
  }

  void _nextWord() {
    if (_isCorrect) {
      final currentWord = gameWords[currentIndex]['word'] as String;
      if (!completedWords.contains(currentWord)) {
        completedWords.add(currentWord);
        _saveCompletedWords();
      }
    }
    setState(() {
      currentIndex = _random.nextInt(gameWords.length);
      userInput = '';
      _isCorrect = false;
      _showHint = false;
    });
  }

  void _giveHint() {
    final word = gameWords[currentIndex]['word'] as String;
    final partial = gameWords[currentIndex]['partial'] as String;

    List<int> underscoreIndices = [];
    for (int i = 0; i < partial.length; i++) {
      if (partial[i] == '_') {
        underscoreIndices.add(i);
      }
    }

    int numMissing = underscoreIndices.length;
    if (userInput.length >= numMissing) return;

    int hintPosition = userInput.length;
    int selectedIndex = underscoreIndices[hintPosition];

    setState(() {
      userInput += word[selectedIndex];
    });
  }

  Widget _buildWordDisplay() {
    final partial = gameWords[currentIndex]['partial'];
    final word = gameWords[currentIndex]['word'];
    final chars = partial.split('');
    final inputChars = userInput.split('');
    int inputIndex = 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: chars.map<Widget>((char) {
          if (char == '_') {
            final inputChar =
                inputIndex < inputChars.length ? inputChars[inputIndex] : '';
            final isCorrect = inputChar.isNotEmpty &&
                inputChar == word[inputIndex + partial.indexOf('_')];
            inputIndex++;
            return _buildLetterSlot(inputChar, isCorrect: isCorrect);
          }
          return _buildLetterSlot(char, isCorrect: true);
        }).toList(),
      ),
    );
  }

  Widget _buildLetterSlot(String char, {bool isCorrect = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: char.isEmpty
            ? AppColors.lightGrey.withOpacity(0.3)
            : AppColors.pureWhite,
        border: Border.all(
            color: isCorrect
                ? AppColors.primaryGreen
                : AppColors.primaryGreen.withOpacity(0.5),
            width: 2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        boxShadow: isCorrect
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [
                BoxShadow(
                  color: AppColors.darkGrey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Center(
        child: Text(
          char,
          style: AppTextStyles.heading3.copyWith(
            fontSize: 24,
            fontWeight: isCorrect ? FontWeight.bold : FontWeight.w600,
            color: isCorrect ? AppColors.primaryGreen : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final letters = _generateKeyboardLetters();
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 5,
      childAspectRatio: 1.2,
      children: letters.map((char) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              onTap: () => _addLetter(char),
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.primaryGreen.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    char,
                    style: AppTextStyles.heading4.copyWith(
                      fontSize: 20,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _showCelebrationDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: AppDecorations.primaryCard.copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGreen.withOpacity(0.1),
              AppColors.accentOrange.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/badge.png', width: 120),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Baara Kabako!',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryGreen,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'I ka baara kɛ kosɛbɛ!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wisdomTeal,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.accentOrange],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.pureWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    'Laban!',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return Scaffold(
        body: LoadingOverlay(
          isLoading: true,
          message: 'Daɲɛw labɛnni...',
          child: Container(),
        ),
      );
    }

    if (_showCelebration) {
      return Scaffold(body: _showCelebrationDialog(context));
    }

    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Daɲɛw dafali',
        showLogo: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryGreen.withOpacity(0.2),
                  AppColors.primaryGreen.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Hakɛ: ${completedWords.length}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isCorrect
                  ? Lottie.asset('assets/animations/success.json',
                      width: 150, repeat: false, key: UniqueKey())
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          gameWords[currentIndex]['image'],
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.cover,
                          key: UniqueKey(),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: InkWell(
                  onTap: () => setState(() => _showHint = !_showHint),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen.withOpacity(0.1),
                          AppColors.primaryGreen.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppColors.primaryGreen,
                          size: 24,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            _showHint
                                ? gameWords[currentIndex]['hint']
                                : 'bilasirali',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildWordDisplay(),
            const SizedBox(height: 16),
            Expanded(child: _buildKeyboard()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!_isCorrect)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.accentOrange,
                          AppColors.accentOrange.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentOrange.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => setState(() => userInput =
                          userInput.isNotEmpty
                              ? userInput.substring(0, userInput.length - 1)
                              : ''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.pureWhite,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Sigini jɔɔsi',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withOpacity(0.8)
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.volume_up,
                        color: AppColors.pureWhite, size: 30),
                    onPressed: () =>
                        _playAudio(gameWords[currentIndex]['audio']),
                  ),
                ),
                if (_isCorrect)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreen.withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.pureWhite,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Dangan',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.pureWhite,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: !_isCorrect
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8)
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: _checkWord,
                child: Icon(
                  Icons.check,
                  color: AppColors.pureWhite,
                  size: 28,
                ),
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
