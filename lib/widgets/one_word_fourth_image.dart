import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/onewordmultipleimagequestions.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';

class OneWordMultipleImagePage extends StatefulWidget {
  OneWordMultipleImagePage({required this.list, required this.user, super.key});
  List<OneWordMultipleImagesQuestion> list;
  Users user;
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
  bool _showCelebration = false;

  // Updated list of questions using the new class with Option objects
  List<OneWordMultipleImagesQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    questions = widget.list;
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
    final currentQuestion = questions[_currentQuestionIndex];
    // Find the selected option
    final selectedOption = currentQuestion.options.firstWhere(
      (opt) => opt.image == imagePath,
      orElse: () => Option(image: '', correct: false),
    );
    final isCorrect = selectedOption.correct;

    setState(() {
      _selectedImage = imagePath;
      _isCorrect = isCorrect;
    });

    if (isCorrect) {
      _confettiController.play();
      await Future.delayed(const Duration(seconds: 2));
      widget.user.xp += 1;
      if (_currentQuestionIndex < questions.length - 1) {
        setState(() {
          _currentQuestionIndex++;
          _selectedImage = null;
          _isCorrect = false;
          // _loadRandomImage();
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
      });
    } else {
      setState(() => _showCelebration = true);
    }
  }

  Widget _buildCelebration() {
    context
        .read<ApiFirebaseService>()
        .saveUserData(widget.user.uid!, widget.user);
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
                  'Baara Kabako!',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.celebration, color: Colors.white),
                  label: const Text('Laban!',
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Container(
          // padding: const EdgeInsets.all(16),
          // margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currentQuestion.question,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
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
              // Header with question and close button
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(height: 10),
              // Word display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  currentQuestion.word,
                  style: const TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // ListView for images
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: currentQuestion.options.length,
                  itemBuilder: (context, index) {
                    final option = currentQuestion.options[index];
                    final isSelected = _selectedImage == option.image;
                    final isCorrectOption = option.correct;
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
                          onTap: () => _checkAnswer(option.image),
                          child: AnimatedContainer(
                            duration: 300.ms,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? (isCorrectOption
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
                                  Image.network(
                                    option.image,
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
                                            isCorrectOption
                                                ? Icons.check_circle
                                                : Icons.cancel,
                                            color: Colors.white,
                                            size: 50,
                                          ).animate().scale(),
                                        ),
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
                    Lottie.asset('assets/animations/success.json',
                        width: 150, repeat: false),
                    ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Nata'),
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
