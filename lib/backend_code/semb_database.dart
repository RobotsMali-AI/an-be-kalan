import 'package:flutter/foundation.dart';
import 'package:literacy_app/models/Users.dart';
import 'package:literacy_app/models/book.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/models/page.dart';
import 'package:literacy_app/models/xpLog.dart';
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
  final _pagesStore = intMapStoreFactory.store('pages');
  final _usersStore = intMapStoreFactory.store('users');
  final _xpLogsStore = intMapStoreFactory.store('xpLogs');
  final _bookUsersStore = intMapStoreFactory.store('bookUsers');

  // Book operations
  // Future<int> insertBook(Book book) async {
  //   final db = await database;
  //   Map<String, dynamic> save = await book.toSnapshot();
  //   final id = await _booksStore.add(db, save);
  //   notifyListeners();
  //   return id;
  // }

  Future<int> insertBook(Book book) async {
    final db = await database;

    // Wait for the Future to resolve
    final Map<String, dynamic> save = await book.toSnapshot();

    // Pass the resolved map to the store
    final id = await _booksStore.add(db, save);

    notifyListeners();
    return id;
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

  // Future<Book?> updateBook(int id, Map<String, dynamic> book) async {
  //   final db = await database;
  //   final updated = await _booksStore.record(id).update(db, book);
  //   notifyListeners();
  //   return updated != null ? Book.fromSemb(updated) : null;
  // }

  Future<int?> deleteBook(int id) async {
    final db = await database;
    final count = await _booksStore.record(id).delete(db);
    notifyListeners();
    return count;
  }

  // Page operations
  Future<int> insertPage(Page page) async {
    final db = await database;
    Map<String, dynamic> save = await page.toSnapshot();
    final id = await _pagesStore.add(db, save);
    notifyListeners();
    return id;
  }

  Future<List<Page>> getPages(String bookTitle) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('bookTitle', bookTitle));
    return await _pagesStore.find(db, finder: finder).then((records) =>
        records.map((snapshot) => Page.fromSnapshot(snapshot.value)).toList());
  }

  // Future<Page?> updatePage(int id, Map<String, dynamic> page) async {
  //   final db = await database;
  //   final updated = await _pagesStore.record(id).update(db, page);
  //   notifyListeners();
  //   return updated != null ? Page.fromSnapshot(updated) : null;
  // }

  // User operations
  Future<int> insertUser(Users user) async {
    final db = await database;
    final id = await _usersStore.add(db, user.toSemb());
    notifyListeners();
    return id;
  }

  // Future<List<Users>> getUsers() async {
  //   final db = await database;
  //   return await _usersStore.find(db).then((records) =>
  //       records.map((snapshot) => Users.fromSemb(snapshot.value)).toList());
  // }

  Future<void> getUser(String uid) async {
    final db = await database;
    _usersStore.find(db).then((records) => records
            .map((snapshot) => Users.fromSemb(snapshot.value))
            .toList()
            .forEach((user) {
          if (user.uid == uid) {
            userData = user;
          }
        }));
  }

  Future<Users?> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    _usersStore.update(db, user);
    //final updated = await _usersStore.record(id).update(db, user);
    notifyListeners();
    return Users.fromSemb(user);
  }

  // BookUser operations
  Future<int> insertBookUser(BookUser bookUser) async {
    final db = await database;
    final id = await _bookUsersStore.add(db, bookUser.toSemb());
    notifyListeners();
    return id;
  }

  Future<List<BookUser>> getBookUsers(String userId) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('userId', userId));
    return await _bookUsersStore.find(db, finder: finder).then((records) =>
        records
            .map((snapshot) => BookUser.fromSnapshot(snapshot.value))
            .toList());
  }

  Future<BookUser?> updateBookUser(
      int id, Map<String, dynamic> bookUser) async {
    final db = await database;
    final updated = await _bookUsersStore.record(id).update(db, bookUser);
    notifyListeners();
    return updated != null ? BookUser.fromSnapshot(updated) : null;
  }

  // XPLog operations
  Future<int> insertXPLog(XPLog xpLog) async {
    final db = await database;
    final id = await _xpLogsStore.add(db, xpLog.toSnapshot());
    notifyListeners();
    return id;
  }

  Future<List<XPLog>> getXPLogs(String userId) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('userId', userId));
    return await _xpLogsStore.find(db, finder: finder).then((records) =>
        records.map((snapshot) => XPLog.fromSnapshot(snapshot.value)).toList());
  }

  Future<XPLog?> updateXPLog(int id, Map<String, dynamic> xpLog) async {
    final db = await database;
    final updated = await _xpLogsStore.record(id).update(db, xpLog);
    notifyListeners();
    return updated != null ? XPLog.fromSnapshot(updated) : null;
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
    // Save new userData to firebase
    await updateUser(0, userData.toSemb());
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
