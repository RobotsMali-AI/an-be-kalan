import 'package:flutter/foundation.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper extends ChangeNotifier {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  List<Book> books = [];
  Users? userData;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/literacy_app.db';

    return databaseFactoryIo.openDatabase(dbPath);
  }

  // Define stores for each class
  final _booksStore = intMapStoreFactory.store('books');
  final _usersStore = intMapStoreFactory.store('users');

  Future<int?> insertBook(Book book, String uid) async {
    final db = await database;

    // Check if a book with the same title already exists
    final existingBookSnapshot = await _booksStore.findFirst(db,
        finder: Finder(filter: Filter.equals('title', book.title)));

    if (existingBookSnapshot != null) {
      // If the book already exists, update the UUID list if needed
      Book existingBook = Book.fromSemb(existingBookSnapshot.value);
      if (existingBook.uuid != null) {
        if (!existingBook.uuid!.contains(uid)) {
          existingBook.uuid!.add(uid);
          await _booksStore
              .record(existingBookSnapshot.key)
              .update(db, await existingBook.toSnapshot());
          notifyListeners();
        }
      }

      return existingBookSnapshot.key; // Return the existing book ID
    } else {
      // If the book does not exist, insert it
      book.uuid = [uid];
      final id = await _booksStore.add(db, await book.toSnapshot());
      notifyListeners();
      return id;
    }
  }

  Future<void> getBooks() async {
    final db = await database;
    books = await _booksStore.find(db).then((records) =>
        records.map((snapshot) => Book.fromSemb(snapshot.value)).toList());
    notifyListeners();
  }

  Future<Book?> getBook(String title) async {
    final db = await database;
    books = await _booksStore.find(db).then((records) =>
        records.map((snapshot) => Book.fromSemb(snapshot.value)).toList());
    for (var element in books) {
      if (element.title == title) {
        return element;
      }
      notifyListeners();
    }
    return null;
  }

  Future<int?> deleteBook(int id) async {
    final db = await database;
    final count = await _booksStore.record(id).delete(db);
    notifyListeners();
    return count;
  }

  // User operations
  Future<int> insertUser(Users user) async {
    final db = await database;
    final id = await _usersStore.add(db, user.toSemb());
    notifyListeners();
    return id;
  }

  Future<bool> getUser(String uid) async {
    final db = await database;
    List<Users> data = await _usersStore.find(db).then((records) =>
        records.map((snapshot) => Users.fromSemb(snapshot.value)).toList());
    for (var user in data) {
      if (user.uid == uid) {
        userData = user;
        return true;
      }
    }
    return false;
  }

  Future<Users?> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    _usersStore.update(db, user);
    //final updated = await _usersStore.record(id).update(db, user);
    notifyListeners();
    return Users.fromSemb(user);
  }

  Future<void> bookmark(String uid, BookUser readBook, Users userData) async {
    // Check if the book is already bookmarked
    final bookmarkedIndex = userData.inProgressBooks
        .indexWhere((book) => book.title == readBook.title);

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
    // Save new userData to firebase
    await updateUser(userData.toSemb());
    // Return the latest version of userData
    userData = userData;
    notifyListeners();
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
