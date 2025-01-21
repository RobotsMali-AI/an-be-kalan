import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/models/xpLog.dart';

class Users {
  String? uid;
  DateTime? birth_date;
  List<dynamic> completedBooks;
  List<dynamic>? downloadBooks;
  List<BookUser> inProgressBooks;
  List<dynamic> favoriteBooks;
  List<XPLog> xpLog;
  int xp;
  int totalReadingTime;

  Users({
    this.birth_date,
    this.uid,
    this.downloadBooks,
    required this.completedBooks,
    required this.inProgressBooks,
    required this.favoriteBooks,
    required this.xpLog,
    required this.xp,
    required this.totalReadingTime,
  });

  // Convert Firestore document to Users object
  factory Users.fromFirestore(DocumentSnapshot<Map<String, dynamic>> data) {
    final file = data.data();
    return Users(
      downloadBooks: file!["downloadsBooks"] ?? [],
      uid: data.id,
      birth_date: file['birth_date'],
      completedBooks: file['completedBooks'] ?? [],
      inProgressBooks: (file['inProgressBooks'] as List)
          .map((book) => BookUser.fromSnapshot(book))
          .toList(),
      favoriteBooks: file['favoriteBooks'] ?? [],
      xpLog: (file['xpLog'] as List)
          .map((log) => XPLog.fromSnapshot(log))
          .toList(),
      xp: file['xp'] ?? 0,
      totalReadingTime: file['totalReadingTime'] ?? 0,
    );
  }

  factory Users.fromSemb(Map<String, dynamic> json) {
    return Users(
      downloadBooks: json["downloadsBooks"] ?? [],
      uid: json["uid"],
      birth_date: json['birth_date'],
      completedBooks: json['completedBooks'] ?? [],
      inProgressBooks: (json['inProgressBooks'] as List)
          .map((book) => BookUser.fromSnapshot(book))
          .toList(),
      favoriteBooks: json['favoriteBooks'] ?? [],
      xpLog: (json['xpLog'] as List)
          .map((log) => XPLog.fromSnapshot(log))
          .toList(),
      xp: json['xp'] ?? 0,
      totalReadingTime: json['totalReadingTime'] ?? 0,
    );
  }

  // Convert Users object to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'completedBooks': completedBooks,
      'downloadsBooks': downloadBooks,
      'inProgressBooks':
          inProgressBooks.map((book) => book.toSnapshot()).toList(),
      'favoriteBooks': favoriteBooks,
      'xpLog': xpLog.map((log) => log.toSnapshot()).toList(),
      'xp': xp,
      'totalReadingTime': totalReadingTime,
      'birth_date': birth_date,
    };
  }
}
