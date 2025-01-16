import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:literacy_app/models/book.dart';

/// Retrieves a specific book by its title from the catalog in books.json.
///
/// Parameters:
/// - `title`: The title of the book to retrieve.
///
/// Returns a `Map<String, dynamic>?` containing the book details
/// if the book is successfully retrieved, or `null` otherwise.
Future<Book?> getBook(String title) async {
  String jsonString = await rootBundle.loadString('assets/books/books.json');

  // Decode the JSON string into a list of maps
  final List<dynamic> booksList = jsonDecode(jsonString);

  // Find the book with the matching title
  for (var book in booksList) {
    if (book['title'].trim() == title.trim()) {
      return Book.fromJson(book);
    }
  }

  // Return null if the book is not found or an error occurred
  return null;
}
