import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

class SyllableSoundsScreen extends StatefulWidget {
  @override
  _SyllableSoundsScreenState createState() => _SyllableSoundsScreenState();
}

class _SyllableSoundsScreenState extends State<SyllableSoundsScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<Map<String, String>> syllables = [
    {"text": "ba", "sound": "ba.mp3"},
    {"text": "da", "sound": "da.mp3"},
    {"text": "ga", "sound": "ga.mp3"},
    {"text": "ka", "sound": "ka.mp3"},
    {"text": "ma", "sound": "ma.mp3"},
    {"text": "pa", "sound": "pa.mp3"},
    {"text": "ta", "sound": "ta.mp3"},
    {"text": "za", "sound": "za.mp3"},
  ];
  List<Map<String, String>> currentSyllables = [];
  Map<String, String>? correctSyllable;
  int? selectedIndex;
  bool? isCorrect;
  int score = 0;
  int level = 1;
  String resultMessage = '';

  @override
  void initState() {
    super.initState();
    startNewRound();
  }

  void startNewRound() {
    setState(() {
      currentSyllables = List.from(syllables)..shuffle();
      currentSyllables = currentSyllables.sublist(0, 4);
      correctSyllable = currentSyllables[Random().nextInt(4)];
      selectedIndex = null;
      isCorrect = null;
      resultMessage = '';
      if (score > 0 && score % 5 == 0) {
        level++;
      }
    });
  }

  void _playSound(String soundFile) async {
    await _audioPlayer.play(AssetSource('sounds/$soundFile'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Sɛbɛnni kalan',
        showLogo: false,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            margin: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.bookBlue.withOpacity(0.2),
                  AppColors.bookBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: AppColors.bookBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Hakɛ: $score | Cogoya: $level',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.bookBlue,
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              // Header section
              AppCard(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.bookBlue.withOpacity(0.1),
                        AppColors.bookBlue.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.hearing,
                        size: 48,
                        color: AppColors.bookBlue,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Sɛbɛnni lamɛnni',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.bookBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sɛbɛnni lamɛn ka a sugandi',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.wisdomTeal,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Audio button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.bookBlue,
                      AppColors.bookBlue.withOpacity(0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bookBlue.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.volume_up,
                      color: AppColors.pureWhite, size: 60),
                  onPressed: () {
                    if (correctSyllable != null) {
                      _playSound(correctSyllable!['sound']!);
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Sɛbɛnni lamɛnni kɛ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.bookBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Result message
              if (resultMessage.isNotEmpty)
                AppCard(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCorrect!
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
                      resultMessage,
                      style: AppTextStyles.heading3.copyWith(
                        color: isCorrect!
                            ? AppColors.primaryGreen
                            : AppColors.accentOrange,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (resultMessage.isNotEmpty)
                const SizedBox(height: AppSpacing.lg),
              // Syllable grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final syllable = currentSyllables[index];
                    final isSelected = selectedIndex == index;
                    final scale =
                        isSelected ? (isCorrect == true ? 1.1 : 0.9) : 1.0;

                    return Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: InkWell(
                        onTap: () {
                          if (selectedIndex == null) {
                            setState(() {
                              selectedIndex = index;
                              isCorrect =
                                  syllable['text'] == correctSyllable!['text'];
                              if (isCorrect!) {
                                _playSound('success.mp3');
                                score++;
                                resultMessage = 'Tiɲɛ!';
                              } else {
                                _playSound('wrong.mp3');
                                resultMessage = 'A tɛ tiɲɛ!';
                              }
                              Future.delayed(const Duration(seconds: 1), () {
                                startNewRound();
                              });
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform: Matrix4.identity()..scale(scale),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? (isCorrect == true
                                    ? LinearGradient(colors: [
                                        AppColors.primaryGreen,
                                        AppColors.primaryGreen.withOpacity(0.8)
                                      ])
                                    : LinearGradient(colors: [
                                        AppColors.accentOrange,
                                        AppColors.accentOrange.withOpacity(0.8)
                                      ]))
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.bookBlue.withOpacity(0.1),
                                      AppColors.bookBlue.withOpacity(0.05),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                              color: isSelected
                                  ? (isCorrect == true
                                      ? AppColors.primaryGreen
                                      : AppColors.accentOrange)
                                  : AppColors.bookBlue.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? (isCorrect == true
                                        ? AppColors.primaryGreen
                                            .withOpacity(0.3)
                                        : AppColors.accentOrange
                                            .withOpacity(0.3))
                                    : AppColors.bookBlue.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              syllable['text']!,
                              style: AppTextStyles.heading1.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.pureWhite
                                    : AppColors.bookBlue,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
