import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:literacy_app/imageToBase64.dart';
import 'package:literacy_app/models/page.dart';

class Book {
  final String title;
  final dynamic cover;
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

  Future<Map<String, dynamic>> toSnapshot() async {
    final contentSnapshot =
        await Future.wait(content.entries.map((entry) async {
      final pageSnapshot = await entry.value.toSnapshot();
      return MapEntry(entry.key, pageSnapshot);
    }));
    final imageBytes = await imageUrlToBase64(cover);
    return {
      'title': title,
      'cover': imageBytes,
      'content': Map.fromEntries(contentSnapshot),
    };
  }
}
