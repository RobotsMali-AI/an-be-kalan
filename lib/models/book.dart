import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:literacy_app/models/page.dart';

class Book {
  final dynamic title;
  final String cover;
  final Map<String, Page> content; // Adjusted type to match Firestore structure

  Book({
    required this.title,
    required this.cover,
    required this.content,
  });

  factory Book.fromJson(DocumentSnapshot<Map<String, dynamic>> json) {
    final data = json.data()!;
    return Book(
      cover: data['cover'] ?? '',
      title: data['title'] ?? '',
      content: (data['content'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, Page.fromSnapshot(value as Map<String, dynamic>)),
      ),
    );
  }

  factory Book.fromSemb(Map<String, dynamic> json) {
    return Book(
      cover: json['cover'] ?? '',
      title: json['title'] ?? '',
      content: (json['content'] as Map<String, dynamic>).map(
        (key, value) =>
            MapEntry(key, Page.fromSnapshot(value as Map<String, dynamic>)),
      ),
    );
  }

  Map<String, dynamic> toSnapshot() {
    return {
      'title': title,
      'cover': cover,
      'content': content.map(
        (key, page) => MapEntry(key, page.toSnapshot()),
      ),
    };
  }
}
