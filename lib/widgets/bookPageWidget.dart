import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/api_firebase_service.dart';
import 'package:literacy_app/lesson_screen.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/widgets/bookWidgetView.dart';

// ignore: must_be_immutable
class BookPageWidget extends StatefulWidget {
  BookPageWidget(
      {super.key,
      required this.apiFirebaseService,
      required this.userData,
      required this.user});
  ApiFirebaseService apiFirebaseService;
  Users userData;
  User user;

  @override
  State<BookPageWidget> createState() => _BookPageWidgetState();
}

class _BookPageWidgetState extends State<BookPageWidget> {
  final TextEditingController _bookSearchController = TextEditingController();
  List<Book> books = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    books = widget.apiFirebaseService.books;
  }

  void searchBook(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, show all books
        books = widget.apiFirebaseService.books;
      } else {
        // Filter books based on the query
        books = widget.apiFirebaseService.books
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            'An ka gafew',
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
                final isInProgress = widget.userData.inProgressBooks
                    .any((b) => b.title == book.title);
                final isCompleted =
                    widget.userData.completedBooks.contains(book.title);

                final isDownloaded =
                    widget.userData.downloadBooks!.contains(book.title);

                BookUser? bookUser;
                for (var element in widget.userData.inProgressBooks) {
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
                      widget.userData,
                    );
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
          ),
        ),
      ],
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
        userData = updatedUserData;
      });
    }
  }
}
