import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:literacy_app/backend_code/semb_database.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';

class ApiFirebaseService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Users? userInfo;
  DatabaseHelper helper = DatabaseHelper();
  List<Book> books = [];
  Book? book;

  /// Function to save user data as a Firebase database collection
  Future<void> saveUserData(String uid, Users userData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(userData.toFirestore(), SetOptions(merge: true));
    userData.uid = uid;
    notifyListeners();
  }

  /// Function that retrieves a specific user data from
  Future<void> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    userInfo = doc.exists
        ? Users.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)
        : createUserData(uid);
    //final b = helper.getUser(uid);
    //print(b);
    notifyListeners();
  }

  /// Deleting a User data from the collection
  Future<void> deleteUserData(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    //await helper.
    notifyListeners();
  }

  Future<Map<String, dynamic>> transcribeAudio(File audioFile) async {
    DocumentSnapshot<Map<String, dynamic>> serve =
        await _firestore.collection('api').doc("SmKsDBpP7jBAKeEtckCD").get();
    final serverUrl = serve.data()!['key'];
    final uri = Uri.parse(serverUrl);
    final request = http.MultipartRequest('POST', uri);

    // Attach the audio file to the request under the key 'audio'
    request.files.add(
      await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        contentType: MediaType('audio', 'wav'),
      ),
    );

    // Send the request
    final response = await request.send();

    // Parse the streamed response
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return jsonDecode(respStr);
    } else {
      return {
        "error": "Request failed with status code ${response.statusCode}"
      };
    }
  }

  /// Function that creates and save empty user data dictionary for new user
  Users createUserData(String uid) {
    Users userData = Users(
        completedBooks: [],
        favoriteBooks: [],
        xpLog: [],
        totalReadingTime: 0,
        inProgressBooks: [],
        xp: 0);

    // Save user data to Firestore
    helper.insertUser(userData);
    saveUserData(uid, userData); // Ensure it's saved before returning
    notifyListeners();
    return userData;
  }

  Future<void> bookmark(String uid, BookUser readBook, Users userData) async {
    // Check if the book is already bookmarked
    final bookmarkedIndex = userData.inProgressBooks
        .indexWhere((book) => book.title == readBook.title);

    print(bookmarkedIndex);

    if (bookmarkedIndex != -1) {
      // Update the existing bookmark
      userData.inProgressBooks[bookmarkedIndex].bookmark = readBook.bookmark;
      userData.inProgressBooks[bookmarkedIndex].readingTime =
          readBook.readingTime; // Increment reading time
      userData.inProgressBooks[bookmarkedIndex].accuracies =
          readBook.accuracies; // Update accuracies
    } else {
      // Create new bookmark
      BookUser bookMarking = BookUser(
          totalPages: readBook.totalPages,
          lastAccessed: DateTime.now(),
          title: readBook.title,
          bookmark: readBook.bookmark,
          readingTime: readBook.readingTime,
          accuracies: readBook.accuracies);
      // Add a new bookmark
      userData.inProgressBooks.add(bookMarking);
    }
    await helper.updateUser(userData.toSemb());
    // Save new userData to firebase
    await saveUserData(uid, userData);
    // Return the latest version of userData
    userInfo = userData;
    notifyListeners();
  }

  Future<Map<String, dynamic>> markBookAsCompleted(
    String uid,
    BookUser book,
    Users userData,
  ) async {
    // Check if the book is already bookmarked
    final bookmarkedIndex =
        userData.inProgressBooks.indexWhere((book) => book.title == book.title);

    if (bookmarkedIndex != -1) {
      // Remove the bookmark
      userData.inProgressBooks.removeAt(bookmarkedIndex);
    }

    // Add the book to completed books if not already present
    if (!userData.completedBooks.contains(book.title)) {
      userData.completedBooks.add(book.title);
    }

    // Calculate average accuracy
    double averageAccuracy = book.accuracies.sum / book.accuracies.length;

    // Update User XP based on reading time and average accuracy
    int earnedXp =
        ((20 * averageAccuracy) + (50 / (book.readingTime + 1))).toInt();
    userData.xp += earnedXp;

    // Save the updated userData (assuming you have a function to save it)
    await saveUserData(uid, userData);
    await helper.updateUser(userData.toSemb());
    notifyListeners();
    // Return updated userData, total reading time, and average accuracy
    return {
      'userData': userData,
      'averageAccuracy': averageAccuracy,
      'earnedXp': earnedXp,
    };
  }

  Future<void> addBookToSembest(Book b, Users userData) async {
    if (!userData.downloadBooks!.contains(b.title)) {
      userData.downloadBooks!.add(b.title);
    }
    await saveUserData(userData.uid!, userData);
    await helper.insertBook(b, userData.uid!);
  }

  /// Sends an audio file to the ASR model for inference
  /// and returns the transcribed text.
  ///
  /// This function checks the file extension to ensure it's either a `.flac` or `.wav`
  /// format before proceeding. It then reads the file and sends it as a POST request
  /// to the ASR model API. If the request is successful, it returns the transcribed
  /// text. If the service is unavailable, it retries the request.
  ///
  /// Args:
  ///   filePath (String): The path to the audio file to be transcribed.
  ///
  /// Returns:
  ///   Future<String?>: The transcribed text from the ASR model if successful, or
  ///   `null` if the request fails or the file format is unsupported.
  ///

  Future<String?> inferenceASRModel(String filePath) async {
    // final apiUrl = Uri.parse(asrModelApiUri);

    // Validate file format
    if (!filePath.endsWith('.m4a') && !filePath.endsWith('.wav')) {
      print('Unsupported file format: $filePath');
      return null;
    }
    try {
      final audioFile = File(filePath);

      final transcribe = await transcribeAudio(audioFile);
      return transcribe["transcription"];
    } catch (e, stackTrace) {
      print('Exception occurred: $e');
      print(stackTrace);
      return null;
    }
  }

  /// Retrieves a specific book by its title from the catalog in books.json.
  ///
  /// Parameters:
  /// - `title`: The title of the book to retrieve.
  ///
  /// Returns a `Map<String, dynamic>?` containing the book details
  /// if the book is successfully retrieved, or `null` otherwise.

  Future<void> getAllBooks() async {
    // if (FirebaseAuth.instance.currentUser == null) {
    //   print(
    //       'User is not authenticated------------------------------------------');
    //   return;
    // }
    books = [];
    final data = await _firestore.collection('books').get();
    data.docs.forEach((element) {
      books.add(Book.fromJson(element));
    });

    // final b = await helper.getBooks();
    // print(b);
    notifyListeners();
  }

  Future<Book?> getBook(String title) async {
    // Find the book with the matching title
    for (var elementBook in books) {
      if (elementBook.title.trim() == title.trim()) {
        book = elementBook;
        //notifyListeners();
        return elementBook;
      }
    }
    return null;
  }
}
