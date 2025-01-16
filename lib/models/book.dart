import 'package:literacy_app/models/pageContent.dart';

class Book {
  final String title;
  final Map<String, PageContent> content;

  Book({
    required this.title,
    required this.content,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      content: (json['content'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, PageContent.fromJson(value))) ??
          {},
    );
  }

  

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}
