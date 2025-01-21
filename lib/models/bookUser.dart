import 'package:cloud_firestore/cloud_firestore.dart';

class BookUser {
  String title;
  String bookmark;
  int readingTime;
  List<double> accuracies;
  DateTime lastAccessed;
  int totalPages;

  BookUser({
    required this.title,
    required this.bookmark,
    required this.readingTime,
    required this.accuracies,
    required this.lastAccessed,
    required this.totalPages,
  });

  factory BookUser.fromSnapshot(Map<String, dynamic> data) {
    Timestamp timestamp = data['lastAccessed'];
    return BookUser(
      title: data['title'],
      bookmark: data['bookmark'],
      readingTime: data['readingTime'],
      accuracies: List<double>.from(data['accuracies']),
      lastAccessed: timestamp.toDate(),
      totalPages: data['totalPages'],
    );
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'title': title,
      'bookmark': bookmark,
      'readingTime': readingTime,
      'accuracies': accuracies,
      'lastAccessed': lastAccessed,
      'totalPages': totalPages,
    };
  }
}
