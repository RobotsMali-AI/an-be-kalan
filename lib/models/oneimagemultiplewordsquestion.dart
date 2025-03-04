class OneImageMultipleWordsQuestion {
  final String question;
  final String answer;
  final String image;
  final List<String> options;

  OneImageMultipleWordsQuestion({
    required this.question,
    required this.answer,
    required this.image,
    required this.options,
  });

  factory OneImageMultipleWordsQuestion.fromJson(Map<String, dynamic> json) {
    return OneImageMultipleWordsQuestion(
      question: json['question'] ?? '',
      answer: json['answers'] ?? '',
      image: json['image'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }
}
