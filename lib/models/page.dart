import 'package:literacy_app/imageToBase64.dart';
import 'package:literacy_app/models/sentences.dart';

class Page {
  final dynamic imageUrl;
  final List<Sentence> sentences;

  Page({
    required this.imageUrl,
    required this.sentences,
  });

  factory Page.fromSnapshot(Map<String, dynamic> snapshot) {
    return Page(
      imageUrl: snapshot['image'] ?? '',
      sentences: (snapshot['sentences'] as List<dynamic>?)
              ?.map((s) => Sentence.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Future<Map<String, dynamic>> toSnapshot() async {
    return {
      'image': await imageUrlToBase64(imageUrl),
      'sentences': sentences,
    };
  }
}
