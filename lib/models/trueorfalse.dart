class Trueorfalse {
  String question;
  bool answers;
  Trueorfalse({required this.answers, required this.question});

  factory Trueorfalse.fromJson(Map<String, dynamic> json) {
    return Trueorfalse(
        question: json['question'] ?? "", answers: json['answers'] ?? false);
  }

  factory Trueorfalse.fromSemb(Map<String, dynamic> json) {
    return Trueorfalse(
        question: json['question'] ?? "", answers: json['answers'] ?? false);
  }

  Future<Map<String, dynamic>> toSnapshot() async {
    return {
      'question': question,
      'answers': answers,
    };
  }
}
