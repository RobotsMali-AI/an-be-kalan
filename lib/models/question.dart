class Question {
  final String question;
  final List<String> options;
  final List<String> correct;

  Question(
      {required this.question, required this.options, required this.correct});

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      question: data['questions'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correct: List<String>.from(data['correct'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questions': question,
      'options': options,
      'correct': correct,
    };
  }
}
