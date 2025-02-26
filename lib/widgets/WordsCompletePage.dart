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
//   final List<Map<String, dynamic>> words = [
//     {
//       'word': 'CHICKEN',
//       'partial': 'CHI___N',
//       'image': 'assets/chicken.jpg',
//       'audio': 'sounds/chicken.mp3',
//       'hint': 'Farm animal that lays eggs'
//     },
//     {
//       'word': 'CAT',
//       'partial': 'C_T',
//       'image': 'assets/chicken.jpg',
//       'audio': 'sounds/chicken.mp3',
//       'hint': 'animal that mioule'
//     },
//     {
//       'word': 'CHICKEN',
//       'partial': 'CHI___N',
//       'image': 'assets/chicken.jpg',
//       'audio': 'sounds/chicken.mp3',
//       'hint': 'Farm animal that lays eggs'
//     },
//     {
//       'word': 'CHICKEN',
//       'partial': 'CHI___N',
//       'image': 'assets/chicken.jpg',
//       'audio': 'sounds/chicken.mp3',
//       'hint': 'Farm animal that lays eggs'
//     },
//     // Add more words...
//   ];

//   int currentIndex = 0;
//   String userInput = '';
//   bool _isCorrect = false;
//   bool _showCelebration = false;

//   void checkWord() {
//     final currentWord = words[currentIndex];
//     final partial = currentWord['partial'];
//     final fullWord = currentWord['word'];

//     // Calculate expected input length
//     final expectedLength = partial.replaceAll(RegExp(r'[^_]'), '').length;

//     if (userInput.length != expectedLength) {
//       _handleWrongAnswer();
//       return;
//     }

//     // Reconstruct the full word from partial and user input
//     final reconstructed = _reconstructWord(partial, userInput);

//     if (reconstructed == fullWord) {
//       _handleCorrectAnswer();
//     } else {
//       _handleWrongAnswer();
//     }
//   }

//   String _reconstructWord(String partial, String input) {
//     final inputChars = input.toUpperCase().split('');
//     int inputIndex = 0;
//     final result = <String>[];

//     for (final char in partial.split('')) {
//       if (char == '_' && inputIndex < inputChars.length) {
//         result.add(inputChars[inputIndex]);
//         inputIndex++;
//       } else {
//         result.add(char);
//       }
//     }

//     return result.join();
//   }

//   void _handleCorrectAnswer() async {
//     setState(() => _isCorrect = true);
//     _confettiController.play();
//     _playAudio(words[currentIndex]['audio']);
//     await Future.delayed(const Duration(seconds: 2));

//     if (currentIndex < words.length - 1) {
//       setState(() {
//         userInput = '';
//         currentIndex++;
//         _isCorrect = false;
//       });
//     } else {
//       setState(() => _showCelebration = true);
//     }
//   }

//   void _handleWrongAnswer() async {
//     setState(() => _isCorrect = false);
//     await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
//   }

//   void _playAudio(String path) async {
//     await _audioPlayer.play(AssetSource(path));
//   }

//   Widget _buildCelebration() {
//     return Stack(
//       children: [
//         Positioned.fill(
//           child: Container(
//             color: Colors.black,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Lottie.asset('assets/animations/celebration.json',
//                       width: 300, repeat: false),
//                   const Text('Amazing Work!',
//                       style: TextStyle(
//                           fontSize: 32,
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 20),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.celebration),
//                     label: const Text('Finish!'),
//                     onPressed: () => Navigator.pop(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.amber,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 30, vertical: 15),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         Align(
//           alignment: Alignment.topCenter,
//           child: ConfettiWidget(
//             confettiController: _confettiController,
//             blastDirectionality: BlastDirectionality.explosive,
//             colors: const [
//               Colors.green,
//               Colors.blue,
//               Colors.pink,
//               Colors.orange
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildKeyboard() {
//     final currentPartial = words[currentIndex]['partial'];
//     final maxInputLength =
//         currentPartial.replaceAll(RegExp(r'[^_]'), '').length;

//     const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//     return GridView.count(
//       shrinkWrap: true,
//       crossAxisCount: 6,
//       children: letters.split('').map((char) {
//         return Padding(
//           padding: const EdgeInsets.all(2.0),
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: userInput.length >= maxInputLength
//                   ? Colors.grey
//                   : Colors.blue[100],
//             ),
//             onPressed: userInput.length >= maxInputLength
//                 ? null
//                 : () => setState(() => userInput += char),
//             child: Center(child: Text(char)),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_showCelebration) {
//       return Scaffold(
//         body: _buildCelebration(),
//       );
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
//           Text(
//             'Niveau ${currentIndex + 1}/${words.length}',
//             style: const TextStyle(color: Colors.white),
//           )
//         ],
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//             gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.white, Colors.white])),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             children: [
//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 500),
//                 child: _isCorrect
//                     ? Lottie.asset('assets/animations/success.json',
//                         width: 150, repeat: false)
//                     : Image.asset(words[currentIndex]['image'], height: 180),
//               ),
//               const SizedBox(height: 10),
//               Text(words[currentIndex]['hint'],
//                   style: const TextStyle(fontSize: 18, color: Colors.black)),
//               const SizedBox(height: 10),
//               Text(words[currentIndex]['partial'],
//                   style: const TextStyle(
//                       fontSize: 22,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                     color: Colors.black,
//                     borderRadius: BorderRadius.circular(15)),
//                 child: Text(userInput,
//                     style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white)),
//               ),
//               const SizedBox(height: 10),
//               Expanded(child: _buildKeyboard()),
//               Row(
//                 children: [
//                   ElevatedButton(
//                     onPressed: () => setState(() {
//                       if (userInput.isNotEmpty) {
//                         userInput =
//                             userInput.substring(0, userInput.length - 1);
//                       }
//                     }),
//                     child: const Text('Delete'),
//                   ),
//                   const Spacer(),
//                   IconButton(
//                     icon: const Icon(Icons.volume_up,
//                         color: Colors.black, size: 30),
//                     onPressed: () => _playAudio(words[currentIndex]['audio']),
//                   ),
//                   const Spacer(
//                     flex: 2,
//                   )
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.amber,
//         child: const Icon(Icons.check),
//         onPressed: checkWord,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     _confettiController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';

class WordsCompletePage extends StatefulWidget {
  const WordsCompletePage({super.key});

  @override
  State<WordsCompletePage> createState() => _WordsCompletePageState();
}

class _WordsCompletePageState extends State<WordsCompletePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  final List<Map<String, dynamic>> words = [
    {
      'word': 'CHICKEN',
      'partial': 'CHI___N',
      'image': 'assets/chicken.jpg', // Black-and-white image
      'audio': 'sounds/chicken.mp3',
      'hint': 'Farm animal that lays eggs'
    },
    {
      'word': 'CAT',
      'partial': 'C_T',
      'image': 'assets/cat.jpg', // Black-and-white image
      'audio': 'sounds/cat.mp3',
      'hint': 'Animal that meows'
    },
    // Add more words...
  ];

  int currentIndex = 0;
  String userInput = '';
  bool _isCorrect = false;
  bool _showCelebration = false;
  bool _showHint = false;

  // Generate a smaller keyboard with correct letters + distractors
  List<String> _generateKeyboardLetters() {
    final word = words[currentIndex]['word'] as String;
    final partial = words[currentIndex]['partial'] as String;
    List<String> missing = [
      for (int i = 0; i < word.length; i++)
        if (partial[i] == '_') word[i]
    ];
    final distractors = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        .split('')
        .where((c) => !missing.contains(c))
        .toList()
      ..shuffle();
    return (missing + distractors.take(5).toList()).toSet().toList()..shuffle();
  }

  void _addLetter(String letter) {
    final maxLength =
        words[currentIndex]['partial'].replaceAll(RegExp(r'[^_]'), '').length;
    if (userInput.length < maxLength) {
      setState(() {
        userInput += letter;
        _audioPlayer
            .play(AssetSource('sounds/click.mp3')); // Sound for letter tap
      });
    }
  }

  void _checkWord() {
    final word = words[currentIndex]['word'];
    final partial = words[currentIndex]['partial'];
    final expectedLength = partial.replaceAll(RegExp(r'[^_]'), '').length;

    if (userInput.length != expectedLength) {
      _handleWrongAnswer();
      return;
    }

    final reconstructed = _reconstructWord(partial, userInput);
    if (reconstructed == word) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  String _reconstructWord(String partial, String input) {
    final inputChars = input.toUpperCase().split('');
    int inputIndex = 0;
    final result = partial.split('').map((char) {
      if (char == '_') {
        return inputIndex < inputChars.length ? inputChars[inputIndex++] : '_';
      }
      return char;
    }).join();
    return result;
  }

  void _handleCorrectAnswer() async {
    setState(() => _isCorrect = true);
    _confettiController.play();
    _playAudio(words[currentIndex]['audio']);
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
    if (currentIndex < words.length - 1) {
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

  // Build the word display with individual slots
  Widget _buildWordDisplay() {
    final partial = words[currentIndex]['partial'];
    final word = words[currentIndex]['word'];
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
        boxShadow:
            isCorrect ? [BoxShadow(color: Colors.black26, blurRadius: 4)] : [],
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
                    width: 300, repeat: false), // Grayscale animation
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
            child: Text('Level ${currentIndex + 1}/${words.length}',
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
                  : Image.asset(words[currentIndex]['image'],
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
                            ? words[currentIndex]['hint']
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
                  onPressed: () => _playAudio(words[currentIndex]['audio']),
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
              child: const Icon(Icons.check, color: Colors.black),
              onPressed: _checkWord,
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
