import 'dart:developer' show log;
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/profile.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:literacy_app/main.dart' show auth;
import 'package:literacy_app/widgets/bookPageWidget.dart';
import 'package:literacy_app/widgets/page_accueil_Nkalan.dart';
import 'package:literacy_app/widgets/translate_page_widget.dart';
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
  bool isLoading = true;
  bool verification = false;
  // final Speech = SpeechToText();
  Future<void> initUserData() async {
    try {
      if (user != null) {
        verification = await context.read<DatabaseHelper>().getUser(user!.uid);
        setState(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ApiFirebaseService>().getUserData(user!.uid);
            verification;
          });
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error fetching user data: $e');
      setState(() {
        isLoading = false;
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
        initUserData();
      }
    });

    log(user.toString());
  }

  @override
  Widget build(BuildContext context) {
    //trasncribe();
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
            child: CircularProgressIndicator(),
          );
        }
        Users userData = apiFirebaseService.userInfo!;
        if (!verification) {
          conext.read<DatabaseHelper>().insertUser(userData);
          conext.read<DatabaseHelper>().getUser(userData.uid!);
        }
        // final downloadedBooks = conext
        //     .read<DatabaseHelper>()
        //     .books
        //     .map((book) => book.title)
        //     .toSet();

        // for (var bookTitle in userData.downloadBooks ?? []) {
        //   if (!downloadedBooks.contains(bookTitle)) {
        //     final book = context
        //         .read<ApiFirebaseService>()
        //         .books
        //         .firstWhereOrNull((b) => b.title == bookTitle);
        //     if (book != null) {
        //       conext.read<DatabaseHelper>().insertBook(book, userData.uid!);
        //     }
        //   }
        // }
        if (_selectedTabIndex == 0) {
          return BookPageWidget(
              apiFirebaseService: apiFirebaseService,
              userData: userData,
              user: user!);
        }
        // else if (_selectedTabIndex == 1) {
        //   return DownloadBookPageWidget(
        //       user: user!); // Placeholder for identical page
        // }
        else if (_selectedTabIndex == 1) {
          return const TranslationPage();
        } else if (_selectedTabIndex == 2) {
          return const AcceilNkalan();
        } else {
          return ProfilePage(user: user!, userData: userData);
        }
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CrystalNavigationBar(
          currentIndex: _selectedTabIndex,
          selectedItemColor: Colors.yellowAccent,
          unselectedItemColor: Colors.white,
          backgroundColor: Colors.black,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          items: [
            CrystalNavigationBarItem(
              icon: Icons.book,
            ),
            CrystalNavigationBarItem(
              icon: Icons.translate,
            ),
            CrystalNavigationBarItem(
              icon: Icons.gamepad,
            ),
            CrystalNavigationBarItem(
              icon: Icons.person,
            ),
          ],
        ),
      ),
    );
  }
}
