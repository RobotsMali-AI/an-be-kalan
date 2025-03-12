class Sentence {
  final String text;
  final String audio;

  Sentence({required this.text, required this.audio});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      text: json['text'] ?? json['tex'] ?? '', // Handles typo in JSON
      audio: json['audio'] ?? '',
    );
  }
}
