import 'dart:async';

import 'package:fade_shimmer_master/fade_shimmer_grid.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/routes.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/widgets/bookWidgetView.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fade_shimmer_master/fade_shimmer_master.dart';
import 'package:literacy_app/backend_code/user_session_service.dart';
import 'package:literacy_app/tutorial_service.dart';
import 'package:literacy_app/widgets/common/unified_app_bar.dart';
import 'package:literacy_app/theme/app_colors.dart';
import 'package:literacy_app/theme/app_styles.dart';
import 'package:literacy_app/widgets/common/app_widgets.dart';

// ignore: must_be_immutable
class BookPageWidget extends StatefulWidget {
  BookPageWidget({
    super.key,
    required this.apiFirebaseService,
    required this.userData,
    required this.userSession,
  });
  ApiFirebaseService apiFirebaseService;
  Users userData;
  UserSessionService userSession;

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  final TextEditingController _bookSearchController = TextEditingController();
  late Connectivity _connectivity;
  bool _isConnected = true;
  List<Book> allBooks = [];
  List<Book> displayedBooks = [];
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late Future<List<Book>> booksFuture;

  // GlobalKeys for tutorial targets
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _refreshKey = GlobalKey();
  final GlobalKey _firstBookKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch books
    booksFuture =
        widget.apiFirebaseService.getBooks(); // Ensure this method exists
    _connectivity = Connectivity();

    // Show tutorial for first-time users on books page
    _checkAndShowTutorial();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        if (mounted) {
          setState(() {
            _isConnected = !results.contains(ConnectivityResult.none);
          });
        }
      },
    );

    // Check initial connectivity
    _connectivity
        .checkConnectivity()
        .then((List<ConnectivityResult> resultList) {
      if (mounted) {
        setState(() {
          _isConnected = !resultList.contains(ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _bookSearchController.dispose();
    super.dispose();
  }

  Future<void> _checkAndShowTutorial() async {
    if (mounted) {
      _attemptToShowBooksTutorial();
    }
  }

  void _attemptToShowBooksTutorial({int attempt = 0}) {
    if (attempt > 5) return; // Give up after 5 attempts

    Future.delayed(Duration(milliseconds: 1000 + (attempt * 500)), () async {
      if (mounted && !TutorialService.isTutorialShowing()) {
        await TutorialService.showBooksTutorial(
          context,
          searchKey: _searchKey,
          firstBookKey: _firstBookKey,
          refreshKey: _refreshKey,
          waitForHomeTutorial: true,
        );
      } else if (mounted && TutorialService.isTutorialShowing()) {
        // Retry if another tutorial is showing
        _attemptToShowBooksTutorial(attempt: attempt + 1);
      }
    });
  }

  void searchBook(String query) {
    if (mounted) {
      setState(() {
        if (query.isEmpty) {
          displayedBooks = List<Book>.from(allBooks);
        } else {
          // Use a Set to ensure no duplicates in search results
          final filteredSet = <String, Book>{};
          for (final book in allBooks) {
            if (book.title.toLowerCase().contains(query.toLowerCase())) {
              filteredSet[book.title] = book;
            }
          }
          displayedBooks = filteredSet.values.toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: UnifiedAppBar(
        title: 'Gafew',
        actions: [
          AppBarActionButton(
            key: _refreshKey,
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                booksFuture = widget.apiFirebaseService.getBooks();
              });
            },
            tooltip: 'Kurala',
          ),
        ],
        bottom: AppBarSearchWidget(
          key: _searchKey,
          hintText: 'Gafe dɔ ɲini...',
          onChanged: searchBook,
          controller: _bookSearchController,
          onClear: () => searchBook(''),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection status banner
            if (!_isConnected)
              Container(
                width: double.infinity,
                color: AppColors.error.withOpacity(0.1),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Ɛntɛrinɛti ɲɔgɔndan tɛ yen',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            // Section header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.book,
                      color: AppColors.pureWhite,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'An ka gafew',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
            ),

            // Books grid
            Expanded(
              child: _isConnected
                  ? FutureBuilder<List<Book>>(
                      future: booksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: FadeShimmerGrid(
                              itemCount: 6,
                              itemHeight: 160,
                              useGradient: true,
                              itemWidth: 140,
                              highlightColor: AppColors.surfaceMedium,
                              baseColor: AppColors.surfaceLight,
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisSpacing: AppSpacing.md,
                              fadeTheme: FadeTheme.light,
                              staggered: true,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: InfoBanner(
                              title: 'Fili cogo dɔ',
                              message:
                                  'Gafew sɔrɔli ma ɲɛ. I ye a lajɛ kokura.',
                              icon: Icons.error_outline,
                              color: AppColors.error,
                              buttonText: 'A lajɛ kokura',
                              onButtonPressed: () {
                                setState(() {
                                  booksFuture =
                                      widget.apiFirebaseService.getBooks();
                                });
                              },
                            ),
                          );
                        } else {
                          // Ensure no duplicates by using a Set with book titles as unique identifiers
                          final bookSet = <String, Book>{};
                          for (final book in snapshot.data ?? []) {
                            bookSet[book.title] = book;
                          }
                          allBooks = bookSet.values.toList();

                          if (displayedBooks.isEmpty && allBooks.isNotEmpty) {
                            displayedBooks = List<Book>.from(allBooks);
                          }

                          if (displayedBooks.isEmpty) {
                            return Center(
                              child: InfoBanner(
                                title: 'Gafe si tɛ yen',
                                message: 'Gafe wɛrɛw bɛ na sɔɔni.',
                                icon: Icons.book_outlined,
                                color: AppColors.mediumGrey,
                              ),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: AppSpacing.md,
                                mainAxisSpacing: AppSpacing.lg,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: displayedBooks.length,
                              itemBuilder: (context, index) {
                                final book = displayedBooks[index];
                                final isInProgress = widget
                                    .userData.inProgressBooks
                                    .any((b) => b.title == book.title);
                                final isCompleted = widget
                                    .userData.completedBooks
                                    .contains(book.title);
                                final isDownloaded = widget
                                    .userData.downloadBooks
                                    .contains(book.title);

                                BookUser? bookUser;
                                for (var element
                                    in widget.userData.inProgressBooks) {
                                  if (book.title == element.title) {
                                    bookUser = element;
                                    break;
                                  }
                                }

                                return GestureDetector(
                                  key: index == 0 ? _firstBookKey : null,
                                  onTap: () {
                                    openLesson(
                                        context, book.title, widget.userData);
                                  },
                                  child: BookWidgetView(
                                    user: widget.userData,
                                    book: book,
                                    isCompleted: isCompleted,
                                    isInProgress: isInProgress,
                                    isDownloaded: isDownloaded,
                                    bookUser: bookUser,
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      },
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: InfoBanner(
                          title: 'Ɛntɛrinɛti ɲɔgɔndan tɛ',
                          message:
                              'I tɛ ɛntɛrinɛti kan. Aw ye aw ka jɛgɛnsira lajɛ.',
                          icon: Icons.wifi_off,
                          color: AppColors.error,
                          buttonText: 'A lajɛ kokura',
                          onButtonPressed: () {
                            _connectivity
                                .checkConnectivity()
                                .then((resultList) {
                              if (mounted) {
                                setState(() {
                                  _isConnected = !resultList
                                      .contains(ConnectivityResult.none);
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openLesson(
      BuildContext context, String bookTitle, Users? userData) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.lesson,
      arguments: LessonScreenArgs(
        isOffLine: false,
        uid: widget.userSession.currentUser?.uid ?? '',
        bookTitle: bookTitle,
        userData: userData,
      ),
    );

    if (result != null && result is Users && mounted) {
      setState(() {
        widget.userData = result;
      });
    }
  }
}
