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
  const OneWordMultipleImagePage(
      {required this.list, required this.user, super.key});
  final List<OneWordMultipleImagesQuestion> list;
  final Users user;

  @override
  _OneWordMultipleImagePageState createState() =>
      _OneWordMultipleImagePageState();
}

class _OneWordMultipleImagePageState extends State<OneWordMultipleImagePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  int _currentQuestionIndex = 0;
  String? _selectedImage;
  bool _isCorrect = false;
  bool _hasAnswered = false; // Track if the user has selected an answer
  final bool _showCelebration = false;
  int correctAnswers = 0; // Track correct answers

  List<OneWordMultipleImagesQuestion> questions = [];

  @override
  void initState() {
    super.initState();
    questions = widget.list;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _confettiController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _playAudio(String audioPath) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(audioPath));
  }

  void _checkAnswer(String imagePath) async {
    if (_hasAnswered) return; // Prevent multiple selections
    final currentQuestion = questions[_currentQuestionIndex];
    final selectedOption = currentQuestion.options.firstWhere(
      (opt) => opt.image == imagePath,
      orElse: () => Option(image: '', correct: false),
    );
    final isCorrect = selectedOption.correct;

    setState(() {
      _selectedImage = imagePath;
      _isCorrect = isCorrect;
      _hasAnswered = true;
    });

    if (isCorrect) {
      correctAnswers++;
      widget.user.xp += 1;
      _confettiController.play();
      _playAudio('sounds/correct.mp3');
    } else {
      _playAudio('sounds/wrong.mp3');
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedImage = null;
        _isCorrect = false;
        _hasAnswered = false;
      });
    } else {
      context
          .read<ApiFirebaseService>()
          .saveUserData(widget.user.uid!, widget.user);
      showDialog(
        context: context,
        builder: (_) => _buildCelebration(),
      );
    }
  }

  String performanceMessage() {
    double score = correctAnswers / questions.length;
    if (score == 1.0) {
      return 'Great Job! You got all answers correct!';
    } else if (score >= 0.7) {
      return 'Well Done! You did a fantastic job!';
    } else {
      return 'Good Effort! You can do even better!';
    }
  }

  Widget _buildCelebration() {
    // Save user data before celebrating.
    return Dialog(
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/celebration.json',
                width: 250,
                repeat: false,
              ),
              const SizedBox(height: 20),
              Text(
                performanceMessage(),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'I ye ɲuman $correctAnswers/${questions.length}. I donniya $correctAnswers sɔrɔ!',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.celebration, color: Colors.white),
                label: const Text(
                  'A bana',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
    final currentQuestion = questions[_currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Container(
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
            colors: [Colors.white, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
              ),
              const SizedBox(height: 10),
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
                          opacity: animationValue,
                          child: Transform.scale(
                            scale: animationValue,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GestureDetector(
                          onTap: _hasAnswered
                              ? null
                              : () => _checkAnswer(option.image),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? (isCorrectOption
                                        ? Colors.green
                                        : Colors.red)
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
                                duration: const Duration(milliseconds: 300),
                                hz: 4,
                                amount: isSelected && !_isCorrect ? 2 : 0,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_hasAnswered)
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentQuestionIndex < questions.length - 1
                        ? 'Nata'
                        : 'A bana',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
