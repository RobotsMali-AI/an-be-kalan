import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/trueorfalse.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

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
  final AudioPlayer _audioPlayer = AudioPlayer();
  int _correctCount = 0;
  late List<int> questionOrder; // Added to store shuffled indices

  @override
  void initState() {
    super.initState();
    // Initialize the shuffled question order
    questionOrder = List.generate(widget.questions.length, (index) => index)
      ..shuffle();
    _confettiController = ConfettiController(duration: 2.seconds);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _checkAnswer(String answer) async {
    setState(() {
      selectedAnswer = answer;
      isCorrect = answer ==
          (widget.questions[questionOrder[currentIndex]].answers
              ? 'Sɛbɛ'
              : 'Nkalon');
    });
    if (isCorrect!) {
      widget.user.xp += 1;
      _correctCount++;
      _confettiController.play();
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } else {
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
    }
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
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: Container(
          decoration: AppDecorations.primaryCard.copyWith(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.wisdomTeal.withOpacity(0.1),
                AppColors.accentOrange.withOpacity(0.1),
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
                        AppColors.wisdomTeal.withOpacity(0.2),
                        AppColors.accentOrange.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.wisdomTeal.withOpacity(0.3),
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
                // Star icon
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.wisdomTeal, AppColors.accentOrange],
                    ),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Icon(
                    Icons.star,
                    size: 60,
                    color: AppColors.pureWhite,
                  ),
                ).animate().rotate(duration: 700.ms),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  "Score Dafalen!",
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.wisdomTeal,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Tiɲɛ jaabi: $_correctCount / ${widget.questions.length}",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  "XP sɔrɔlen: $_correctCount",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.wisdomTeal, AppColors.accentOrange],
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
                      "KABAKOMA!",
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
      ),
    );
  }

  Widget _buildAnswerButton(String answer, IconData icon) {
    final isSelected = selectedAnswer == answer;
    final isCorrect = answer ==
        (widget.questions[questionOrder[currentIndex]].answers
            ? 'Sɛbɛ'
            : 'Nkalon');

    return SizedBox(
      width: 150,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: selectedAnswer == null
                ? [AppColors.wisdomTeal, AppColors.wisdomTeal.withOpacity(0.8)]
                : (isSelected
                    ? (this.isCorrect!
                        ? [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8)
                          ]
                        : [
                            AppColors.accentOrange,
                            AppColors.accentOrange.withOpacity(0.8)
                          ])
                    : (isCorrect
                        ? [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8)
                          ]
                        : [
                            AppColors.lightGrey,
                            AppColors.lightGrey.withOpacity(0.8)
                          ])),
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: (selectedAnswer == null
                      ? AppColors.wisdomTeal
                      : (isSelected
                          ? (this.isCorrect!
                              ? AppColors.primaryGreen
                              : AppColors.accentOrange)
                          : (isCorrect
                              ? AppColors.primaryGreen
                              : AppColors.lightGrey)))
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: selectedAnswer == null ? () => _checkAnswer(answer) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: AppColors.pureWhite,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected)
                Icon(icon, size: 24, color: AppColors.pureWhite)
                    .animate()
                    .scale(duration: _buttonAnimDuration),
              if (isSelected) const SizedBox(width: AppSpacing.sm),
              Text(
                answer,
                style: AppTextStyles.buttonText.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: answer == 'Sɛbɛ' ? 500.ms : 700.ms)
        .slideX(begin: answer == 'Sɛbɛ' ? -1 : 1, curve: Curves.easeOutBack)
        .fadeIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Tiɲɛ don walima Nkalon',
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
              '${currentIndex + 1}/${widget.questions.length}',
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
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          // Question Card
                          AppCard(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: AppSpacing.xl, bottom: AppSpacing.xl),
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
                                borderRadius:
                                    BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Text(
                                widget.questions[questionOrder[currentIndex]]
                                    .question,
                                style: AppTextStyles.heading2.copyWith(
                                  color: AppColors.wisdomTeal,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                              .animate(delay: 300.ms)
                              .scaleXY(curve: Curves.elasticOut),

                          const SizedBox(height: AppSpacing.xl),

                          // Answer Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildAnswerButton('Sɛbɛ', Icons.check_circle),
                              const SizedBox(width: AppSpacing.xl),
                              _buildAnswerButton('Nkalon', Icons.cancel),
                            ],
                          ),

                          const Spacer(),

                          // Next Button
                          if (selectedAnswer != null)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.wisdomTeal,
                                    AppColors.accentOrange
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.wisdomTeal.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
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
                                icon: Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.pureWhite,
                                )
                                    .animate(onPlay: (c) => c.repeat())
                                    .shake(delay: 2.seconds, hz: 2),
                                label: Text(
                                  'Nata',
                                  style: AppTextStyles.buttonText.copyWith(
                                    color: AppColors.pureWhite,
                                  ),
                                ),
                              ),
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
                  colors: [
                    AppColors.wisdomTeal,
                    AppColors.accentOrange,
                    AppColors.primaryGreen,
                  ],
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
