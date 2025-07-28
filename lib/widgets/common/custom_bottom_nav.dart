import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<GlobalKey>? navKeys;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.navKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.book_rounded,
              label: 'Gafew',
              color: AppColors.primaryGreen,
              key: navKeys?[0],
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.translate_rounded,
              label: 'Bamanankan',
              color: AppColors.wisdomTeal,
              key: navKeys?[1],
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.games_rounded,
              label: 'Tulonkɛlaw',
              color: AppColors.accentOrange,
              key: navKeys?[2],
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_rounded,
              label: 'Profil',
              color: AppColors.bookBlue,
              key: navKeys?[3],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
    GlobalKey? key,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      key: key,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with background
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: isSelected ? 40 : 40,
              height: isSelected ? 40 : 40,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.pureWhite : AppColors.mediumGrey,
                size: isSelected ? 24 : 22,
              ),
            ),

            // Spacing
            const SizedBox(height: AppSpacing.xs),

            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? color : AppColors.mediumGrey,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alternative floating style bottom navigation
class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AppSpacing.lg,
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.pureWhite,
              AppColors.pureWhite.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.05),
              blurRadius: 48,
              offset: const Offset(0, 24),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFloatingNavItem(
              index: 0,
              icon: Icons.auto_stories_rounded,
              color: AppColors.primaryGreen,
            ),
            _buildFloatingNavItem(
              index: 1,
              icon: Icons.translate_rounded,
              color: AppColors.wisdomTeal,
            ),
            _buildFloatingNavItem(
              index: 2,
              icon: Icons.games_rounded,
              color: AppColors.accentOrange,
            ),
            _buildFloatingNavItem(
              index: 3,
              icon: Icons.account_circle_rounded,
              color: AppColors.bookBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavItem({
    required int index,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: isSelected ? 56 : 48,
        height: isSelected ? 56 : 48,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Background gradient for selected state
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),

            // Icon
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  icon,
                  color:
                      isSelected ? AppColors.pureWhite : AppColors.mediumGrey,
                  size: isSelected ? 26 : 24,
                ),
              ),
            ),

            // Ripple effect
            if (isSelected)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Modern minimal bottom navigation
class MinimalBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MinimalBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMinimalNavItem(
                index: 0,
                icon: Icons.library_books_rounded,
                activeIcon: Icons.library_books,
                label: 'Gafew',
                color: AppColors.primaryGreen,
              ),
              _buildMinimalNavItem(
                index: 1,
                icon: Icons.translate_outlined,
                activeIcon: Icons.translate,
                label: 'Bamanankan',
                color: AppColors.wisdomTeal,
              ),
              _buildMinimalNavItem(
                index: 2,
                icon: Icons.games_outlined,
                activeIcon: Icons.games,
                label: 'Tulonkɛlaw',
                color: AppColors.accentOrange,
              ),
              _buildMinimalNavItem(
                index: 3,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                color: AppColors.bookBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color color,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with indicator
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? color : AppColors.mediumGrey,
                    size: 26,
                  ),
                ),

                // Active indicator dot
                if (isSelected)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // Label with animated underline
            Column(
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 250),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? color : AppColors.mediumGrey,
                  ),
                  child: Text(label),
                ),

                // Animated underline
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  height: 2,
                  width: isSelected ? 20 : 0,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
