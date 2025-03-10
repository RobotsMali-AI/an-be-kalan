// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:lottie/lottie.dart';
// import 'package:confetti/confetti.dart';

// class WordsCompletePage extends StatefulWidget {
//   const WordsCompletePage({super.key});

//   @override
//   State<WordsCompletePage> createState() => _WordsCompletePageState();
// }

// class _WordsCompletePageState extends State<WordsCompletePage> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   final ConfettiController _confettiController =
//       ConfettiController(duration: const Duration(seconds: 2));
//   final Random _random = Random();

//   // List of words without hardcoded partials
//   final List<Map<String, dynamic>> words = [
//     {
//       'word': 'cincin',
//       'image': 'assets/nkalanIm/sable.jpg',
//       'audio': 'nkalanSound/sable.mp3',
//       'hint': 'siman bɛ kɛ a la'
//     },
//     {
//       'word': 'dan',
//       'image': 'assets/nkalanIm/terminaison.jpg',
//       'audio': 'nkalanSound/terminaison.mp3',
//       'hint': 'a tɛ tɛmɛ yen ka'
//     },
//     {
//       'word': 'baara',
//       'image': 'assets/nkalanIm/travail.jpg',
//       'audio': 'nkalanSound/travail.mp3',
//       'hint': 'a bɛ kɛ ni fanga ye.'
//     },
//     {
//       'word': 'feere',
//       'image': 'assets/nkalanIm/vente.jpg',
//       'audio': 'nkalanSound/vente.mp3',
//       'hint': 'falen wari la.'
//     },
//     {
//       'word': 'fu',
//       'image': 'assets/nkalanIm/zero.jpg',
//       'audio': 'nkalanSound/zero.mp3',
//       'hint': 'fosi fosi.'
//     },
//     {
//       'word': 'fali',
//       'image': 'assets/nkalanIm/ane.jpg',
//       'audio': 'nkalanSound/ane.mp3',
//       'hint': 'a bɛ bin dun.'
//     },
//     {
//       'word': 'feere',
//       'image': 'assets/nkalanIm/vente.jpg',
//       'audio': 'nkalanSound/vente.mp3',
//       'hint': 'a bɛ kɛ sugula.'
//     },
//     {
//       'word': 'araye',
//       'image': 'assets/nkalanIm/rail.jpg',
//       'audio': 'nkalanSound/rail.mp3',
//       'hint': 'tɛrɛn bɛ boli'
//     },
//     {
//       'word': 'araye',
//       'image': 'assets/nkalanIm/rail.jpg',
//       'audio': 'nkalanSound/rail.mp3',
//       'hint': 'tɛrɛn bɛ boli'
//     },
//     {
//       'word': 'bonya',
//       'image': 'assets/nkalanIm/respect.jpg',
//       'audio': 'nkalanSound/respect.mp3',
//       'hint': 'mɔgɔ kɔrɔba ni a kakan'
//     },

//     // Add more unique words here...
//   ];

//   List<Map<String, dynamic>> gameWords = [];
//   int currentIndex = 0;
//   String userInput = '';
//   bool _isCorrect = false;
//   bool _showCelebration = false;
//   bool _showHint = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeGame();
//   }

//   // Initialize the game by shuffling words and generating partials
//   void _initializeGame() {
//     setState(() {
//       gameWords = List.from(words)..shuffle(_random);
//       for (var word in gameWords) {
//         word['partial'] = _generatePartialWord(word['word']);
//       }
//       currentIndex = 0;
//       userInput = '';
//       _isCorrect = false;
//       _showCelebration = false;
//       _showHint = false;
//     });
//   }

//   // Generate a random partial word by hiding some letters
//   String _generatePartialWord(String word) {
//     final length = word.length;
//     final numToHide =
//         (length / 2).ceil(); // Hide approximately half the letters
//     final indicesToHide = <int>{};
//     while (indicesToHide.length < numToHide) {
//       indicesToHide.add(_random.nextInt(length));
//     }
//     return word.split('').asMap().entries.map((entry) {
//       return indicesToHide.contains(entry.key) ? '_' : entry.value;
//     }).join();
//   }

//   // Generate keyboard with correct letters + distractors
//   List<String> _generateKeyboardLetters() {
//     final word = gameWords[currentIndex]['word'] as String;
//     final partial = gameWords[currentIndex]['partial'] as String;
//     List<String> missing = [
//       for (int i = 0; i < word.length; i++)
//         if (partial[i] == '_') word[i]
//     ];
//     final distractors = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
//         .split('')
//         .where((c) => !missing.contains(c))
//         .toList()
//       ..shuffle(_random);
//     return (missing + distractors.take(5).toList()).toSet().toList()
//       ..shuffle(_random);
//   }

//   void _addLetter(String letter) {
//     final maxLength = gameWords[currentIndex]['partial']
//         .replaceAll(RegExp(r'[^_]'), '')
//         .length;
//     if (userInput.length < maxLength) {
//       setState(() {
//         userInput += letter;
//         _audioPlayer.play(AssetSource('sounds/click.mp3'));
//       });
//     }
//   }

//   void _checkWord() {
//     final word = gameWords[currentIndex]['word'];
//     final partial = gameWords[currentIndex]['partial'];
//     final expectedLength = partial.replaceAll(RegExp(r'[^_]'), '').length;

//     if (userInput.length != expectedLength) {
//       _handleWrongAnswer();
//       return;
//     }

//     final reconstructed = _reconstructWord(partial, userInput);
//     if (reconstructed.toLowerCase() == word) {
//       _handleCorrectAnswer();
//     } else {
//       _handleWrongAnswer();
//     }
//   }

//   String _reconstructWord(String partial, String input) {
//     final inputChars = input.toUpperCase().split('');
//     int inputIndex = 0;
//     return partial.split('').map((char) {
//       if (char == '_') {
//         return inputIndex < inputChars.length ? inputChars[inputIndex++] : '_';
//       }
//       return char;
//     }).join();
//   }

//   void _handleCorrectAnswer() async {
//     setState(() => _isCorrect = true);
//     _confettiController.play();
//     _playAudio(gameWords[currentIndex]['audio']);
//     await Future.delayed(const Duration(seconds: 2));
//   }

//   void _handleWrongAnswer() async {
//     setState(() => _isCorrect = false);
//     await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
//   }

//   void _playAudio(String path) async {
//     await _audioPlayer.play(AssetSource(path));
//   }

//   void _nextWord() {
//     if (currentIndex < gameWords.length - 1) {
//       setState(() {
//         currentIndex++;
//         userInput = '';
//         _isCorrect = false;
//         _showHint = false;
//       });
//     } else {
//       setState(() => _showCelebration = true);
//     }
//   }

//   // Build word display with individual slots
//   Widget _buildWordDisplay() {
//     final partial = gameWords[currentIndex]['partial'];
//     final word = gameWords[currentIndex]['word'];
//     final chars = partial.split('');
//     final inputChars = userInput.split('');
//     int inputIndex = 0;

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: chars.map<Widget>((char) {
//         if (char == '_') {
//           final inputChar =
//               inputIndex < inputChars.length ? inputChars[inputIndex] : '';
//           final isCorrect = inputChar.isNotEmpty &&
//               inputChar == word[inputIndex + partial.indexOf('_')];
//           inputIndex++;
//           return _buildLetterSlot(inputChar, isCorrect: isCorrect);
//         }
//         return _buildLetterSlot(char, isCorrect: true);
//       }).toList(),
//     );
//   }

//   Widget _buildLetterSlot(String char, {bool isCorrect = false}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       width: 40,
//       height: 40,
//       margin: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: char.isEmpty ? Colors.grey[200] : Colors.white,
//         border: Border.all(color: Colors.black),
//         boxShadow: isCorrect
//             ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
//             : [],
//       ),
//       child: Center(
//         child: Text(
//           char,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
//             color: Colors.black,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildKeyboard() {
//     final letters = _generateKeyboardLetters();
//     return GridView.count(
//       shrinkWrap: true,
//       crossAxisCount: 5,
//       childAspectRatio: 1.2,
//       children: letters.map((char) {
//         return Padding(
//           padding: const EdgeInsets.all(4.0),
//           child: GestureDetector(
//             onTap: () => _addLetter(char),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 100),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(color: Colors.black),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Center(
//                 child: Text(char,
//                     style: const TextStyle(fontSize: 20, color: Colors.black)),
//               ),
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildCelebration() {
//     return Stack(
//       children: [
//         Container(
//           color: Colors.black,
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Lottie.asset('assets/animations/celebration.json',
//                     width: 300, repeat: false),
//                 const Text(
//                   'You’re Awesome!',
//                   style: TextStyle(
//                       fontSize: 32,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.check, color: Colors.black),
//                   label: const Text('Finish!',
//                       style: TextStyle(color: Colors.black)),
//                   onPressed: () => Navigator.pop(context),
//                   style:
//                       ElevatedButton.styleFrom(backgroundColor: Colors.white),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.topCenter,
//           child: ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirectionality: BlastDirectionality.explosive,
//             colors: const [Colors.black, Colors.grey, Colors.white],
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_showCelebration) {
//       return Scaffold(body: _buildCelebration());
//     }

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text('Word Builder',
//             style: TextStyle(color: Colors.white, fontSize: 24)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text('Level ${currentIndex + 1}/${gameWords.length}',
//                 style: const TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//       body: Container(
//         color: Colors.grey[100],
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               child: _isCorrect
//                   ? Lottie.asset('assets/animations/success.json',
//                       width: 150, repeat: false, key: UniqueKey())
//                   : Image.asset(gameWords[currentIndex]['image'],
//                       height: 180, key: UniqueKey()),
//             ),
//             const SizedBox(height: 16),
//             GestureDetector(
//               onTap: () => setState(() => _showHint = !_showHint),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.black),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(Icons.lightbulb_outline, color: Colors.black),
//                     const SizedBox(width: 8),
//                     Text(
//                         _showHint
//                             ? gameWords[currentIndex]['hint']
//                             : 'Tap for Hint',
//                         style:
//                             const TextStyle(fontSize: 18, color: Colors.black)),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildWordDisplay(),
//             const SizedBox(height: 16),
//             Expanded(child: _buildKeyboard()),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 ElevatedButton(
//                   onPressed: () => setState(() => userInput =
//                       userInput.isNotEmpty
//                           ? userInput.substring(0, userInput.length - 1)
//                           : ''),
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.black),
//                   child: const Text('Delete'),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.volume_up,
//                       color: Colors.black, size: 30),
//                   onPressed: () => _playAudio(gameWords[currentIndex]['audio']),
//                 ),
//                 if (_isCorrect)
//                   ElevatedButton(
//                     onPressed: _nextWord,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.black),
//                     child: const Text('Next'),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: !_isCorrect
//           ? FloatingActionButton(
//               backgroundColor: Colors.white,
//               onPressed: _checkWord,
//               child: const Icon(Icons.check, color: Colors.black),
//             )
//           : null,
//     );
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;

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

  List<Map<String, dynamic>> words = []; // Initialisé vide
  List<Map<String, dynamic>> gameWords = [];
  int currentIndex = 0;
  String userInput = '';
  bool _isCorrect = false;
  bool _showCelebration = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _loadJsonData(); // Charger les données au démarrage
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
    if (currentIndex < gameWords.length - 1) {
      setState(() {
        currentIndex++;
        userInput = '';
        _isCorrect = false;
        _showHint = false;
      });
    } else {
      setState(() => _showCelebration = true);
    }
  }

  Widget _buildWordDisplay() {
    final partial = gameWords[currentIndex]['partial'];
    final word = gameWords[currentIndex]['word'];
    final chars = partial.split('');
    final inputChars = userInput.split('');
    int inputIndex = 0;

    return Row(
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
        border: Border.all(color: Colors.black),
        boxShadow: isCorrect
            ? [const BoxShadow(color: Colors.black26, blurRadius: 4)]
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
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(char,
                    style: const TextStyle(fontSize: 20, color: Colors.black)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCelebration() {
    return Stack(
      children: [
        Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/celebration.json',
                    width: 300, repeat: false),
                const Text(
                  'You’re Awesome!',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: const Text('Finish!',
                      style: TextStyle(color: Colors.black)),
                  onPressed: () => Navigator.pop(context),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [Colors.black, Colors.grey, Colors.white],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showCelebration) {
      return Scaffold(body: _buildCelebration());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Word Builder',
            style: TextStyle(color: Colors.white, fontSize: 24)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Level ${currentIndex + 1}/${gameWords.length}',
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isCorrect
                  ? Lottie.asset('assets/animations/success.json',
                      width: 150, repeat: false, key: UniqueKey())
                  : Image.asset(gameWords[currentIndex]['image'],
                      height: 180, key: UniqueKey()),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => setState(() => _showHint = !_showHint),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                        _showHint
                            ? gameWords[currentIndex]['hint']
                            : 'Tap for Hint',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black)),
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
                ElevatedButton(
                  onPressed: () => setState(() => userInput =
                      userInput.isNotEmpty
                          ? userInput.substring(0, userInput.length - 1)
                          : ''),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  child: const Text('Delete'),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up,
                      color: Colors.black, size: 30),
                  onPressed: () => _playAudio(gameWords[currentIndex]['audio']),
                ),
                if (_isCorrect)
                  ElevatedButton(
                    onPressed: _nextWord,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black),
                    child: const Text('Next'),
                  ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: !_isCorrect
          ? FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _checkWord,
              child: const Icon(Icons.check, color: Colors.black),
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
