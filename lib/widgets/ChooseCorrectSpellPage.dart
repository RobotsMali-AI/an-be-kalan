import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;

class ChooseCorrectSpellPage extends StatefulWidget {
  const ChooseCorrectSpellPage({super.key});

  @override
  State<ChooseCorrectSpellPage> createState() => _ChooseCorrectSpellPageState();
}

class _ChooseCorrectSpellPageState extends State<ChooseCorrectSpellPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  List<Map<String, dynamic>> spells = []; // Initialisé vide

  int currentIndex = 0;
  String? selectedOption;
  bool _showCelebration = false;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _showWordCompletion = false;
  final TextEditingController _wordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJsonData(); // Charger les données au démarrage
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/jsons/chooseCorrectSpellPage.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        spells = jsonData.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Erreur lors du chargement du JSON: $e');
    }
  }

  void checkAnswer(String option) async {
    setState(() {
      selectedOption = option;
      _isCorrect = option == spells[currentIndex]['word'];
    });

    if (_isCorrect) {
      _confettiController.play();
      _playAudio(spells[currentIndex]['audio']);
      await Future.delayed(1.seconds);
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  void _nextWord() {
    if (currentIndex < spells.length - 1) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        _isCorrect = false;
        _showHint = false;
        _showWordCompletion = false;
        _wordController.clear();
      });
    } else {
      setState(() => _showCelebration = true);
    }
  }

  void _checkTypedAnswer() {
    if (_wordController.text.toUpperCase() == spells[currentIndex]['word']) {
      setState(() {
        selectedOption = _wordController.text.toUpperCase();
        _isCorrect = true;
      });
      _confettiController.play();
      _playAudio(spells[currentIndex]['audio']);
    } else {
      _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  Widget _buildOption(String option) {
    final isSelected = selectedOption == option;
    final isCorrectOption = option == spells[currentIndex]['word'];

    return GestureDetector(
      onTap: () => checkAnswer(option),
      child: AnimatedContainer(
        duration: 300.ms,
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrectOption ? Colors.black : Colors.grey[300])
              : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (isSelected)
                Icon(
                  isCorrectOption ? Icons.check : Icons.close,
                  color: isCorrectOption ? Colors.white : Colors.black,
                ),
              const SizedBox(width: 10),
              Text(
                option,
                style: TextStyle(
                  fontSize: 24,
                  color: isSelected && isCorrectOption
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.bold,
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
    // Save user data to Firebase

    // Show the celebration dialog
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          // Bright yellow background
          Container(
            color: Colors.white30, // Cheerful background color
            child: Center(
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10, // Shadow for a floating effect
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Golden badge image
                      Image.asset(
                        'assets/badge.png', // Add this asset to your project
                        width: 150,
                      ),
                      const SizedBox(height: 20),
                      // Celebratory text in Bambara
                      const Text(
                        'Baara Kabako!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Purple button with Bambara text
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(50), // Rounded shape
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 20,
                          ),
                        ),
                        child: const Text(
                          'Laban!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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
    if (spells.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showCelebration) return _showCelebrationDialog(context);

    final currentSpell = spells[currentIndex];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text('Hakɛya ${currentIndex + 1}/${spells.length}',
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: currentIndex / spells.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(currentSpell['image'], height: 200),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.volume_up, color: Colors.black),
                          onPressed: () => _playAudio(currentSpell['audio']),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.lightbulb, color: Colors.black),
                          onPressed: () =>
                              setState(() => _showHint = !_showHint),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black),
                          onPressed: () => setState(
                              () => _showWordCompletion = !_showWordCompletion),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Jaabi ye ?',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...currentSpell['options'].map((option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildOption(option),
                        )),
                    if (_showHint)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          currentSpell['hint'],
                          style: const TextStyle(
                              color: Colors.black, fontSize: 18),
                        ),
                      ),
                    if (_showWordCompletion)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Text(
                              'a daminɛ ye: ${currentSpell['partial']}',
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _wordController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                hintText: 'Daɲɛ sɛbɛn...',
                                hintStyle: const TextStyle(color: Colors.grey),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.black),
                                  onPressed: _checkTypedAnswer,
                                ),
                              ),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                    if (_isCorrect)
                      Column(
                        children: [
                          Lottie.asset('assets/animations/success.json',
                              width: 150, repeat: false),
                          ElevatedButton(
                            onPressed: _nextWord,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Dangan'),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
