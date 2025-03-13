import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/question.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

class MultipleChoiceQuestionPage extends StatefulWidget {
  final List<Question> questions;
  final String title;
  Users user;

  MultipleChoiceQuestionPage({
    required this.questions,
    required this.title,
    required this.user,
    super.key,
  });

  @override
  _MultipleChoiceQuestionPageState createState() =>
      _MultipleChoiceQuestionPageState();
}

class _MultipleChoiceQuestionPageState extends State<MultipleChoiceQuestionPage>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  int correctCount = 0; // Track the number of correct answers
  List<String> selectedAnswers = [];
  bool isAnswered = false;
  late AnimationController _controller;
  late Animation<Offset> _shakeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final _questionAnimDuration = 500.ms;
  final _optionAnimInterval = 100.ms;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);
  }

  void _toggleAnswer(String answer) {
    setState(() {
      final allowedSelections =
          widget.questions[currentQuestionIndex].correct.length;
      if (selectedAnswers.contains(answer)) {
        // Remove the answer if it's already selected.
        selectedAnswers.remove(answer);
      } else {
        // Only add the answer if the number of selections is below the allowed limit.
        if (selectedAnswers.length < allowedSelections) {
          selectedAnswers.add(answer);
        }
        // Optionally, you can provide feedback if the user tries to select too many answers.
      }
    });
  }

  void _playSound(String soundPath) async {
    await _audioPlayer.play(AssetSource(soundPath));
  }

  void _checkAnswers() {
    _playSound('sounds/check.mp3');
    setState(() {
      isAnswered = true;
      final correctAnswers = widget.questions[currentQuestionIndex].correct;
      if (selectedAnswers.length == correctAnswers.length &&
          selectedAnswers.every((answer) => correctAnswers.contains(answer))) {
        widget.user.xp += 1;
        correctCount += 1; // Increment correct count when answer is correct
        _playSound('sounds/correct.mp3');
      } else {
        _playSound('sounds/wrong.mp3');
        _controller.forward().then((_) => _controller.reverse());
      }
    });
  }

  void _nextQuestion() async {
    if (isAnswered) {
      setState(() {
        selectedAnswers = [];
        isAnswered = false;
        if (currentQuestionIndex < widget.questions.length - 1) {
          currentQuestionIndex++;
        } else {
          context
              .read<ApiFirebaseService>()
              .saveUserData(widget.user.uid!, widget.user);
          showDialog(
            context: context,
            builder: (_) => _buildCelebrationDialog(),
          );
        }
      });
    }
  }

  Color _getTileColor(String option) {
    if (!isAnswered) return Colors.white;
    final correctAnswers = widget.questions[currentQuestionIndex].correct;
    if (selectedAnswers.contains(option)) {
      return correctAnswers.contains(option) ? Colors.green : Colors.red;
    } else {
      return correctAnswers.contains(option)
          ? Colors.green.withOpacity(0.3)
          : Colors.white;
    }
  }

  Color _getTextColor(String option) {
    if (!isAnswered) return Colors.black;
    final tileColor = _getTileColor(option);
    return (tileColor == Colors.green || tileColor == Colors.red)
        ? Colors.white
        : Colors.black;
  }

  bool _isOverallCorrect() {
    final correctAnswers = widget.questions[currentQuestionIndex].correct;
    return selectedAnswers.length == correctAnswers.length &&
        selectedAnswers.every((answer) => correctAnswers.contains(answer));
  }

  Widget _buildCelebrationDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 10,
              blurRadius: 20,
            ),
          ],
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/animations/celebration.json', width: 200),
            const SizedBox(height: 20),
            const Text(
              "Baara ka bon kosɛbɛ!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              // Display correct answers and XP gained
              "I ye hakɛ $correctCount/${widget.questions.length} dafa ani $correctCount XP sɔrɔ!",
              style: const TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "YAY!",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${currentQuestionIndex + 1}/${widget.questions.length}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey[200]!],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 30, bottom: 40),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                          .animate(delay: _questionAnimDuration)
                          .scaleXY(begin: 0.8, curve: Curves.elasticOut),
                      ...currentQuestion.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: _getTileColor(option),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                option,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: _getTextColor(option),
                                ),
                              ),
                              value: selectedAnswers.contains(option),
                              onChanged: isAnswered
                                  ? null
                                  : (bool? value) {
                                      _toggleAnswer(option);
                                    },
                              activeColor: Colors.black,
                              checkColor: Colors.white,
                            ),
                          )
                              .animate(
                                delay: _questionAnimDuration +
                                    _optionAnimInterval * index,
                              )
                              .fadeIn()
                              .slideX(begin: index.isEven ? 0.5 : -0.5),
                        );
                      }),
                      const SizedBox(height: 20),
                      if (isAnswered)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            _isOverallCorrect()
                                ? "Baara ɲuman!"
                                : "Baara jugu!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _isOverallCorrect()
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      const SizedBox(height: 20),
                      if (!isAnswered)
                        ElevatedButton(
                          onPressed:
                              selectedAnswers.isNotEmpty ? _checkAnswers : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            "Ka jɛ",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      if (isAnswered)
                        ElevatedButton(
                          onPressed: _nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _isOverallCorrect() ? Colors.green : Colors.red,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Nata",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ).animate().scale().shake(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}
