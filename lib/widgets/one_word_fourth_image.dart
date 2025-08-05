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
    final accuracy = (correctAnswers / questions.length * 100).round();
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
                            '$correctAnswers/${questions.length}',
                            Icons.check_circle),
                        _buildStatItem(
                            'Ɲɛnamaya', '$accuracy%', Icons.trending_up),
                        _buildStatItem('XP', '+$correctAnswers', Icons.star),
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
}
