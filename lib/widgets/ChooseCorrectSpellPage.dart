import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

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
        decoration: BoxDecoration(
          color: isSelected
              ? (isCorrectOption ? Colors.black : Colors.grey[300])
              : Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                  fontSize: 20,
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
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      );
    }

    if (_showCelebration) return _showCelebrationDialog(context);

    List<String> options = List.from(currentSpell!['options']);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Hakɛya ${allSpells.length - remainingSpells.length - 1}/${allSpells.length}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (allSpells.length - remainingSpells.length - 1) /
                allSpells.length,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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
                          currentSpell!['image'],
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                  color: Colors.white),
                              onPressed: () =>
                                  _playAudio(currentSpell!['audio']),
                            ),
                          ),
                          const SizedBox(width: 20),
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
                              icon: const Icon(Icons.lightbulb,
                                  color: Colors.white),
                              onPressed: () =>
                                  setState(() => _showHint = !_showHint),
                            ),
                          ),
                          const SizedBox(width: 20),
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
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => setState(() =>
                                  _showWordCompletion = !_showWordCompletion),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Jaabi ye ?',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...options.map((option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: _buildOption(option),
                        )),
                    if (_showHint)
                      Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          currentSpell!['hint'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    if (_showWordCompletion)
                      Container(
                        padding: const EdgeInsets.all(15),
                        margin: const EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'a daminɛ ye: ${currentSpell!['partial']}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
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
                                suffixIcon: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.white),
                                    onPressed: _checkTypedAnswer,
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_isCorrect)
                      Column(
                        children: [
                          Lottie.asset('assets/animations/success.json',
                              width: 120, repeat: false),
                          Container(
                            margin: const EdgeInsets.only(top: 20),
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
                                  horizontal: 30,
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
