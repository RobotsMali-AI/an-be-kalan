import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

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
        color: char.isEmpty ? Colors.grey[200] : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: isCorrect
            ? [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
            : [],
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontSize: 24,
            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
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
          child: GestureDetector(
            onTap: () => _addLetter(char),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  char,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 20,
                            ),
                          ),
                          child: const Text(
                            'Laban!',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      );
    }

    if (_showCelebration) {
      return Scaffold(body: _showCelebrationDialog(context));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Daɲɛ dafali',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Hakɛ: ${completedWords.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
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
            GestureDetector(
              onTap: () => setState(() => _showHint = !_showHint),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      _showHint
                          ? gameWords[currentIndex]['hint']
                          : 'bilasirali',
                      style: const TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
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
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
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
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: const Text('Sigini jɔɔsi'),
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.volume_up,
                        color: Colors.white, size: 30),
                    onPressed: () =>
                        _playAudio(gameWords[currentIndex]['audio']),
                  ),
                ),
                if (_isCorrect)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _nextWord,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: const Text('Dangan'),
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
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                onPressed: _checkWord,
                child: const Icon(Icons.check, color: Colors.white),
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
