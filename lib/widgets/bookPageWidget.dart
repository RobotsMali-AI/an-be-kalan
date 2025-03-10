import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/lesson_screen.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/widgets/bookWidgetView.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// ignore: must_be_immutable
class BookPageWidget extends StatefulWidget {
  BookPageWidget({
    super.key,
    required this.apiFirebaseService,
    required this.userData,
    required this.user,
  });
  ApiFirebaseService apiFirebaseService;
  Users userData;
  User user;

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

  @override
  void initState() {
    super.initState();
    // Initialize the future to fetch books
    booksFuture =
        widget.apiFirebaseService.getBooks(); // Ensure this method exists
    _connectivity = Connectivity();

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        setState(() {
          _isConnected = !results.contains(ConnectivityResult.none);
        });
      },
    );

    // Check initial connectivity
    _connectivity
        .checkConnectivity()
        .then((List<ConnectivityResult> resultList) {
      setState(() {
        _isConnected = !resultList.contains(ConnectivityResult.none);
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _bookSearchController.dispose();
    super.dispose();
  }

  void searchBook(String query) {
    setState(() {
      if (query.isEmpty) {
        displayedBooks = List<Book>.from(allBooks);
      } else {
        displayedBooks = allBooks
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.black,
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        automaticallyImplyLeading: false,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
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
                      onChanged: searchBook,
                      controller: _bookSearchController,
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
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_isConnected)
            Container(
              width: double.infinity,
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.cloud_off,
                    color: Colors.purple,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Ɛntɛrinɛti ɲɔgɔndan tɛ yen',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Text(
              'An ka gafew',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _isConnected
                ? FutureBuilder<List<Book>>(
                    future: booksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading books'));
                      } else {
                        allBooks = snapshot.data ?? [];
                        if (displayedBooks.isEmpty && allBooks.isNotEmpty) {
                          displayedBooks = List<Book>.from(allBooks);
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: displayedBooks.isNotEmpty
                              ? GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 1,
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
                                        .userData.downloadBooks!
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
                                      onTap: () {
                                        openLesson(context, book.title,
                                            widget.userData);
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
                                )
                              : const Center(
                                  child: Text(
                                    'Gafe si tɛ yen',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                        );
                      }
                    },
                  )
                : Center(
                    child: Text(
                      'I tɛ ɛntɛrinɛti kan. Aw ye aw ka jɛgɛnsira lajɛ.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> openLesson(
      BuildContext context, String bookTitle, Users? userData) async {
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          isOffLine: false,
          uid: widget.user.uid,
          userdata: userData!,
          bookTitle: bookTitle,
        ),
      ),
    );

    if (updatedUserData != null) {
      setState(() {
        widget.userData = updatedUserData;
      });
    }
  }
}
