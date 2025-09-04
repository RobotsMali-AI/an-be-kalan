import 'package:flutter/material.dart';
import 'package:literacy_app/widgets/ChooseContextPage.dart';
import 'package:literacy_app/widgets/ChooseCorrectSpellPage.dart';
import 'package:literacy_app/widgets/WordsCompletePage.dart';
import 'package:literacy_app/widgets/alphabtPage.dart';
import 'package:literacy_app/widgets/syllabus.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';

class AcceuilNkalan extends StatelessWidget {
  const AcceuilNkalan({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the list of games with titles, images, icons, colors, and navigation pages
    final List<Map<String, dynamic>> games = [
      {
        'title': 'Daɲɛw dafali',
        'subtitle': 'Daɲɛw dafalen',
        'image': 'assets/imJeu3.jpg',
        'icon': Icons.text_fields,
        'color': AppColors.primaryGreen,
        'page': const WordsCompletePage(),
      },
      {
        'title': 'Sɛbɛn cogo ɲuman sugandili',
        'subtitle': 'Sɛbɛnni tiɲɛni',
        'image': 'assets/imJeu2.jpg',
        'icon': Icons.spellcheck,
        'color': AppColors.accentOrange,
        'page': const ChooseCorrectSpellPage(),
      },
      {
        'title': 'Ja ɲuman sukandili',
        'subtitle': 'Kuma hakɛ',
        'image': 'assets/imJeu1.jpg',
        'icon': Icons.psychology,
        'color': AppColors.wisdomTeal,
        'page': const ChooseContextPage(),
      },
      {
        'title': 'Kalan',
        'subtitle': 'Sɛbɛnni kalan',
        'image': 'assets/imJeu1.jpg',
        'icon': Icons.school,
        'color': AppColors.bookBlue,
        'page': const AlphabetPage(),
      },
      {
        'title': 'Kalan',
        'subtitle': 'Sɛbɛnni kalan',
        'image': 'assets/imJeu1.jpg',
        'icon': Icons.school,
        'color': AppColors.bookBlue,
        'page': const AlphabetPage(),
      },
      // {
      //   'title': 'Kalan',
      //   'image':
      //       'assets/imJeu1.jpg', // Replace with actual grayscale image path
      //   'page': SyllableSoundsScreen(),
      // },
    ];

    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'Nkalan',
        showLogo: false,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                decoration: AppDecorations.primaryCard.copyWith(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.accentOrange.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.games,
                      size: 48,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Nkalan Tulon',
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Bamanankan kalan ni tulon ye',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.wisdomTeal,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Games grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: AppSpacing.lg,
                    mainAxisSpacing: AppSpacing.lg,
                  ),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Container(
                      decoration: AppDecorations.primaryCard,
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => game['page']),
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(AppRadius.lg),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        game['image'],
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              (game['color'] as Color)
                                                  .withOpacity(0.6),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Icon overlay
                                      Positioned(
                                        top: AppSpacing.md,
                                        right: AppSpacing.md,
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                              AppSpacing.sm),
                                          decoration: BoxDecoration(
                                            color: AppColors.pureWhite
                                                .withOpacity(0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: (game['color'] as Color)
                                                    .withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            game['icon'] as IconData,
                                            color: game['color'] as Color,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.pureWhite,
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(AppRadius.lg),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      game['title'],
                                      style: AppTextStyles.heading4.copyWith(
                                        fontSize: 14,
                                        color: game['color'] as Color,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      game['subtitle'],
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.mediumGrey,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
