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

  Map<String, dynamic> toSnapshot() {
    return {
      'image': imageUrl,
      'sentences': sentences,
    };
  }
}
