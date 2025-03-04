class OneWordMultipleImagesQuestion {
  final String question;
  final String word;
  final List<String> options;

  OneWordMultipleImagesQuestion({
    required this.question,
    required this.word,
    required this.options,
  });

  factory OneWordMultipleImagesQuestion.fromJson(Map<String, dynamic> json) {
    return OneWordMultipleImagesQuestion(
      question: json['question'] ?? '',
      word: json['word'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }
}
