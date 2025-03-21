import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart' show rootBundle;

class ChooseContextPage extends StatefulWidget {
  const ChooseContextPage({super.key});

  @override
  State<ChooseContextPage> createState() => _ChooseContextPageState();
}

class _ChooseContextPageState extends State<ChooseContextPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  List<Map<String, dynamic>> contexts = []; // Initialisé vide

  int currentIndex = 0;
  String? selectedImage;
  bool _showCelebration = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadJsonData(); // Charger les données au démarrage
  }

  Future<void> _loadJsonData() async {
    try {
      final String jsonString = await rootBundle
          .loadString('assets/jsons/questionsChoseContexPage.json');
      final List<dynamic> jsonData = jsonDecode(jsonString);
      setState(() {
        contexts = jsonData.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Erreur lors du chargement du JSON: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _preloadImages();
  }

  void _preloadImages() {
    if (contexts.isNotEmpty) {
      for (var context in contexts) {
        for (var image in context['images']) {
          precacheImage(AssetImage(image['path']), this.context);
        }
      }
    }
  }

  void checkAnswer(String imagePath) async {
    final isCorrect = contexts[currentIndex]['images']
        .firstWhere((img) => img['path'] == imagePath)['correct'];

    setState(() {
      selectedImage = imagePath;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _confettiController.play();
      await _playAudio(contexts[currentIndex]['audio']);
      await Future.delayed(1.seconds);

      if (currentIndex < contexts.length - 1) {
        setState(() {
          currentIndex++;
          selectedImage = null;
          _isCorrect = false;
        });
      } else {
        setState(() => _showCelebration = true);
      }
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
      setState(() => _isCorrect = false);
    }
  }

  Widget _buildCelebration() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey, Colors.grey],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/celebration.json',
                    width: 300, repeat: false),
                const Text(
                  'Baara ɲana kosɛbɛ!',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.celebration, color: Colors.white),
                  label: const Text('I tila la!',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
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
            colors: const [
              Colors.black,
              Colors.grey,
              Colors.black,
              Colors.grey,
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (contexts.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_showCelebration) return _buildCelebration();

    final currentContext = contexts[currentIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'Round ${currentIndex + 1}/${contexts.length}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / contexts.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.black),
                  SizedBox(width: 10),
                  Text(
                    'ja ɲuman sugandi',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _playAudio(currentContext['audio']),
                child: Text(
                  currentContext['word'],
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              IconButton(
                icon:
                    const Icon(Icons.volume_up, color: Colors.black, size: 40),
                onPressed: () => _playAudio(currentContext['audio']),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: currentContext['images'].map<Widget>((img) {
                    final isSelected = selectedImage == img['path'];
                    return AnimatedContainer(
                      duration: 300.ms,
                      curve: Curves.easeOutBack,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (img['correct'] ? Colors.green : Colors.red)
                              : Colors.transparent,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.asset(img['path'], fit: BoxFit.cover),
                            if (isSelected)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: Center(
                                    child: Icon(
                                      img['correct']
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      color: Colors.white,
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
                            delay:
                                100.ms * currentContext['images'].indexOf(img))
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
