// import 'package:literacy_app/models/Users.dart';
// import 'package:literacy_app/models/book.dart';
// import 'package:literacy_app/models/bookUser.dart';
// import 'package:literacy_app/models/page.dart';
// import 'package:literacy_app/models/xpLog.dart';
// import 'package:sembast/sembast_io.dart';
// import 'package:path_provider/path_provider.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   static Database? _database;

//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;

//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final dbPath = '${dir.path}/literacy_app.db';

//     return databaseFactoryIo.openDatabase(dbPath);
//   }

//   // Define stores for each class
//   final _booksStore = intMapStoreFactory.store('books');
//   final _pagesStore = intMapStoreFactory.store('pages');
//   final _usersStore = intMapStoreFactory.store('users');
//   final _xpLogsStore = intMapStoreFactory.store('xpLogs');
//   final _bookUsersStore = intMapStoreFactory.store('bookUsers');

//   // Book operations
//   Future<int> insertBook(Book book) async {
//     final db = await database;
//     return await _booksStore.add(db, book.toSnapshot());
//   }

//   Future<List<Book>> getBooks() async {
//     final db = await database;
//     return await _booksStore.find(db).then((records) =>
//         records.map((snapshot) => Book.fromSemb(snapshot.value)).toList());
//   }

//   Future<Book?> updateBook(int id, Map<String, dynamic> book) async {
//     final db = await database;
//     return _booksStore
//         .record(id)
//         .update(db, book)
//         .then((onValue) => Book.fromSemb(onValue!));
//   }

//   Future<int?> deleteBook(int id) async {
//     final db = await database;
//     return _booksStore.record(id).delete(db);
//   }

//   // Page operations
//   Future<int> insertPage(Page page) async {
//     final db = await database;
//     return await _pagesStore.add(db, page.toSnapshot());
//   }

//   Future<List<Page>> getPages(String bookTitle) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('bookTitle', bookTitle));
//     return await _pagesStore.find(db, finder: finder).then((records) =>
//         records.map((snapshot) => Page.fromSnapshot(snapshot.value)).toList());
//   }

//   // User operations
//   Future<int> insertUser(Users user) async {
//     final db = await database;
//     return await _usersStore.add(db, user.toFirestore());
//   }

//   Future<List<Users>> getUsers() async {
//     final db = await database;
//     return await _usersStore.find(db).then((records) =>
//         records.map((snapshot) => Users.fromSemb(snapshot.value)).toList());
//   }

//   // BookUser operations
//   Future<int> insertBookUser(BookUser bookUser) async {
//     final db = await database;
//     return await _bookUsersStore.add(db, bookUser.toSnapshot());
//   }

//   Future<List<BookUser>> getBookUsers(String userId) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('userId', userId));
//     return await _bookUsersStore.find(db, finder: finder).then((records) =>
//         records
//             .map((snapshot) => BookUser.fromSnapshot(snapshot.value))
//             .toList());
//   }

//   // XPLog operations
//   Future<int> insertXPLog(XPLog xpLog) async {
//     final db = await database;
//     return await _xpLogsStore.add(db, xpLog.toSnapshot());
//   }

//   Future<List<XPLog>> getXPLogs(String userId) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('userId', userId));
//     return await _xpLogsStore.find(db, finder: finder).then((records) =>
//         records.map((snapshot) => XPLog.fromSnapshot(snapshot.value)).toList());
//   }

//   Future<void> closeDatabase() async {
//     final db = _database;
//     if (db != null) {
//       await db.close();
//     }
//   }
// }

// import 'package:flutter/foundation.dart';
// import 'package:literacy_app/models/Users.dart';
// import 'package:literacy_app/models/book.dart';
// import 'package:literacy_app/models/bookUser.dart';
// import 'package:literacy_app/models/page.dart';
// import 'package:literacy_app/models/xpLog.dart';
// import 'package:sembast/sembast_io.dart';
// import 'package:path_provider/path_provider.dart';

// class DatabaseHelper extends ChangeNotifier {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;

//   static Database? _database;

//   DatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;

//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final dir = await getApplicationDocumentsDirectory();
//     final dbPath = '${dir.path}/literacy_app.db';

//     return databaseFactoryIo.openDatabase(dbPath);
//   }

//   // Define stores for each class
//   final _booksStore = intMapStoreFactory.store('books');
//   final _pagesStore = intMapStoreFactory.store('pages');
//   final _usersStore = intMapStoreFactory.store('users');
//   final _xpLogsStore = intMapStoreFactory.store('xpLogs');
//   final _bookUsersStore = intMapStoreFactory.store('bookUsers');

//   // Book operations
//   Future<int> insertBook(Book book) async {
//     final db = await database;
//     notifyListeners();
//     return await _booksStore.add(db, book.toSnapshot());
//   }

//   Future<List<Book>> getBooks() async {
//     final db = await database;
//     return await _booksStore.find(db).then((records) =>
//         records.map((snapshot) => Book.fromSemb(snapshot.value)).toList());
//   }

//   Future<Book?> updateBook(int id, Map<String, dynamic> book) async {
//     final db = await database;
//     return _booksStore
//         .record(id)
//         .update(db, book)
//         .then((onValue) => onValue != null ? Book.fromSemb(onValue) : null);
//   }

//   Future<int?> deleteBook(int id) async {
//     final db = await database;
//     return _booksStore.record(id).delete(db);
//   }

//   // Page operations
//   Future<int> insertPage(Page page) async {
//     final db = await database;
//     return await _pagesStore.add(db, page.toSnapshot());
//   }

//   Future<List<Page>> getPages(String bookTitle) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('bookTitle', bookTitle));
//     return await _pagesStore.find(db, finder: finder).then((records) =>
//         records.map((snapshot) => Page.fromSnapshot(snapshot.value)).toList());
//   }

//   Future<Page?> updatePage(int id, Map<String, dynamic> page) async {
//     final db = await database;
//     return _pagesStore
//         .record(id)
//         .update(db, page)
//         .then((onValue) => onValue != null ? Page.fromSnapshot(onValue) : null);
//   }

//   // User operations
//   Future<int> insertUser(Users user) async {
//     final db = await database;
//     return await _usersStore.add(db, user.toFirestore());
//   }

//   Future<List<Users>> getUsers() async {
//     final db = await database;
//     return await _usersStore.find(db).then((records) =>
//         records.map((snapshot) => Users.fromSemb(snapshot.value)).toList());
//   }

//   Future<Users?> updateUser(int id, Map<String, dynamic> user) async {
//     final db = await database;
//     return _usersStore
//         .record(id)
//         .update(db, user)
//         .then((onValue) => onValue != null ? Users.fromSemb(onValue) : null);
//   }

//   // BookUser operations
//   Future<int> insertBookUser(BookUser bookUser) async {
//     final db = await database;
//     return await _bookUsersStore.add(db, bookUser.toSnapshot());
//   }

//   Future<List<BookUser>> getBookUsers(String userId) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('userId', userId));
//     return await _bookUsersStore.find(db, finder: finder).then((records) =>
//         records
//             .map((snapshot) => BookUser.fromSnapshot(snapshot.value))
//             .toList());
//   }

//   Future<BookUser?> updateBookUser(
//       int id, Map<String, dynamic> bookUser) async {
//     final db = await database;
//     return _bookUsersStore.record(id).update(db, bookUser).then(
//         (onValue) => onValue != null ? BookUser.fromSnapshot(onValue) : null);
//   }

//   // XPLog operations
//   Future<int> insertXPLog(XPLog xpLog) async {
//     final db = await database;
//     return await _xpLogsStore.add(db, xpLog.toSnapshot());
//   }

//   Future<List<XPLog>> getXPLogs(String userId) async {
//     final db = await database;
//     final finder = Finder(filter: Filter.equals('userId', userId));
//     return await _xpLogsStore.find(db, finder: finder).then((records) =>
//         records.map((snapshot) => XPLog.fromSnapshot(snapshot.value)).toList());
//   }

//   Future<XPLog?> updateXPLog(int id, Map<String, dynamic> xpLog) async {
//     final db = await database;
//     return _xpLogsStore.record(id).update(db, xpLog).then(
//         (onValue) => onValue != null ? XPLog.fromSnapshot(onValue) : null);
//   }

//   Future<void> closeDatabase() async {
//     final db = _database;
//     if (db != null) {
//       await db.close();
//     }
//   }
// }

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
  Future<int> insertBook(Book book) async {
    final db = await database;
    final id = await _booksStore.add(db, book.toSnapshot());
    notifyListeners();
    return id;
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    return await _booksStore.find(db).then((records) =>
        records.map((snapshot) => Book.fromSemb(snapshot.value)).toList());
  }

  Future<Book?> updateBook(int id, Map<String, dynamic> book) async {
    final db = await database;
    final updated = await _booksStore.record(id).update(db, book);
    notifyListeners();
    return updated != null ? Book.fromSemb(updated) : null;
  }

  Future<int?> deleteBook(int id) async {
    final db = await database;
    final count = await _booksStore.record(id).delete(db);
    notifyListeners();
    return count;
  }

  // Page operations
  Future<int> insertPage(Page page) async {
    final db = await database;
    final id = await _pagesStore.add(db, page.toSnapshot());
    notifyListeners();
    return id;
  }

  Future<List<Page>> getPages(String bookTitle) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('bookTitle', bookTitle));
    return await _pagesStore.find(db, finder: finder).then((records) =>
        records.map((snapshot) => Page.fromSnapshot(snapshot.value)).toList());
  }

  Future<Page?> updatePage(int id, Map<String, dynamic> page) async {
    final db = await database;
    final updated = await _pagesStore.record(id).update(db, page);
    notifyListeners();
    return updated != null ? Page.fromSnapshot(updated) : null;
  }

  // User operations
  Future<int> insertUser(Users user) async {
    final db = await database;
    final id = await _usersStore.add(db, user.toFirestore());
    notifyListeners();
    return id;
  }

  Future<List<Users>> getUsers() async {
    final db = await database;
    return await _usersStore.find(db).then((records) =>
        records.map((snapshot) => Users.fromSemb(snapshot.value)).toList());
  }

  Future<Users?> updateUser(int id, Map<String, dynamic> user) async {
    final db = await database;
    final updated = await _usersStore.record(id).update(db, user);
    notifyListeners();
    return updated != null ? Users.fromSemb(updated) : null;
  }

  // BookUser operations
  Future<int> insertBookUser(BookUser bookUser) async {
    final db = await database;
    final id = await _bookUsersStore.add(db, bookUser.toSnapshot());
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

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
