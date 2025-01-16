class PageContent {
  final List<String> sentences;
  final String image;

  PageContent({
    required this.sentences,
    required this.image,
  });

  factory PageContent.fromJson(Map<String, dynamic> json) {
    return PageContent(
      sentences: List<String>.from(json['sentences'] ?? []),
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentences': sentences,
      'image': image,
    };
  }
}
