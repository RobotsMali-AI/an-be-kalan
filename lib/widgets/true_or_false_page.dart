import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/trueorfalse.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class TrueFalseQuestionPage extends StatefulWidget {
  final List<Trueorfalse> questions;
  Users user;

  TrueFalseQuestionPage(
      {required this.questions, required this.user, super.key});

  @override
  _TrueFalseQuestionPageState createState() => _TrueFalseQuestionPageState();
}

class _TrueFalseQuestionPageState extends State<TrueFalseQuestionPage> {
  String? selectedAnswer;
  bool? isCorrect;
  int currentIndex = 0;
  late ConfettiController _confettiController;
  final _buttonAnimDuration = 400.ms;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: 2.seconds);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect =
          answer == (widget.questions[currentIndex].answers ? 'True' : 'False');
      if (isCorrect!) {
        widget.user.xp += 1;
        _confettiController.play();
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      selectedAnswer = null;
      isCorrect = null;
      if (currentIndex < widget.questions.length - 1) {
        currentIndex++;
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    context
        .read<ApiFirebaseService>()
        .saveUserData(widget.user.uid!, widget.user);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 60, color: Colors.black)
                  .animate()
                  .rotate(duration: 700.ms),
              const SizedBox(height: 20),
              const Text("Perfect Score!",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
              const SizedBox(height: 10),
              Text("You nailed all ${widget.questions.length} questions!",
                  style: const TextStyle(fontSize: 18, color: Colors.black)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("AWESOME!",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.grey.shade300, Colors.white]),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: const BoxDecoration(
                            color: Colors.black, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                              '${currentIndex + 1}/${widget.questions.length}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Text('True or False',
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      const Spacer(),
                    ],
                  ),
                ).animate().slideY(begin: -1).fadeIn(),

                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        // Question Card
                        Container(
                          margin: const EdgeInsets.only(top: 40, bottom: 50),
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  spreadRadius: 5),
                            ],
                          ),
                          child: Text(
                            widget.questions[currentIndex].question,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                                color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        )
                            .animate(delay: 300.ms)
                            .scaleXY(curve: Curves.elasticOut),

                        // Answer Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAnswerButton('True', Icons.check_circle),
                            const SizedBox(width: 30),
                            _buildAnswerButton('False', Icons.cancel),
                          ],
                        ),

                        const Spacer(),

                        // Next Button
                        if (selectedAnswer != null)
                          ElevatedButton.icon(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35, vertical: 16),
                                elevation: 5),
                            icon: const Icon(Icons.arrow_forward,
                                    color: Colors.white)
                                .animate(onPlay: (c) => c.repeat())
                                .shake(delay: 2.seconds, hz: 2),
                            label: const Text('Next',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ).animate().slideY(begin: 1).fadeIn(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                colors: const [
                  Colors.black,
                  Colors.grey,
                  Colors.white,
                ],
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                maxBlastForce: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer, IconData icon) {
    final isSelected = selectedAnswer == answer;
    final isCorrectAnswer =
        answer == (widget.questions[currentIndex].answers ? 'True' : 'False');

    return SizedBox(
      width: 150,
      child: ElevatedButton(
        onPressed: selectedAnswer == null ? () => _checkAnswer(answer) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getButtonColor(answer),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Icon(icon, size: 24)
                  .animate()
                  .scale(duration: _buttonAnimDuration),
            if (isSelected) const SizedBox(width: 10),
            Text(answer,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    )
        .animate(delay: answer == 'True' ? 500.ms : 700.ms)
        .slideX(begin: answer == 'True' ? -1 : 1, curve: Curves.easeOutBack)
        .fadeIn();
  }

  Color _getButtonColor(String answer) {
    if (selectedAnswer == null) return Colors.black;
    if (answer == selectedAnswer) {
      return isCorrect! ? Colors.grey.shade700 : Colors.grey.shade500;
    }
    if (answer == (widget.questions[currentIndex].answers ? 'True' : 'False')) {
      return Colors.grey.shade700;
    }
    return Colors.grey.shade300;
  }
}
