import 'dart:developer' show log;
import 'package:fade_shimmer_master/fade_shimmer_grid.dart';
import 'package:fade_shimmer_master/fade_shimmer_master.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/backend_code/user_session_service.dart';
import 'package:literacy_app/profile.dart';
import 'package:literacy_app/tutorial_service.dart';
import 'package:literacy_app/widgets/bookPageWidget.dart';
import 'package:literacy_app/widgets/page_accueil_Nkalan.dart';
import 'package:literacy_app/widgets/translate_page_widget.dart';
import 'package:provider/provider.dart';
import 'models/Users.dart';
import 'theme/app_colors.dart';
import 'widgets/common/custom_bottom_nav.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool isLoading = true;
  bool verification = false;
  int _selectedTabIndex = 0;
  Users? user;
  UserSessionService? _userSession;

  // Navigation bar animation controller
  late AnimationController _navAnimationController;
  late Animation<double> _navAnimation;
  bool _isNavVisible = true;

  // Scroll controller for detecting scroll direction
  final ScrollController _scrollController = ScrollController();

  final List<GlobalKey> _navKeys = [
    GlobalKey(), // Books tab
    GlobalKey(), // Translation tab
    GlobalKey(), // Games/Nkalan tab
    GlobalKey(), // Profile tab
  ];

  // Track tutorials shown during this session
  final Set<String> _tutorialsShownThisSession = {};

  Future<void> initUserData() async {
    try {
      final userSession = context.read<UserSessionService>();

      if (userSession.currentUser != null) {
        user = userSession.currentUser;

        // Check if user exists in local database
        verification = await context.read<DatabaseHelper>().getUser(user!.uid!);

        if (mounted) {
          setState(() {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Load books and update API service if needed
              if (mounted) {
                context.read<ApiFirebaseService>().getAllBooks();
                if (userSession.isAuthenticated) {
                  // For authenticated users, sync with Firebase
                  context.read<ApiFirebaseService>().getUserData(user!.uid!);
                }

                // Show tutorial for first-time users after everything loads
                _checkAndShowTutorial();
              }
            });
            isLoading = false;
          });
        }
      }
    } catch (e) {
      log('Error fetching user data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    // Show tutorial for first-time users
    if (mounted) {
      _checkAndShowTutorial();
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize navigation animation
    _navAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _navAnimationController,
      curve: Curves.easeInOut,
    ));
    _navAnimationController.forward();

    // Add scroll listener
    _scrollController.addListener(_onScroll);

    final userSession = context.read<UserSessionService>();
    _userSession = userSession;
    user = userSession.currentUser;

    if (user != null) {
      initUserData();
    } else {
      log('No user session found.');
      userSession.initializeSession().then((_) {
        if (mounted) {
          setState(() {
            user = userSession.currentUser;
          });
          if (user != null) {
            initUserData();
          }
        }
      });
    }

    userSession.addListener(_onUserSessionChanged);
    log(user.toString());
  }

  double _lastScrollOffset = 0.0;

  void _onScroll() {
    if (_scrollController.hasClients) {
      final currentScrollOffset = _scrollController.offset;
      final isScrollingDown = currentScrollOffset > _lastScrollOffset;

      if (isScrollingDown && _isNavVisible && currentScrollOffset > 100) {
        // Scrolling down - hide navigation
        setState(() {
          _isNavVisible = false;
        });
        _navAnimationController.reverse();
      } else if (!isScrollingDown && !_isNavVisible) {
        // Scrolling up - show navigation
        setState(() {
          _isNavVisible = true;
        });
        _navAnimationController.forward();
      }

      _lastScrollOffset = currentScrollOffset;
    }
  }

  void _onUserSessionChanged() {
    if (mounted && _userSession!.currentUser != user) {
      // Preserve the current tab index before rebuilding
      final currentTabIndex = _selectedTabIndex;

      setState(() {
        user = _userSession!.currentUser;
      });

      // Restore the tab index after the rebuild
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedTabIndex != currentTabIndex) {
          setState(() {
            _selectedTabIndex = currentTabIndex;
          });
        }
      });

      if (user != null) {
        initUserData();
      }
    }
  }

  Future<void> _checkAndShowTutorial() async {
    await TutorialService.initializeFirstLaunchSequence();

    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await TutorialService.showHomeTutorial(context, navKeys: _navKeys);
      }
    }
  }

  Future<void> _checkAndShowPageTutorial() async {
    // Check which page we're on and show tutorial if needed
    String currentPageType;
    switch (_selectedTabIndex) {
      case 0:
        currentPageType = 'books';
        break;
      case 1:
        currentPageType = 'translate';
        break;
      case 2:
        currentPageType = 'games';
        break;
      case 3:
        currentPageType = 'profile';
        break;
      default:
        return;
    }

    // Don't show if already shown this session
    if (_tutorialsShownThisSession.contains(currentPageType)) {
      return;
    }

    // Show tutorial for current page
    if (mounted && !TutorialService.isTutorialShowing()) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        bool shouldShow =
            await TutorialService.shouldShowTutorial(currentPageType);
        if (shouldShow &&
            !_tutorialsShownThisSession.contains(currentPageType)) {
          _tutorialsShownThisSession.add(currentPageType);

          // Trigger tutorial based on page type
          switch (currentPageType) {
            case 'translate':
              // Will be handled by TranslationPage itself
              break;
            case 'profile':
              // Will be handled by ProfilePage itself
              break;
            // Add other page tutorials as needed
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _navAnimationController.dispose();
    _scrollController.dispose();
    _userSession?.removeListener(_onUserSessionChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: FadeShimmerGrid(
            itemCount: 6,
            itemHeight: 120,
            itemWidth: 120,
            highlightColor: AppColors.surfaceMedium,
            baseColor: AppColors.surfaceLight,
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            useGradient: true,
            fadeTheme: FadeTheme.light,
            staggered: true,
          ),
        ),
      );
    }

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        viewInsets: EdgeInsets.zero, // Prevent keyboard from affecting layout
      ),
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      extendBody: true,
      resizeToAvoidBottomInset: false, // Prevent keyboard from affecting layout
      body: Consumer2<ApiFirebaseService, UserSessionService>(
          builder: (context, apiFirebaseService, userSession, _) {
        if (apiFirebaseService.books.isEmpty) {
          apiFirebaseService.getAllBooks();
          return Container(
            decoration: BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: FadeShimmerGrid(
              itemCount: 6,
              itemHeight: 120,
              itemWidth: 120,
              highlightColor: AppColors.surfaceMedium,
              baseColor: AppColors.surfaceLight,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              useGradient: true,
              fadeTheme: FadeTheme.light,
              staggered: true,
            ),
          );
        }

        Users userData = userSession.currentUser!;

        if (!verification) {
          context.read<DatabaseHelper>().insertUser(userData);
          context.read<DatabaseHelper>().getUser(userData.uid!);
        }

        Widget currentPage;
        if (_selectedTabIndex == 0) {
          currentPage = BookPageWidget(
              apiFirebaseService: apiFirebaseService,
              userData: userData,
              userSession: userSession);
        } else if (_selectedTabIndex == 1) {
          currentPage = const TranslationPage();
        } else if (_selectedTabIndex == 2) {
          currentPage = const AcceuilNkalan();
        } else {
          currentPage =
              ProfilePage(userData: userData, userSession: userSession);
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (scrollNotification) {
            // Only handle scroll notifications, ignore other notifications
            if (scrollNotification is ScrollUpdateNotification) {
              final scrollDelta = scrollNotification.scrollDelta ?? 0.0;

              // Only handle scroll events if we're not in a dialog
              if (ModalRoute.of(context)?.isCurrent == true) {
                if (scrollDelta > 0 && _isNavVisible) {
                  // Scrolling down - hide navigation
                  setState(() {
                    _isNavVisible = false;
                  });
                  _navAnimationController.reverse();
                } else if (scrollDelta < 0 && !_isNavVisible) {
                  // Scrolling up - show navigation
                  setState(() {
                    _isNavVisible = true;
                  });
                  _navAnimationController.forward();
                }
              }
            }
            return false;
          },
          child: currentPage,
        );
      }),
      bottomNavigationBar: AnimatedBuilder(
        animation: _navAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, (1 - _navAnimation.value) * 100),
            child: CustomBottomNav(
              currentIndex: _selectedTabIndex,
              navKeys: _navKeys,
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                });
                // Trigger tutorial check for new page
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _checkAndShowPageTutorial();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
