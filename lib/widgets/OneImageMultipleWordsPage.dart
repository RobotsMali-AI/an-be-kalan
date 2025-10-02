import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/oneimagemultiplewordsquestion.dart';
import 'package:provider/provider.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

class OneImageMultipleWordsPage extends StatefulWidget {
  const OneImageMultipleWordsPage({
    required this.list,
    required this.user,
    super.key,
  });

  final List<OneImageMultipleWordsQuestion> list;
  final Users user;

  @override
  State<OneImageMultipleWordsPage> createState() =>
      _OneImageMultipleWordsPageState();
}

class _OneImageMultipleWordsPageState extends State<OneImageMultipleWordsPage>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController =
      ConfettiController(duration: const Duration(seconds: 2));

  late List<int> questionOrder;
  late AnimationController _progressController;
  late AnimationController _feedbackController;
  late AnimationController _slideController;

  late Animation<double> _progressAnimation;
  late Animation<double> _feedbackAnimation;
  late Animation<Offset> _slideAnimation;

  int currentLevel = 0;
  String? selectedOption;
  bool hasChecked = false;
  bool isAnswering = false;
  int correctAnswers = 0;
  int streak = 0;
  int maxStreak = 0;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeQuestions();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _feedbackController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _feedbackAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _feedbackController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _progressController.forward();
    _slideController.forward();
  }

  void _initializeQuestions() {
    questionOrder = List.generate(widget.list.length, (index) => index)
      ..shuffle();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _feedbackController.dispose();
    _slideController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkSelection() async {
    if (isAnswering || !mounted) return;

    setState(() {
      isAnswering = true;
      hasChecked = true;
    });

    HapticFeedback.mediumImpact();

    final currentQuestion = widget.list[questionOrder[currentLevel]];
    final isCorrect = selectedOption == currentQuestion.answer;

    _feedbackController.reset();
    _feedbackController.forward();

    if (isCorrect) {
      correctAnswers++;
      streak++;
      maxStreak = maxStreak > streak ? maxStreak : streak;
      widget.user.xp += _calculateXP();

      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
      _confettiController.play();
      if (mounted) HapticFeedback.lightImpact();
    } else {
      streak = 0;
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
      if (mounted) HapticFeedback.heavyImpact();
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          isAnswering = false;
        });
      }
    });
  }

  int _calculateXP() {
    int baseXP = 1;
    if (streak >= 3) baseXP += 1;
    if (streak >= 5) baseXP += 1;
    return baseXP;
  }

  Future<void> _nextQuestion() async {
    if (isAnswering) return;

    HapticFeedback.selectionClick();

    if (currentLevel < widget.list.length - 1) {
      _slideController.reset();

      setState(() {
        currentLevel++;
        hasChecked = false;
        selectedOption = null;
        showHint = false;
      });

      _progressController.animateTo((currentLevel + 1) / widget.list.length);
      _slideController.forward();
    } else {
      await _showCompletionDialog();
    }
  }

  Future<void> _showCompletionDialog() async {
    await context
        .read<ApiFirebaseService>()
        .saveUserData(widget.user.uid!, widget.user);

    final accuracy = (correctAnswers / widget.list.length * 100).round();
    final performance = _getPerformanceMessage(accuracy);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
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
                      performance['title']!,
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
                      performance['subtitle']!,
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
                              '$correctAnswers/${widget.list.length}',
                              Icons.check_circle),
                          _buildStatItem(
                              'Ɲɛnamaya', '$accuracy%', Icons.trending_up),
                          _buildStatItem(
                              'XP',
                              '+${correctAnswers * _calculateXP()}',
                              Icons.star),
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

  void _resetGame() {
    setState(() {
      currentLevel = 0;
      selectedOption = null;
      hasChecked = false;
      isAnswering = false;
      correctAnswers = 0;
      streak = 0;
      maxStreak = 0;
      showHint = false;
    });

    questionOrder.shuffle();
    _progressController.reset();
    _progressController.forward();
    _slideController.reset();
    _slideController.forward();
  }

  void _toggleHint() {
    setState(() {
      showHint = !showHint;
    });
    HapticFeedback.lightImpact();
  }

  Future<bool> _onWillPop() async {
    if (currentLevel == 0 && !hasChecked) {
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
            color: AppColors.primaryGreen,
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
            child: Text('Awɔ', style: TextStyle(color: AppColors.primaryGreen)),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.list[questionOrder[currentLevel]];
    final progress = (currentLevel + 1) / widget.list.length;

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
        backgroundColor: AppColors.offWhite,
        appBar: UnifiedAppBar(
          title: 'Ja ni Daɲɛw',
          actions: [
            AppBarActionButton(
              icon: showHint ? Icons.lightbulb : Icons.lightbulb_outline,
              onPressed: _toggleHint,
              tooltip: 'Dɛmɛ',
              backgroundColor: AppColors.accentSurfaceLight,
              iconColor:
                  showHint ? AppColors.accentOrange : AppColors.mediumGrey,
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withOpacity(0.1),
                    AppColors.wisdomTeal.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.quiz,
                    color: AppColors.primaryGreen,
                    size: 14,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${currentLevel + 1}/${widget.list.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
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
              // Progress bar
              _buildProgressBar(progress),

              // Main content
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        // Question text
                        _buildQuestionSection(currentQuestion.question),

                        const SizedBox(height: AppSpacing.md),

                        // Image and options in a column layout
                        Expanded(
                          child: Column(
                            children: [
                              // Image section (top)
                              Container(
                                height: 200,
                                width: double.infinity,
                                constraints: const BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child:
                                    _buildImageSection(currentQuestion.image),
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Options section (bottom)
                              Expanded(
                                child: _buildOptionsSection(currentQuestion),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        _buildActionButtons(),

                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ),

              // Confetti overlay
              if (hasChecked && selectedOption == currentQuestion.answer)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirection: 1.57,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 15,
                    gravity: 0.05,
                    shouldLoop: false,
                    colors: const [
                      Colors.yellow,
                      Colors.orange,
                      Colors.green,
                      Colors.blue,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      height: 6,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value * progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.wisdomTeal],
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionSection(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.08),
            AppColors.wisdomTeal.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            question,
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.primaryGreen,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (showHint) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: AppColors.accentOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: AppColors.accentOrange,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Ja in lajɛ ka ɲɛ!',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accentOrange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
          ],
        ],
      ),
    );
  }

  Widget _buildImageSection(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: AppColors.primaryGreen,
                    strokeWidth: 3,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: AppColors.mediumGrey,
                      size: 36,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ja ma jira',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(OneImageMultipleWordsQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildOptionCard(option, question.answer, index)
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: index * 100),
                duration: 300.ms,
              )
              .slideX(begin: 0.3),
        );
      }).toList(),
    );
  }

  Widget _buildOptionCard(String option, String answer, int index) {
    final bool isSelected = selectedOption == option;
    final bool isCorrect = option == answer;
    final bool showFeedback = hasChecked;

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (showFeedback) {
      if (isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
      } else if (isSelected) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
      } else {
        borderColor = AppColors.lightGrey;
        backgroundColor = AppColors.pureWhite;
        textColor = AppColors.mediumGrey;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primaryGreen;
        backgroundColor = AppColors.primaryGreen.withOpacity(0.1);
        textColor = AppColors.primaryGreen;
      } else {
        borderColor = AppColors.lightGrey;
        backgroundColor = AppColors.pureWhite;
        textColor = AppColors.charcoal;
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          if (isSelected && !showFeedback)
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: showFeedback || isAnswering
              ? null
              : () {
                  setState(() {
                    selectedOption = option;
                  });
                  HapticFeedback.selectionClick();
                },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Option indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected || (showFeedback && isCorrect)
                        ? (showFeedback && isCorrect
                            ? AppColors.success
                            : showFeedback && isSelected
                                ? AppColors.error
                                : AppColors.primaryGreen)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected || (showFeedback && isCorrect)
                          ? Colors.transparent
                          : AppColors.lightGrey,
                      width: 2,
                    ),
                  ),
                  child: showFeedback && (isCorrect || isSelected)
                      ? Icon(
                          isCorrect ? Icons.check : Icons.close,
                          color: AppColors.pureWhite,
                          size: 16,
                        )
                      : isSelected
                          ? Icon(
                              Icons.check,
                              color: AppColors.pureWhite,
                              size: 16,
                            )
                          : null,
                ),

                const SizedBox(width: AppSpacing.md),

                // Option text
                Expanded(
                  child: Text(
                    option,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Feedback animation
                if (showFeedback && (isCorrect || isSelected))
                  ScaleTransition(
                    scale: _feedbackAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: AppColors.pureWhite,
                        size: 14,
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

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      child: Row(
        children: [
          if (!hasChecked) ...[
            Expanded(
              child: PrimaryButton(
                text: 'Sɛgɛsɛgɛli',
                onPressed: selectedOption == null || isAnswering
                    ? () {}
                    : _checkSelection,
                icon: Icons.check,
                isLoading: isAnswering,
              ),
            ),
          ] else ...[
            Expanded(
              child: PrimaryButton(
                text: currentLevel < widget.list.length - 1 ? 'Nata' : 'Dafa',
                onPressed: isAnswering ? () {} : _nextQuestion,
                icon: currentLevel < widget.list.length - 1
                    ? Icons.arrow_forward
                    : Icons.flag,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
