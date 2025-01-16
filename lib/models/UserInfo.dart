import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:literacy_app/models/bookUser.dart';

class UserInfo {
  String? uid;
  List<dynamic> completedBooks;
  List<BookUser> inProgressBooks;
  int xp;

  UserInfo({
    this.uid,
    required this.completedBooks,
    required this.inProgressBooks,
    required this.xp,
  });

  // Convert Firestore document to UserModel object
  factory UserInfo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> data) {
    final file = data.data();
    return UserInfo(
      completedBooks: file!['completedBooks'],
      inProgressBooks: (file['inProgressBooks'] as List)
          .map((book) => BookUser.fromSnapshot(book))
          .toList(),
      xp: data['xp'],
    );
  }

  // Convert UserModel object to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'completedBooks': completedBooks,
      'inProgressBooks':
          inProgressBooks.map((book) => book.toSnapshot()).toList(),
      'xp': xp,
    };
  }
}
