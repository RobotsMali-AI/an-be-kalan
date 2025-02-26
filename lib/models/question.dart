class Question {
  String question;
  List<String> options;
  String correct;

  Question(
      {required this.question, required this.options, required this.correct});

  factory Question.fromMap(Map<String, dynamic> data) {
    return Question(
      question: data['question'] as String,
      options: List<String>.from(data['options']),
      correct: data['correct'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correct': correct,
    };
  }
}
