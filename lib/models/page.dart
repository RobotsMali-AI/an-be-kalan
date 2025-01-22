import 'package:literacy_app/imageToBase64.dart';

class Page {
  final dynamic imageUrl;
  final List<String> sentences;

  Page({
    required this.imageUrl,
    required this.sentences,
  });

  factory Page.fromSnapshot(Map<String, dynamic> snapshot) {
    return Page(
      imageUrl: snapshot['image'] ?? '',
      sentences: List<String>.from(snapshot['sentences'] ?? []),
    );
  }

  Future<Map<String, dynamic>> toSnapshot() async {
    return {
      'image': await imageUrlToBase64(imageUrl),
      'sentences': sentences,
    };
  }
}
