import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:literacy_app/imageToBase64.dart';
import 'package:literacy_app/models/evaluation.dart';
import 'package:literacy_app/models/page.dart';

class Book {
  final String title;
  final dynamic cover;
  final Map<String, Page> content; // Adjusted type to match Firestore structure
  List<String>? uuid;
  Evaluation? evaluation;

  Book(
      {required this.title,
      required this.cover,
      required this.content,
      this.evaluation,
      this.uuid});

  factory Book.fromJson(DocumentSnapshot<Map<String, dynamic>> json) {
    final data = json.data()!;
    return Book(
      cover: data['cover'] ?? '',
      evaluation: data['evaluation'] == null
          ? null
          : Evaluation.fromMap(data['evaluation']),
      title: data['title'] ?? '',
      content: {
        for (int i = 0; i < (data['content'] as List<dynamic>).length; i++)
          i.toString():
              Page.fromSnapshot(data['content'][i] as Map<String, dynamic>)
      },
    );
  }

  factory Book.fromSemb(Map<String, dynamic> json) {
    return Book(
      uuid: (json['uuid'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      cover: json['cover'] ?? '',
      title: json['title'] ?? '',
      evaluation: json['evaluation'],
      content: {
        for (int i = 0; i < (json['content'] as List<dynamic>).length; i++)
          i.toString():
              Page.fromSnapshot(json['content'][i] as Map<String, dynamic>)
      },
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
      'uuid': uuid,
      'title': title,
      'evaluation': evaluation,
      'cover': imageBytes,
      'content': Map.fromEntries(contentSnapshot),
    };
  }
}
