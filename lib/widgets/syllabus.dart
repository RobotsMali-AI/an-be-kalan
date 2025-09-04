import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

class SyllableSoundsScreen extends StatefulWidget {
  const SyllableSoundsScreen({super.key});

  @override
  _SyllableSoundsScreenState createState() => _SyllableSoundsScreenState();
}

class _SyllableSoundsScreenState extends State<SyllableSoundsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, String>> syllables = [
    {"text": "ba", "sound": "ba.mp3"},
    {"text": "da", "sound": "da.mp3"},
    {"text": "ga", "sound": "ga.mp3"},
    {"text": "ka", "sound": "ka.mp3"},
    {"text": "ma", "sound": "ma.mp3"},
    {"text": "pa", "sound": "pa.mp3"},
    {"text": "ta", "sound": "ta.mp3"},
    {"text": "za", "sound": "za.mp3"},
  ];
  List<Map<String, String>> currentSyllables = [];
  Map<String, String>? correctSyllable;
  int? selectedIndex;
  bool? isCorrect;
  int score = 0;
  int level = 1;
  String resultMessage = '';

  @override
  void initState() {
    super.initState();
    startNewRound();
  }

  void startNewRound() {
    setState(() {
      currentSyllables = List.from(syllables)..shuffle();
      currentSyllables = currentSyllables.sublist(0, 4);
      correctSyllable = currentSyllables[Random().nextInt(4)];
      selectedIndex = null;
      isCorrect = null;
      resultMessage = '';
      if (score > 0 && score % 5 == 0) {
        level++;
      }
    });
  }

  void _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('sounds/$soundFile'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Syllable Sounds - Level $level'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[800]!, Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'Score: $score',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            IconButton(
              icon: Icon(Icons.volume_up, color: Colors.white, size: 60),
              onPressed: () {
                if (correctSyllable != null) {
                  _playSound(correctSyllable!['sound']!);
                }
              },
            ),
            Text(
              'Tap to hear the syllable',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 20),
            if (resultMessage.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  resultMessage,
                  style: TextStyle(
                    color: isCorrect! ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
<<<<<<< Updated upstream
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
=======
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
>>>>>>> Stashed changes
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final syllable = currentSyllables[index];
                    final isSelected = selectedIndex == index;
                    final tileColor = isSelected
                        ? (isCorrect == true
                            ? Colors.greenAccent
                            : Colors.redAccent)
                        : Colors.white;
                    final scale =
                        isSelected ? (isCorrect == true ? 1.1 : 0.9) : 1.0;

                    return GestureDetector(
                      onTap: () {
                        if (selectedIndex == null) {
                          setState(() {
                            selectedIndex = index;
                            isCorrect =
                                syllable['text'] == correctSyllable!['text'];
                            if (isCorrect!) {
                              _playSound('success.mp3');
                              score++;
                              resultMessage = 'Correct!';
                            } else {
                              _playSound('wrong.mp3');
                              resultMessage = 'Incorrect!';
                            }
                            Future.delayed(Duration(seconds: 1), () {
                              startNewRound();
                            });
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        transform: Matrix4.identity()..scale(scale),
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            syllable['text']!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
