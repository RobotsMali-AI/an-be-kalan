import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';

class TutorialService {
  static const String _hasSeenHomeTutorial = 'hasSeenHomeTutorial';
  static const String _hasSeenBooksTutorial = 'hasSeenBooksTutorial';
  static const String _hasSeenLessonTutorial = 'hasSeenLessonTutorial';
  static const String _hasSeenTranslateTutorial = 'hasSeenTranslateTutorial';
  static const String _hasSeenProfileTutorial = 'hasSeenProfileTutorial';
  static const String _isFirstAppLaunch = 'isFirstAppLaunch';

  // Flag to prevent multiple tutorials from showing simultaneously
  static bool _isTutorialShowing = false;

  // Flag to track tutorial sequence during first launch
  static int _currentTutorialStep = 0;

  static Future<bool> hasSeenHomeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenHomeTutorial) ?? false;
  }

  static Future<bool> hasSeenBooksTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenBooksTutorial) ?? false;
  }

  static Future<bool> hasSeenLessonTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenLessonTutorial) ?? false;
  }

  static Future<bool> hasSeenTranslateTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenTranslateTutorial) ?? false;
  }

  static Future<bool> hasSeenProfileTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenProfileTutorial) ?? false;
  }

  static Future<bool> isFirstAppLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstAppLaunch) ?? true;
  }

  static Future<void> markHomeTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenHomeTutorial, true);
  }

  static Future<void> markBooksTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenBooksTutorial, true);
  }

  static Future<void> markLessonTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenLessonTutorial, true);
  }

  static Future<void> markTranslateTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenTranslateTutorial, true);
  }

  static Future<void> markProfileTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenProfileTutorial, true);
  }

  static Future<void> markFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstAppLaunch, false);
    _currentTutorialStep = 0;
  }

  // Reset all tutorials (useful for testing)
  static Future<void> resetAllTutorials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenHomeTutorial, false);
    await prefs.setBool(_hasSeenBooksTutorial, false);
    await prefs.setBool(_hasSeenLessonTutorial, false);
    await prefs.setBool(_hasSeenTranslateTutorial, false);
    await prefs.setBool(_hasSeenProfileTutorial, false);
    await prefs.setBool(_isFirstAppLaunch, true);
    _currentTutorialStep = 0;
  }

  // Check if any tutorial is currently showing
  static bool isTutorialShowing() {
    return _isTutorialShowing;
  }

  // Initialize first launch sequence
  static Future<void> initializeFirstLaunchSequence() async {
    final isFirstLaunch = await isFirstAppLaunch();
    if (isFirstLaunch) {
      _currentTutorialStep = 0;
    }
  }

  // Check if we should show tutorial based on first launch sequence
  static Future<bool> shouldShowTutorial(String tutorialType) async {
    // Prevent multiple tutorials from showing at once
    if (_isTutorialShowing) {
      print('Tutorial already showing, skipping $tutorialType');
      return false;
    }

    final isFirstLaunch = await isFirstAppLaunch();

    if (!isFirstLaunch) {
      // Not first launch, check individual tutorial status
      switch (tutorialType) {
        case 'home':
          return !(await hasSeenHomeTutorial());
        case 'books':
          return !(await hasSeenBooksTutorial());
        case 'lesson':
          return !(await hasSeenLessonTutorial());
        case 'translate':
          return !(await hasSeenTranslateTutorial());
        case 'profile':
          return !(await hasSeenProfileTutorial());
        default:
          return false;
      }
    }

    // First launch - show appropriate tutorial based on type
    switch (tutorialType) {
      case 'home':
        return _currentTutorialStep == 0 && !(await hasSeenHomeTutorial());
      case 'books':
        return !(await hasSeenBooksTutorial());
      case 'translate':
        return !(await hasSeenTranslateTutorial());
      case 'profile':
        return !(await hasSeenProfileTutorial());
      case 'lesson':
        return !(await hasSeenLessonTutorial());
      default:
        return false;
    }
  }

  // Check if element is properly visible for tutorial highlighting
  static bool _isElementVisible(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return false;

    try {
      final renderObject = context.findRenderObject() as RenderBox?;
      if (renderObject == null) return false;

      final size = renderObject.size;
      final position = renderObject.localToGlobal(Offset.zero);

      // Get screen size
      final screenSize = MediaQuery.of(context).size;
      final screenHeight = screenSize.height;
      final screenWidth = screenSize.width;

      // Calculate safe area (accounting for status bar, navigation bar, etc.)
      final mediaQuery = MediaQuery.of(context);
      final topPadding = mediaQuery.padding.top;
      final bottomPadding = mediaQuery.padding.bottom;

      // Reduced requirements for tutorial visibility - make it more flexible
      final minPadding = 40.0; // Reduced from 80px
      final tutorialContentSpace = 200.0; // Reduced from 320px

      // Check if element and tutorial content can fit properly on screen
      final elementTop = position.dy;
      final elementBottom = position.dy + size.height;
      final elementLeft = position.dx;
      final elementRight = position.dx + size.width;

      // More flexible visibility check - element just needs to be on screen
      final isHorizontallyVisible =
          elementLeft >= 0 && elementRight <= screenWidth;

      final isVerticallyVisible = elementTop >= topPadding &&
          elementBottom <= screenHeight - bottomPadding;

      // More flexible space check - allow tutorials with less space
      final hasSpaceAbove = elementTop >= topPadding + tutorialContentSpace;
      final hasSpaceBelow =
          elementBottom <= screenHeight - bottomPadding - tutorialContentSpace;
      final hasMinimalSpace = elementTop >= topPadding + 100 ||
          elementBottom <= screenHeight - bottomPadding - 100;

      final hasSpaceForContent =
          hasSpaceAbove || hasSpaceBelow || hasMinimalSpace;

      final isVisible =
          isHorizontallyVisible && isVerticallyVisible && hasSpaceForContent;

      if (!isVisible) {
        print(
            'Element not properly visible - Top: $elementTop, Bottom: $elementBottom, Screen: ${screenHeight - bottomPadding}, HasSpaceAbove: $hasSpaceAbove, HasSpaceBelow: $hasSpaceBelow, HasMinimalSpace: $hasMinimalSpace');
      }

      return isVisible;
    } catch (e) {
      print('Error checking element visibility: $e');
      return false;
    }
  }

  // Check if element is in bottom area of screen
  static bool _isBottomElement(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return false;

    try {
      final renderObject = context.findRenderObject() as RenderBox?;
      if (renderObject == null) return false;

      final position = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      final screenSize = MediaQuery.of(context).size;

      final elementBottom = position.dy + size.height;
      final screenHeight = screenSize.height;

      // Consider element as "bottom" if it's in the bottom 40% of screen
      return elementBottom > screenHeight * 0.6;
    } catch (e) {
      return false;
    }
  }

  // Get optimal alignment for tutorial content based on element position
  static ContentAlign _getOptimalContentAlign(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return ContentAlign.bottom;

    try {
      final renderObject = context.findRenderObject() as RenderBox?;
      if (renderObject == null) return ContentAlign.bottom;

      final position = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      final screenSize = MediaQuery.of(context).size;
      final mediaQuery = MediaQuery.of(context);

      final elementTop = position.dy;
      final elementBottom = position.dy + size.height;
      final screenHeight = screenSize.height;
      final topPadding = mediaQuery.padding.top;
      final bottomPadding = mediaQuery.padding.bottom;

      // Calculate available space above and below element
      final spaceAbove = elementTop - topPadding;
      final spaceBelow = screenHeight - bottomPadding - elementBottom;

      // Minimum space needed for tutorial content (approximately)
      final minContentSpace =
          280.0; // Increased for better bottom element handling

      // More aggressive detection for bottom elements (translate button case)
      if (elementBottom > screenHeight * 0.6 && spaceBelow < minContentSpace) {
        return ContentAlign.top; // Force above for elements in bottom 40%
      }
      // If element is in top quarter and not enough space above, force content below
      else if (elementTop < screenHeight * 0.25 &&
          spaceAbove < minContentSpace) {
        return ContentAlign.bottom;
      }
      // Special case: if element is very close to bottom (like translate button)
      else if (elementBottom > screenHeight * 0.75) {
        return ContentAlign.top; // Always force above for bottom 25%
      }
      // For middle elements, prefer the side with more space
      else if (spaceAbove > spaceBelow + 30) {
        return ContentAlign.top;
      } else if (spaceBelow > spaceAbove + 30) {
        return ContentAlign.bottom;
      } else {
        // Default to bottom for middle elements with similar space
        return ContentAlign.bottom;
      }
    } catch (e) {
      print('Error determining content alignment: $e');
      return ContentAlign.bottom;
    }
  }

  // Get optimal skip alignment based on element position
  static Alignment _getOptimalSkipAlign(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return Alignment.topCenter;

    try {
      final renderObject = context.findRenderObject() as RenderBox?;
      if (renderObject == null) return Alignment.topCenter;

      final position = renderObject.localToGlobal(Offset.zero);
      final size = renderObject.size;
      final screenSize = MediaQuery.of(context).size;

      final elementCenterX = position.dx + (size.width / 2);
      final elementCenterY = position.dy + (size.height / 2);
      final screenCenterX = screenSize.width / 2;
      final screenCenterY = screenSize.height / 2;

      // Determine best position for skip button based on element location
      if (elementCenterY < screenCenterY / 2) {
        // Element in top quarter - put skip at bottom
        return elementCenterX < screenCenterX
            ? Alignment.bottomRight
            : Alignment.bottomLeft;
      } else if (elementCenterY > screenCenterY * 1.5) {
        // Element in bottom quarter - put skip at top
        return elementCenterX < screenCenterX
            ? Alignment.topRight
            : Alignment.topLeft;
      } else {
        // Element in middle - put skip at opposite horizontal side
        return elementCenterX < screenCenterX
            ? Alignment.centerRight
            : Alignment.centerLeft;
      }
    } catch (e) {
      print('Error determining skip alignment: $e');
      return Alignment.topCenter;
    }
  }

  // Scroll element into view if needed with proper positioning
  static Future<void> _ensureElementVisible(GlobalKey key,
      {bool isBottom = false}) async {
    final context = key.currentContext;
    if (context == null) return;

    // Wait for UI to settle
    await Future.delayed(const Duration(milliseconds: 150));

    // Check if element is already properly visible
    if (_isElementVisible(key)) {
      print('Element already properly visible, skipping scroll');
      return;
    }

    try {
      final renderObject = context.findRenderObject();
      if (renderObject != null) {
        final renderBox = renderObject as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          final screenSize = MediaQuery.of(context).size;
          final mediaQuery = MediaQuery.of(context);

          final screenHeight = screenSize.height;
          final topPadding = mediaQuery.padding.top;
          final bottomPadding = mediaQuery.padding.bottom;

          final elementTop = position.dy;
          final elementBottom = position.dy + size.height;

          // Calculate optimal alignment to ensure element is visible with tutorial content
          double alignment = 0.5; // Default center

          // If element is too close to top, push it down
          if (elementTop < topPadding + 150) {
            alignment = 0.2; // Show element in upper part of screen
          }
          // If element is too close to bottom, pull it up more aggressively
          else if (elementBottom > screenHeight - bottomPadding - 200) {
            alignment =
                0.9; // Show element higher up for tutorial content space
          }
          // If element is in middle but tutorial content won't fit, adjust
          else {
            final availableSpaceAbove = elementTop - topPadding;
            final availableSpaceBelow =
                screenHeight - bottomPadding - elementBottom;

            // If more space below, position element higher
            if (availableSpaceBelow > availableSpaceAbove + 100) {
              alignment = 0.3;
            }
            // If more space above, position element lower
            else if (availableSpaceAbove > availableSpaceBelow + 100) {
              alignment = 0.7;
            }
            // Otherwise center
          }

          print(
              'Scrolling element to alignment: $alignment (elementTop: $elementTop, elementBottom: $elementBottom, screenHeight: $screenHeight)');

          await Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: alignment,
          );

          // Wait for scroll to complete and UI to settle
          await Future.delayed(const Duration(milliseconds: 300));

          // Verify element is now visible, if not try one more time with center alignment
          if (!_isElementVisible(key)) {
            print(
                'Element still not visible after scroll, trying center alignment');
            await Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.5,
            );
            await Future.delayed(const Duration(milliseconds: 200));
          }

          print('Element scroll completed');
        }
      }
    } catch (e) {
      print('Tutorial scroll failed: $e');
      // Continue with tutorial even if scrolling fails
    }
  }

  // Home Tutorial - 4 main navigation tabs
  static Future<void> showHomeTutorial(
    BuildContext context, {
    required List<GlobalKey> navKeys, // Keys for the 4 navigation tabs
  }) async {
    if (!(await shouldShowTutorial('home'))) return;

    await initializeFirstLaunchSequence();

    final targets = <TargetFocus>[];

    // Books tab
    targets.add(
      TargetFocus(
        identify: "books_tab",
        keyTarget: navKeys[0],
        alignSkip: _getOptimalSkipAlign(navKeys[0]),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(navKeys[0]),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.book,
              title: 'Gafew',
              description:
                  'Nin ye gafew yɔrɔ ye. Aw bɛ se ka gafe caman lajɛ ani ka kalan daminɛ.',
              isFirst: true,
              controller: controller,
            ),
          ),
        ],
      ),
    );

    // Translation tab
    targets.add(
      TargetFocus(
        identify: "translation_tab",
        keyTarget: navKeys[1],
        alignSkip: _getOptimalSkipAlign(navKeys[1]),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(navKeys[1]),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.translate,
              title: 'Bamanankan-Faransi',
              description:
                  'Aw bɛ se ka daɲɛw baara bamanankan na ka kɛ faransi ye, ani ka faransi daɲɛw baara bamanankan na.',
              controller: controller,
            ),
          ),
        ],
      ),
    );

    // Games/Nkalan tab
    targets.add(
      TargetFocus(
        identify: "games_tab",
        keyTarget: navKeys[2],
        alignSkip: _getOptimalSkipAlign(navKeys[2]),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(navKeys[2]),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.games,
              title: 'Nkalan',
              description:
                  'Yan, aw bɛ se ka tulon kɛ ani ka jateminɛw ɲɛnabɔ walasa ka dɔnniya jigin.',
              controller: controller,
            ),
          ),
        ],
      ),
    );

    // Profile tab
    targets.add(
      TargetFocus(
        identify: "profile_tab",
        keyTarget: navKeys[3],
        alignSkip: _getOptimalSkipAlign(navKeys[3]),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(navKeys[3]),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.person,
              title: 'Profil',
              description:
                  'Aw ka kunnafoniw, aw ka ɲɛtaa ani aw ka paramɛtiriw bɛ yan.',
              isLast: true,
              controller: controller,
              onComplete: () async {
                await markHomeTutorialSeen();
                _currentTutorialStep = 1;
                // Mark first launch complete after home tutorial
                await markFirstLaunchComplete();
              },
            ),
          ),
        ],
      ),
    );

    _showTutorial(context, targets);
  }

  // Books Tutorial - search and book interaction
  static Future<void> showBooksTutorial(
    BuildContext context, {
    required GlobalKey searchKey,
    required GlobalKey firstBookKey,
    GlobalKey? refreshKey,
    bool waitForHomeTutorial = true,
  }) async {
    // Check if we should show this tutorial
    if (!(await shouldShowTutorial('books'))) return;

    // If home tutorial hasn't been seen yet, wait for it to complete or skip books tutorial
    if (waitForHomeTutorial) {
      final hasSeenHomeTutorial = await TutorialService.hasSeenHomeTutorial();
      if (!hasSeenHomeTutorial) {
        // Home tutorial should show first - don't show books tutorial
        return;
      }
    }

    final targets = <TargetFocus>[];

    // Search functionality - ensure it's visible
    targets.add(
      TargetFocus(
        identify: "search_books",
        keyTarget: searchKey,
        alignSkip: _getOptimalSkipAlign(searchKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(searchKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.search,
              title: 'Gafe ɲinini',
              description:
                  'Yan, aw bɛ se ka gafe kɛnɛ ni u tɔgɔ sɛbɛnni ye. Sɛbɛnni daminɛ walasa ka ɲinini kɛ.',
              isFirst: true,
              controller: controller,
              onShow: () => _ensureElementVisible(searchKey),
            ),
          ),
        ],
      ),
    );

    // Refresh button (if available) - handle top positioning
    if (refreshKey != null) {
      targets.add(
        TargetFocus(
          identify: "refresh_books",
          keyTarget: refreshKey,
          alignSkip: _getOptimalSkipAlign(refreshKey),
          contents: [
            TargetContent(
              align: _getOptimalContentAlign(refreshKey),
              builder: (context, controller) => _buildTutorialContent(
                icon: Icons.refresh,
                title: 'Gafew kurala',
                description:
                    'Nin button in na, aw bɛ se ka gafe kuraw lajɛ walasa ka kura sɔrɔ.',
                controller: controller,
                onShow: () => _ensureElementVisible(refreshKey),
              ),
            ),
          ],
        ),
      );
    }

    // First book interaction - use smart positioning
    targets.add(
      TargetFocus(
        identify: "select_book",
        keyTarget: firstBookKey,
        alignSkip: _getOptimalSkipAlign(firstBookKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(firstBookKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.touch_app,
              title: 'Gafe kirayɛ',
              description:
                  'Gafe dɔ kirayɛ walasa ka kalan daminɛ. Gafe kɔnɔ, aw bɛ na ka kalan sahaniw lajɛ.',
              isLast: true,
              controller: controller,
              onComplete: () => markBooksTutorialSeen(),
              onShow: () => _ensureElementVisible(firstBookKey),
            ),
          ),
        ],
      ),
    );

    _showTutorial(context, targets);
  }

  // Lesson Tutorial - recording and playback
  static Future<void> showLessonTutorial(
    BuildContext context, {
    required GlobalKey micButtonKey,
    required GlobalKey audioButtonKey,
    required GlobalKey resetButtonKey,
    GlobalKey? exitButtonKey,
  }) async {
    // Check if we should show this tutorial
    if (!(await shouldShowTutorial('lesson'))) return;
    final targets = <TargetFocus>[];

    // Audio play button - use smart positioning
    targets.add(
      TargetFocus(
        identify: "audio_play",
        keyTarget: audioButtonKey,
        alignSkip: _getOptimalSkipAlign(audioButtonKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(audioButtonKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.volume_up,
              title: 'Kumakan lamɛnni',
              description:
                  'Fɔlɔ, nin button in kirayɛ walasa ka kumasen lamɛn. O bɛna aw dɛmɛ ka fɔcogo ɲuman dɔn.',
              isFirst: true,
              controller: controller,
              onShow: () => _ensureElementVisible(audioButtonKey),
            ),
          ),
        ],
      ),
    );

    // Recording button - use smart positioning
    targets.add(
      TargetFocus(
        identify: "mic_record",
        keyTarget: micButtonKey,
        alignSkip: _getOptimalSkipAlign(micButtonKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(micButtonKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.mic,
              title: 'Kan taju',
              description:
                  'Kumasen lamɛnni kɔfɛ, nin button in kirayɛ walasa ka aw ka fɔli taju. Fɔ kumasen in cogo kelen na.',
              controller: controller,
              onShow: () => _ensureElementVisible(micButtonKey),
            ),
          ),
        ],
      ),
    );

    // Reset button - use smart positioning
    targets.add(
      TargetFocus(
        identify: "reset_record",
        keyTarget: resetButtonKey,
        alignSkip: _getOptimalSkipAlign(resetButtonKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(resetButtonKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.refresh,
              title: 'Kan juturu segin',
              description:
                  'Ni aw tɛ kɛnɛ don aw ka kan juturu la, nin button in kirayɛ walasa ka a segin ka wɛrɛ taju.',
              controller: controller,
              onShow: () => _ensureElementVisible(resetButtonKey),
            ),
          ),
        ],
      ),
    );

    // Exit button (if available) - use smart positioning
    if (exitButtonKey != null) {
      targets.add(
        TargetFocus(
          identify: "exit_lesson",
          keyTarget: exitButtonKey,
          alignSkip: _getOptimalSkipAlign(exitButtonKey),
          contents: [
            TargetContent(
              align: _getOptimalContentAlign(exitButtonKey),
              builder: (context, controller) => _buildTutorialContent(
                icon: Icons.close,
                title: 'Kalan dabɔ',
                description:
                    'Kalan kɔfɛ walasa ka segin gafew la, nin button in kirayɛ. Aw ka ɲɛtaa bɛna mara.',
                isLast: true,
                controller: controller,
                onComplete: () => markLessonTutorialSeen(),
                onShow: () => _ensureElementVisible(exitButtonKey),
              ),
            ),
          ],
        ),
      );
    } else {
      // If no exit button, mark as last step on reset
      targets.last = TargetFocus(
        identify: "reset_record",
        keyTarget: resetButtonKey,
        alignSkip: _getOptimalSkipAlign(resetButtonKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(resetButtonKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.refresh,
              title: 'Kan juturu segin',
              description:
                  'Ni aw tɛ kɛnɛ don aw ka kan juturu la, nin button in kirayɛ walasa ka a segin ka wɛrɛ taju.',
              isLast: true,
              controller: controller,
              onComplete: () => markLessonTutorialSeen(),
              onShow: () => _ensureElementVisible(resetButtonKey),
            ),
          ),
        ],
      );
    }

    _showTutorial(context, targets);
  }

  // Translation Tutorial - language selection and translation features
  static Future<void> showTranslateTutorial(
    BuildContext context, {
    required GlobalKey inputFieldKey,
    required GlobalKey swapButtonKey,
    required GlobalKey translateButtonKey,
    GlobalKey? languageDropdownKey,
  }) async {
    // Check if we should show this tutorial
    if (!(await shouldShowTutorial('translate'))) return;

    // Force show tutorial even if elements aren't perfectly positioned
    _isTutorialShowing = true;

    final targets = <TargetFocus>[];

    // Language dropdown (if available) - use smart positioning
    if (languageDropdownKey != null) {
      targets.add(
        TargetFocus(
          identify: "language_selection",
          keyTarget: languageDropdownKey,
          alignSkip: _getOptimalSkipAlign(languageDropdownKey),
          contents: [
            TargetContent(
              align: _getOptimalContentAlign(languageDropdownKey),
              builder: (context, controller) => _buildTutorialContent(
                icon: Icons.language,
                title: 'Kan sugandi',
                description:
                    'Yan, aw bɛ se ka kan sugandi min na aw bɛ baara kɛ ani kan min ma aw bɛ baara kɛ.',
                isFirst: true,
                controller: controller,
                onShow: () => _ensureElementVisible(languageDropdownKey),
              ),
            ),
          ],
        ),
      );
    }

    // Input field - use smart positioning
    targets.add(
      TargetFocus(
        identify: "input_field",
        keyTarget: inputFieldKey,
        alignSkip: _getOptimalSkipAlign(inputFieldKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(inputFieldKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.edit,
              title: 'Sɛbɛnni yɔrɔ',
              description:
                  'Yan, aw bɛ daɲɛ min bɛ ka bamanankan kɛ, o sɛbɛn. Daɲɛ surun walima janya, o bɛɛ bɛ se ka kɛ.',
              isFirst: languageDropdownKey == null,
              controller: controller,
              onShow: () => _ensureElementVisible(inputFieldKey),
            ),
          ),
        ],
      ),
    );

    // Swap button - use smart positioning
    targets.add(
      TargetFocus(
        identify: "swap_languages",
        keyTarget: swapButtonKey,
        alignSkip: _getOptimalSkipAlign(swapButtonKey),
        contents: [
          TargetContent(
            align: _getOptimalContentAlign(swapButtonKey),
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.swap_vert,
              title: 'Kanw cayali',
              description:
                  'Nin button in na, aw bɛ se ka kanw cayali - bamanankan ka kɛ faransi ye walima faransi ka kɛ bamanankan ye.',
              controller: controller,
              isBottomElement: _isBottomElement(swapButtonKey),
              onShow: () => _ensureElementVisible(swapButtonKey),
            ),
          ),
        ],
      ),
    );

    // Translate button - use smart positioning with compact content for bottom element
    // Force show this target even if visibility check fails
    targets.add(
      TargetFocus(
        identify: "translate_button",
        keyTarget: translateButtonKey,
        alignSkip: _getOptimalSkipAlign(translateButtonKey),
        contents: [
          TargetContent(
            align: ContentAlign.top, // Force content above for translate button
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.translate,
              title: 'Bamanankan',
              description: 'Nin button in kirayɛ walasa ka bamanankan kɛ.',
              isLast: true,
              controller: controller,
              isBottomElement: true, // Force compact content
              onComplete: () => markTranslateTutorialSeen(),
              onShow: () {
                // Skip visibility check for translate button
                print('Showing translate button tutorial (forced)');
              },
            ),
          ),
        ],
      ),
    );

    _showTutorial(context, targets);
  }

  // Profile Tutorial - user settings and account features
  static Future<void> showProfileTutorial(
    BuildContext context, {
    required GlobalKey nameInputKey,
    required GlobalKey statsKey,
    GlobalKey? authBannerKey,
    GlobalKey? avatarKey,
  }) async {
    // Check if we should show this tutorial
    if (!(await shouldShowTutorial('profile'))) return;

    final targets = <TargetFocus>[];

    // Avatar (if available) - ensure it's visible
    if (avatarKey != null) {
      targets.add(
        TargetFocus(
          identify: "profile_avatar",
          keyTarget: avatarKey,
          alignSkip: Alignment.bottomRight,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) => _buildTutorialContent(
                icon: Icons.account_circle,
                title: 'Aw ka ja',
                description:
                    'Nin ye aw ka ja ye. Aw bɛ se ka aw ka ja caman lajɛ ani ka aw ka tɔgɔ fɔ.',
                isFirst: true,
                controller: controller,
                onShow: () => _ensureElementVisible(avatarKey),
              ),
            ),
          ],
        ),
      );
    }

    // Name input - ensure it's visible
    targets.add(
      TargetFocus(
        identify: "name_input",
        keyTarget: nameInputKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.edit,
              title: 'Aw ka tɔgɔ',
              description:
                  'Yan, aw bɛ se ka aw ka tɔgɔ sɛmɛntiya. Tɔgɔ kura sɛbɛn ka a mara.',
              isFirst: avatarKey == null,
              controller: controller,
              onShow: () => _ensureElementVisible(nameInputKey),
            ),
          ),
        ],
      ),
    );

    // Authentication banner (if available) - ensure it's visible
    if (authBannerKey != null) {
      targets.add(
        TargetFocus(
          identify: "auth_banner",
          keyTarget: authBannerKey,
          alignSkip: Alignment.topCenter,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) => _buildTutorialContent(
                icon: Icons.security,
                title: 'Jatebɔsɛbɛn',
                description:
                    'Jatebɔsɛbɛn dabɔ walasa ka aw ka ɲɛtaa sabati ani ka baara kɛ kɛrɛnkɛrɛnnenya wɛrɛw la.',
                controller: controller,
                onShow: () => _ensureElementVisible(authBannerKey),
              ),
            ),
          ],
        ),
      );
    }

    // Stats section - ensure it's visible (typically at bottom)
    targets.add(
      TargetFocus(
        identify: "stats_section",
        keyTarget: statsKey,
        alignSkip: Alignment.topRight,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildTutorialContent(
              icon: Icons.analytics,
              title: 'Aw ka ɲɛtaa',
              description:
                  'Yan, aw bɛ se ka aw ka kalan ɲɛtaa lajɛ - aw ka XP, kalan waati ani aw ka tilennenya.',
              isLast: true,
              controller: controller,
              onComplete: () => markProfileTutorialSeen(),
              onShow: () => _ensureElementVisible(statsKey, isBottom: true),
            ),
          ),
        ],
      ),
    );

    _showTutorial(context, targets);
  }

  static void _showTutorial(BuildContext context, List<TargetFocus> targets) {
    // Prevent multiple tutorials from showing at once
    if (_isTutorialShowing) {
      print('Tutorial already showing, aborting new tutorial');
      return;
    }

    if (targets.isEmpty) {
      print('No tutorial targets provided');
      return;
    }

    _isTutorialShowing = true;
    print('Starting tutorial with ${targets.length} targets');

    // Add a small delay to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        TutorialCoachMark(
          targets: targets,
          colorShadow: AppColors.charcoal,
          textSkip: "Ka tɛmɛ",
          paddingFocus: 15, // Increased padding for better visibility
          opacityShadow: 0.8,
          imageFilter: null,
          hideSkip: false,
          alignSkip: Alignment.topRight,
          onFinish: () {
            print('Tutorial completed successfully');
            _isTutorialShowing = false;
          },
          onClickTarget: (target) {
            print('Tutorial target clicked: ${target.identify}');
          },
          onClickTargetWithTapPosition: (target, tapDetails) {
            print('Tutorial target clicked with position: ${target.identify}');
          },
          onClickOverlay: (target) {
            print('Tutorial overlay clicked: ${target.identify}');
          },
          onSkip: () {
            print('Tutorial skipped by user');
            _isTutorialShowing = false;
            return true;
          },
        ).show(context: context);
      } catch (e) {
        print('Error showing tutorial: $e');
        _isTutorialShowing = false;
      }
    });
  }

  static Widget _buildTutorialContent({
    required IconData icon,
    required String title,
    required String description,
    required TutorialCoachMarkController controller,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onComplete,
    VoidCallback? onShow,
    bool isBottomElement = false, // New parameter for bottom elements
  }) {
    // Call onShow callback when this content is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onShow?.call();
    });

    return Builder(
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final screenWidth = screenSize.width;
        final screenHeight = screenSize.height;

        // Responsive sizing based on screen dimensions
        final maxWidth = screenWidth * 0.9; // Max 90% of screen width
        final maxHeight = isBottomElement
            ? screenHeight * 0.45 // Smaller for bottom elements (45%)
            : screenHeight * 0.6; // Normal size (60%)

        // Responsive padding and spacing - more compact for bottom elements
        final padding = isBottomElement
            ? (screenWidth < 400 ? AppSpacing.md : AppSpacing.lg)
            : (screenWidth < 400 ? AppSpacing.lg : AppSpacing.xl);
        final spacing = isBottomElement
            ? AppSpacing.sm // Smaller spacing for bottom elements
            : (screenWidth < 400 ? AppSpacing.md : AppSpacing.lg);
        final titleSpacing = screenWidth < 400 ? AppSpacing.sm : AppSpacing.md;

        // Responsive text styles
        final titleStyle = screenWidth < 400
            ? AppTextStyles.heading4
                .copyWith(color: AppColors.primaryGreen, fontSize: 18)
            : AppTextStyles.heading4.copyWith(color: AppColors.primaryGreen);

        final descriptionStyle = screenWidth < 400
            ? AppTextStyles.bodyMedium
                .copyWith(color: AppColors.charcoal, height: 1.4)
            : AppTextStyles.bodyLarge
                .copyWith(color: AppColors.charcoal, height: 1.5);

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          child: Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.charcoal.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and title
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            screenWidth < 400 ? AppSpacing.sm : AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          icon,
                          color: AppColors.pureWhite,
                          size: screenWidth < 400 ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: titleSpacing),
                      Expanded(
                        child: Text(
                          title,
                          style: titleStyle,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: spacing),

                  // Description with scrollable text if needed
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxHeight *
                          0.5, // Max 50% of available height for description
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        description,
                        style: descriptionStyle,
                      ),
                    ),
                  ),

                  SizedBox(height: spacing),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button (only show if not first)
                      if (!isFirst)
                        Flexible(
                          child: TextButton(
                            onPressed: () => controller.previous(),
                            child: Text(
                              'Ka kɔrɔ',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      if (isFirst) const Spacer(),

                      // Next/Finish button
                      Flexible(
                        child: Container(
                          decoration: AppDecorations.primaryButtonDecoration,
                          child: ElevatedButton(
                            onPressed: () {
                              if (isLast) {
                                onComplete?.call();
                                controller.skip();
                              } else {
                                controller.next();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth < 400
                                    ? AppSpacing.md
                                    : AppSpacing.lg,
                                vertical: screenWidth < 400
                                    ? AppSpacing.sm
                                    : AppSpacing.md,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                              ),
                            ),
                            child: Text(
                              isLast ? 'A ye' : 'Ka taa fɛ',
                              style: AppTextStyles.buttonText,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
