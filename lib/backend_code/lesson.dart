/// Defining the main utility functions for a reading lesson
import 'package:collection/collection.dart';
import 'package:literacy_app/backend_code/user.dart' show saveUserData;
import 'package:literacy_app/models/bookUser.dart';

import '../models/UserInfo.dart';

Future<UserInfo> bookmark(String uid, BookUser book, UserInfo userData) async {
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
  return userData;
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

  // Return updated userData, total reading time, and average accuracy
  return {
    'userData': userData,
    'averageAccuracy': averageAccuracy,
    'earnedXp': earnedXp,
  };
}
