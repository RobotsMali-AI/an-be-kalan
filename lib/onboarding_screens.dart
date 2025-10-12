import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:literacy_app/auth.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Ka tɛmɛ',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.wisdomTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    _buildWelcomeScreen(),
                    _buildTranscriptionScreen(),
                    _buildTranslationScreen(),
                    _buildGamesScreen(),
                  ],
                ),
              ),

              // Page indicators and navigation
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    // Page indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _totalPages,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: _currentPage == index
                                ? AppColors.primaryGreen
                                : AppColors.lightGrey,
                          ),
                        ).animate().scale(
                              duration: 200.ms,
                              curve: Curves.easeInOut,
                            ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Next/Start button
                    Container(
                      width: double.infinity,
                      decoration: AppDecorations.primaryButtonDecoration,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Text(
                          _currentPage == _totalPages - 1
                              ? 'A daminɛ'
                              : 'Ka taa fɛ',
                          style:
                              AppTextStyles.buttonText.copyWith(fontSize: 18),
                        ),
                      ),
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

  Widget _buildWelcomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Add some top spacing to center content on larger screens
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          // App logo with animation
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.jpg',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ).animate().scale(
                duration: 800.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AppSpacing.xl),

          // App name
          Text(
            'An bɛ kalan',
            style: AppTextStyles.heading1.copyWith(
              fontSize: 36,
              color: AppColors.primaryGreen,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideY(
                begin: 0.3,
                duration: 600.ms,
                curve: Curves.easeOut,
              ),

          const SizedBox(height: AppSpacing.sm),

          // Subtitle
          Text(
            'Bamanankan kalan',
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 18,
              color: AppColors.wisdomTeal,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 500.ms).slideY(
                begin: 0.3,
                duration: 600.ms,
              ),

          const SizedBox(height: AppSpacing.xl),

          // Description
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.primaryCard.copyWith(
              gradient: LinearGradient(
                colors: [AppColors.pureWhite, AppColors.surfaceLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.school_outlined,
                  size: 40,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'I ni ce!',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bamanankankalan fɛrɛ koura min bɛ baara kɛ ni teknoloji IA ye walasa ka bamanankan kalanni nɔgɔya.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    height: 1.6,
                    color: AppColors.charcoal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 700.ms).slideY(
                begin: 0.5,
                duration: 800.ms,
                curve: Curves.easeOut,
              ),
          // Add bottom spacing for better scrolling experience
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }

  Widget _buildTranscriptionScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Add some top spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          // AI Icon with animation
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.bookBlue, AppColors.wisdomTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.bookBlue.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              Icons.mic_outlined,
              size: 60,
              color: AppColors.pureWhite,
            ),
          ).animate().scale(
                duration: 800.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Bamanankan fɔcogo sɛgɛsɛgɛli',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.bookBlue,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideX(
                begin: -0.3,
                duration: 600.ms,
              ),

          const SizedBox(height: AppSpacing.lg),

          // Features
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.primaryCard,
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: Icons.record_voice_over,
                  title: 'Kumakan Sɛgɛsɛgɛli',
                  description:
                      'Aw ye sɛbɛnni kalan walasa k\'aw kumakanw sɛgɛsɛgɛ',
                  color: AppColors.bookBlue,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildFeatureItem(
                  icon: Icons.spellcheck,
                  title: 'Filiw latilenni',
                  description:
                      'Aw ye aw kumakan bayelemanenw kalan ka aw ka filiw don',
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFeatureItem(
                  icon: Icons.analytics_outlined,
                  title: 'Ɲɛtaa Jateminɛ',
                  description: 'Aw ye aw ka ɲɛtaa jateminɛ',
                  color: AppColors.accentOrange,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(
                begin: 0.3,
                duration: 800.ms,
              ),
          // Add bottom spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }

  Widget _buildTranslationScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Add some top spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          // Translation Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentOrange.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              Icons.translate,
              size: 60,
              color: AppColors.pureWhite,
            ),
          ).animate().scale(
                duration: 800.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Bamanankan bayɛlɛmani',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.accentOrange,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideX(
                begin: 0.3,
                duration: 600.ms,
              ),

          const SizedBox(height: AppSpacing.lg),

          // Translation features
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.primaryCard,
            child: Column(
              children: [
                // Language pair display
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🇲🇱',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Bamanankan',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Icon(
                      Icons.swap_horiz,
                      color: AppColors.accentOrange,
                      size: 24,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🇫🇷',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Français',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                _buildFeatureItem(
                  icon: Icons.translate,
                  title: 'Bayɛlɛmani kɛ teliyala',
                  description: 'Daɲɛw ani kumasenw bayɛlɛmani',
                  color: AppColors.accentOrange,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFeatureItem(
                  icon: Icons.history,
                  title: 'Bayɛlɛmanenw mara',
                  description:
                      'Aw ka bayɛlɛmanenw mara walasa aw bɛ se ka segin u ma',
                  color: AppColors.wisdomTeal,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(
                begin: 0.3,
                duration: 800.ms,
              ),
          // Add bottom spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }

  Widget _buildGamesScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Add some top spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
          // Games Icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(
              Icons.games_outlined,
              size: 60,
              color: AppColors.pureWhite,
            ),
          ).animate().scale(
                duration: 800.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            'Tulon ani Jateminɛw',
            style: AppTextStyles.heading2.copyWith(
              color: AppColors.success,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms).slideX(
                begin: -0.3,
                duration: 600.ms,
              ),

          const SizedBox(height: AppSpacing.lg),

          // Games features
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: AppDecorations.primaryCard,
            child: Column(
              children: [
                _buildFeatureItem(
                  icon: Icons.quiz_outlined,
                  title: 'Jateminɛw',
                  description: 'Aw ka dɔnniya jate ni jateminɛw kɛcogo la',
                  color: AppColors.success,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFeatureItem(
                  icon: Icons.psychology,
                  title: 'Hakilijigin Tulon',
                  description:
                      'Tulon minnu bɛ hakili jigin ani ka kalan nɔgɔya',
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFeatureItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'Jɔyɔrɔw ani XP',
                  description: 'XP sɔrɔ, jɔyɔrɔw dabɔ ani ka i hakɛ tɔgɔw la',
                  color: AppColors.accentOrange,
                ),
                const SizedBox(height: AppSpacing.md),
                _buildFeatureItem(
                  icon: Icons.group_outlined,
                  title: 'Bɛɛ ye Kɛlɛn',
                  description:
                      'Kalan ni i teriya bɛɛ ye kɛlɛn, ka jɔyɔrɔw ɲɔgɔn fara',
                  color: AppColors.wisdomTeal,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(
                begin: 0.3,
                duration: 800.ms,
              ),
          // Add bottom spacing
          SizedBox(height: MediaQuery.of(context).size.height * 0.05),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading4.copyWith(
                  color: color,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.mediumGrey,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
