class OneWordMultipleImagesQuestion {
  final String question;
  final String word;
  final List<Option> options;

  OneWordMultipleImagesQuestion({
    required this.question,
    required this.word,
    required this.options,
  });

  factory OneWordMultipleImagesQuestion.fromJson(Map<String, dynamic> json) {
    return OneWordMultipleImagesQuestion(
      question: json['question'] ?? '',
      word: json['word'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((opt) => Option.fromJson(opt))
              .toList() ??
          [],
    );
  }
}

class Option {
  final String image;
  final bool correct;

  Option({
    required this.image,
    required this.correct,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      image: json['image'] ?? '',
      correct: json['correct'] ?? false,
    );
  }
}
