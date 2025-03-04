// // import 'package:flutter/material.dart';
// // import 'package:flutter/animation.dart';
// // import 'package:literacy_app/models/question.dart';

// // class MultipleChoiceQuestionPage extends StatefulWidget {
// //   final List<Question> questions;
// //   final String title;

// //   const MultipleChoiceQuestionPage({
// //     required this.questions,
// //     required this.title,
// //     super.key,
// //   });

// //   @override
// //   _MultipleChoiceQuestionPageState createState() =>
// //       _MultipleChoiceQuestionPageState();
// // }

// // class _MultipleChoiceQuestionPageState extends State<MultipleChoiceQuestionPage>
// //     with SingleTickerProviderStateMixin {
// //   int currentQuestionIndex = 0;
// //   String? selectedAnswer;
// //   bool? isCorrect;
// //   bool isAnswered = false;
// //   late AnimationController _controller;
// //   late Animation<Offset> _shakeAnimation;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _controller = AnimationController(
// //       duration: const Duration(milliseconds: 500),
// //       vsync: this,
// //     );
// //     _shakeAnimation = Tween<Offset>(
// //       begin: Offset.zero,
// //       end: const Offset(0.05, 0),
// //     ).chain(CurveTween(curve: Curves.elasticIn)).animate(_controller);
// //   }

// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   void _checkAnswer(String answer) {
// //     setState(() {
// //       selectedAnswer = answer;
// //       isCorrect = (answer == widget.questions[currentQuestionIndex].correct);
// //       isAnswered = true;

// //       if (!isCorrect!) {
// //         _controller.forward().then((_) => _controller.reverse());
// //       }
// //     });
// //   }

// //   void _nextQuestion() {
// //     if (isAnswered) {
// //       setState(() {
// //         selectedAnswer = null;
// //         isCorrect = null;
// //         isAnswered = false;
// //         if (currentQuestionIndex < widget.questions.length - 1) {
// //           currentQuestionIndex++;
// //         } else {
// //           // All questions answered
// //           showDialog(
// //             context: context,
// //             builder: (_) => AlertDialog(
// //               title: const Text("Quiz Completed!"),
// //               content:
// //                   const Text("Congratulations! You've completed the quiz."),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   child: const Text("OK"),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     var currentQuestion = widget.questions[currentQuestionIndex];

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // Header
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     widget.title,
// //                     style: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.black,
// //                     ),
// //                   ),
// //                   Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.black,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: IconButton(
// //                       icon: const Icon(Icons.close, color: Colors.white),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             // Main Content
// //             Expanded(
// //               child: Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Text(
// //                       currentQuestion.question,
// //                       style: const TextStyle(
// //                           fontSize: 22, fontWeight: FontWeight.bold),
// //                       textAlign: TextAlign.center,
// //                     ),
// //                     const SizedBox(height: 20),
// //                     ...currentQuestion.options.map((option) => Padding(
// //                           padding: const EdgeInsets.symmetric(
// //                               vertical: 8.0, horizontal: 16.0),
// //                           child: SlideTransition(
// //                             position: (selectedAnswer == option &&
// //                                     isCorrect != null &&
// //                                     !isCorrect!)
// //                                 ? _shakeAnimation
// //                                 : const AlwaysStoppedAnimation(Offset.zero),
// //                             child: ElevatedButton(
// //                               onPressed: isAnswered
// //                                   ? null
// //                                   : () => _checkAnswer(option),
// //                               style: ElevatedButton.styleFrom(
// //                                 // Handle null with default color
// //                                 backgroundColor: selectedAnswer == option
// //                                     ? (isCorrect ?? false
// //                                         ? Colors.green
// //                                         : Colors.red)
// //                                     : Colors.purple,
// //                                 // Fix disabled button color
// //                                 disabledBackgroundColor:
// //                                     selectedAnswer == option
// //                                         ? (isCorrect ?? false
// //                                             ? Colors.green
// //                                             : Colors.red)
// //                                         : Colors.purple,
// //                                 shape: RoundedRectangleBorder(
// //                                   borderRadius: BorderRadius.circular(20),
// //                                   // p: const EdgeInsets.symmetric(
// //                                   //     vertical: 15, horizontal: 20),
// //                                 ),
// //                               ),
// //                               child: Text(
// //                                 option,
// //                                 style: const TextStyle(
// //                                     color: Colors.white, fontSize: 18),
// //                               ),
// //                             ),
// //                           ),
// //                         )),
// //                     const SizedBox(height: 20),
// //                     // Audio Control (Optional)
// //                     IconButton(
// //                       icon: const Icon(Icons.volume_up,
// //                           color: Colors.purple, size: 30),
// //                       onPressed: () {
// //                         // Add audio playback logic here
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             // Bottom Navigation
// //             Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: ElevatedButton(
// //                 onPressed: isAnswered ? _nextQuestion : null,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: isAnswered ? Colors.purple : Colors.grey,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   padding:
// //                       const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
// //                 ),
// //                 child: const Text(
// //                   "Next",
// //                   style: TextStyle(color: Colors.white, fontSize: 18),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/animation.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:literacy_app/models/question.dart';

// class MultipleChoiceQuestionPage extends StatefulWidget {
//   final List<Question> questions;
//   final String title;

//   const MultipleChoiceQuestionPage({
//     required this.questions,
//     required this.title,
//     super.key,
//   });

//   @override
//   _MultipleChoiceQuestionPageState createState() =>
//       _MultipleChoiceQuestionPageState();
// }

// class _MultipleChoiceQuestionPageState extends State<MultipleChoiceQuestionPage>
//     with SingleTickerProviderStateMixin {
//   int currentQuestionIndex = 0;
//   String? selectedAnswer;
//   bool? isCorrect;
//   bool isAnswered = false;
//   late AnimationController _controller;
//   late Animation<Offset> _shakeAnimation;

//   // New animations
//   final _questionAnimDuration = 500.ms;
//   final _optionAnimInterval = 100.ms;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 500),
//       vsync: this,
//     );
//     _shakeAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0.1, 0),
//     ).chain(CurveTween(curve: Curves.elasticOut)).animate(_controller);
//   }

//   void _checkAnswer(String answer) {
//     setState(() {
//       selectedAnswer = answer;
//       isCorrect = (answer == widget.questions[currentQuestionIndex].correct);
//       isAnswered = true;

//       if (!isCorrect!) {
//         _controller.forward().then((_) => _controller.reverse());
//       }
//     });
//   }

//   void _nextQuestion() {
//     if (isAnswered) {
//       setState(() {
//         selectedAnswer = null;
//         isCorrect = null;
//         isAnswered = false;
//         if (currentQuestionIndex < widget.questions.length - 1) {
//           currentQuestionIndex++;
//         } else {
//           showDialog(
//             context: context,
//             builder: (_) => _buildCelebrationDialog(),
//           );
//         }
//       });
//     }
//   }

//   Widget _buildCelebrationDialog() {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(30),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.purple.withOpacity(0.2),
//               spreadRadius: 10,
//               blurRadius: 20,
//             )
//           ],
//         ),
//         padding: const EdgeInsets.all(30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(Icons.celebration, size: 60, color: Colors.purple),
//             const SizedBox(height: 20),
//             const Text(
//               "Awesome Job!",
//               style: TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.purple),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "You've completed ${widget.title}!",
//               style: const TextStyle(fontSize: 18),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.purple,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//                 Navigator.pop(context);
//               },
//               child: const Text("YAY!", style: TextStyle(fontSize: 18)),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     var currentQuestion = widget.questions[currentQuestionIndex];

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom App Bar
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.purple.withOpacity(0.1),
//                 borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(30),
//                     bottomRight: Radius.circular(30)),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//               child: Row(
//                 children: [
//                   // Progress Indicator
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.purple,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Center(
//                       child: Text(
//                         '${currentQuestionIndex + 1}/${widget.questions.length}',
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 15),
//                   Expanded(
//                     child: Text(
//                       widget.title,
//                       style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.purple),
//                     ),
//                   ),
//                   // IconButton(
//                   //   icon: const Icon(Icons.close, color: Colors.purple),
//                   //   onPressed: () => Navigator.pop(context),
//                   // ),
//                 ],
//               ),
//             ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

//             // Main Content
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     // Question Card
//                     Container(
//                       margin: const EdgeInsets.only(top: 30, bottom: 40),
//                       padding: const EdgeInsets.all(25),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(25),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.purple.withOpacity(0.1),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           )
//                         ],
//                       ),
//                       child: Text(
//                         currentQuestion.question,
//                         style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w600,
//                             height: 1.3),
//                         textAlign: TextAlign.center,
//                       ),
//                     )
//                         .animate(delay: _questionAnimDuration)
//                         .scaleXY(begin: 0.8, curve: Curves.elasticOut),

//                     // Answer Options
//                     ...currentQuestion.options.asMap().entries.map((entry) {
//                       final index = entry.key;
//                       final option = entry.value;
//                       return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8),
//                           child: AnimatedSwitcher(
//                             duration: 300.ms,
//                             child: ElevatedButton(
//                               key: ValueKey(option),
//                               onPressed: isAnswered
//                                   ? null
//                                   : () => _checkAnswer(option),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: _getButtonColor(option),
//                                 foregroundColor: Colors.white,
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 18, horizontal: 25),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 elevation: 5,
//                                 shadowColor: Colors.purple.withOpacity(0.2),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   if (selectedAnswer == option)
//                                     Icon(
//                                       isCorrect!
//                                           ? Icons.check_circle
//                                           : Icons.cancel,
//                                       size: 24,
//                                     ).animate().scale(),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Text(
//                                       option,
//                                       style: const TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.w500),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                                 .animate(
//                                     delay: _questionAnimDuration +
//                                         _optionAnimInterval * index)
//                                 .fadeIn()
//                                 .slideX(begin: index.isEven ? 0.5 : -0.5),
//                           ));
//                     }),

//                     const Spacer(),

//                     // Next Button
//                     if (isAnswered)
//                       ElevatedButton(
//                         onPressed: _nextQuestion,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.purple,
//                           shape: const StadiumBorder(),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 16),
//                         ),
//                         child: const Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text("Next", style: TextStyle(fontSize: 18)),
//                             SizedBox(width: 10),
//                             Icon(Icons.arrow_forward, size: 20),
//                           ],
//                         ),
//                       ).animate().scale().shake(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color? _getButtonColor(String option) {
//     if (!isAnswered) return Colors.purple;
//     if (option == selectedAnswer) {
//       return isCorrect! ? Colors.green.shade400 : Colors.red.shade400;
//     }
//     if (option == widget.questions[currentQuestionIndex].correct) {
//       return Colors.green.shade400;
//     }
//     return Colors.purple.withOpacity(0.3);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:literacy_app/models/question.dart';

class MultipleChoiceQuestionPage extends StatefulWidget {
  final List<Question> questions;
  final String title;

  const MultipleChoiceQuestionPage({
    required this.questions,
    required this.title,
    super.key,
  });

  @override
  _MultipleChoiceQuestionPageState createState() =>
      _MultipleChoiceQuestionPageState();
}

class _MultipleChoiceQuestionPageState extends State<MultipleChoiceQuestionPage>
    with SingleTickerProviderStateMixin {
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool? isCorrect;
  bool isAnswered = false;
  late AnimationController _controller;
  late Animation<Offset> _shakeAnimation;

  // Animation durations
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

  void _checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      isCorrect = (answer == widget.questions[currentQuestionIndex].correct);
      isAnswered = true;

      if (!isCorrect!) {
        _controller.forward().then((_) => _controller.reverse());
      }
    });
  }

  void _nextQuestion() {
    if (isAnswered) {
      setState(() {
        selectedAnswer = null;
        isCorrect = null;
        isAnswered = false;
        if (currentQuestionIndex < widget.questions.length - 1) {
          currentQuestionIndex++;
        } else {
          showDialog(
            context: context,
            builder: (_) => _buildCelebrationDialog(),
          );
        }
      });
    }
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
              color: Colors.black.withOpacity(0.2), // Changed from purple
              spreadRadius: 10,
              blurRadius: 20,
            )
          ],
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 60,
              color: Colors.black, // Changed from purple
            ),
            const SizedBox(height: 20),
            const Text(
              "Awesome Job!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Changed from purple
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You've completed ${widget.title}!",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black, // Changed from default
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Changed from purple
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "YAY!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Explicitly set to white
                ),
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
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              decoration: const BoxDecoration(
                color: Colors.black, // Changed from purple.withOpacity(0.1)
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  // Progress Indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white, // Changed from purple
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${currentQuestionIndex + 1}/${widget.questions.length}',
                        style: const TextStyle(
                          color: Colors.black, // Changed from white
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
                        color: Colors.white, // Changed from purple
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Question Card
                    Container(
                      margin: const EdgeInsets.only(top: 30, bottom: 40),
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.1), // Changed from purple
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
                          color: Colors.black, // Explicitly set to black
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                        .animate(delay: _questionAnimDuration)
                        .scaleXY(begin: 0.8, curve: Curves.elasticOut),

                    // Answer Options
                    ...currentQuestion.options.asMap().entries.map((entry) {
                      final index = entry.key;
                      final option = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: AnimatedSwitcher(
                          duration: 300.ms,
                          child: ElevatedButton(
                            key: ValueKey(option),
                            onPressed:
                                isAnswered ? null : () => _checkAnswer(option),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getButtonColor(option),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 25,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black
                                  .withOpacity(0.2), // Changed from purple
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (selectedAnswer == option)
                                  Icon(
                                    isCorrect!
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 24,
                                    color: Colors.white,
                                  ).animate().scale(),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate(
                                delay: _questionAnimDuration +
                                    _optionAnimInterval * index,
                              )
                              .fadeIn()
                              .slideX(begin: index.isEven ? 0.5 : -0.5),
                        ),
                      );
                    }),

                    const Spacer(),

                    // Next Button
                    if (isAnswered)
                      ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Changed from purple
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
                              "Next",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white, // Explicitly set to white
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward,
                              size: 20,
                              color: Colors.white, // Changed from default
                            ),
                          ],
                        ),
                      ).animate().scale().shake(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getButtonColor(String option) {
    if (!isAnswered) return Colors.grey[800]!; // Dark gray for unanswered
    if (option == selectedAnswer) {
      return isCorrect!
          ? Colors.black
          : Colors.grey[600]!; // Black for correct, medium gray for incorrect
    }
    if (option == widget.questions[currentQuestionIndex].correct) {
      return Colors.black; // Black for correct answer
    }
    return Colors.grey[400]!; // Light gray for other options
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
