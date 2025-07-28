import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/question.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

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
  late List<int> questionOrder; // Added for shuffling
  late Animation<Offset> _shakeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final _questionAnimDuration = 500.ms;
  final _optionAnimInterval = 100.ms;

  // Getter for the current question
  Question get currentQuestion =>
      widget.questions[questionOrder[currentQuestionIndex]];

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
    questionOrder = List.generate(widget.questions.length, (index) => index)
      ..shuffle();
  }

  void _toggleAnswer(String answer) {
    setState(() {
      final allowedSelections = currentQuestion.correct.length;
      if (selectedAnswers.contains(answer)) {
        selectedAnswers.remove(answer);
      } else {
        if (selectedAnswers.length < allowedSelections) {
          selectedAnswers.add(answer);
        }
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
      final correctAnswers = currentQuestion.correct;
      if (selectedAnswers.length == correctAnswers.length &&
          selectedAnswers.every((answer) => correctAnswers.contains(answer))) {
        widget.user.xp += 1;
        correctCount += 1;
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
    final correctAnswers = currentQuestion.correct;
    if (selectedAnswers.contains(option)) {
      return correctAnswers.contains(option)
          ? Colors.black.withOpacity(0.1)
          : Colors.black.withOpacity(0.05);
    } else {
      return correctAnswers.contains(option)
          ? Colors.black.withOpacity(0.1)
          : Colors.white;
    }
  }

  Color _getTextColor(String option) {
    if (!isAnswered) return AppColors.darkGrey;
    final correctAnswers = currentQuestion.correct;
    if (selectedAnswers.contains(option)) {
      return correctAnswers.contains(option)
          ? AppColors.primaryGreen
          : AppColors.accentOrange;
    } else {
      return correctAnswers.contains(option)
          ? AppColors.primaryGreen
          : AppColors.darkGrey;
    }
  }

  List<Color> _getOptionGradient(String option) {
    if (!isAnswered) {
      return [
        AppColors.wisdomTeal.withOpacity(0.1),
        AppColors.wisdomTeal.withOpacity(0.05),
      ];
    }
    final correctAnswers = currentQuestion.correct;
    if (selectedAnswers.contains(option)) {
      return correctAnswers.contains(option)
          ? [
              AppColors.primaryGreen.withOpacity(0.2),
              AppColors.primaryGreen.withOpacity(0.1)
            ]
          : [
              AppColors.accentOrange.withOpacity(0.2),
              AppColors.accentOrange.withOpacity(0.1)
            ];
    } else {
      return correctAnswers.contains(option)
          ? [
              AppColors.primaryGreen.withOpacity(0.2),
              AppColors.primaryGreen.withOpacity(0.1)
            ]
          : [
              AppColors.wisdomTeal.withOpacity(0.1),
              AppColors.wisdomTeal.withOpacity(0.05)
            ];
    }
  }

  Color _getOptionBorderColor(String option) {
    if (!isAnswered) return AppColors.wisdomTeal.withOpacity(0.3);
    final correctAnswers = currentQuestion.correct;
    if (selectedAnswers.contains(option)) {
      return correctAnswers.contains(option)
          ? AppColors.primaryGreen
          : AppColors.accentOrange;
    } else {
      return correctAnswers.contains(option)
          ? AppColors.primaryGreen
          : AppColors.wisdomTeal.withOpacity(0.3);
    }
  }

  bool _isOverallCorrect() {
    final correctAnswers = currentQuestion.correct;
    return selectedAnswers.length == correctAnswers.length &&
        selectedAnswers.every((answer) => correctAnswers.contains(answer));
  }

  Widget _buildCelebrationDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: AppDecorations.primaryCard.copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.wisdomTeal.withOpacity(0.1),
              AppColors.primaryGreen.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo with celebration animation
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.2),
                      AppColors.wisdomTeal.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Celebration animation
              Lottie.asset(
                'assets/animations/celebration.json',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "Baara ka bon kosɛbɛ!",
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primaryGreen,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "I ye hakɛ $correctCount/${widget.questions.length} dafa ani $correctCount XP sɔrɔ!",
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.wisdomTeal,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryGreen, AppColors.wisdomTeal],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: AppColors.pureWhite,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Laban!",
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.pureWhite,
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

  @override
  Widget build(BuildContext context) {
    var currentQuestion = widget.questions[questionOrder[currentQuestionIndex]];

    return Scaffold(
      appBar: UnifiedAppBar(
        title: widget.title,
        showLogo: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.wisdomTeal.withOpacity(0.2),
                  AppColors.wisdomTeal.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.wisdomTeal.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${currentQuestionIndex + 1}/${widget.questions.length}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.wisdomTeal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppCard(
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: AppSpacing.lg, bottom: AppSpacing.xl),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.wisdomTeal.withOpacity(0.1),
                                AppColors.wisdomTeal.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.wisdomTeal,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                          .animate(delay: _questionAnimDuration)
                          .scaleXY(begin: 0.8, curve: Curves.elasticOut),
                      ...currentQuestion.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          child: AppCard(
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _getOptionGradient(option),
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: _getOptionBorderColor(option),
                                    width: 2,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.lg,
                                      vertical: AppSpacing.md),
                                  title: Text(
                                    option,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: _getTextColor(option),
                                      fontWeight: FontWeight.w600,
                                      height: 1.5,
                                    ),
                                  ),
                                  value: selectedAnswers.contains(option),
                                  onChanged: isAnswered
                                      ? null
                                      : (bool? value) {
                                          _toggleAnswer(option);
                                        },
                                  activeColor: AppColors.wisdomTeal,
                                  checkColor: AppColors.pureWhite,
                                ),
                              ),
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
                      const SizedBox(height: AppSpacing.lg),
                      if (isAnswered)
                        AppCard(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isOverallCorrect()
                                    ? [
                                        AppColors.primaryGreen.withOpacity(0.2),
                                        AppColors.primaryGreen.withOpacity(0.1)
                                      ]
                                    : [
                                        AppColors.accentOrange.withOpacity(0.2),
                                        AppColors.accentOrange.withOpacity(0.1)
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Text(
                              _isOverallCorrect()
                                  ? "Baara ɲuman!"
                                  : "Baara jugu!",
                              style: AppTextStyles.heading3.copyWith(
                                color: _isOverallCorrect()
                                    ? AppColors.primaryGreen
                                    : AppColors.accentOrange,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      if (!isAnswered)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.wisdomTeal,
                                AppColors.wisdomTeal.withOpacity(0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.wisdomTeal.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedAnswers.isNotEmpty
                                ? _checkAnswers
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.pureWhite,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Text(
                              "Ka jɛ",
                              style: AppTextStyles.buttonText.copyWith(
                                color: AppColors.pureWhite,
                              ),
                            ),
                          ),
                        ),
                      if (isAnswered)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.primaryGreen.withOpacity(0.8)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.pureWhite,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Nata",
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 24,
                                  color: AppColors.pureWhite,
                                ),
                              ],
                            ),
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
