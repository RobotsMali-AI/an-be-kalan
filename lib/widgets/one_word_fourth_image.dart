import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart'; // Replace just_audio with audioplayers for simplicity
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

/// Class to represent a question with its attributes
class Question {
  String title;
  String word;
  List<Map<String, dynamic>> images; // List of image paths and correctness
  String audioPath;

  Question({
    required this.title,
    required this.word,
    required this.images,
    required this.audioPath,
  });
}

class OneWordMultipleImagePage extends StatefulWidget {
  const OneWordMultipleImagePage({super.key});

  @override
  _OneWordMultipleImagePageState createState() =>
      _OneWordMultipleImagePageState();
}

class _OneWordMultipleImagePageState extends State<OneWordMultipleImagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: 2.seconds);
  int _currentQuestionIndex = 0;
  String? _selectedImage;
  bool _isCorrect = false;
  bool _showHint = false;
  bool _showCelebration = false;

  // List of questions with grayscale images and audio
  final List<Question> questions = [
    Question(
      title: 'Bagaguw Round 1',
      word: 'BAGAGUW',
      images: [
        {
          'path': 'assets/chicken.jpg',
          'correct': true
        }, // Grayscale chicken image
        {'path': 'assets/dog.jpg', 'correct': false}, // Grayscale dog image
        {'path': 'assets/cat.jpg', 'correct': false}, // Grayscale cat image
        {'path': 'assets/cat.jpg', 'correct': false}, // Grayscale rabbit image
      ],
      audioPath: 'assets/sounds/chicken.mp3',
    ),
    Question(
      title: 'Bagaguw Round 2',
      word: 'BAGAGUW',
      images: [
        {'path': 'assets/chicken.jpg', 'correct': true},
        {'path': 'assets/dog.jpg', 'correct': false},
        {'path': 'assets/cat.jpg', 'correct': false},
        {'path': 'assets/cat.jpg', 'correct': false},
      ],
      audioPath: 'assets/sounds/chicken.mp3',
    ),
    // Add more questions as needed...
  ];

//********************************************************************* */
  final List<String> _imageNames = [
    'ane',
    'boeuf',
    'coton', // Ajoutez autant d'images que vous avez
  ];

  final Question qt = Question(title: "", word: "", images: [], audioPath: "");

// Méthode pour charger une image et sa légende aléatoirement
  Future<void> _loadRandomImage() async {
    final random = Random();
    final randomIndex = random.nextInt(_imageNames.length);
    final selectedImageName = _imageNames[randomIndex];
    final randomIndex2 = random.nextInt(_imageNames.length);
    final selectedImageName2 = _imageNames[randomIndex2];
    final randomIndex3 = random.nextInt(_imageNames.length);
    final selectedImageName3 = _imageNames[randomIndex3];
    final randomIndex4 = random.nextInt(_imageNames.length);
    final selectedImageName4 = _imageNames[randomIndex4];

    // Chemin de l'image
    final imagePath = 'assets/nkalanIm/$selectedImageName.jpg';

    // Chemin de la légende
    final captionPath1 = 'assets/nkalanTx/$selectedImageName.txt';

    // Chemin de l'audio
    final audioPath = 'assets/sounds/$selectedImageName.mp3';

    // Charger la légende depuis le fichier texte
    final legendPath = await rootBundle.loadString(captionPath1);

    qt.title = "Ja sugantdi";
    qt.word = legendPath;
    qt.images = [
      {'path': 'assets/nkalanIm/$selectedImageName.jpg', 'correct': true},
      {'path': 'assets/nkalanIm/$selectedImageName2.jpg', 'correct': false},
      {'path': 'assets/nkalanIm/$selectedImageName3.jpg', 'correct': false},
      {'path': 'assets/nkalanIm/$selectedImageName4.jpg', 'correct': false},
    ];
    qt.audioPath = audioPath;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward(); // Start the animation when the page loads
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _playAudio(String audioPath) async {
    await _audioPlayer.stop(); // Prevent audio overlap
    await _audioPlayer.play(AssetSource(audioPath.split('assets/')[1]));
  }

  void _checkAnswer(String imagePath) async {
    final currentQuestion = qt;
    final isCorrect = currentQuestion.images
        .firstWhere((img) => img['path'] == imagePath)['correct'];

    setState(() {
      _selectedImage = imagePath;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _confettiController.play();
      _playAudio(currentQuestion.audioPath);
      await Future.delayed(const Duration(seconds: 2));

      if (_currentQuestionIndex < 11) {
        setState(() {
          _currentQuestionIndex++;
          _selectedImage = null;
          _isCorrect = false;
          _showHint = false;
          _loadRandomImage();
        });
      } else {
        setState(() => _showCelebration = true);
      }
    } else {
      await _audioPlayer.play(AssetSource('sounds/error.mp3'));
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedImage = null;
        _isCorrect = false;
        _showHint = false;
      });
    } else {
      setState(() => _showCelebration = true);
    }
  }

  Widget _buildCelebration() {
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/animations/celebration.json',
                    width: 300, repeat: false),
                const Text(
                  'Amazing Work!',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.celebration, color: Colors.white),
                  label: const Text('Finish!',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
            colors: [
              Colors.black,
              Colors.grey[800]!,
              Colors.grey[600]!,
              Colors.grey[400]!
            ],
          ),
        ),
      ],
    );
  }

  double getAnimationValue(int index) {
    double start = (index * 200) / 1100;
    double end = (index * 200 + 500) / 1100;
    double value = (_controller.value - start) / (end - start);
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_showCelebration) return _buildCelebration();

    final currentQuestion = questions[_currentQuestionIndex];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white], // Black-and-white theme
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title and close button
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currentQuestion.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(height: 16),
              // Instruction text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.black),
                    SizedBox(width: 10),
                    Text(
                      'Tap the correct picture for',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Word display with tap for audio
              GestureDetector(
                onTap: () => _playAudio(currentQuestion.audioPath),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    currentQuestion.word,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Audio playback button
              IconButton(
                icon:
                    const Icon(Icons.volume_up, color: Colors.black, size: 40),
                onPressed: () => _playAudio(currentQuestion.audioPath),
              ),
              const SizedBox(height: 20),
              // Hint button
              IconButton(
                icon: const Icon(Icons.lightbulb, color: Colors.black),
                onPressed: () => setState(() => _showHint = !_showHint),
              ),
              if (_showHint)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Hint: Look for the animal associated with eggs on a farm.',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              const SizedBox(height: 20),
              // ListView for images
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: currentQuestion.images.length,
                  itemBuilder: (context, index) {
                    final image = currentQuestion.images[index];
                    final isSelected = _selectedImage == image['path'];
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        double animationValue = getAnimationValue(index);
                        return Opacity(
                          opacity: animationValue, // Fade-in effect
                          child: Transform.scale(
                            scale: animationValue, // Scale-up effect
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: () => _checkAnswer(image['path']),
                          child: AnimatedContainer(
                            duration: 300.ms,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? (image['correct']
                                        ? Colors.black
                                        : Colors.grey[400]!)
                                    : Colors.transparent,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    image['path'],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 200,
                                  ),
                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.4),
                                        child: Center(
                                          child: Icon(
                                            image['correct']
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: Colors.white,
                                            size: 50,
                                          ).animate().scale(),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.volume_up,
                                          color: Colors.black),
                                      onPressed: () => _playAudio(
                                          'image_$index'), // Play specific audio for each image
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().shakeX(
                                duration: 300.ms,
                                hz: 4,
                                amount: isSelected && !_isCorrect ? 2 : 0,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isCorrect)
                Column(
                  children: [
                    Lottie.asset('assets/animations/success_bw.json',
                        width: 150, repeat: false),
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Next'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
