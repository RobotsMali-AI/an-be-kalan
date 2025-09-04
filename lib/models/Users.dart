import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:literacy_app/models/bookUser.dart';
import 'package:literacy_app/models/xpLog.dart';

class Users {
  String? uid;
  DateTime? birth_date;
  List<dynamic> completedBooks;
  List<dynamic> downloadBooks;
  List<BookUser> inProgressBooks;
  List<dynamic> favoriteBooks;
  List<XPLog> xpLog;
  int xp;
  int totalReadingTime;
  // New fields for optional authentication
  String? email;
  String? phone;
  String? password; // Hashed password
  bool isAuthenticated;
  DateTime? createdAt;
  String? displayName;

  Users({
    this.birth_date,
    this.uid,
    required this.downloadBooks,
    required this.completedBooks,
    required this.inProgressBooks,
    required this.favoriteBooks,
    required this.xpLog,
    required this.xp,
    required this.totalReadingTime,
    this.email,
    this.phone,
    this.password,
    this.isAuthenticated = false,
    this.createdAt,
    this.displayName,
  });

  // Convert Firestore document to Users object
  factory Users.fromFirestore(DocumentSnapshot<Map<String, dynamic>> data) {
    final file = data.data();
    return Users(
      downloadBooks: List<dynamic>.from(file!["downloadsBooks"] ?? []),
      uid: data.id,
      birth_date: file['birth_date'] != null
          ? DateTime.tryParse(file['birth_date'])
          : null,
      completedBooks: List<dynamic>.from(file['completedBooks'] ?? []),
      inProgressBooks: (file['inProgressBooks'] as List?)
              ?.map((book) => BookUser.fromSnapshot(book))
              .toList() ??
          <BookUser>[],
      favoriteBooks: List<dynamic>.from(file['favoriteBooks'] ?? []),
      xpLog: (file['xpLog'] as List?)
              ?.map((log) => XPLog.fromSnapshot(log))
              .toList() ??
          <XPLog>[],
      xp: file['xp'] ?? 0,
      totalReadingTime: file['totalReadingTime'] ?? 0,
      email: file['email'],
      phone: file['phone'],
      password: file['password'],
      isAuthenticated: file['isAuthenticated'] ?? false,
      createdAt: file['createdAt'] != null
          ? DateTime.tryParse(file['createdAt'])
          : null,
      displayName: file['displayName'],
    );
  }

  factory Users.fromSemb(Map<String, dynamic> json) {
    return Users(
      downloadBooks: List<dynamic>.from(json["downloadsBooks"] ?? []),
      uid: json["uid"],
      birth_date: DateTime.tryParse(json['birth_date'] ?? ''),
      completedBooks: List<dynamic>.from(json['completedBooks'] ?? []),
      inProgressBooks: (json['inProgressBooks'] as List?)
              ?.map((book) => BookUser.fromSemb(book))
              .toList() ??
          <BookUser>[],
      favoriteBooks: List<dynamic>.from(json['favoriteBooks'] ?? []),
      xpLog: (json['xpLog'] as List?)
              ?.map((log) => XPLog.fromSnapshot(log))
              .toList() ??
          <XPLog>[],
      xp: json['xp'] ?? 0,
      totalReadingTime: json['totalReadingTime'] ?? 0,
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      isAuthenticated: json['isAuthenticated'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      displayName: json['displayName'],
    );
  }

  // Convert Users object to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'completedBooks': completedBooks,
      'downloadsBooks': downloadBooks,
      'inProgressBooks':
          inProgressBooks.map((book) => book.toSnapshot()).toList(),
      'favoriteBooks': favoriteBooks,
      'xpLog': xpLog.map((log) => log.toSnapshot()).toList(),
      'xp': xp,
      'totalReadingTime': totalReadingTime,
      'birth_date': birth_date?.toIso8601String(),
      'email': email,
      'phone': phone,
      'password': password,
      'isAuthenticated': isAuthenticated,
      'createdAt': createdAt?.toIso8601String(),
      'displayName': displayName,
    };
  }

  Map<String, dynamic> toSemb() {
    return {
      'uid': uid,
      'completedBooks': completedBooks,
      'downloadsBooks': downloadBooks,
      'inProgressBooks': inProgressBooks.map((book) => book.toSemb()).toList(),
      'favoriteBooks': favoriteBooks,
      'xpLog': xpLog.map((log) => log.toSnapshot()).toList(),
      'xp': xp,
      'totalReadingTime': totalReadingTime,
      'birth_date': birth_date?.toIso8601String() ?? '',
      'email': email,
      'phone': phone,
      'password': password,
      'isAuthenticated': isAuthenticated,
      'createdAt': createdAt?.toIso8601String() ?? '',
      'displayName': displayName,
    };
  }
}
