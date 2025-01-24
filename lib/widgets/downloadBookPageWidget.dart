import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/lesson_screen.dart';
import 'package:literacy_app/main.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/widgets/offlineBookWideget.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DownloadBookPageWidget extends StatefulWidget {
  DownloadBookPageWidget({super.key, required this.user});
  User user;
  @override
  State<DownloadBookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<DownloadBookPageWidget> {
  bool isLoading = true;
  List<Book> books = [];
  Future<void> initUserData() async {
    try {
      setState(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<DatabaseHelper>().getUser(widget.user.uid);
          context.read<DatabaseHelper>().getBooks();
          books = context.read<DatabaseHelper>().books;
        });
        isLoading = false;
      });
    } catch (e) {
      log('Error fetching user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initUserData();
    auth.userChanges().listen((event) {
      if (event != null && mounted) {
        setState(() {
          widget.user = event;
        });
        initUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DatabaseHelper>(builder: (context, database, _) {
      database.getUser(widget.user.uid);

      // database.getBooks();
      if (isLoading) {
        database.getBooks();
        database.getUser(widget.user.uid);
        return CircularProgressIndicator();
      }
      if (database.userData == null) {
        database.getBooks();
        database.getUser(widget.user.uid);
        return CircleAvatar();
      }
      void searchBook(String query) {
        setState(() {
          if (query.isEmpty) {
            // If the query is empty, reset to the original book list from the database
            books = context.read<DatabaseHelper>().books;
          } else {
            // Filter books based on the query
            books = context
                .read<DatabaseHelper>()
                .books
                .where((book) =>
                    book.title.toLowerCase().contains(query.toLowerCase()))
                .toList();
          }
        });
      }

      Users userData = database.userData!;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                const Text(
                  'Ne be Kalan',
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
                        onChanged: searchBook,
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
                        onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              'Ne ka gafew',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  final isInProgress = userData.inProgressBooks
                      .any((b) => b.title == book.title);
                  final isCompleted =
                      userData.completedBooks.contains(book.title);

                  final isDownloaded =
                      userData.downloadBooks!.contains(book.title);

                  BookUser? bookUser;
                  for (var element in userData.inProgressBooks) {
                    if (book.title == element.title) {
                      bookUser = element;
                    } else {
                      bookUser = null;
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      openLesson(
                        context,
                        book.title,
                        userData,
                      );
                    },
                    child: OffBookWidgetView(
                      user: userData,
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
    });
  }

  Future<void> openLesson(
      BuildContext context, String bookTitle, Users? userData) async {
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          isOffLine: true,
          uid: widget.user.uid,
          userdata: userData!,
          bookTitle: bookTitle,
        ),
      ),
    );

    if (updatedUserData != null) {
      setState(() {
        userData = updatedUserData;
      });
    }
  }
}
