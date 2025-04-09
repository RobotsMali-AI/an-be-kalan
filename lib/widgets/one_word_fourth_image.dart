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
  late List<int> questionOrder; // List to store shuffled indices

  @override
  void initState() {
    super.initState();
    questions = widget.list;
    questionOrder = List.generate(questions.length, (index) => index)
      ..shuffle();
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
    final currentQuestion = questions[questionOrder[_currentQuestionIndex]];
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

  double getAnimationValue(int index) {
    double start = (index * 200) / 1100;
    double end = (index * 200 + 500) / 1100;
    double value = (_controller.value - start) / (end - start);
    return value.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[questionOrder[_currentQuestionIndex]];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentQuestion.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  currentQuestion.word,
                  style: const TextStyle(
                    fontSize: 36,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: _hasAnswered
                              ? null
                              : () => _checkAnswer(option.image),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? (isCorrectOption
                                        ? Colors.black
                                        : Colors.black.withOpacity(0.5))
                                    : Colors.transparent,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.network(
                                    option.image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 220,
                                  ),
                                  if (isSelected)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.4),
                                        child: Center(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              isCorrectOption
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              color: Colors.black,
                                              size: 50,
                                            ),
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
                Container(
                  margin: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentQuestionIndex < questions.length - 1
                          ? 'Nata'
                          : 'A bana',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebration() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Lottie.asset(
                'assets/animations/celebration.json',
                width: 200,
                repeat: false,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              performanceMessage(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'I ye ɲuman $correctAnswers/${questions.length}. I donniya $correctAnswers sɔrɔ!',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.celebration, color: Colors.white),
              label: const Text(
                'A bana',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
