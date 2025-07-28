import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/onewordmultipleimagequestions.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

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
      appBar: UnifiedAppBar(
        title: currentQuestion.question,
        showLogo: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentOrange.withOpacity(0.2),
                  AppColors.accentOrange.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.accentOrange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${_currentQuestionIndex + 1}/${questions.length}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accentOrange,
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / questions.length,
                  backgroundColor: AppColors.lightGrey.withOpacity(0.3),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentOrange),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentOrange.withOpacity(0.1),
                        AppColors.accentOrange.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Text(
                    currentQuestion.word,
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 36,
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: AppCard(
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: InkWell(
                              onTap: _hasAnswered
                                  ? null
                                  : () => _checkAnswer(option.image),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isCorrectOption
                                            ? AppColors.primaryGreen
                                            : AppColors.accentOrange)
                                        : AppColors.accentOrange
                                            .withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected
                                          ? (isCorrectOption
                                              ? AppColors.primaryGreen
                                                  .withOpacity(0.3)
                                              : AppColors.accentOrange
                                                  .withOpacity(0.3))
                                          : AppColors.accentOrange
                                              .withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.lg),
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
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  (isCorrectOption
                                                          ? AppColors
                                                              .primaryGreen
                                                          : AppColors
                                                              .accentOrange)
                                                      .withOpacity(0.8),
                                                  (isCorrectOption
                                                          ? AppColors
                                                              .primaryGreen
                                                          : AppColors
                                                              .accentOrange)
                                                      .withOpacity(0.6),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColors.pureWhite,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: (isCorrectOption
                                                              ? AppColors
                                                                  .primaryGreen
                                                              : AppColors
                                                                  .accentOrange)
                                                          .withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                padding: const EdgeInsets.all(
                                                    AppSpacing.md),
                                                child: Icon(
                                                  isCorrectOption
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color: isCorrectOption
                                                      ? AppColors.primaryGreen
                                                      : AppColors.accentOrange,
                                                  size: 50,
                                                ),
                                              ).animate().scale(),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ).animate().shakeX(
                              duration: const Duration(milliseconds: 300),
                              hz: 4,
                              amount: isSelected && !_isCorrect ? 2 : 0,
                            ),
                      ),
                    );
                  },
                ),
              ),
              if (_hasAnswered)
                Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentOrange,
                        AppColors.accentOrange.withOpacity(0.8)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentOrange.withOpacity(0.3),
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
                    child: Text(
                      _currentQuestionIndex < questions.length - 1
                          ? 'Nata'
                          : 'A bana',
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

  Widget _buildCelebration() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
        decoration: AppDecorations.primaryCard.copyWith(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentOrange.withOpacity(0.1),
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
                      AppColors.accentOrange.withOpacity(0.2),
                      AppColors.primaryGreen.withOpacity(0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withOpacity(0.3),
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
                repeat: false,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "Baara ka bon kosɛbɛ!",
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.accentOrange,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'I ye ɲuman $correctAnswers/${questions.length}. I donniya $correctAnswers sɔrɔ!',
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
                    colors: [AppColors.accentOrange, AppColors.primaryGreen],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.celebration, color: AppColors.pureWhite),
                  label: Text(
                    'A bana',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.pureWhite,
                    ),
                  ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
