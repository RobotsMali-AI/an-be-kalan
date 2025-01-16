import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:literacy_app/models/UserInfo.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:http/http.dart' as http;
import 'package:literacy_app/constant.dart'
    show asrModelApiUri, asrModelApiToken;

class ApiFirebaseService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserInfo? userInfo;
  Book? book;

  /// Function to save user data as a Firebase database collection
  Future<void> saveUserData(String uid, UserInfo userData) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(userData.toFirestore(), SetOptions(merge: true));
    notifyListeners();
  }

  /// Function that retrieves a specific user data from
  Future<void> getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    userInfo = doc.exists
        ? UserInfo.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)
        : createUserData(uid);
    notifyListeners();
  }

  /// Deleting a User data from the collection
  Future<void> deleteUserData(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    notifyListeners();
  }

  /// Function that creates and save empty user data dictionary for new user
  UserInfo createUserData(String uid) {
    UserInfo userData =
        UserInfo(completedBooks: [], inProgressBooks: [], xp: 0);

    // Save user data to Firestore
    saveUserData(uid, userData); // Ensure it's saved before returning
    notifyListeners();
    return userData;
  }

  Future<void> bookmark(String uid, BookUser book, UserInfo userData) async {
    // Check if the book is already bookmarked
    final bookmarkedIndex =
        userData.inProgressBooks.indexWhere((book) => book.title == book.title);

    if (bookmarkedIndex != -1) {
      // Update the existing bookmark
      userData.inProgressBooks[bookmarkedIndex].bookmark = book.bookmark;
      userData.inProgressBooks[bookmarkedIndex].readingTime =
          book.readingTime; // Increment reading time
      userData.inProgressBooks[bookmarkedIndex].accuracies =
          book.accuracies; // Update accuracies
    } else {
      // Create new bookmark
      BookUser bookMarking = BookUser(
          title: book.title,
          bookmark: book.bookmark,
          readingTime: book.readingTime,
          accuracies: book.accuracies);
      // Add a new bookmark
      userData.inProgressBooks.add(bookMarking);
    }
    // Save new userData to firebase
    await saveUserData(uid, userData);
    // Return the latest version of userData
    userInfo = userData;
    notifyListeners();
  }

  Future<Map<String, dynamic>> markBookAsCompleted(
    String uid,
    BookUser book,
    UserInfo userData,
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
    notifyListeners();
    // Return updated userData, total reading time, and average accuracy
    return {
      'userData': userData,
      'averageAccuracy': averageAccuracy,
      'earnedXp': earnedXp,
    };
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
    final apiUrl = Uri.parse(asrModelApiUri);

    // Check if the file is .m4a or .wav
    if (!filePath.endsWith('.m4a') && !filePath.endsWith('.wav')) {
      return null;
    }

    // Read the file
    final file = File(filePath);
    final fileBytes = await file.readAsBytes();

    // Set headers
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $asrModelApiToken',
      'Content-Type': 'audio/wav',
    };

    try {
      // Send the POST request
      final response =
          await http.post(apiUrl, headers: headers, body: fileBytes);

      // Check the response status
      if (response.statusCode == 200) {
        final decodedString = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = jsonDecode(decodedString);
        return data["text"];
      } else if (response.statusCode == 503) {
        await Future.delayed(const Duration(seconds: 5));
        notifyListeners();
        return inferenceASRModel(filePath);
      } else {
        notifyListeners();
        return null;
      }
    } catch (e) {
      notifyListeners();
      null;
    }
  }

  /// Retrieves a specific book by its title from the catalog in books.json.
  ///
  /// Parameters:
  /// - `title`: The title of the book to retrieve.
  ///
  /// Returns a `Map<String, dynamic>?` containing the book details
  /// if the book is successfully retrieved, or `null` otherwise.
  Future<void> getBook(String title) async {
    String jsonString = await rootBundle.loadString('assets/books/books.json');

    // Decode the JSON string into a list of maps
    final List<dynamic> booksList = jsonDecode(jsonString);

    // Find the book with the matching title
    for (var book in booksList) {
      if (book['title'].trim() == title.trim()) {
        book = Book.fromJson(book);
      }
    }
  }
}
