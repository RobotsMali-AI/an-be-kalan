import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_styles.dart';
import 'widgets/common/custom_bottom_nav.dart';

/// Demo page to showcase different navigation styles
class NavigationStyleDemo extends StatefulWidget {
  const NavigationStyleDemo({super.key});

  @override
  State<NavigationStyleDemo> createState() => _NavigationStyleDemoState();
}

class _NavigationStyleDemoState extends State<NavigationStyleDemo> {
  int _currentIndex = 0;
  int _selectedStyle = 0;

  final List<String> _styleNames = [
    'Custom Modern',
    'Floating Style',
    'Minimal Clean',
  ];

  final List<String> _descriptions = [
    'Modern design with rounded containers, smooth animations, and color-coded sections. Perfect for a professional learning app.',
    'Floating style with gradient backgrounds and elevated effects. Great for a premium, modern feel.',
    'Clean minimal design with indicator dots and underlines. Excellent for a sophisticated, uncluttered interface.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(
          'Navigation Styles',
          style: AppTextStyles.heading3,
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            // Style selector
            Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: AppDecorations.primaryCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Navigation Style',
                    style: AppTextStyles.heading4,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(_styleNames.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: RadioListTile<int>(
                        value: index,
                        groupValue: _selectedStyle,
                        onChanged: (value) {
                          setState(() {
                            _selectedStyle = value!;
                          });
                        },
                        title: Text(
                          _styleNames[index],
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          _descriptions[index],
                          style: AppTextStyles.bodySmall,
                        ),
                        activeColor: AppColors.primaryGreen,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: AppDecorations.primaryCard,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getTabIcon(_currentIndex),
                        size: 60,
                        color: _getTabColor(_currentIndex),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        _getTabName(_currentIndex),
                        style: AppTextStyles.heading2.copyWith(
                          color: _getTabColor(_currentIndex),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Current navigation style: ${_styleNames[_selectedStyle]}',
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    switch (_selectedStyle) {
      case 0:
        return CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        );
      case 1:
        return Stack(
          children: [
            const SizedBox(height: 100), // Space for floating nav
            FloatingBottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ],
        );
      case 2:
        return MinimalBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        );
      default:
        return CustomBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        );
    }
  }

  IconData _getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.book_rounded;
      case 1:
        return Icons.translate_rounded;
      case 2:
        return Icons.games_rounded;
      case 3:
        return Icons.person_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Color _getTabColor(int index) {
    switch (index) {
      case 0:
        return AppColors.primaryGreen;
      case 1:
        return AppColors.wisdomTeal;
      case 2:
        return AppColors.accentOrange;
      case 3:
        return AppColors.bookBlue;
      default:
        return AppColors.primaryGreen;
    }
  }

  String _getTabName(int index) {
    switch (index) {
      case 0:
        return 'Gafew';
      case 1:
        return 'Bamanankan';
      case 2:
        return 'Tulonkɛlaw';
      case 3:
        return 'Profil';
      default:
        return 'Gafew';
    }
  }
}
