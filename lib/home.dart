import 'dart:developer' show log;
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/profile.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:literacy_app/main.dart' show auth;
import 'package:literacy_app/lesson_screen.dart' show LessonScreen;
import 'package:literacy_app/widgets/bookWidgetView.dart';
import 'package:provider/provider.dart';

import 'models/Users.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTabIndex = 0;
  User? user;
  // Users? userData;
  bool isLoading = true; // Track loading state

  Future<void> initUserData() async {
    try {
      if (user != null) {
        //Users data = await getUserData(user!.uid);
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ApiFirebaseService>().getUserData(user!.uid);
            // userData = context.read<ApiFirebaseService>().Users;
          });
          isLoading = false; // Data fetched
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
      setState(() {
        isLoading = false; // Avoid infinite loading
      });
    }
  }

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;

    if (user != null) {
      initUserData();
    } else {
      log('No user is currently signed in.');
    }

    auth.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          user = event;
        });
        initUserData(); // Reinitialize userData when user changes
      }
    });

    log(user.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(), // Loading spinner
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Consumer<ApiFirebaseService>(
          builder: (conext, apiFirebaseService, _) {
        if (apiFirebaseService.userInfo == null) {
          apiFirebaseService.getUserData(user!.uid);
          apiFirebaseService.getAllBooks();
          return const Center(
            child: CircularProgressIndicator(), // Loading spinner
          );
        }
        Users userData = apiFirebaseService.userInfo!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vocal Search Bar at the Top
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  const Text(
                    'An be Kalan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Gafe dɔ ɲini',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.white),
                        onPressed: () {
                          // Implement vocal search logic here
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Book List
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'An ka gafew',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemCount: apiFirebaseService.books.length,
                  itemBuilder: (context, index) {
                    final book = apiFirebaseService.books[index];
                    final isInProgress = userData.inProgressBooks
                        .any((b) => b.title == book.title);
                    final isCompleted =
                        userData.completedBooks.contains(book.title);

                    final isDownloaded =
                        userData.downloadBooks!.contains(book.title);

                    late BookUser? bookUser;
                    for (var element in userData.inProgressBooks) {
                      if (book.title == element.title) {
                        bookUser = element;
                      } else {
                        bookUser = null;
                      }
                    }

                    return GestureDetector(
                      onTap: () => openLesson(
                        context,
                        book.title,
                        userData,
                      ),
                      child: BookWidgetView(
                        book: book,
                        isCompleted: isCompleted,
                        isInProgress: isInProgress,
                        isDownloaded: isDownloaded,
                        bookUser: bookUser,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),
      // Navigation Tab Bar at the Bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedTabIndex,
          selectedItemColor:
              Colors.yellowAccent, // Fun and bright selected color
          unselectedItemColor: Colors.white, // Clean white for unselected items
          backgroundColor:
              Colors.purpleAccent, // Vibrant and kid-friendly background color
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
            if (index == 0) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context); // Navigate back to HomePage if possible
              }
            } else if (index == 3) {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.person, color: Colors.deepPurple),
                      title: const Text(
                        'Profile',
                        style:
                            TextStyle(fontSize: 18, color: Colors.deepPurple),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        navigateToProfilePage(
                            context.read<ApiFirebaseService>().userInfo);
                      },
                    ),
                    ListTile(
                      leading:
                          const Icon(Icons.settings, color: Colors.deepPurple),
                      title: const Text(
                        'Settings',
                        style:
                            TextStyle(fontSize: 18, color: Colors.deepPurple),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        navigateToSettingsPage();
                      },
                    ),
                  ],
                ),
              );
            }
          },
          items: [
            CrystalNavigationBarItem(
              icon: Icons.home,
              //label: 'Home',
              //iconColor: Colors.yellow, // Bright yellow for fun
            ),
            CrystalNavigationBarItem(
              icon: Icons.book,
              //label: 'Books',
              //iconColor: Colors.lightBlue, // Cool blue for a calm vibe
            ),
            CrystalNavigationBarItem(
              icon: Icons.games,
              //label: 'Games',
              //iconColor: Colors.greenAccent, // Green for playful energy
            ),
            CrystalNavigationBarItem(
              icon: Icons.more_horiz,
              //label: 'More',
              //: Colors.pinkAccent, // Pink for an extra pop of color
            ),
          ],
        ),
      ),
    );
  }

  void navigateToProfilePage(Users? userData) {
    if (userData != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            xp: userData.xp,
            user: user!,
          ),
        ),
      );
    }
  }

  void navigateToSettingsPage() {
    // Logic for navigating to the Settings Page
  }

  Future<void> openLesson(
      BuildContext context, String bookTitle, Users? userData) async {
    // Navigate to LessonScreen and await the result
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          uid: user!.uid,
          userdata: userData!,
          bookTitle: bookTitle,
        ),
      ),
    );

    // Update `userdata` if a result is returned
    if (updatedUserData != null) {
      setState(() {
        userData = updatedUserData;
      });
    }
  }
}
