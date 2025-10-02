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
import 'package:confetti/confetti.dart';

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
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));
  int maxStreak = 0;
  int streak = 0;

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
    final accuracy = (correctCount / widget.questions.length * 100).round();
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryGreen.withOpacity(0.95),
              AppColors.wisdomTeal.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: 1.57,
                particleDrag: 0.05,
                emissionFrequency: 0.05,
                numberOfParticles: 20,
                gravity: 0.05,
                shouldLoop: false,
                colors: const [
                  Colors.yellow,
                  Colors.orange,
                  Colors.pink,
                  Colors.blue,
                  Colors.green,
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.jpg',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPerformanceIcon(accuracy),
                      color: AppColors.pureWhite,
                      size: 36,
                    ),
                  ).animate().scale(
                        delay: 300.ms,
                        duration: 500.ms,
                        curve: Curves.elasticOut,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _getPerformanceMessage(accuracy)['title']!,
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(
                        delay: 600.ms,
                        duration: 400.ms,
                      ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _getPerformanceMessage(accuracy)['subtitle']!,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.pureWhite.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(
                        delay: 800.ms,
                        duration: 400.ms,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.pureWhite.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                            'Tiɲɛ',
                            '$correctCount/${widget.questions.length}',
                            Icons.check_circle),
                        _buildStatItem(
                            'Ɲɛnamaya', '$accuracy%', Icons.trending_up),
                        _buildStatItem('XP',
                            '+${correctCount * _calculateXP()}', Icons.star),
                        if (maxStreak > 1)
                          _buildStatItem('Jɛka', '$maxStreak',
                              Icons.local_fire_department),
                      ],
                    ),
                  ).animate().slideY(
                        delay: 1000.ms,
                        begin: 0.3,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.wisdomTeal,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
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
                          vertical: AppSpacing.lg,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home,
                            color: AppColors.pureWhite,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'N sɔnna',
                            style: AppTextStyles.buttonText.copyWith(
                              color: AppColors.pureWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                        delay: 1200.ms,
                        duration: 400.ms,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (currentQuestionIndex == 0 && !isAnswered) {
      // First question, not answered yet - allow exit
      return true;
    }

    // Show confirmation dialog
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Ka bɔ?',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.wisdomTeal,
          ),
        ),
        content: Text(
          'Aw ka ɲɛtaa bɛna bɔ. Aw b\'a fɛ ka bɔ?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Ayi', style: TextStyle(color: AppColors.mediumGrey)),
          ),
          TextButton(
            onPressed: () {
              // Save progress before exiting
              context
                  .read<ApiFirebaseService>()
                  .saveUserData(widget.user.uid!, widget.user);
              Navigator.pop(context, true);
            },
            child: Text('Awɔ', style: TextStyle(color: AppColors.wisdomTeal)),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var currentQuestion = widget.questions[questionOrder[currentQuestionIndex]];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
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
                                          AppColors.primaryGreen
                                              .withOpacity(0.2),
                                          AppColors.primaryGreen
                                              .withOpacity(0.1)
                                        ]
                                      : [
                                          AppColors.accentOrange
                                              .withOpacity(0.2),
                                          AppColors.accentOrange
                                              .withOpacity(0.1)
                                        ],
                                ),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
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
                                  color:
                                      AppColors.primaryGreen.withOpacity(0.3),
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
      ),
    );
  }

  int _calculateXP() {
    int baseXP = 1;
    if (streak >= 3) baseXP += 1;
    if (streak >= 5) baseXP += 1;
    return baseXP;
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.pureWhite, size: 20),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.pureWhite.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Map<String, String> _getPerformanceMessage(int accuracy) {
    if (accuracy >= 90) {
      return {
        'title': 'Barika da!',
        'subtitle': 'I ye baara ɲuman kɛ kosɛbɛ!',
      };
    } else if (accuracy >= 70) {
      return {
        'title': 'Aw ni ce!',
        'subtitle': 'I ye ɲɛnamaya ɲuman sɔrɔ!',
      };
    } else if (accuracy >= 50) {
      return {
        'title': 'Ka ɲɛ!',
        'subtitle': 'I bɛ ɲɛtaa sɔrɔ, kɛ ka taa ɲɛ!',
      };
    } else {
      return {
        'title': 'Kalan kɛ!',
        'subtitle': 'Segin ka kɛ, i bɛna ɲɛ!',
      };
    }
  }

  IconData _getPerformanceIcon(int accuracy) {
    if (accuracy >= 90) return Icons.emoji_events;
    if (accuracy >= 70) return Icons.thumb_up;
    if (accuracy >= 50) return Icons.trending_up;
    return Icons.school;
  }

  void _resetGame() {
    setState(() {
      currentQuestionIndex = 0;
      selectedAnswers = [];
      isAnswered = false;
      correctCount = 0;
      streak = 0;
      maxStreak = 0;
    });
    questionOrder.shuffle();
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
